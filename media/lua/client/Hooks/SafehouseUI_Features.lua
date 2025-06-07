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

    -- First, are they already a manager?
    if SafehouseClient.IsManagerEx(selectedPlayer.name, self.parent.safehouse) and self.parent:canAddManagers() then
        self.parent.mgrBtn.title = "Remove Manager";
        self.parent.mgrBtn:setWidth(REMOVE_LEN);
        self.parent.mgrBtn.onclick = ISSafehouseUI.onClickRemoveManager;
        return;
    end

    -- Reset button data for clarity.
    self.parent.mgrBtn.title = "Add Manager";
    self.parent.mgrBtn:setWidth(ADD_LEN);
    self.parent.mgrBtn.onclick = ISSafehouseUI.onClickAddManager;

    -- If no, then make sure managers can be added.
    local maxManagers = SANDBOX_OPTIONS:getOptionByName("SafehouseLine.MaxManagers"):getValue(); 
    local managersForSafehouse = SafehouseClient.GetSafehouseManagers(self.parent.safehouse);


    if #managersForSafehouse >= maxManagers then
        self.parent.mgrBtn.tooltip = string.format("<RED>%d of %d managers.", managersForSafehouse, maxManagers);
        return;
    end

    if not SafehouseClient.IsManagerEx(selectedPlayer.name, self.parent.safehouse) and self.parent:canAddManagers() then
        self.parent.mgrBtn.enable = true;
    end
end

function ISSafehouseUI:canAddManagers()
    return self:isOwner() or self:hasPrivilegedAccessLevel();
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
end

local vanillaPlayerListFunction = ISSafehouseUI.populateList;
function ISSafehouseUI:populateList()
    local selected = self.playerList.selected;
    self.playerList:clear();

    for i = 0, self.safehouse:getPlayers():size() - 1 do
        local newPlayer = {};
        newPlayer.name = self.safehouse:getPlayers():get(i);
        newPlayer.isManager = SafehouseClient.IsManagerEx(newPlayer.name);

        local lineStr = newPlayer.name;

        if newPlayer.isManager then
            lineStr = lineStr .. " - Manager";
        end

        if newPlayer.name ~= self.safehouse:getOwner() or isDebugEnabled() then
            self.playerList:addItem(lineStr, newPlayer);
        end;
    end;
    self.playerList.selected = math.min(selected, #self.playerList.items);
end
