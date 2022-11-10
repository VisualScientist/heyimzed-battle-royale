
_G.Battleroyale = setmetatable({
	_BATTLES = {},
	_DEBUG_MESSAGES = false,	-- set this to true to print debug messages!
	_CAN_USE_NATIVE = true, -- set this to false to not use natives for Cayo Perico DLC
}, {
	__index = {
		DebugPrint = function(self, _m, ...)
			if self._DEBUG_MESSAGES then
				print(("[pmc-battleroyale:DEBUG] %s"):format((_m):format(...)))
			end
		end,
		Ensure = function(self, _o, _t, _d)
			assert(type(_o) == _t, 'invalid Lua type')
			if _d then return _d end
		end,
		EnsureBattle = function(self, _i)
			self:Ensure(_i, 'number')
			if self._BATTLES[_i] == nil then
				self._BATTLES[_i] = {
					players = {},
					spectators = {},
					playerNames = {},
					playerCount = 0,
					started = false,
					waiting = true,
					startedAt = 0,
					lastNotify = 0,
				}
			end
		end,
		HasStarted = function(self, _i)
			self:Ensure(_i, 'number')
			self:EnsureBattle(_i)
			return self._BATTLES[_i].started
		end,
		CanJoinBattle = function(self, _i)
			self:Ensure(_i, 'number')
			return self._BATTLES[_i].playerCount < Config.MaxBattlePlayers
		end,
		PlayerExistsInBattle = function(self, _s, _i)
			self:Ensure(_s, 'number')
			self:Ensure(_i, 'number')
			return self._BATTLES[_i].players[tostring(_s)] ~= nil
		end,
		RemoveFromBattle = function(self, _i, _s)
			if self:PlayerExistsInBattle(_s, _i) then
				self._BATTLES[_i].players[tostring(_s)] = nil
				self._BATTLES[_i].playerNames[tostring(_s)] = nil
				return true
			end
			return false
		end,
		CheckBattleForEnd = function(self, _i)
			self:Ensure(_i, 'number')
			if self:HasStarted(_i) then
				if self._BATTLES[_i].playerCount == 1 then
					local _k, _s = next(self._BATTLES[_i].players)
					SetPlayerRoutingBucket(tostring(_s), 0)
					EnsureClientEvent('pmc-battleroyale:game:end', _s, true)
					self:DebugPrint('%s won game arena %s', _s, _i)
					Database:AddPlayerScore(_s, 1)
					if Config.EnableChatMessages then
						EnsureClientEvent('chat:addMessage', -1, {
							args = {"BATTLEROYALE", _U("won", GetPlayerName(_s)..(" (%s)"):format(Database:GetPlayerScore(_s).score), _i)}
						})
					end
					self._BATTLES[_i] = nil
					Database:Save()
				end
			end
		end,
		JoinPlayer = function(self, _s, _i)
			self:Ensure(_s, 'number')
			self:Ensure(_i, 'number')
			if not self:HasStarted(_i) and self:CanJoinBattle(_i) then
				-- add player
				self._BATTLES[_i].players[tostring(_s)] = _s
				self._BATTLES[_i].playerNames[tostring(_s)] = GetPlayerName(_s)
				-- instance the player
				SetPlayerRoutingBucket(tostring(_s), _i)
				-- client "join" the game
				EnsureClientEvent('pmc-battleroyale:joined:game', _s, _i, self._CAN_USE_NATIVE, self._BATTLES[_i].playerNames)
				-- add player to count
				self._BATTLES[_i].playerCount = self._BATTLES[_i].playerCount + 1
				-- update players counter
				EnsureClientEvent('pmc-battleroyale:client:update:status:playerCount', self:GetPlayersInBattle(_i), self._BATTLES[_i].playerCount, 'join', GetPlayerName(_s), _s)
				self:DebugPrint('%s joined game arena %s (routing bucket %s)', _s, _i, GetPlayerRoutingBucket(tostring(_s)))
				-- check if the battle should start
				self:StartBattle(_i)
				return true
			else
				return false
			end
		end,
		LeavePlayer = function(self, _s, _i, _d)
			self:Ensure(_s, 'number')
			self:Ensure(_i, 'number')
			self:EnsureBattle(_i)
			if self:RemoveFromBattle(_i, _s) then
				EnsureClientEvent('pmc-battleroyale:game:end', _s)
				SetPlayerRoutingBucket(tostring(_s), 0)
				self._BATTLES[_i].playerCount = self._BATTLES[_i].playerCount - 1
				if self._BATTLES[_i].playerCount == 0 then
					self._BATTLES[_i] = nil
				else
					EnsureClientEvent('pmc-battleroyale:client:update:status:playerCount', self:GetPlayersInBattle(_i), self._BATTLES[_i].playerCount, _d and 'died' or 'left', GetPlayerName(_s), _s)
					if self._BATTLES[_i].playerCount < Config.MinPlayersToStart then
						self._BATTLES[_i].lastNotify = 0
					end
				end
				self:DebugPrint('%s leaved game arena %s', _s, _i)
				return true
			end
			return false
		end,
		GetPlayersInBattle = function(self, _i)
			self:Ensure(_i, 'number')
			return self._BATTLES[_i].players
		end,
		StartBattle = function(self, _i, _f)
			self:Ensure(_i, 'number')
			if not self:HasStarted(_i) then
				if _f == true then
					self._BATTLES[_i].started = true; self._BATTLES[_i].waiting = false;
					self._BATTLES[_i].startedAt = os.clock()
					local rndTime = {hour = 14, minute = 0}
					if Config.RandomTime then
						rndTime.hour 	= math.random(Config.RandomHourBetween[1], Config.RandomHourBetween[2])
						rndTime.minute 	= math.random(Config.RandomMinuteBetween[1], Config.RandomMinuteBetween[2])
					end
					EnsureClientEvent('pmc-battleroyale:game:started', self:GetPlayersInBattle(_i), Config.Weathers[math.random(1, #Config.Weathers)], rndTime)
					math.randomseed(GetGameTimer() * math.random(30123, 90456))
					EnsureClientEvent('pmc-battleroyale:update:status:zone', self:GetPlayersInBattle(_i), Config.ClosingRingSpots[math.random(1, #Config.ClosingRingSpots)])
					self:DebugPrint('started game arena %s', _i)
				elseif self._BATTLES[_i].playerCount >= Config.MinPlayersToStart then
					if self._BATTLES[_i].lastNotify == 0 then self._BATTLES[_i].lastNotify = os.clock() end
					EnsureClientEvent('pmc-battleroyale:client:update:status:readySoon', self:GetPlayersInBattle(_i), _i, (Config.SecondsToStart-(os.clock() - (self._BATTLES[_i].lastNotify or os.clock())))*1000)
				end
			end
		end,
		CheckBattles = function(self)
			for _i, _B in pairs(self._BATTLES) do
				if _B.waiting and _B.playerCount >= Config.MinPlayersToStart then
					if os.clock() - (_B.lastNotify or os.clock()) >= Config.SecondsToStart then
						self:StartBattle(_i, true)
					end
				elseif _B.started and _B.playerCount == 1 and os.clock() - _B.startedAt >= 60 then
					self:CheckBattleForEnd(_i)
				end
			end
		end,
		EndBattle = function(self, _i)
			self:Ensure(_i, 'number')
			if self:HasStarted(_i) then
				local _ps = self:GetPlayersInBattle(_i)
				EnsureClientEvent('pmc-battleroyale:game:end', _ps)
				self:DebugPrint('end game arena %s', _i)
				for _, _s in pairs(_ps) do
					SetPlayerRoutingBucket(tostring(_s), 0)
				end
				self._BATTLES[_i] = nil
			end
		end,
	}
})

CreateThread(function()
	while true do
		Wait(500)
		Battleroyale:CheckBattles()
	end
end)
