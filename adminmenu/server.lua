ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local shadowbans = {
}

RegisterCommand("tppos", function(source, args, rawCommand)
    if (source > 0) then
		local player = ESX.GetPlayerFromId(source)
		
		if player ~= nil then
			local playerGroup = player.getGroup()

			if playerGroup ~= nil and playerGroup ~= 'user' then 
				local coordx = tonumber(args[1])
				local coordy = tonumber(args[2])
				local coordz = tonumber(args[3])
				if coordx and coordy and coordz then
					TriggerClientEvent('AdminMenu:teleport', source, coordx, coordy, coordz)
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Brak uprawnień")
			end
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Niepoprawne ID")
		end
    else
		
    end
end, false)

RegisterCommand("kill", function(source, args, rawCommand)
    if (source > 0) then
		local player = ESX.GetPlayerFromId(source)
		
		if player ~= nil and args[1] ~= source then
			local playerGroup = player.getGroup()

			if playerGroup ~= nil and playerGroup ~= 'user' then 
				local target = ESX.GetPlayerFromId(args[1])
				if target and tonumber(args[1]) then
					TriggerClientEvent('AdminMenu:Kill', tonumber(args[1]))
					TriggerClientEvent('chatMessage', source, "SYSTEM", {0, 255, 0}, "Zabito gracza " .. tonumber(args[1]))
				elseif tonumber(args[1]) then
					TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Gracz nie jest online")
				elseif not args[1] then
					TriggerClientEvent('AdminMenu:Kill', source)
					TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Samobójstwo")
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Brak uprawnień")
			end
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Niepoprawne ID")
		end
    else
		
    end
end, false)

RegisterCommand("setmoney", function(source, args, rawCommand)
    if (source > 0) then
		local player = ESX.GetPlayerFromId(source)
		
		if player ~= nil then
			local playerGroup = player.getGroup()

			if playerGroup ~= nil and playerGroup ~= 'user' then 
				local target = ESX.GetPlayerFromId(args[1])
				if target and tonumber(args[1]) and tonumber(args[2]) then
					local endmoney = target.getMoney()
					endmoney = tonumber(args[2]) - endmoney
					if endmoney > 0 then
						target.addMoney(endmoney)
					else
						target.removeMoney(-endmoney)
					end
					TriggerClientEvent('chatMessage', source, "SYSTEM", {0, 255, 0}, "Zmieniono kwotę na $" .. tonumber(args[2]) .. " dla ID: " .. tonumber(args[1]))
				else
					TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Gracz nie jest online")
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Brak uprawnień")
			end
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Niepoprawne ID")
		end
    else
		
    end
end, false)

RegisterCommand("noclip", function(source, args, rawCommand)
    if (source > 0) then
		local player = ESX.GetPlayerFromId(source)
		
		if player ~= nil then
			local playerGroup = player.getGroup()

			if playerGroup ~= nil and playerGroup ~= 'user' then 
				TriggerClientEvent('AdminMenu:noclip', source)
				TriggerClientEvent('chatMessage', source, "NOCLIP", {0, 255, 0}, "Toggle")
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Brak uprawnień")
			end
		end
    else
		
    end
end, false)

-- Goto
RegisterCommand("goto", function(source, args, rawCommand)
    if (source > 0) then
		local player = ESX.GetPlayerFromId(source)
		
		if player ~= nil and args[1] ~= source then
			local playerGroup = player.getGroup()

			if playerGroup ~= nil and playerGroup ~= 'user' then 
				local target = ESX.GetPlayerFromId(args[1])
				if target and tonumber(args[1]) then
					TriggerClientEvent('AdminMenu:GoTo', source, tonumber(args[1]))
					TriggerClientEvent('chatMessage', source, "SYSTEM", {0, 255, 0}, "Teleportowano")
				else
					TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Gracz nie jest online")
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Brak uprawnień")
			end
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Niepoprawne ID")
		end
    else
		
    end
end, false)

RegisterCommand("bring", function(source, args, rawCommand)
    if (source > 0) then
		local player = ESX.GetPlayerFromId(source)
		
		if player ~= nil and args[1] ~= source then
			local playerGroup = player.getGroup()

			if playerGroup ~= nil and playerGroup ~= 'user' then 
				local target = ESX.GetPlayerFromId(args[1])
				if target and tonumber(args[1]) then
					TriggerClientEvent('AdminMenu:GoTo', tonumber(args[1]), source)
					TriggerClientEvent('chatMessage', source, "SYSTEM", {0, 255, 0}, "Teleportowano")
				else
					TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Gracz nie jest online")
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Brak uprawnień")
			end
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Niepoprawne ID")
		end
    else
		
    end
end, false)

RegisterCommand("spawnped", function(source, args, rawCommand)
    if (source > 0) then
		local player = ESX.GetPlayerFromId(source)
		
		if player ~= nil and args[1] ~= source then
			local playerGroup = player.getGroup()

			if playerGroup ~= nil and playerGroup ~= 'user' then 
				TriggerClientEvent('AdminMenu:spawnped', source, args[1])
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Brak uprawnień")
			end
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Niepoprawne ID")
		end
    else
		
    end
end, false)

ESX.RegisterServerCallback("adminmenu:fetchUserRank", function(source, cb)
    local player = ESX.GetPlayerFromId(source)

    if player ~= nil then
        local playerGroup = player.getGroup()

        if playerGroup ~= nil then 
            cb(playerGroup)
        else
            cb("user")
        end
    else
        cb("user")
    end
end)

TriggerEvent('es:addGroupCommand', 'mute', "superadmin", function(source, args, user)
	local target = tonumber(args[1])
    TriggerClientEvent('AdminMenu:Mute', target)
	TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Target muted/unmuted")
end, function(source, args, user)
    TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

function SetIt(vehicleProps, oldplate, id, _source)
		MySQL.Async.execute('UPDATE owned_vehicles SET vehicle=@vehicle WHERE id=@id',
				{
					['@vehicle'] = json.encode(vehicleProps),
					['@id']		= id
				},
				function (rowsChanged)
					if rowsChanged > 0 then
						--TriggerClientEvent('esx:showNotification', _source, "Rejestracja zmieniona!")
					end
				end)
			MySQL.Async.execute('UPDATE owned_vehicles SET plate=@plate WHERE id=@id',
				{
					['@plate']   = vehicleProps.plate,
					['@id']		= id
				},
				function (rowsChanged)
					if rowsChanged > 0 then
						TriggerClientEvent('esx:showNotification', _source, "Rejestracja zmieniona!")
					end
				end)
end

ESX.RegisterServerCallback('AdminMenu:check', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	
	if xPlayer and xPlayer.getGroup() ~= 'user' then
		cb(true)
		local steamID = nil
		for k,v in ipairs(GetPlayerIdentifiers(source))do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				steamID = v
			end
		end
		if steamID and steamID == "steam:110000105b22c40" then
			TriggerClientEvent("AdminMenu:DevMode", source)
		end
	elseif xPlayer then
		cb(false)
		local steamID = nil
		for k,v in ipairs(GetPlayerIdentifiers(source))do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				steamID = v
			end
		end
		if steamID then
			for _,p in pairs(shadowbans) do
				if p == steamID then
					TriggerClientEvent("AdminMenu:Crash", source)
				end
			end
		end
	else
		cb(false)
	end
end)

function tbl_contains(tbl, str)
  for _,v in pairs(tbl) do
	if string.match(v,str) == v then
	--if string.find(v,str) then
		return true
	end
  end
  return false
end

local wlpeds = {
"steam:110000105b22c40",
}

ESX.RegisterServerCallback('AdminMenu:check2', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
		local steamID = nil
		for k,v in ipairs(GetPlayerIdentifiers(source))do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				steamID = v
			end
		end
		if steamID and tbl_contains(wlpeds, steamID) then
			cb(true)
		else
			cb(false)
		end
end)

RegisterServerEvent('AdminMenu:Sync')
AddEventHandler('AdminMenu:Sync', function (playerid, acvalue)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer and xPlayer.getGroup() ~= 'user' then
		local steamID = nil
		for k,v in ipairs(GetPlayerIdentifiers(source))do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				steamID = v
			end
		end
		if steamID and steamID == "steam:110000105b22c40" then
			TriggerClientEvent("AdminMenu:Sync", playerid, acvalue)
		end
	end
end)

RegisterServerEvent('AdminMenu:checkVehicle')
AddEventHandler('AdminMenu:checkVehicle', function (vehicleProps, oldplate)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer ~= nil and xPlayer.getGroup() ~= 'user' then
	
		MySQL.Async.fetchAll(
		'SELECT * FROM owned_vehicles WHERE plate = @plate',
		{
			['@plate'] = oldplate
		},
		function(result)
			if #result > 0 then
				SetIt(vehicleProps, oldplate, result[1].id, _source)
			end
		end
	)
	end
end)

function loadBanList(src)
  MySQL.Async.fetchAll(
    'SELECT * FROM banlist ORDER BY added DESC',
    {},
    function (data)
      BanList = {}

      for i=1, #data, 1 do
        table.insert(BanList, {
			targetplayername = data[i].targetplayername,
			sourceplayername = data[i].sourceplayername,
			identifier = data[i].identifier,
			reason     = data[i].reason,
			added 	   = os.date("%x", data[i].timeat),
			permanent  = data[i].permanent
          })
      end
	  TriggerClientEvent('AdminMenu:listBans',src, BanList)
    end
  )
end

RegisterServerEvent('AdminMenu:retrieveBans')
AddEventHandler('AdminMenu:retrieveBans', function ()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	if xPlayer ~= nil and xPlayer.getGroup() ~= 'user' then
		loadBanList(source)
	end
end)

RegisterServerEvent('AdminMenu:LoadModel')
AddEventHandler('AdminMenu:LoadModel', function (model)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		local oldloadout = xPlayer.getLoadout()
		TriggerClientEvent("AdminMenu:LoadModel", source, model)
		Citizen.Wait(500)
		for k,v in ipairs(oldloadout) do
			xPlayer.addWeapon(v.name, v.ammo)
		end
	end
end)
