
RegisterNetEvent('pmc-battleroyale:join:game')
AddEventHandler('pmc-battleroyale:join:game', function(gameIndex)
	local source = tonumber(source)
	if gameIndex ~= nil and tonumber(gameIndex) ~= nil and gameIndex > 0 then
		if Battleroyale:JoinPlayer(source, gameIndex) then
		else
			-- game is full or started
		end
	else
		for i=1, Config.MaxGameArenas, 1 do
			if not Battleroyale:HasStarted(i) then
				if Battleroyale:JoinPlayer(source, i) then
					break
				end
			end
		end
	end
end)

RegisterNetEvent('pmc-battleroyale:leave:game')
AddEventHandler('pmc-battleroyale:leave:game', function(gameIndex, died)
	local source = tonumber(source)
	if gameIndex ~= nil and tonumber(gameIndex) ~= nil and gameIndex > 0 and not Battleroyale:LeavePlayer(source, gameIndex, died) then
		-- probably made a Lua injection?
	end
end)

RegisterNetEvent('pmc-battleroyale:request:leaderboard')
AddEventHandler('pmc-battleroyale:request:leaderboard', function()
	local source = tonumber(source)
	EnsureClientEvent('pmc-battleroyale:update:leaderboard', source, Database:GetPlayersScore(true))
end)

RegisterNetEvent('pmc-battleroyale:test:start')
AddEventHandler('pmc-battleroyale:test:start', function(gameIndex)
	if not Battleroyale:HasStarted(gameIndex) then
		Battleroyale:StartBattle(gameIndex, true)
	end
end)

RegisterNetEvent('pmc-battleroyale:test:end')
AddEventHandler('pmc-battleroyale:test:end', function(gameIndex)
	if Battleroyale:HasStarted(gameIndex) then
		Battleroyale:EndBattle(gameIndex)
	end
end)

RegisterNetEvent('pmc-battleroyale:test:check')
AddEventHandler('pmc-battleroyale:test:check', function(gameIndex)
	if Battleroyale:HasStarted(gameIndex) then
		Battleroyale:CheckBattleForEnd(gameIndex)
	end
end)

--[[ RegisterCommand('inst', function(s, args)
	local i = instance.new(tonumber(args[1]))
	i:removePlayer(tonumber(args[2]))
end, true) ]]
