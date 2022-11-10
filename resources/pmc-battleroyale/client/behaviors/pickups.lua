
function SpawnPickupHere(pos)
	local pickup = CreatePickup(Config.Pickups[math.random(1, #Config.Pickups)], pos.x, pos.y, pos.z-0.5, 513, math.random(1, Config.Game.LootMaxAmount), false)
	while not DoesPickupExist(pickup) do Wait(1) end
	SetPickupRegenerationTime(pickup, -1)
	return pickup
end

function RemoveAllPickups()
	for _, pickup in pairs(CurrentGame.pickups) do
		if DoesPickupExist(pickup) then
			RemovePickup(pickup)
		end
	end
	CurrentGame.pickups = {}
end

function RunPickups()
	math.randomseed(GetGameTimer()*math.random(30568, 90214))
	for _, pos in pairs(Config.Game.LootSpawns) do
		if math.random(0,1) == 1 then
			table.insert(CurrentGame.pickups, SpawnPickupHere(pos))
		end
	end
	while CurrentGame.playing do
		for _, pickup in pairs(CurrentGame.pickups) do
			if HasPickupBeenCollected(pickup) then
				RemovePickup(pickup)
			end
		end
		Wait(1000)
	end
end
