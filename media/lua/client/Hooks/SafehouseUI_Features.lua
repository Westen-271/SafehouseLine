require "ISUI/UserPanel/ISSafehouseUI";
SafehouseClient = require("SafehouseClient"); 

if isServer() then return end;

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);

function ISSafehouseUI:onClickAddManager(button)
end 

function ISSafehouseUI:onClickManagementPanel(button)
end 

function ISSafehouseUI:onMouseUp(x, y) -- NOTE, the self of this is the playerList itself!
    print("YOU HAVE SELECTED PLAYER ");
    print(self.selected);

    local selected = self.selected;
    if selected == 0 then return end;

    local selectedPlayer = self.items[selected].item;
    if not selectedPlayer then return end;

    if not SafehouseClient.IsManagerEx(selectedPlayer.name, self.parent.safehouse) and self.parent:hasPrivilegedAccessLevel() then
        self.parent.mgrBtn.enable = true;
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
    self.addPlayer.enable = self:isOwner() or hasPrivilegedAccessLevel or SafehouseClient.IsManager(getPlayer(), self.safehouse);

    self.playerList.onMouseUp = self.onMouseUp;
end

local vanillaPlayerListFunction = ISSafehouseUI.populateList;
function ISSafehouseUI:populateList()
    local selected = self.playerList.selected;
    self.playerList:clear();

    for i = 0, self.safehouse:getPlayers():size() - 1 do
            local newPlayer = {};
            newPlayer.name = self.safehouse:getPlayers():get(i);

            local lineStr = newPlayer.name;

            if SafehouseClient.IsManager(newPlayer) then
                lineStr = lineStr .. (" - Manager");
            end

            if newPlayer.name ~= self.safehouse:getOwner() or isDebugEnabled() then
                self.playerList:addItem(lineStr, newPlayer);
            end;
--        end
    end;
    self.playerList.selected = math.min(selected, #self.playerList.items);
end
