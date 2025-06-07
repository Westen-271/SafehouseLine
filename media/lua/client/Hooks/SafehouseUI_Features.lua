require "ISUI/UserPanel/ISSafehouseUI";
SafehouseClient = require("SafehouseClient");

if isServer() then return end;

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);

local SANDBOX_OPTIONS = getSandboxOptions();

local ADD_LEN = getTextManager():MeasureStringX(UIFont.Small, "Add Manager") + 5;
local REMOVE_LEN = getTextManager():MeasureStringX(UIFont.Small, "Remove Manager") + 5;

function ISSafehouseUI:onClickAddManager(button)
    -- Find player and check if they are in game.
    local selected = self.playerList.selected;

    local selectedName = self.playerList.items[selected].item.name;
    if not selectedName then return end;

    -- Check if player is valid.
    local matchingPlayer = getPlayerFromUsername(selectedName);
    if not matchingPlayer then return end; -- They have likely DCed or crashed between selecting and clicking accept (rare edge case).

    SafehouseClient.AddSafehouseManager(self.safehouse, matchingPlayer);

    self:populateList();
    self.playerList:onMouseUp(getMouseX(), getMouseY());
    self:updateManagerButtons();
end 

function ISSafehouseUI:onClickRemoveManager(button)
    -- Find player and check if they are in game.
    local selected = self.playerList.selected;

    local selectedName = self.playerList.items[selected].item.name;
    if not selectedName then return end;

    -- Check if player is valid.
    local matchingPlayer = getPlayerFromUsername(selectedName);
    if not matchingPlayer then return end; -- They have likely DCed or crashed between selecting and clicking accept (rare edge case).

    SafehouseClient.RemoveSafehouseManager(self.safehouse, matchingPlayer);

    self:populateList();
    self.playerList:onMouseDown(getMouseX(), getMouseY());
    self:updateManagerButtons();
end

function ISSafehouseUI:onMouseDown_List(x, y) -- NOTE, the self of this is the playerList itself!
    print("SafehouseLine - onMouseDown");

    local row = self:rowAt(x, y);
    if not row or row == -1 then return; end

    if not self:isMouseOverScrollBar() then
        self.selected = row;
    end

    local selected = self.selected;

    local selectedPlayer = self.items[selected].item;
    if not selectedPlayer then return end;

    if not self.parent:canAddManagers() then return end;
    self.parent:updateManagerButtons();
end

function ISSafehouseUI:canAddManagers()
    return self:isOwner() or self:hasPrivilegedAccessLevel();
end

function ISSafehouseUI:updateManagerButtons()
    -- 1. Is there a player selected?
    if not self.playerList.selected or self.playerList.selected == 0 then return end;

    local selected = self.playerList.selected;

    -- Get player from selected.
    local managerItem = self.playerList.items[selected].item;
    if not managerItem then return end;

    -- 2. If selected, are they a manager?
    local isMgr = SafehouseClient.IsManagerEx(managerItem.name, self.safehouse);

    -- 3. If they're NOT a manager:
    if not isMgr or isMgr == false then
        local mgrSlotsLeft = SafehouseClient.GetRemainingManagerSlots(self.safehouse);
        if not mgrSlotsLeft then return end;
        -- a. If manager slots available, "add manager".
        if mgrSlotsLeft > 0 then
            self.mgrBtn.title = "Add Manager";
            self.mgrBtn:setWidth(ADD_LEN + 5);
            self.mgrBtn.onclick = ISSafehouseUI.onClickAddManager;

            if self:canAddManagers() then
                self.mgrBtn.enable = true;
            end
        -- b. If manager slots NOT available, keep button disabled.
        else
            self.mgrBtn.enable = false;
        end
        return;
    end

    -- 4. If they ARE a manager:
        -- a. Show remove manager button.
    self.mgrBtn.title = "Remove Manager";
    self.mgrBtn:setWidth(REMOVE_LEN + 5);
    self.mgrBtn.onclick = ISSafehouseUI.onClickRemoveManager;

    if self:canAddManagers() then
        self.mgrBtn.enable = true;
    end
end

--[[
    OVERRIDE DEFAULT SAFEHOUSE UI INIT FUNCTIONALITY
    Call initial functionality.
    Then inject our own features.
--]]
local vanillaSafehouseFunction = ISSafehouseUI.initialise;
function ISSafehouseUI:initialise()
    vanillaSafehouseFunction(self);

    local safehouse = self.safehouse;
    if not safehouse then return end;

    local mgrBtn = ISButton:new(self.addPlayer:getRight() + 5, self.playerList.y + self.playerList.height + 5, 70, FONT_HGT_SMALL, getText("IGUI_SafehouseUI_AddManager"), self, ISSafehouseUI.onClickAddManager);
    mgrBtn.internal = "ADDMGR";
    mgrBtn:initialise();
    mgrBtn:instantiate();
    mgrBtn.borderColor = self.buttonBorderColor;
    mgrBtn.tooltip = "Managers allow other players to add/remove from the safehouse, but not make other players managers themselves.";
    self:addChild(mgrBtn);

    self.mgrBtn = mgrBtn;
    self.mgrBtn.enable = false;

    ---

    -- Override vanilla functionality to allow managers to add players.
    self.addPlayer.enable = self:isOwner() or self:hasPrivilegedAccessLevel() or SafehouseClient.IsManager(getPlayer(), self.safehouse);
    self.playerList.onMouseDown = self.onMouseDown_List;

    self:populateList();
    self:updateManagerButtons();
end

local vanillaPlayerListFunction = ISSafehouseUI.populateList;
function ISSafehouseUI:populateList()
    local selected = self.playerList.selected;
    self.playerList:clear();

    for i = 0, self.safehouse:getPlayers():size() - 1 do
        local newPlayer = {};
        newPlayer.name = self.safehouse:getPlayers():get(i);

        local isManager = SafehouseClient.IsManagerEx(newPlayer.name, self.safehouse);

        local lineStr = newPlayer.name;

        if isManager then
            lineStr = lineStr .. " - Manager";
        end

        if newPlayer.name ~= self.safehouse:getOwner() or isDebugEnabled() then
            self.playerList:addItem(lineStr, newPlayer);
        end;
    end;
    self.playerList.selected = math.min(selected, #self.playerList.items);
end
