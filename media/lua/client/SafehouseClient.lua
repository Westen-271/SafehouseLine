if isServer() then return end;

SafehouseManagersCache = {};

SafehouseClient = {};

function SafehouseClient.OnReceiveGlobalModData(key, data)
    if key ~= "SafehouseLine_Managers" then return end;
    SafehouseManagersCache = data;
end

function SafehouseClient.AddSafehouseManager(safehouse, newManager)
    -- We need to do this both locally and server-side, because there may be a delay between the server receiving and transmitting
    -- the updated mod data, which then will cause a discrepenacy in the UI.
    -- If it is faster than the time to render the UI, then this will not be a problem as it will be overwritten anyway.
    if not safehouse then return end;
    if not newManager then return end;

    local id = safehouse:getId();
    if not id then return end;

    if not SafehouseManagersCache[id] then
        SafehouseManagersCache[id] = {};
    end

    table.insert(SafehouseManagersCache[id], newManager:getUsername());

    sendClientCommand(getPlayer(), "SafehouseLine", "AddSafehouseManager", { safehouse = id, manager = newManager:getUsername(), issuer = getPlayer():getUsername() });
end

function SafehouseClient.RemoveSafehouseManager(safehouse, newManager)
    if not safehouse then return end;
    if not newManager then return end;

    local id = safehouse:getId();
    if not id then return end;

    if not SafehouseManagersCache[id] then
        SafehouseManagersCache[id] = {};
    end

    for i, mgr in ipairs(SafehouseManagersCache[id]) do
        if mgr == newManager:getUsername() then
            table.remove(SafehouseManagersCache[id], i);
        end
    end

    sendClientCommand(getPlayer(), "SafehouseLine", "RemoveSafehouseManager", { safehouse = id, manager = newManager:getUsername(), issuer = getPlayer():getUsername() });
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