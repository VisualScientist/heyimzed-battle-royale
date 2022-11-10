
_G.Database = setmetatable({
	_PLAYERS = {},
	_READY = false,
}, {
	__index = {
		Ensure = function(self, _o, _t, _d)
			assert(type(_o) == _t, 'invalid Lua type')
			if _d then return _d end
		end,
		EnsurePlayer = function(self, _s)
			local _i = self:GetIdentifier(_s)
			if not self._PLAYERS[_i] then
				self._PLAYERS[_i] = {name=GetPlayerName(_s), score = 0}
			else
				self._PLAYERS[_i].name = GetPlayerName(_s)
			end
		end,
		GetIdentifier = function(self, _s)
			self:Ensure(_s, 'number')
			local _pi = GetPlayerIdentifiers(_s)
			if _pi == nil then return 'none' end
			for _, _i in pairs(_pi) do
				if string.find(_i, 'license') then
					return _i
				end
			end
		end,
		GetPlayerScore = function(self, _s)
			self:Ensure(_s, 'number')
			self:EnsurePlayer(_s)
			return self._PLAYERS[self:GetIdentifier(_s)]
		end,
		SetPlayerScore = function(self, _s, _a)
			self:Ensure(_s, 'number')
			self:Ensure(_a, 'number')
			self:EnsurePlayer(_s)
			self._PLAYERS[self:GetIdentifier(_s)].score = _a
		end,
		AddPlayerScore = function(self, _s, _a)
			self:Ensure(_s, 'number')
			self:Ensure(_a, 'number')
			self:EnsurePlayer(_s)
			self:SetPlayerScore(_s, self._PLAYERS[self:GetIdentifier(_s)].score + _a)
		end,
		RemovePlayerScore = function(self, _s, _a)
			self:Ensure(_s, 'number')
			self:Ensure(_a, 'number')
			self:EnsurePlayer(_s)
			self:SetPlayerScore(_s, self._PLAYERS[self:GetIdentifier(_s)].score - _a)
		end,
		GetPlayersScore = function(self, _c)
			if not _c then return self._PLAYERS
			else
				local _t = {}
				for _i, _p in pairs(self._PLAYERS) do
					table.insert(_t, _p)
				end
				return _t
			end
		end,
		Save = function(self)
			for _i, _p in pairs(self._PLAYERS) do
				MySQL.Sync.execute('INSERT INTO `pmc_battleroyale` VALUES(@identifier, @name, @score) ON DUPLICATE KEY UPDATE `name` = @name, `score` = @score ', {
					['@score'] = _p.score,
					['@name'] = _p.name,
					['@identifier'] = _i,
				})
			end
			Battleroyale:DebugPrint('database saved!')
			EnsureClientEvent('pmc-battleroyale:update:leaderboard', -1, self:GetPlayersScore(true))
		end,
	}
})

MySQL.ready(function()
MySQL.Sync.execute(
[[CREATE TABLE IF NOT EXISTS `pmc_battleroyale` (
	identifier VARCHAR(50) PRIMARY KEY NOT NULL,
	name TEXT NOT NULL,
	score INT NOT NULL DEFAULT 0
)]])

local _rs = MySQL.Sync.fetchAll('SELECT `identifier`, `name`, `score` FROM `pmc_battleroyale`')
if #_rs > 0 then
	for _, _P in pairs(_rs) do
		Database._PLAYERS[_P.identifier] = {name = _P.name, score = _P.score}
	end
end

Database._READY = true
end)
