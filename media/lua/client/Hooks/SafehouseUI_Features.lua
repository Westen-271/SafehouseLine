require "ISUI/UserPanel/ISSafehouseUI";

if isServer() then return end;

local vanillaSafehouseFunction = ISSafehouseUI["initialize"];

ISSafehouseUI["initialize"] = function(self)

    vanillaSafehouseFunction(self);

    local sandboxOptions = getSandboxOptions();
    if not sandboxOptions then return end;

    local safehouse = self.safehouse;
    if not safehouse then return end;

    local maxManagers = sandboxOptions:getOptionByName("SafehouseLine.MaxManagers"):getValue();

    
end