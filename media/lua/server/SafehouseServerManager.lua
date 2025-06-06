if isClient() then return end;

require "Logs/ISLogSystem"

SafehouseManagers = {};

function LogSafehouseChange(safehouseKey, changeStr)
    local messageString = string.format("[SafehouseLine] Safehouse %s: %s", safehouseKey, changeStr); 
    print(messageString);
    writeLog("SafehouseLine", messageString);
end

function OnInitGlobalModData(newGame)
    SafehouseManagers = ModData.getOrCreate("SafehouseLine_Managers");
end

function OnServerStartSave()
    SaveSafehouseManagers();
end 

function SaveSafehouseManagers()
    ModData.add("SafehouseLine_Managers", SafehouseManagers);
    ModData.transmit(SafehouseManagers);
end

function AddManagerToSafehouse(safehouseKey, newManagerName, issuerName)
    
    if not SafehouseManagers[safehouseKey] then
        SafehouseManagers[safehouseKey] = {};
    end

    table.insert(SafehouseManagers[safehouseKey], newManagerName);
    
    LogSafehouseChange(safehouseKey, string.format("%s has been added as a manager by %s", newManagerName, issuerName));
    SaveSafehouseManagers();
end

function RemoveManagerFromSafehouse(safehouseKey, managerName, issuerName)
    if not SafehouseManager[safehouseKey] then return end;

    for i, v in ipairs(SafehouseManager[safehouseKey]) do
        local iteratedManager = SafehouseManager[safehouseKey][i];
        if iteratedManager and iteratedManager == managerName then
            table.remove(SafehouseManager[safehouseKey], i);
        end
    end

    LogSafehouseChange(safehouseKey, string.format("%s has been removed as a manager by %s", newManagerName, issuerName));
    SaveSafehouseManagers();
end

function compositeKey(safehouse)
    return string.format("%s|%d,%d|%d,%d|%d", safehouse:getTitle(), getX(), getY(), getX2(), getY2(), getW());
end

function OnClientCommand(module, command, player, args)
    if module ~= "SafehouseLine" then return end;
    if not args then return end;

    if command == "AddSafehouseManager" then
        if not (args.safehouse or args.manager or args.issuer) then return end;

        local key = compositeKey(args.safehouse);
        AddManagerToSafehouse(key, args.manager, args.issuer);
    elseif command == "RemoveSafehouseManager" then
    
        if not (args.safehouse or args.manager or args.issuer) then return end;

        local key = compositeKey(args.safehouse);
        RemoveManagerToSafehouse(key, args.manager, args.issuer);
    end

    
end


Events.OnInitGlobalModData(OnInitGlobalModData);
Events.OnServerStartSaving.Add(OnServerStartSave);
Events.OnClientCommand.Add(OnClientCommand);