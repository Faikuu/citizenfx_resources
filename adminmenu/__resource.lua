resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_script{
'client.lua'
}

server_scripts{
'server.lua',
'@async/async.lua',
'@mysql-async/lib/MySQL.lua',
}
client_script '@blackout_anticheat/init.lua'