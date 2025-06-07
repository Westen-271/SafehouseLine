if isServer() then return end;

SafehouseManagersCache = {};

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

-------

function SafehouseClient.IsManager(player, safehouse)
    if not player or not safehouse then return false end;

    local mgrs = SafehouseClient.GetSafehouseManagers(safehouse);
    local username = player:getUsername();
    if not mgrs or #mgrs == 0 then return false end;

    for i, v in ipairs(mgrs) do
        if mgrs[i] == username then
            return true;
        end
    end

    return false;
end

function SafehouseClient.IsManagerEx(playerName, safehouse)
    if not playerName or not safehouse then return false end;

    local mgrs = SafehouseClient.GetSafehouseManagers(safehouse);
    if not mgrs or #mgrs == 0 then return false end;

    for i, v in ipairs(mgrs) do
        if mgrs[i] == playerName then
            return true;
        end
    end

    return false;
end

function SafehouseClient.GetSafehouseManagers(safehouse)
    local key = safehouse:getId();
    if not key then return {} end;
    
    if not SafehouseManagersCache[key] then return {} end;

    return SafehouseManagersCache[key];
end

Events.OnReceiveGlobalModData.Add(SafehouseClient.OnReceiveGlobalModData);


return SafehouseClient;