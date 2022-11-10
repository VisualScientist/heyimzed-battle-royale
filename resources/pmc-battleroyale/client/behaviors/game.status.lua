
_G.CurrentGame = setmetatable({
	index = 0,
	joined = false,
	playing = false,
	waiting = false,
	alreadySoon = false,
	pickups = {},
	playerCount = 0,
	playerNames = {},
	leaderboard = {},
}, {
	__index = {
		SetDefaults = function(self)
			self.index = 0; self.joined = false; self.playing = false; self.waiting = false; self.pickups = {}; self.playerCount = 0; self.playerNames = {}; self.alreadySoon = false;
		end,
	}
})

_G.GameMenu = setmetatable({
	showing = false,
	firstLoad = false,
}, {
	__index = {
		SendNUI = function(self, _payload)
			_payload.action = 'menu'
			SendNUIMessage(_payload)
		end,
		Show = function(self, _b)
			self.showing = _b
			self:SendNUI({show = _b})
		end,
		FirstLoad = function(self)
			self.firstLoad = true
			self:SendNUI({
				locales = {current_arena = _U('current_arena'), wins = _U('wins')},
				max = Config.MaxBattlePlayers,
			})
		end,
		GetPlayerList = function(self)
			local _t = {}
			for _i, _n in pairs(CurrentGame.playerNames) do
				local _ins = false
				for _ii, _p in pairs(CurrentGame.leaderboard) do
					if _p.name == _n then
						table.insert(_t, _p)
						_ins = true
						break
					end
				end
				if not _ins then
					table.insert(_t, {name=_n, score=0})
				end
			end
			return _t
		end,
		Update = function(self)
			if CurrentGame.joined then
				self:SendNUI({
					arena = CurrentGame.index,
					status = (CurrentGame.waiting == true and _U('status_waiting') or _U('status_playing')),
					players = self:GetPlayerList(),
				})
			end
		end,
		UpdateStatus = function(self, _s)
			self:SendNUI({status = _s})
		end,
	}
})

_G.GameCounter = setmetatable({
	showing = false,
}, {
	__index = {
		SendNUI = function(self, payload)
			payload.action = 'counter'
			SendNUIMessage(payload)
		end,
		Show = function(self)
			self.showing = not self.showing
			self:SendNUI({
				show = self.showing
			})
		end,
		Update = function(self)
			if not self.showing then self:Show() end
			self:SendNUI({
				text = _U('remaining', CurrentGame.playerCount, Config.MaxBattlePlayers)
			})
		end,
		NextRing = function(self, seconds)
			if self.showing then
				self:SendNUI({
					nextRing = seconds,
					format = _U('next_ring'),
				})
			end
		end,
	}
})

RegisterNetEvent('pmc-battleroyale:client:update:status:playerCount')
AddEventHandler('pmc-battleroyale:client:update:status:playerCount', function(newPlayerCount, reason, playerName, filter)
	CurrentGame.playerCount = newPlayerCount
	SendScreenLog(_U(reason, playerName, CurrentGame.playerCount))
	if GetPlayerServerId(PlayerId()) ~= filter then
		if reason == 'join' then
			table.insert(CurrentGame.playerNames, playerName)
		elseif reason == 'left' or reason == 'died' then
			local _R_K = 0
			for _i, _name in pairs(CurrentGame.playerNames) do
				if _name == playerName then
					_R_K = _i
					break
				end
			end
			CurrentGame.playerNames[_R_K] = nil
		end
	end
	GameMenu:Update();
	if CurrentGame.playing then
		GameCounter:Update();
	end
end)

RegisterNetEvent('pmc-battleroyale:client:update:status:readySoon')
AddEventHandler('pmc-battleroyale:client:update:status:readySoon', function(gameIndex, seconds)
	if CurrentGame.joined and CurrentGame.waiting and CurrentGame.index == gameIndex and not CurrentGame.alreadySoon then
		CurrentGame.alreadySoon = true
		local now = GetGameTimer()
		local steps = 0
		while CurrentGame.joined and not CurrentGame.playing and CurrentGame.playerCount >= Config.MinPlayersToStart do
			Wait(100)
			if GetGameTimer() - now >= 1000 then
				now = GetGameTimer()
				steps = steps + 1
				GameMenu:UpdateStatus(_U('seconds_left', math.floor((seconds/1000)-steps)))
			end
		end
		if not CurrentGame.playing then
			GameMenu:UpdateStatus(_U('status_waiting'))
			CurrentGame.alreadySoon = false
		else
			GameMenu:Show(false)
		end
	end
end)

function RunDeathStatus()
	while CurrentGame.playing do
		Wait(200)
		if IsEntityDead(PlayerPedId()) then
			DrawBigMessage(_U('you_died'), 5000)
			PlayNowSound("LOSER", "HUD_AWARDS")
			Wait(5000)
			-- TO:DO add spectator mode
			TriggerServerEvent('pmc-battleroyale:leave:game', CurrentGame.index, true)
			PlayNowSound("Hit", "RESPAWN_ONLINE_SOUNDSET")
			break
		end
	end
end
