if isServer() then return end;

local SafehouseManagersCache = {};

SafehouseClient = {};

function SafehouseClient.OnReceiveGlobalModData(key, data)
    if key ~= "SafehouseLine_Managers" then return end;
    SafehouseManagersCache = data;
end

function SafehouseClient.AddSafehouseManager(safehouse, newManager)
    sendClientCommand(getPlayer(), "SafehouseLine", "AddSafehouseManager", { safehouse = safehouse, manager = newManager:getUsername(), issuer = getPlayer():getUsername() });
end

function SafehouseClient.RemoveSafehouseManager(safehouse, newManager)
    sendClientCommand(getPlayer(), "SafehouseLine", "RemoveSafehouseManager", { safehouse = safehouse, manager = newManager:getUsername(), issuer = getPlayer():getUsername() });
end

Events.OnReceiveGlobalModData.Add(SafehouseClient.OnReceiveGlobalModData);

return SafehouseClient;