fx_version 'cerulean'
game 'gta5'

developer 'PiterMcFlebor'
discord 'ƤƖƬЄƦ MƇƑԼЄƁƠƦ#9270'
discord_server 'https://discord.gg/wwYDUsJv'	-- get updates here!
version '1.2'
locale 'en'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/leaderboard.html',
	'html/js/*.js',
	'html/css/*.css',
}

shared_scripts {
	'config.lua',
	'locale/common.lua',
	'locale/*.locale.lua',
}

client_scripts {
	'client/utils.lua',
	'client/remove.lua',	-- debug file
	'client/behaviors/*.lua',
	'client/main.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/utils.lua',
	'server/classes/*.lua',
	'server/main.lua',
}

dependencies {
	'mysql-async',
	'spawnmanager',
}
