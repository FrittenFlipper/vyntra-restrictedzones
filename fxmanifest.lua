fx_version "cerulean"
game "gta5"
lua54 "yes"

author "toasty3920"
description "Restricted zones script for ESX allowing players to create restricted areas."
version "1.0.1"

client_scripts {
    "client/cl_main.lua",
}

shared_scripts {
    "@es_extended/imports.lua",
    "config.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/sv_main.lua",
}
