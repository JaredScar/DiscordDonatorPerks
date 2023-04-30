author "Badger#0002"
description "DiscordDonatorPerks"
fx_version "cerulean"
game "gta5"

client_scripts { 
	"client.lua",
}
server_scripts {
	"config.lua",
	"server.lua",
	"@mysql-async/lib/MySQL.lua"
}