require "ISUI/UserPanel/ISSafehouseUI";
SafehouseClient = require("SafehouseClient");

if isServer() then return end;

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);

function ISSafehouseUI:onClickAddManager(button)
    print("OnClickManager");
    print(self.playerList.selected);

    -- Find player and check if they are in game.
    local selected = self.playerList.selected;

    local selectedName = self.playerList.items[selected].item.name;
    if not selectedName then return end;

    -- Check if player is valid.
    local matchingPlayer = getPlayerFromUsername(selectedName);
    if not matchingPlayer then return end; -- They have likely DCed or crashed between selecting and clicking accept (rare edge case).

    SafehouseClient.AddManagerToSafehouse(self.safehouse, matchingPlayer);
    self:populateList();
end 

function ISSafehouseUI:onClickManagementPanel(button)
end 

function ISSafehouseUI:onMouseUp(x, y) -- NOTE, the self of this is the playerList itself!
    print("SafehouseLine - onMouseUp");

    local selected = self.selected;
    if selected == 0 then return end;

    local selectedPlayer = self.items[selected].item;
    if not selectedPlayer then return end;

    print(selectedPlayer.name);

    if not SafehouseClient.IsManagerEx(selectedPlayer.name, self.parent.safehouse) and self.parent:canAddManagers() then
        print("Player is not manager and have permission to add manager.");
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

    local sandboxOptions = getSandboxOptions();
    if not sandboxOptions then return end;

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

    local maxManagers = sandboxOptions:getOptionByName("SafehouseLine.MaxManagers"):getValue(); 
    local managersForSafehouse = SafehouseClient.GetSafehouseManagers(safehouse);

    self.mgrBtn.enable = false;

    ---

    -- Override vanilla functionality to allow managers to add players.
    self.addPlayer.enable = self:isOwner() or self:hasPrivilegedAccessLevel() or SafehouseClient.IsManager(getPlayer(), self.safehouse);

    self.playerList.onMouseUp = self.onMouseUp;
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

        if SafehouseClient.IsManager(newPlayer) then
            lineStr = lineStr .. (" - Manager");
        end

        if newPlayer.name ~= self.safehouse:getOwner() or isDebugEnabled() then
            self.playerList:addItem(lineStr, newPlayer);
        end;
    end;
    self.playerList.selected = math.min(selected, #self.playerList.items);
end
