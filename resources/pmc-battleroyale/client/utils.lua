_G._invn = Citizen.InvokeNative

function DrawScreenText(x, y, text, size)
	if type(text) == 'table' then
		for i, line in pairs(text) do
			SetTextColour(0, 255, 0, 255)
			SetTextDropShadow()
			SetTextScale(1.0, size)
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(line)
			EndTextCommandDisplayText(x, y+((i-1)*0.025))
		end
	else
		SetTextScale(1.0, size)
		BeginTextCommandDisplayText('STRING')
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandDisplayText(x, y)
	end
end

function PlayNowSound(audioName, audioRef)
	SetAudioFlag("LoadMPData", true)
	PlaySoundFrontend(-1, audioName, audioRef, true)
end

function DrawBigMessage(text, msec)
	if msec then
		local text = text
		local msec = msec
		CreateThread(function()
			local scaleform = RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
			while not HasScaleformMovieLoaded(scaleform) do Wait(0) end
			BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			BeginTextCommandScaleformString("STRING")
			AddTextComponentSubstringPlayerName(text)
			EndTextCommandScaleformString()
			EndScaleformMovieMethod()
			
			local now = GetGameTimer()
			while (GetGameTimer() - now) <= msec do
				Wait(1)
				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
			end
			SetScaleformMovieAsNoLongerNeeded(scaleform)
		end)
	else
		local scaleform = RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
		while not HasScaleformMovieLoaded(scaleform) do Wait(0) end
		BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
		BeginTextCommandScaleformString("STRING")
		AddTextComponentSubstringPlayerName(text)
		EndTextCommandScaleformString()
		EndScaleformMovieMethod()
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		SetScaleformMovieAsNoLongerNeeded(scaleform)
	end
end

function LoadIslandHeist(state)
	_invn(0x9A9D1BA639675CF1, 'HeistIsland', state)
	_invn(0x5E1460624D194A38, state)
	_invn(0xF74B1FFA4A15FBEA, state)
	_invn(0x53797676AD34A9AA, not state)
	if state then SetDeepOceanScaler(0.0) else ResetDeepOceanScaler() end
end

RegisterCommand('forceisland', function(s, args) LoadIslandHeist(args[1] == 'true') end, true)
