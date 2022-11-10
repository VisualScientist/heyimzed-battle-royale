_G._LAST_HIT = 0
function HitPlayer()
	if GetGameTimer() - _LAST_HIT >= 5000 then
		ApplyDamageToPed(PlayerPedId(), 10, false)
		_LAST_HIT = GetGameTimer()
	end
end

function RunGameZone()
	local swimTime = 0
	while CurrentGame.playing do
		local pos = GetEntityCoords(PlayerPedId())
		if #(Config.MapCenter.xy - pos.xy) >= Config.MaxRadius and not IsPedDeadOrDying(PlayerPedId()) then
			DrawBigMessage(_U('zone_out'))
			HitPlayer()
		else
			if (IsPedSwimming(PlayerPedId()) == 1) then
				swimTime = swimTime + 1
				if swimTime >= (Config.Game.SecondsToDrown*1000)/2 then
					if swimTime >= (Config.Game.SecondsToDrown*1000) then
						DrawBigMessage(_U('drowning'))
						HitPlayer()
					else
						DrawBigMessage(_U('drown_soon'))
					end
				end
			elseif swimTime > 0 then
				swimTime = 0
			end
		end
		Wait(0)
	end
end

function MakeZoneBlip(pos, radius, edgeColour, _f)
	local blip = AddBlipForRadius(pos.x, pos.y, 0.0, radius)
	SetBlipAlpha(blip, 255)
	SetBlipColour(blip, edgeColour or 1)
	SetRadiusBlipEdge(blip, true)
	return tonumber(blip)
end

function UpdateZoneBlip(blip, oldRadius, newRadius)
	if DoesBlipExist(blip) then
		local tempBlip = MakeZoneBlip(Config.MapCenter, newRadius, 3)
		local r = tonumber(oldRadius)+0.0
		while r > newRadius and CurrentGame.playing do
			r = r - 0.1
			SetBlipScale(blip, r)
			Config.MaxRadius = r
			Wait(10)
		end
		RemoveBlip(tempBlip)
	end
end

RegisterNetEvent('pmc-battleroyale:update:status:zone')
AddEventHandler('pmc-battleroyale:update:status:zone', function(mapCenter)
	local firstMapCenter = Config.MapCenter.xy
	local firstRadius = tonumber(Config.MaxRadius)
	Config.MapCenter = vec(mapCenter.x, mapCenter.y)
	local blip = MakeZoneBlip(Config.MapCenter, Config.MaxRadius)
	Wait(5 * 1000)
	repeat
		GameCounter:NextRing(Config.SecondsBetweenRings)
		Wait(Config.SecondsBetweenRings * 1000)
		UpdateZoneBlip(blip, Config.MaxRadius, Config.MaxRadius - (Config.MaxRadius / 3))
	until (CurrentGame.playing == false)
	RemoveBlip(blip)
	Config.MapCenter = firstMapCenter.xy
	Config.MaxRadius = firstRadius
end)
