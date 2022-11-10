
RegisterNetEvent('pmc-battleroyale:joined:game')
AddEventHandler('pmc-battleroyale:joined:game', function(_i, canUseNative, playerNames)
	CurrentGame.index = _i; CurrentGame.joined = true; CurrentGame.waiting = true;
	CurrentGame.playerNames = playerNames;
	SendScreenLog(_U('joined_arena', _i))
	local _x, _y, _z = table.unpack(GetEntityCoords(PlayerPedId()))
	CurrentGame.lastPos = {x = _x, y = _y, z = _z, w = GetEntityHeading(PlayerPedId())}
	if canUseNative and Config.NativeLoadMap then
		CurrentGame.canUseNative = true
		LoadIslandHeist(true)
	else
		CurrentGame.canUseNative = false
		SetDeepOceanScaler(0.0)
	end
	SetEntityCoords(PlayerPedId(), Config.WaitingSpawn.x, Config.WaitingSpawn.y, Config.WaitingSpawn.z, Config.WaitingSpawn.w, 0, 0, false)
	SetEntityInvincible(PlayerPedId(), true)
	SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
	CurrentGame.plane, CurrentGame.pilot = CreatePlane()
	SetEntityVisible(CurrentGame.plane, false, 0)
	if not GameMenu.firstLoad then GameMenu:FirstLoad() end
	GameMenu:Update(); GameMenu:Show(true)
end)

RegisterNetEvent('pmc-battleroyale:game:started')
AddEventHandler('pmc-battleroyale:game:started', function(weather, time)
	SetEntityVisible(CurrentGame.plane, true, 0)
	SetPedIntoVehicle(PlayerPedId(), CurrentGame.plane, -2)
	CreateThread(function()
		while CurrentGame.waiting do
			Wait(1)
			DisableControlAction(1, 75, true)
		end
	end)
	--
	SetWeatherTypeNowPersist(weather); NetworkOverrideClockTime(time.hour, time.minute, 0);
	CurrentGame.playing = true
	GameCounter:Update();
	if GameMenu.showing then GameMenu:Show(false) end
	PlayNowSound("5s_To_Event_Start_Countdown", "GTAO_FM_Events_Soundset")
	DrawBigMessage(_U('5s_to_start'), 5000)
	Wait(4000)
	TaskPlaneMission(CurrentPilot, CurrentPlane, 0, 0,
		Config.Game.Planes[CurrentPlaneConfig].despawn.x, Config.Game.Planes[CurrentPlaneConfig].despawn.y, Config.Game.Planes[CurrentPlaneConfig].despawn.z,
		4, 100.0, 0, GetEntityHeading(CurrentPlane), Config.Game.Planes[CurrentPlaneConfig].despawn.z+1.0, Config.Game.Planes[CurrentPlaneConfig].despawn.x-1.0)
	Wait(1000)
	FreezeEntityPosition(CurrentPlane, false)
	Wait(15--[[ secs ]]*1000)
	CreateThread(function()
		-- enable friendly damage
		NetworkSetFriendlyFireOption(true)
		SetCanAttackFriendly(PlayerPedId(), true, true)
		-- disable heal regen
		SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
		SetPlayerHealthRechargeLimit(PlayerId(), 0.0)
		SetEntityInvincible(PlayerPedId(), false)
		if CurrentGame.playing then
			CurrentGame.waiting = false
			if RunAirdrop() then
				if CurrentGame.playing then
					CreateThread(RunPickups)
					CreateThread(RunGameZone)
					CreateThread(RunDeathStatus)
				end
			else
				TriggerServerEvent('pmc-battleroyale:leave:game', CurrentGame.index)
			end
		end
	end)
	while DoesEntityExist(CurrentPlane) and #(Config.Game.Planes[CurrentPlaneConfig].despawn - GetEntityCoords(CurrentPlane)) >= 20.0 do Wait(500) end
	RemovePlane()
end)

RegisterNetEvent('pmc-battleroyale:game:end')
AddEventHandler('pmc-battleroyale:game:end', function(won)
	if won then
		SetPlayerInvincible(PlayerId(), true)
		DrawBigMessage(_U('you_won'), 5000)
		PlayNowSound("Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS")
		Wait(5000)
	end
	ResetDeepOceanScaler()
	if DoesEntityExist(CurrentPlane) then
		RemovePlane()
	end
	RemoveAllPedWeapons(PlayerPedId())
	RemoveAllPickups()
	if CurrentGame.canUseNative then LoadIslandHeist(false) end
	SetEntityCoords(PlayerPedId(), CurrentGame.lastPos.x, CurrentGame.lastPos.y, CurrentGame.lastPos.z, CurrentGame.lastPos.w, 0, 0, false)
	if IsEntityDead(PlayerPedId()) then
		NetworkResurrectLocalPlayer(CurrentGame.lastPos.x, CurrentGame.lastPos.y, CurrentGame.lastPos.z, CurrentGame.lastPos.w, 0, 0)
	else
		SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
	end
	SetPlayerInvincible(PlayerId(), false)
	ClearPedBloodDamage(PlayerPedId())
	GameMenu:Show(false); GameCounter:Show();
	CurrentGame:SetDefaults()
	SetWeatherTypeNowPersist("CLEAR"); NetworkOverrideClockTime(14, 0, 0);
end)


RegisterCommand('joinbattle', function(s, args)
	if CurrentGame.joined == false then
		if args[1] ~= nil and tonumber(args[1]) ~= nil then
			TriggerServerEvent('pmc-battleroyale:join:game', tonumber(args[1]))
		else
			TriggerServerEvent('pmc-battleroyale:join:game')
		end
	end
end, false)
RegisterCommand('leavebattle', function()
	if CurrentGame.joined == true then
		TriggerServerEvent('pmc-battleroyale:leave:game', CurrentGame.index)
	end
end, false)


RegisterCommand('checkbattle', function() TriggerServerEvent('pmc-battleroyale:test:check', CurrentGame.index) end, true)
RegisterCommand('startbattle', function() TriggerServerEvent('pmc-battleroyale:test:start', CurrentGame.index) end, true)
RegisterCommand('endbattle', function() TriggerServerEvent('pmc-battleroyale:test:end', CurrentGame.index) end, true)
