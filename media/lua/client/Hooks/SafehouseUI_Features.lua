require "ISUI/UserPanel/ISSafehouseUI";
SafehouseClient = require("SafehouseClient"); 

if isServer() then return end;

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);

function ISSafehouseUI:onClickAddManager(button)
end 

function ISSafehouseUI:onClickManagementPanel(button)
end 



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
    self:addChild(mgrBtn);

    local openMgmtBtn = ISButton:new(self.changeOwnership:getRight() + 5, self.changeOwnership.y, 70, FONT_HGT_SMALL, getText("IGUI_SafehouseUI_ManagerPanel"), self, ISSafehouseUI.onClickManagementPanel);
    openMgmtBtn.internal = "OPENMGMTPANEL";
    openMgmtBtn:initialise();
    openMgmtBtn:instantiate();
    openMgmtBtn.borderColor = self.buttonBorderColor;
    self:addChild(openMgmtBtn);

    local maxManagers = sandboxOptions:getOptionByName("SafehouseLine.MaxManagers"):getValue(); 
    local managersForSafehouse = SafehouseClient.GetSafehouseManagers(safehouse);
    
    if #managersForSafehouse >= maxManagers then
        addMgr.enable = false;
    end
end

