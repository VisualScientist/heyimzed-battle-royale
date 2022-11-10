    -- ⠀⢀⣤⣶⣿⣿⣿⣿⣷⣦⡀⠀⠀⠀⣠⣶⣿⣿⣿⣿⣷⡆⠀⢸⣿⣿⣿⣿⡄⠀⠀⠀⢰⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⣿⣧⠀⠀⠀⠀⣾⣿⣿⣿⡇⠀⠀⢸⣿⣿⣿⣿⣿⣿⡆⠘⢿⣿⣿⣄⠀⠀⣰⣿⣿⡿⠃
-- ⢀⣾⣿⣿⠟⠉⠉⠛⣿⣿⣿⡆⠀⢰⣿⣿⣿⠉⠉⠙⠛⠀⠀⢸⣿⣿⣿⣿⣧⠀⠀⠀⣾⣿⣿⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⣿⣿⡄⠀⠀⢰⣿⣿⣿⣿⡇⠀⠀⢸⣿⣿⡏⠉⠉⠉⠁⠀⠈⢻⣿⣿⣆⣰⣿⣿⡿⠁
-- ⢸⣿⣿⡿⠀⠀⠀⠀⢸⣿⣿⣷⠀⠈⢿⣿⣿⣷⣦⣤⡀⠀⠀⢸⣿⣿⡏⣿⣿⡆⠀⢸⣿⡿⢸⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⢹⣿⣷⠀⠀⣿⣿⠇⣿⣿⡇⠀⠀⢸⣿⣿⣧⣤⣤⣤⠀⠀⠀⠀⠻⣿⣿⣿⣿⠟
-- ⢸⣿⣿⣷⠀⠀⠀⠀⢸⣿⣿⣿⠀⠀⠀⠙⠛⠿⣿⣿⣿⣆⠀⢸⣿⣿⡇⢹⣿⣷⢀⣿⣿⠃⢸⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⢸⣿⣿⡇⠀⠀⠀⢸⣿⣿⡇⠀⠀⣿⣿⣿⠈⣿⣿⡆⣸⣿⡟⠀⣿⣿⡇⠀⠀⢸⣿⣿⡿⠿⠿⠿⠀⠀⠀⠀⣴⣿⣿⣿⣿⣆
-- ⠈⣿⣿⣿⣦⣀⣀⣤⣿⣿⣿⠇⠀⢰⣤⣄⣀⣀⣸⣿⣿⡟⠀⢸⣿⣿⡇⠀⣿⣿⣿⣿⡟⠀⢸⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⠘⣿⣿⣿⣄⣀⣠⣾⣿⣿⠇⠀⠀⣿⣿⣿⠀⢸⣿⣿⣿⣿⠃⠀⣿⣿⡇⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⠀⢀⣾⣿⣿⠏⠹⣿⣿⣧⡀
-- ⠀⠈⠻⢿⣿⣿⣿⣿⡿⠟⠃⠀⠀⠸⢿⣿⣿⣿⣿⡿⠟⠁⠀⢸⣿⣿⡇⠀⠸⣿⣿⣿⠃⠀⢸⣿⣿⠀⠀⠀⣿⣿⣿⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⠿⠋⠀⠀⠀⣿⣿⣿⠀⠀⢿⣿⣿⡟⠀⠀⣿⣿⡇⠀⠀⢸⣿⣿⡇⠀⠀⠀⠀⣠⣿⣿⣿⠃⠀⠀⠙⣿⣿⣿⣄

-----------------------------------------------------------------------------------------------------------------------------------

local QBCore = exports['qb-core']:GetCoreObject()

local pilot, aircraft, parachute, crate, blip, soundID, dropID= nil, nil, nil, nil, nil, nil, nil

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for k, v in pairs(Config.Props) do
        RequestModel(GetHashKey(v))
        while not HasModelLoaded(GetHashKey(v)) do
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent("crateDrop")
AddEventHandler("crateDrop", function(planeSpawnDistance, dropCoords, id) 
    DoReset()
    local NewCoords = vector3(dropCoords.x, dropCoords.y, dropCoords.z)
    dropID = id
    CrateDrop(planeSpawnDistance, NewCoords)
end)

function CrateDrop(planeSpawnDistance, dropCoords)
    Citizen.CreateThread(function()

        local rHeading = math.random(0, 360)
        local theta = (rHeading / 180.0) * 3.14
        local rPlaneSpawn = vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance, -350.0) -- the plane is spawned at

        local minHeight = dropCoords.z

        local dx = dropCoords.x - rPlaneSpawn.x
        local dy = dropCoords.y - rPlaneSpawn.y
        local heading = GetHeadingFromVector_2d(dx, dy)

        TriggerEvent('AddBlips', dropCoords.x, dropCoords.y, dropCoords.z)

        aircraft = CreateVehicle(GetHashKey(Config.Props['aircraft']), rPlaneSpawn, heading, false, true)
        SetEntityHeading(aircraft, heading)
        SetEntityLodDist(aircraft, planeSpawnDistance) 
        SetVehicleDoorsLocked(aircraft, 2)
        SetEntityDynamic(aircraft, true)
        -- ActivatePhysics(aircraft)
        SetVehicleForwardSpeed(aircraft, 80.0)
        SetHeliBladesFullSpeed(aircraft) 
        SetVehicleEngineOn(aircraft, true, true, false)
        ControlLandingGear(aircraft, 3) 
        OpenBombBayDoors(aircraft)
        SetEntityProofs(aircraft, true, false, true, false, false, false, false, false)

        pilot = CreatePedInsideVehicle(aircraft, 1, GetHashKey(Config.Props['pilot']), -1, false, true)
        SetBlockingOfNonTemporaryEvents(pilot, true) 
        SetPedRandomComponentVariation(pilot, false)
        SetPedKeepTask(pilot, true)
        SetPlaneMinHeightAboveTerrain(aircraft, 100)

        TaskVehicleDriveToCoord(pilot, aircraft, vector3(dropCoords.x, dropCoords.y, dropCoords.z) + vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance, 350.0), 100.0, 0, GetHashKey(Config.Props['aircraft']), 262144, -1.0, -1.0) 
        -- TaskVehicleDriveToCoord(pilot, aircraft, vector3(dropCoords.x, dropCoords.y, minHeight), 120.0, 0, GetHashKey(Config.Props['aircraft']), 262144, 15.0, -1.0) 

        local droparea = vector2(dropCoords.x, dropCoords.y)
        local planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y)

        while not IsEntityDead(pilot) and #(planeLocation - droparea) > 20.0 do 
            Wait(100)
            planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y) 
        end

        -- TaskVehicleDriveToCoord(pilot, aircraft, vector3(dropCoords.x, dropCoords.y, dropCoords.z) + vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance, 350.0), 100.0, 0, GetHashKey(Config.Props['aircraft']), 262144, -1.0, -1.0) 

        local crateSpawn = vector3(dropCoords.x, dropCoords.y, dropCoords.z)

        crate = CreateObject(GetHashKey(Config.Props['crate']), crateSpawn, false, true, true) 
        SetEntityLodDist(crate, 1000) 
        ActivatePhysics(crate)
        parachute = CreateObject(GetHashKey(Config.Props['parachute']), crateSpawn, false, true, true) 
        SetEntityLodDist(parachute, 1000)

        AttachEntityToEntity(parachute, crate, 0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

        if Config.EnableDropSound then 
            TriggerEvent('CrateSound', crate)
        end
        

        -- print(crate, dropCoords, GetEntityCoords(crate).z, dropCoords.z, DoesEntityExist(crate))
        while GetEntityCoords(crate).z - dropCoords.z > 2 do 
            Citizen.Wait(10)
            -- print(GetEntityCoords(crate))
            SetEntityCoords(crate, GetEntityCoords(crate).x, GetEntityCoords(crate).y, GetEntityCoords(crate).z - 0.1, false, false, false, true)
        end

        PlaceObjectOnGroundProperly(crate)

        TriggerEvent('StartText')
        
        if Config.EnableFlare then 
            TriggerEvent('Smoke', crate)
        end

    end)
end

function DoReset()
    pilot, aircraft, parachute, crate, blip, soundID, dropID= nil, nil, nil, nil, nil, nil, nil
    if DoesEntityExist(pilot) then
        SetEntityAsMissionEntity(pilot, false, true)
        DeleteEntity(pilot)
    end
    if DoesEntityExist(aircraft) then
        SetEntityAsMissionEntity(aircraft, false, true)
        DeleteEntity(aircraft)
    end
    if DoesEntityExist(parachute) then 
        DeleteEntity(parachute)
    end
    DeleteEntity(crate)
    RemoveBlip(blip)
    StopSound(soundID)
    ReleaseSoundId(soundID)
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then

        if DoesEntityExist(pilot) then
            SetEntityAsMissionEntity(pilot, false, true)
            DeleteEntity(pilot)
        end
        if DoesEntityExist(aircraft) then
            SetEntityAsMissionEntity(aircraft, false, true)
            DeleteEntity(aircraft)
        end
        if DoesEntityExist(parachute) then 
            DeleteEntity(parachute)
        end
        DeleteEntity(crate)
        RemoveBlip(blip)
        StopSound(soundID)
        ReleaseSoundId(soundID)

        for i = 1, #Config.Props do
            Wait(0)
            SetModelAsNoLongerNeeded(GetHashKey(Config.Props[i]))
        end

    end
end)

local TextSecondaryColor = {r = 33, g = 244, b = 218, a = 255} -- Use RGB color picker	

RegisterNetEvent('StartText')
AddEventHandler('StartText', function()
    DeleteEntity(parachute)    
    DeleteEntity(aircraft)
    DeleteEntity(pilot)
    parachute, pilot, aircraft = nil, nil, nil

    SetBlipAlpha(blip, 255) 

    if not Config.UseTarget then 
        Citizen.CreateThread(function()
            while true do 
                Citizen.Wait(5)
                if DoesEntityExist(crate) then 
                    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(crate)) < 3 then 
                        local cratecor = GetEntityCoords(crate)
                        Draw3DText(cratecor.x, cratecor.y, cratecor.z - 0.8, '[E] - Open Air Drop', 4, 0.08, 0.08, TextSecondaryColor)
                            if IsControlJustPressed(0, 38) then
                                TriggerServerEvent('LootDrop', dropID)
                            end
                    else
                        Citizen.Wait(1000)
                    end
                else
                    break
                end
            end
        end)
    else
        -- exports['qb-target']:AddTargetEntity(crate, {
        --     options = {
        --         {
        --             type = "server",
        --             event = "LootDrop:Target",
        --             icon = "fas fa-box-circle-check",
        --             label = Config.InteractionText,
        --             crateID = dropID,
        --         },
        --     },
        --     distance = 3.0,
        -- })
        exports['qb-target']:AddBoxZone("airdrop"..dropID, GetEntityCoords(crate), 1.3, 1.3, {
            name = "airdrop"..dropID,
            heading = 11.0,
            debugPoly = false,
            minZ = GetEntityCoords(crate).z-2,
            maxZ = GetEntityCoords(crate).z+2,
            }, {
            options = {
                {
                    type = "server",
                    event = "LootDrop:Target",
                    icon = "fas fa-box-circle-check",
                    label = Config.InteractionText,
                    crateID = dropID,
                },
            },
            distance = 3.0,
        })
    end

    Citizen.Wait(Config.DeleteDropDuration * 60 * 1000)
    -- DeleteEntity(crate)
    exports['qb-target']:RemoveZone("airdrop"..dropID)
    
end)

RegisterNetEvent('ClientLootDrop')
AddEventHandler('ClientLootDrop', function(items)
    local ShopItems = {}
    ShopItems.label = 'Drop Loot'
    ShopItems.items = items
    ShopItems.slots = 30
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "AirDropLoot", ShopItems)
end)

RegisterNetEvent('NormalNotification')
AddEventHandler('NormalNotification', function(text)
    QBCore.Functions.Notify(text)
end)

RegisterNetEvent('LargeNotification')
AddEventHandler('LargeNotification', function(text)
    if QBCore.Functions.GetPlayerData().job.name ~= 'police' then 
        QBCore.Functions.Notify(text)
    end
end)

RegisterNetEvent('Smoke')
AddEventHandler('Smoke', function(drop)
    local particleDictionary = "core"
    local particleName = "exp_grd_flare"
    local loopAmount = 2
    
    RequestNamedPtfxAsset(particleDictionary)

    while not HasNamedPtfxAssetLoaded(particleDictionary) do
        Citizen.Wait(0)
    end
    
    local particleEffects = {}
    for x=0,loopAmount do
        UseParticleFxAssetNextCall(particleDictionary)

        local particle = StartNetworkedParticleFxLoopedOnEntity(particleName, drop, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, false, false, false, 0.0, 0.0, 0.0, 0.0)
        -- Add the particle effect to the table.
        table.insert(particleEffects, 1, particle)
        -- Prevent freezing.
        Citizen.Wait(0)
    end

    Citizen.Wait(Config.FlareDuration * 1000)
    for _,particle in pairs(particleEffects) do
        -- Stopping each particle effect.
        StopParticleFxLooped(particle, true)
    end
    if Config.EnableDropSound and soundID ~= nil then 
        StopSound(soundID)
        ReleaseSoundId(soundID)
        soundID = nil
    end
end)

RegisterNetEvent('CrateSound')
AddEventHandler('CrateSound', function(crate)
    soundID = GetSoundId() 
    PlaySoundFromEntity(soundID, "Crate_Beeps", crate, "MP_CRATE_DROP_SOUNDS", true, 0) 
end)


RegisterNetEvent('AddBlips')
AddEventHandler('AddBlips', function(x, y, z)
    if QBCore.Functions.GetPlayerData().job.name ~= 'police' then 
        blip = AddBlipForCoord(x,y,z)
        SetBlipSprite(blip, Config.BlipSprite)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.BlipText)
        EndTextCommandSetBlipName(blip)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 1)
        SetBlipAlpha(blip, 254)

        if Config.BlipBlink then 
            Citizen.CreateThread(function()
                while true do 
                    Citizen.Wait(500)
                    if GetBlipAlpha(blip) ~= 255 then 
                        if visibleBlip then 
                            SetBlipAlpha(blip, 5) 
                            visibleBlip = false
                        else
                            SetBlipAlpha(blip, 254) 
                            visibleBlip = true
                        end
                    else
                        break
                    end
                end
            end)
        end
    end

    Citizen.Wait(Config.DeleteDropDuration * 60 * 1000)
    DeleteEntity(crate)
    RemoveBlip(blip)
    if Config.EnableDropSound and soundID ~= nil then 
        StopSound(soundID)
        ReleaseSoundId(soundID)
        soundID = nil
    end
    pilot, aircraft, parachute, crate, blip, soundID = nil, nil, nil, nil, nil, nil
end)

function Draw3DText(x,y,z,textInput,fontId,scaleX,scaleY,color)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
	local scale = (1/dist)*20
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
	SetTextScale(scaleX*scale, scaleY*scale)
	SetTextFont(fontId)
	SetTextProportional(1)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextDropshadow(1, 1, 1, 1, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(textInput)
	SetDrawOrigin(x,y,z+2, 0)
	DrawText(0.0, 0.0)
	ClearDrawOrigin()
end