
function loadScaleform(scaleform)
	scaleformHandle = RequestScaleformMovie(scaleform)
	local p = promise.new()
	CreateThread(function()
		while true do
			if HasScaleformMovieLoaded(scaleformHandle) then
				p:resolve(scaleformHandle)
				break
			else
				scaleformHandle = RequestScaleformMovie(scaleform)
			end
			Wait(100)
		end
	end)
	return p
end

url = 'https://cfx-nui-'..GetCurrentResourceName()..'/html/leaderboard.html'
scale = 0.2
sfName = 'leaderboard'

width = 1280
height = 720

sfHandle = nil
txdHasBeenSet = false
duiObj = nil

CreateThread(function()
	while true do
		if not CurrentGame.playing and #(GetGameplayCamCoord()-Config.LeaderBoard.xyz) <= 20.0 then
			Wait(1)
			if sfHandle ~= nil and not txdHasBeenSet then
				BeginScaleformMovieMethod(sfHandle, 'SET_TEXTURE')

				PushScaleformMovieMethodParameterString('meows')
				PushScaleformMovieMethodParameterString('woof')

				ScaleformMovieMethodAddParamInt(0)	-- x
				ScaleformMovieMethodAddParamInt(0)	-- y
				ScaleformMovieMethodAddParamInt(width)
				ScaleformMovieMethodAddParamInt(height)

				EndScaleformMovieMethod()

				txdHasBeenSet = true
			end

			if sfHandle ~= nil and HasScaleformMovieLoaded(sfHandle) then
				DrawScaleformMovie_3dNonAdditive(
					sfHandle,
					Config.LeaderBoard.x, Config.LeaderBoard.y, Config.LeaderBoard.z+2.0,
					0, Config.LeaderBoard.w+0.0, 0,
					2, 2, 2,
					scale*1, scale*(9/16), 1,
					2)
			end
		else
			Wait(500)
		end
	end
end)

RegisterNetEvent('pmc-battleroyale:update:leaderboard')
AddEventHandler('pmc-battleroyale:update:leaderboard', function(board)
	while not IsDuiAvailable(duiObj) do Wait(100) end
	CurrentGame.leaderboard = board
	SendDuiMessage(duiObj, json.encode({
		action = 'update',
		board = board,
		locales = {
			leaderboard = _U('leaderboard'),
			wins = _U('wins'),
			description = _U('tutorial'),
		}
	}))
end)

AddEventHandler('onClientResourceStart', function(res)
	if res == GetCurrentResourceName() then
		sfHandle = Citizen.Await(loadScaleform(sfName))
		runtimeTxd = 'meows'

		txd = CreateRuntimeTxd('meows')
		duiObj = CreateDui(url, width, height)
		dui = GetDuiHandle(duiObj)
		tx = CreateRuntimeTextureFromDuiHandle(txd, 'woof', dui)
		SetTimeout(1000, function()
			TriggerServerEvent('pmc-battleroyale:request:leaderboard')
		end)
	end
end)

AddEventHandler('onResourceStop', function(res)
	if res == GetCurrentResourceName() and duiObj ~= nil and sfHandle ~= nil then
		DestroyDui(duiObj)
	end
end)
