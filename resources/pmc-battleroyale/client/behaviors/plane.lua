local function _RqModel(model)
    if type(model) == 'string' then model = GetHashKey(model) end
    if not IsModelInCdimage(model) then print('Model not exists:', model); return false end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    return true
end

_G.CurrentPlane = 0
_G.CurrentPilot = 0

function RunAirdrop()
    DrawBigMessage(_U('press_f'), 5000)
    while DoesEntityExist(CurrentPlane) do
        Wait(1)
        DisableControlAction(1, 75, true)
        if IsDisabledControlJustPressed(1, 75) then
            GiveWeaponToPed(PlayerPedId(), `gadget_parachute`, 1, false, true)
            local pos = GetEntityCoords(CurrentPlane)
            SetEntityCoords(PlayerPedId(), pos.x, pos.y, pos.z-5.0, GetEntityHeading(CurrentPlane), 0, 0, false)
            return true
        end
    end
    return false
end

function DOING_TASK(ped)
    return (GetIsTaskActive(ped, 2)==1 or GetIsTaskActive(ped, 152)==1 or GetIsTaskActive(ped, 167)==1 or GetIsTaskActive(ped, 95)==1)
end

function CreatePlane()
    if _RqModel(Config.Game.PlaneModel) then
        math.randomseed(GetGameTimer())
        local _P = math.random(1, #Config.Game.Planes)
        CurrentPlaneConfig = _P
        -- CREATE PLANE
        CurrentPlane = CreateVehicle(Config.Game.PlaneModel, Config.Game.Planes[_P].spawn.x, Config.Game.Planes[_P].spawn.y, Config.Game.Planes[_P].spawn.z, Config.Game.Planes[_P].spawn.w, false, true)
        while not DoesEntityExist(CurrentPlane) do Wait(10) end
        SetVehicleDoorsLocked(CurrentPlane, 4)
        FreezeEntityPosition(CurrentPlane, true)
        -- CREATE PILOT
        if _RqModel(`s_m_m_pilot_02`) then
            CurrentPilot = CreatePedInsideVehicle(CurrentPlane, 4, `s_m_m_pilot_02`, -1, false, true)
            while not DoesEntityExist(CurrentPilot) do Wait(10) end
            CreateThread(function()
                while DoesEntityExist(CurrentPilot) == 1 do
                    if DOING_TASK(CurrentPilot) then
                        ClearPedTasks(CurrentPilot)
                    end
                    Wait(1)
                end
            end)
        end
        --
        SetVehicleEngineOn(CurrentPlane, true, true, false)
        SetEntityAsMissionEntity(CurrentPlane,0,0)
        SetEntityAsMissionEntity(CurrentPilot,0,0)
        return CurrentPlane, CurrentPilot, _P
    end
end

function RemovePlane(pos)
    if DoesEntityExist(CurrentPlane) then
        DeleteEntity(CurrentPlane)
        DeleteEntity(CurrentPilot)
        CurrentPlane = 0
        CurrentPilot = 0
    end
end
