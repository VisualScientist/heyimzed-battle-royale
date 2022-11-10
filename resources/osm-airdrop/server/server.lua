-- ⠀⢀⣤⣶⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⣠⣶⣿⣿⣿⣿⣷⡆⠀⢸⣿⣿⣿⣿⡄⠀⠀⠀⢰⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⣿⣧⠀⠀⠀⠀⣾⣿⣿⣿⡇⠀⠀⢸⣿⣿⣿⣿⣿⣿⡆⠘⢿⣿⣿⣄⠀⠀⣰⣿⣿⡿⠃
-- ⢀⣾⣿⣿⠟⠉⠉⠛⣿⣿⣿⡆⠀⢰⣿⣿⣿⠉⠉⠙⠛⠀⠀⢸⣿⣿⣿⣿⣧⠀⠀⠀⣾⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⣿⣿⡄⠀⠀⢰⣿⣿⣿⣿⡇⠀⠀⢸⣿⣿⡏⠉⠉⠉⠁⠀⠈⢻⣿⣿⣆⣰⣿⣿⡿⠁
-- ⢸⣿⣿⡿⠀⠀⠀⠀⢸⣿⣿⣷⠀⠈⢿⣿⣿⣷⣦⣤⡀⠀⠀⢸⣿⣿⡏⣿⣿⡆⠀⢸⣿⡿⢸⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⢹⣿⣷⠀⠀⣿⣿⠇⣿⣿⡇⠀⠀⢸⣿⣿⣧⣤⣤⣤⠀⠀⠀⠀⠻⣿⣿⣿⣿⠟
-- ⢸⣿⣿⣷⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠙⠛⠿⣿⣿⣿⣆⠀⢸⣿⣿⡇⢹⣿⣷⢀⣿⣿⠃⢸⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⠈⣿⣿⡆⣸⣿⡟⠀⣿⣿⡇⠀⠀⢸⣿⣿⡿⠿⠿⠿⠀⠀⠀⠀⣴⣿⣿⣿⣿⣆
-- ⠈⣿⣿⣿⣦⣀⣀⣤⣿⣿⣿⠇⠀⢰⣤⣄⣀⣀⣸⣿⣿⡟⠀⢸⣿⣿⡇⠀⣿⣿⣿⣿⡟⠀⢸⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⠘⣿⣿⣿⣄⣀⣠⣾⣿⣿⠇⠀⠀⣿⣿⣿⠀⢸⣿⣿⣿⣿⠃⠀⣿⣿⡇⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⢀⣾⣿⣿⠏⠹⣿⣿⣧⡀
-- ⠀⠈⠻⢿⣿⣿⣿⣿⡿⠟⠃⠀⠀⠸⢿⣿⣿⣿⣿⡿⠟⠁⠀⢸⣿⣿⡇⠀⠸⣿⣿⣿⠃⠀⢸⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⠿⠋⠀⠀⠀⣿⣿⣿⠀⠀⢿⣿⣿⡟⠀⠀⣿⣿⡇⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⣠⣿⣿⣿⠃⠀⠀⠙⣿⣿⣿⣄

-----------------------------------------------------------------------------------------------------------------------------------

local QBCore = exports['qb-core']:GetCoreObject()

local ServerDrops = {}

local id = 1

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(10)
        Citizen.Wait(math.random(Config.DropGapDuration.min, Config.DropGapDuration.max) * 60000)
        local randomloc = GetRandomLoc()
        lastLoc = randomloc
        TriggerClientEvent('crateDrop', -1, Config.PlaneDistance, Config.Locations[randomloc], id)
        id = id + 1
        if Config.EnableServerAlert then 
            TriggerEvent('InteractSound_SV:PlayOnAll', Config.SVAlertName, Config.SVAlertVolume)
            TriggerClientEvent('LargeNotification', -1, Config.SVAlertText)
        end
    end
end)

RegisterServerEvent('StartManualDrop')
AddEventHandler('StartManualDrop', function()
    local randomloc = GetRandomLoc()
    TriggerClientEvent('crateDrop', -1, Config.PlaneDistance, Config.Locations[randomloc], id)
    id = id + 1
    if Config.EnableServerAlert then 
        TriggerEvent('InteractSound_SV:PlayOnAll', Config.SVAlertName, Config.SVAlertVolume)
        TriggerClientEvent('LargeNotification', -1, Config.SVAlertText)

    end
end)

function GetRandomLoc()
    return math.random(1, #Config.Locations)
end

RegisterServerEvent('LootDrop')
AddEventHandler('LootDrop', function(drop)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if ServerDrops[drop] == nil then 
        ServerDrops[drop] = drop
        local random = math.random(1, #Config.Products)
        local items = Config.Products[random]
        if items ~= nil then 
            if Config.DirectLootEnabled then 
                for k,v in pairs(items) do 
                    local name = v.name
                    local amount = v.amount
                    Player.Functions.AddItem(name, amount)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[name], "add")
                end
            else
                TriggerClientEvent('ClientLootDrop', src, items)
            end
        end
    else
        TriggerClientEvent('NormalNotification', src, Config.AlreadyLootedText)
    end
end)



RegisterServerEvent('LootDrop:Target')
AddEventHandler('LootDrop:Target', function(data)
    local src = source
    local drop = data.crateID
    local Player = QBCore.Functions.GetPlayer(src)

    if ServerDrops[drop] == nil then 
        ServerDrops[drop] = drop
        local random = math.random(1, #Config.Products)
        local items = Config.Products[random]
        if items ~= nil then 
            if Config.DirectLootEnabled then 
                for k,v in pairs(items) do 
                    local name = v.name
                    local amount = v.amount
                    Player.Functions.AddItem(name, amount)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[name], "add")
                end
            else
                TriggerClientEvent('ClientLootDrop', src, items)
            end
        end
    else
        TriggerClientEvent('NormalNotification', src, Config.AlreadyLootedText)
    end
end)

-- RegisterServerEvent('StartText_SV')
-- AddEventHandler('StartText_SV', function(parachute, aircraft, crate)
--     TriggerClientEvent('StartText', -1, parachute, aircraft, crate)
-- end)

-- RegisterServerEvent('CrateSound_SV')
-- AddEventHandler('CrateSound_SV', function(crate)
--     TriggerClientEvent('CrateSound', -1, crate)
-- end)

-- RegisterServerEvent('Smoke_SV')
-- AddEventHandler('Smoke_SV', function(drop)
--     TriggerClientEvent('Smoke', -1, drop)
-- end)

-- RegisterServerEvent('AddBlips_SV')
-- AddEventHandler('AddBlips_SV', function(x,y,z)
--     TriggerClientEvent('AddBlips', -1, x,y,z)
-- end)

QBCore.Commands.Add('cratedrop', 'CrateDrops (GOD)', {}, false, function(source, args)
    Citizen.Wait(5000)
    TriggerEvent('StartManualDrop')
end, 'god')





