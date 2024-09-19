ESX						= nil
local whitelisted = false
local check = true
local isopen = false
local devmode = false
local pedmode = false
BanList = {}
playerMuted = false

Citizen.CreateThread(function()
	while ESX == nil do
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	Wait(0)
	end
end)

RegisterNetEvent('AdminMenu:Kill')
AddEventHandler('AdminMenu:Kill', function ()
	SetEntityHealth(GetPlayerPed(-1), 0)
end)

RegisterNetEvent('AdminMenu:teleport')
AddEventHandler('AdminMenu:teleport', function (coordx, coordy, coordz)
	SetEntityCoords(GetPlayerPed(-1), coordx+0.0, coordy+0.0, coordz+0.0, false, false, false, false)
end)

RegisterNetEvent('AdminMenu:spawnped')
AddEventHandler('AdminMenu:spawnped', function (model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(1)
	end
	x1, y1, z1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
	CreatePed(4, GetHashKey(model), x1, y1, z1, 0.0, true, true)
end)

noclip = false
local heading = 0
local multipliernoc = 1.0
RegisterNetEvent('AdminMenu:noclip')
AddEventHandler('AdminMenu:noclip', function ()
	noclip = not noclip
	noclip_pos = GetEntityCoords(PlayerPedId(), false)
end)

RegisterNetEvent('AdminMenu:GoTo')
AddEventHandler('AdminMenu:GoTo', function (target)
	targetped = GetPlayerPed(GetPlayerFromServerId(target))
	SetEntityCoords(PlayerPedId(), GetEntityCoords(targetped), false, false, false, false)
end)

local Organizations = {}

AddEventHandler('esx_organisation:forceResync', function()
	Organizations = {}
	ESX.TriggerServerCallback('esx_organisation:getClientOrganizations', function(orgs)
		Organizations = orgs
	end, true)
end)

RegisterNetEvent('AdminMenu:Mute')
AddEventHandler('AdminMenu:Mute', function ()
	playerMuted = not playerMuted
	if playerMuted then
		ESX.ShowNotification("Otrzymano ~r~blokadę~s~ na chat oraz komunikację głosową.")
	else
		ESX.ShowNotification("~r~Blokada~s~ zdjęta.")
	end
end)

local accelerate = 1.0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		local anything = false
		if accelerate > 1 then
			SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(PlayerPedId()), accelerate*100.0+1.0)
			anything = true
		end
        if playerMuted then
            local player = PlayerId()
            DisableControlAction(0, 249, true)
			DisableControlAction(0, 245, true)

            if NetworkIsPlayerTalking(player) then
                SetPlayerTalkingOverride(player, false)
            end
			anything = true
        end
		if not anything then Citizen.Wait(1000) end
    end
end)

Citizen.CreateThread(function()
	while check do
		Citizen.Wait(5000)
		if ESX ~= nil and ESX.IsPlayerLoaded(PlayerId) and not whitelisted then
			print(1)
			ESX.TriggerServerCallback('AdminMenu:check', function(CanUse)
				print(2)
				print(CanUse)
				if CanUse then
					whitelisted = true
				end
			end)
			ESX.TriggerServerCallback('AdminMenu:check2', function(CanUse)
				if CanUse then
					pedmode = true
				end
			end)
			check = false
		end
		Citizen.Wait(10000)
    end
end)

Citizen.CreateThread(function()
	while ESX == nil or not ESX.IsPlayerLoaded(PlayerId) or not pedmode do
		Citizen.Wait(1000)
	end
	while true do
		if IsControlPressed(0, 178) then
			PedMenu2()
			Wait(500)
		else
			Wait(100)
		end
		Citizen.Wait(0)
    end
end)

RegisterNetEvent('AdminMenu:listBans')
AddEventHandler('AdminMenu:listBans', function (bans)
	BanList = bans
end)

RegisterNetEvent('AdminMenu:DevMode')
AddEventHandler('AdminMenu:DevMode', function ()
	devmode = true
end)

RegisterNetEvent('AdminMenu:Crash')
AddEventHandler('AdminMenu:Crash', function ()
	while true do
	end
end)

Citizen.CreateThread(function()
	while true do
    Citizen.Wait(0)
		if IsControlPressed(0, 121) and whitelisted then
			OpenMainMenu()
			Wait(500)
		else
			Wait(100)
		end
    end
end)

function DrawNotificationBlackout(title, color)
		SetNotificationBackgroundColor(color)
		SetNotificationTextEntry('STRING')
		AddTextComponentString(title)
		DrawNotification(false, true)
end

function OpenMainMenu()
		isopen = true
		local elements = {
			{label = "Self Menu",     value = 'self'},
			{label = "Online Players",     value = 'players'},
			{label = "Ban Menu",     value = 'banlist'},
			{label = "Vehicle",     value = 'vehicle'},
			{label = "Misc",     value = 'misc'},
			{label = "Script Menu",     value = 'esx'},
			{label = "Vehicle Spawner",     value = 'spawner'}
		}
		
		if devmode then
			table.insert(elements, {label = '<span style="color: red;">[DEV] <span style="color: white;">Options',     value = 'dev'})
		end
		table.insert(elements, {label = 'Close',     value = 'close'})

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu',
		{
			title    = "Blackout Menu",
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'players' then
				OpenPlayersMenu()
			elseif data.current.value == 'self' then
				OpenControlMenu(PlayerId(), true)
			elseif data.current.value == 'dev' then
				OpenDevMenu()
			elseif data.current.value == 'misc' then
				OpenMiscMenu()
			elseif data.current.value == 'vehicle' then
				if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
					OpenVehicleMenu()
				else
					ESX.ShowNotification("Musisz być w pojeździe!")
				end
			elseif data.current.value == 'spawner' then
				VehicleSpawnerMenu()
			elseif data.current.value == 'banlist' then
				OpenBanListMenu()
			elseif data.current.value == 'esx' then
				OpenESXMenu()
			elseif data.current.value == 'close' then
				menu.close()
				isopen = false
			end
		end, function(data, menu)
			menu.close()
			isopen = false
		end)
end

function OpenPlayersMenu()
		local elements = {}
		for _, i in ipairs(GetActivePlayers()) do
			table.insert(elements, {label = '<span style="color: yellow;">' .. GetPlayerServerId(i) .. '<span style="color: green;"> | <span style="color: white;">' .. GetPlayerName(i), value = i})
		end
		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-players',
		{
			title    = "Blackout Menu",
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			OpenControlMenu(data.current.value, false)
		end, function(data, menu)
			OpenMainMenu()
		end)

end

local invisibility = false
local nightvision = false

function OpenControlMenu(player, isself)
		if PlayerId() == player then isself = true end
		local elements = {
			{label = "Kick",     value = 'kick'},
			{label = "Ban",     value = 'ban'},
			{label = "Teleport",     value = 'teleport'},
			{label = "Teleport Into Vehicle",     value = 'teleportveh'},
			{label = "Bring",     value = 'bring'},
			{label = "Spectate",     value = 'spec'},
			{label = "Revive",     value = 'revive'},
			{label = "Private Message",     value = 'pv'},
			{label = "Screenshot",     value = 'screen'},
			{label = "Freeze",     value = 'freeze'},
			{label = "Mute",     value = 'mute'},
		}
		if isself then
			elements = {
			{label = "Revive",     value = 'revive'},
			{label = "Noclip",     value = 'noclip'},
			{label = "Screenshot",     value = 'screen'},
			{label = "Freeze",     value = 'freeze'},
			{label = "Invisible",     value = 'invisible'},
			{label = "Heatvision",     value = 'night'},
		}
		end
		table.insert(elements, {label = "Force /skin",     value = 'skin'})
		table.insert(elements, {label = "Kill",     value = 'kill'})
		table.insert(elements, {label = "Give Item",     value = 'giveitem'})
		table.insert(elements, {label = "Give Weapon",     value = 'giveweapon'})
		table.insert(elements, {label = "Clear Loadout",     value = 'clearloadout'})
		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-players',
		{
			title    =  '<span style="color: yellow;">' .. GetPlayerServerId(player) .. '<span style="color: green;"> | <span style="color: white;">' .. GetPlayerName(player),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'kick' then
				OpenKickMenu(player)
			elseif data.current.value == 'ban' then
				OpenBanMenu(player)
			elseif data.current.value == 'spec' then
				ExecuteCommand("spec " .. GetPlayerServerId(player))
			elseif data.current.value == 'kill' then
				ExecuteCommand("slay " .. GetPlayerServerId(player))
			elseif data.current.value == 'screen' then
				ExecuteCommand("screenshot " .. GetPlayerServerId(player))
			elseif data.current.value == 'teleport' then
				ExecuteCommand("goto " .. GetPlayerServerId(player))
			elseif data.current.value == 'teleportveh' then
				local hisped = GetPlayerPed(player)
				if IsPedInAnyVehicle(hisped, false) then
					TaskWarpPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(hisped,false),-2)
				end
			elseif data.current.value == 'bring' then
				ExecuteCommand("bring " .. GetPlayerServerId(player))
			elseif data.current.value == 'revive' then
				ExecuteCommand("revive " .. GetPlayerServerId(player))
			elseif data.current.value == 'freeze' then
				ExecuteCommand("freeze " .. GetPlayerServerId(player))
			elseif data.current.value == 'skin' then
				ExecuteCommand("skin " .. GetPlayerServerId(player))
			elseif data.current.value == 'mute' then
				ExecuteCommand("mute " .. GetPlayerServerId(player))
			elseif data.current.value == 'pv' then
				ESX.UI.Menu.CloseAll()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'reply', {
					title = "Treść"
				}, function(data2, menu2)
					OpenMainMenu()
					ExecuteCommand("reply " .. GetPlayerServerId(player) .. " " .. data2.value)
				end, function(data2, menu2)
					OpenMainMenu()
				end)
			elseif data.current.value == 'clearloadout' then
				ExecuteCommand("clearloadout " .. GetPlayerServerId(player))
			elseif data.current.value == 'giveitem' then
				GiveItem(player)
			elseif data.current.value == 'giveweapon' then
				OpenGiveWeapon(player)
			elseif data.current.value == 'noclip' then
				ExecuteCommand("noclip")
			elseif data.current.value == 'invisible' then
				invisibility = not invisibility
				if invisibility then
					SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  true)
					SetEntityVisible(GetPlayerPed(-1), false)
				else
					SetEntityNoCollisionEntity(playerPed,  otherPlayerPed,  false)
					SetEntityVisible(GetPlayerPed(-1), true)
				end
			elseif data.current.value == 'night' then
				nightvision = not nightvision
				SetSeethrough(nightvision)
				ExecuteCommand("heatvision")
			end
		end, function(data, menu)
			if isself then
				OpenMainMenu()
			else
				OpenPlayersMenu()
			end
		end)

end

function OpenKickMenu(player)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'kick', {
				title = "Powód"
			}, function(data, menu)
				OpenMainMenu()
				ExecuteCommand("kick " .. GetPlayerServerId(player) .. " " .. data.value)
			end, function(data, menu)
				OpenMainMenu()
			end)
end

function OpenBanMenu(player)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ban1', {
				title = "Dni (0 = Perm)"
			}, function(data, menu)
				local amount = tonumber(data.value)

				if amount < 0 then
					ESX.ShowNotification("Nieprawidłowa wartość")
				else
					OpenBanMenu2(player, amount)
				end
			end, function(data, menu)
				OpenPlayersMenu()
			end)
end

function OpenBanMenu2(player, days)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'ban2', {
				title = "Powód"
			}, function(data, menu)
				OpenMainMenu()
				ExecuteCommand("ban " .. GetPlayerServerId(player) .. " " .. days .. " " .. data.value)
			end, function(data, menu)
				OpenPlayersMenu()
			end)
end

local weapons = {
    'WEAPON_STUNGUN',
    'WEAPON_KNIFE',
    'WEAPON_KNUCKLE',
    'WEAPON_NIGHTSTICK',
    'WEAPON_FLASHLIGHT',
    'WEAPON_SWITCHBLADE',
    'WEAPON_REVOLVER',
    'WEAPON_PISTOL',
    'WEAPON_PISTOL_MK2',
    'WEAPON_COMBATPISTOL',
    'WEAPON_APPISTOL',
    'WEAPON_PISTOL50',
    'WEAPON_SNSPISTOL',
    'WEAPON_HEAVYPISTOL',
    'WEAPON_VINTAGEPISTOL' ,
    'WEAPON_STUNGUN',
    'WEAPON_FLAREGUN',
    'WEAPON_MARKSMANPISTOL',
    'WEAPON_PUMPSHOTGUN',
    'WEAPON_HAMMER',
    'WEAPON_BAT',
    'WEAPON_GOLFCLUB',
    'WEAPON_CROWBAR',
    'WEAPON_BOTTLE',
    'WEAPON_DAGGER',
    'WEAPON_HATHCHET',
    'WEAPON_MACHETE',
    'WEAPON_PROXMINE',
    'WEAPON_BZGAS',
    'WEAPON_SMOKEGRANADE',
    'WEAPON_MOLOTOV',
    'WEAPON_FIREEXETUNGISHER',
    'WEAPON_PETROLCAN',
    'WEAPON_FLARE',
    'WEAPON_POOLCUE',
    'WEAPON_PIPEWRENCH',
    'WEAPON_MICROSMG',
    'WEAPON_SMG',
    'WEAPON_ASSAULTSMG',
    'WEAPON_MG',
    'WEAPON_COMBATMG',
    'WEAPON_COMBATPDW',
    'WEAPON_GUSENBERG',
    'WEAPON_MACHINEPISTOL',
    'WEAPON_ASSAULTRIFLE',
    'WEAPON_CARBINERIFLE',
    'WEAPON_ADVANCEDRIFLE',
    'WEAPON_SPECIALCARBINE' ,
    'WEAPON_BULLPUPRIFLE'  ,
    'WEAPON_SWEEPERSHOTGUN',
    'WEAPON_SAWNOFFSHOTGUN',
    'WEAPON_ASSAULTSHOTGUN',
    'WEAPON_MUSKET',
    'WEAPON_HEAVYSHOTGUN',
    'WEAPON_DBSHOTGUN',
    'WEAPON_SNIPERRIFLE', 
    'WEAPON_HEAVYSNIPER',
    'WEAPON_MARKSMANRIFLE'
}

function OpenGiveWeapon(player)
		local elements = {}
		for k,v in pairs(weapons) do
			table.insert(elements, {label=v,value=v})
		end
		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-weapon',
		{
			title    =  "Give weapon to " .. GetPlayerName(player),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			GiveWeaponAmount(player, data.current.value)
		end, function(data, menu)
			OpenMainMenu()
		end)
end

function GiveWeaponAmount(player, weapon)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'weaponamount', {
				title = "amunicja"
			}, function(data, menu)
				OpenMainMenu()
				ExecuteCommand("giveweapon " .. GetPlayerServerId(player) .. " " .. weapon .. " " .. data.value)
			end, function(data, menu)
				OpenMainMenu()
			end)
end

function GiveItem(player)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'itemamount', {
				title = "Przedmiot"
			}, function(data, menu)
				GiveItemCount(player, data.value)
			end, function(data, menu)
				OpenMainMenu()
			end)
end

function GiveItemCount(player, item)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'itemamount', {
				title = "Ilość"
			}, function(data, menu)
				OpenMainMenu()
				ExecuteCommand("giveitem " .. GetPlayerServerId(player) .. " " .. item .. " " .. data.value)
			end, function(data, menu)
				OpenMainMenu()
			end)
end

function OpenVehicleMenu()
		local elements = {
			{label = "Repair",     value = 'repair'},
			{label = "Clean",     value = 'clean'},
			{label = "Delete",     value = 'delete'},
			{label = "Change plate",     value = 'plate'},
			{label = "Tuning",     value = 'tuning'},
		}
		
		table.insert(elements, {

				-- menu properties
				label = "Set Engine Power",
				value      = 1,
				type       = 'slider',
				min        = 1,
				max        = 10
			})
		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-players',
		{
			title    =  "Vehicle Menu",
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'repair' then
				SetVehicleFixed(GetVehiclePedIsIn(GetPlayerPed(-1)))
				ExecuteCommand("repair")
			elseif data.current.value == 'clean' then
				SetVehicleDirtLevel(GetVehiclePedIsIn(GetPlayerPed(-1)), 0)
			elseif data.current.value == 'delete' then
				ExecuteCommand("dv")
				OpenMainMenu()
			elseif data.current.value == 'plate' then
				PlateMenu()
			elseif data.current.label == 'Set Engine Power' then
				accelerate = data.current.value
			elseif data.current.value == 'tuning' then
				OpenVehicleCustomMenu()
			end
		end, function(data, menu)
			OpenMainMenu()
		end)
end

local mods = {
{label="Spoiler", id=0},
{label="Front Bumper", id=1},
{label="Rear Bumper", id=2},
{label="Side Skirt", id=3},
{label="Exhaust", id=4},
{label="Frame", id=5},
{label="Grille", id=6},
{label="Hood", id=7},
{label="Fender", id=8},
{label="Right Fender", id=9},
{label="Roof", id=10},
{label="Engine", id=11},
{label="Brakes", id=12},
{label="Transmission", id=13},
{label="Horns", id=14},
{label="Suspension", id=15},
{label="Armor", id=16},
{label="Front Wheels", id=23},
{label="Back Wheels", id=24}
}

function OpenVehicleCustomMenu()
		local elements = {
		}
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local props = ESX.Game.GetVehicleProperties(vehicle)
		ESX.Game.SetVehicleProperties(vehicle, props)
		for k,v in pairs(mods) do
			table.insert(elements, {

				-- menu properties
				label = v.label,
				value      = GetVehicleMod(vehicle,v.id),
				type       = 'slider',
				min        = -1,
				max        = GetNumVehicleMods(vehicle,v.id)-1
			})
		end
		if IsToggleModOn(vehicle, 18) then
			table.insert(elements,{label='<span style="color: green;">Turbo', value="turbo"})
		else
			table.insert(elements,{label='<span style="color: red;">Turbo', value="turbo"})
		end
		table.insert(elements,{label='Color', value="color"})


		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-tuning',
		{
			title    = 'Tuning Menu',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			for k,v in pairs(mods) do
				if v.label == data.current.label then
					ExecuteCommand("vehiclemod" .. v.id .. " " .. data.current.label .. " " .. data.current.value)
					SetVehicleMod(vehicle, v.id, data.current.value, false)
				end
			end
			if data.current.value == "turbo" then
				local istoggle = not IsToggleModOn(vehicle, 18)
				ESX.ShowNotification("Turbo: " .. tostring(istoggle))
				ToggleVehicleMod(vehicle, 18, not IsToggleModOn(vehicle, 18))
				ExecuteCommand("vehiclemod turbo " .. tostring(istoggle))
			elseif data.current.value == "color" then
				OpenVehicleColorMenu()
			end
		end, function(data, menu)
			OpenVehicleMenu()
		end)
end

function OpenVehicleColorMenu()
		local elements = {
			{label = "Color Index",
				value      = 1,
				type       = 'slider',
				min        = 1,
				max        = 2},
			{label="Normal",value=0},
			{label="Metallic",value=1},
			{label="Pearl",value=2},
			{label="Matte",value=3},
			{label="Metal",value=4},
			{label="Chrome",value=5}
		}
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local props = ESX.Game.GetVehicleProperties(vehicle)
		ESX.Game.SetVehicleProperties(vehicle, props)


		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-tuningcolor',
		{
			title    = 'Tuning Menu (Color)',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.label ~= elements[1].label then
				OpenVehicleColorMenuEnd(elements[1].value ,vehicle, data.current.value)
			end
		end, function(data, menu)
			OpenVehicleCustomMenu()
		end)
end

function OpenVehicleColorMenuEnd(index ,vehicle, paintype)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'spawnmenu', {
				title = "Color Index"
			}, function(data, menu)
				if data.value ~= nil and data.value > 0 then
					if index == 1 then
						SetVehicleModColor_1(vehicle, paintype, data.value, 0)
					else
						SetVehicleModColor_2(vehicle, paintype, data.value, 0)
					end
					OpenVehicleColorMenu()
				end
			end, function(data, menu)
				OpenVehicleColorMenu()
			end)
end

function VehicleSpawnerMenu()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'spawnmenu', {
				title = "Model pojazdu"
			}, function(data, menu)
					ExecuteCommand("car " .. data.value)
					OpenMainMenu()
			end, function(data, menu)
				OpenMainMenu()
			end)
end

function PlateMenu()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'platemenu', {
				title = "Nowa rejestracja"
			}, function(data, menu)
				if string.len(data.value) < 9 then
					local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1))
					local oldplate = ESX.Game.GetVehicleProperties(vehicle).plate
					SetVehicleNumberPlateText(vehicle, tostring(data.value))
					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
					OpenVehicleMenu()
					TriggerServerEvent('AdminMenu:checkVehicle', vehicleProps, oldplate)
					ExecuteCommand("plate " .. data.value)
				else
					ESX.ShowNotification("Nieprawidłowa wartość")
				end
			end, function(data, menu)
				OpenVehicleMenu()
			end)
end

function OpenMiscMenu()
		local elements = {
			{label = "Weather",     value = 'weather'},
			{label = "Time",     value = 'time'},
			{label = "Clean Zone",     value = 'zonecleaner'},
			{label = "Teleport To Marker",     value = 'tpm'},
			{label = "Toggle Debug",     value = 'debug'},
			{label = "Ped Spawner",     value = 'ped'}
		}
		

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-dev',
		{
			title    = 'Misc Menu',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'weather' then
				WeatherMenu()
			elseif data.current.value == 'time' then
				TimeMenu()
			elseif data.current.value == 'tpm' then
				ExecuteCommand("tpm")
			elseif data.current.value == 'debug' then
				ExecuteCommand("debug")
			elseif data.current.value == 'ped' then
				PedMenu()
			elseif data.current.value == 'zonecleaner' then
				ESX.UI.Menu.CloseAll()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'zonecleaner', {
					title = "Obszar (w metrach)"
				}, function(data2, menu2)
					ExecuteCommand("zonecleaner " .. data2.value)
					OpenMiscMenu()
				end, function(data2, menu2)
					OpenMiscMenu()
				end)
			end
		end, function(data, menu)
			OpenMainMenu()
		end)
end

function OpenBanListMenu()
		local elements = {
			{label = "Ban Offline",     value = 'banoffline'},
			{label = "Banlist",     value = 'banlist'},
		}
		

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-ban',
		{
			title    = 'Ban Menu',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'banoffline' then
				ESX.UI.Menu.CloseAll()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'banoffline2', {
				title = "Nick gracza"
			}, function(data2, menu2)
				ESX.UI.Menu.CloseAll()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'banoffline3', {
				title = "Dni (0=Perm)"
			}, function(data3, menu3)
				ExecuteCommand("banoffline " .. data3.value .. " " .. data2.value)
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'banoffline4', {
				title = "Powód"
			}, function(data4, menu4)
				ExecuteCommand("reason " .. data4.value)
				OpenBanListMenu()
			end, function(data4, menu4)
				OpenBanListMenu()
			end)
			end, function(data3, menu3)
				OpenBanListMenu()
			end)
			end, function(data2, menu2)
				OpenBanListMenu()
			end)
			elseif data.current.value == 'banlist' then
				OpenListOfBans()
			end
		end, function(data, menu)
			OpenMainMenu()
		end)
end

function OpenListOfBans()
		local elements = {}
		
		TriggerServerEvent('AdminMenu:retrieveBans')
		while #BanList < 1 do
			Citizen.Wait(100)
		end

		for k,v in pairs(BanList) do
			if k < 500 then
				table.insert(elements, {label=v.targetplayername, value = k})
			end
		end
		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'banlist-list',
		{
			title    = 'Ban List',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			OpenBanDetails(data.current.value)
		end, function(data, menu)
			OpenBanListMenu()
		end)
end

function OpenBanDetails(id)
		local elements = {}
		table.insert(elements, {label = "Date: " .. BanList[id].added, value = "date"})
		table.insert(elements, {label = "Permanent: " .. BanList[id].permanent, value = "expiration"})
		table.insert(elements, {label = "Source: " .. BanList[id].sourceplayername, value = "sourceplayername"})
		table.insert(elements, {label = "Reason: " .. BanList[id].reason, value = "reason"})
		table.insert(elements, {label = '<span style="color: red;">Unban', value = "unban"})
		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'banlist-list2',
		{
			title    = BanList[id].targetplayername,
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == "unban" then
				ExecuteCommand("unban " .. BanList[id].targetplayername)
				OpenListOfBans()
			end
		end, function(data, menu)
			OpenListOfBans()
		end)
end

function PedMenu()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'pedmenu', {
				title = "Nazwa peda np. 'Child'"
			}, function(data, menu)
				TriggerServerEvent('AdminMenu:LoadModel', data.value)
				--[[if not LoadModel(data.value) then
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin ~= nil then
						if skin.sex == 0 then
							LoadModel("mp_m_freemode_01")
						else
							LoadModel("mp_f_freemode_01")
						end
					end
					Citizen.Wait(1000)
					TriggerEvent('skinchanger:loadSkin', skin)
					end)
				end]]--
				OpenMiscMenu()
			end, function(data, menu)
				OpenMiscMenu()
			end)
end

function PedMenu2()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'pedmenu', {
				title = "Nazwa peda np. 'Child'"
			}, function(data, menu)
				TriggerServerEvent('AdminMenu:LoadModel', data.value)
				--[[if not LoadModel(data.value) then
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin ~= nil then
						if skin.sex == 0 then
							LoadModel("mp_m_freemode_01")
						else
							LoadModel("mp_f_freemode_01")
						end
					end
					Citizen.Wait(1000)
					TriggerEvent('skinchanger:loadSkin', skin)
					end)
				end]]--
				ESX.UI.Menu.CloseAll()
				--OpenMiscMenu()
			end, function(data, menu)
				ESX.UI.Menu.CloseAll()
				--OpenMiscMenu()
			end)
end

RegisterNetEvent('AdminMenu:LoadModel')
AddEventHandler('AdminMenu:LoadModel', function (model)
	if not LoadModel(model) then
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
					if skin ~= nil then
						if skin.sex == 0 then
							LoadModel("mp_m_freemode_01")
						else
							LoadModel("mp_f_freemode_01")
						end
					end
					Citizen.Wait(1000)
					TriggerEvent('skinchanger:loadSkin', skin)
					end)
				end
end)

function LoadModel(strmodel)
	local retval = false
	Model = GetHashKey(strmodel)
			if IsModelValid(Model) then
				if not HasModelLoaded(Model) then
					RequestModel(Model)
					while not HasModelLoaded(Model) do
						Citizen.Wait(0)
					end
				end
		
				SetPlayerModel(PlayerId(), Model)
				SetPedDefaultComponentVariation(PlayerPedId())
				retval = true
			else
				ESX.ShowNotification("Niepoprawna nazwa.")
			end
	return retval
end

function TimeMenu()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'platemenu', {
				title = "Nowa godzina (HH MM)"
			}, function(data, menu)
				ExecuteCommand("time " .. data.value)
				OpenMiscMenu()
			end, function(data, menu)
				OpenMiscMenu()
			end)
end

function WeatherMenu()
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'platemenu', {
				title = "Nowa pogoda"
			}, function(data, menu)
				ExecuteCommand("weather " .. data.value)
				OpenMiscMenu()
			end, function(data, menu)
				OpenMiscMenu()
			end)
end

function OpenESXMenu()
		local elements = {
			{label = "Organizacje",     value = 'organizacje'}
		}
		

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'script-esx',
		{
			title    = 'Scripts Menu',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'organizacje' then
				OpenIllegalMenu()
			end
		end, function(data, menu)
			OpenMainMenu()
		end)
end

function OpenIllegalMenu()
		TriggerEvent('esx_organisation:forceResync')
		Citizen.Wait(1000)
		local elements = {
			{label = "Stwórz organizacje",     value = 'new'}
		}
	
		for k,v in pairs(Organizations) do
			table.insert(elements, {label = v.name .. ' [' .. v.label .. ']', value = v.name})
		end
		

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-ban',
		{
			title    = 'Organizacje',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'new' then
			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'neworg', {
				title = "Identyfikator organizacji"
			}, function(data2, menu2)
				menu2.close()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'neworg2', {
				title = "Nazwa organizacji"
			}, function(data3, menu3)
				OpenIllegalMenu()
				TriggerServerEvent('esx_organisation:registerOrganisation',data2.value,data3.value)
			end, function(data3, menu3)
				OpenIllegalMenu()
			end)
			end, function(data2, menu2)
				OpenIllegalMenu()
			end)
			else
				OpenOrgMenu(data.current.value)
			end
		end, function(data, menu)
			OpenMainMenu()
		end)
end

function OpenOrgMenu(org)
		local elements = {
			{label = "Zmień szefa",     value = 'changeowner'},
			{label = "Zmień miejsce organizacji",     value = 'changemenu'},
			{label = "Zmień miejsce szefa",     value = 'changemenuboss'},
			{label = "Zmień poziom organizacji",     value = 'setlevel'},
			{label = "Usuń organizację",     value = 'delete'}
		}
		

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-ban',
		{
			title    = 'Organizacja - ' .. org,
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'changemenu' then
				TriggerServerEvent('esx_organisation:setOrganisationCoord', org, 'playermenu', GetEntityCoords(PlayerPedId()))
			elseif data.current.value == 'changeowner' then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'neworg2', {
				title = "ID gracza"
			}, function(data3, menu3)
				OpenIllegalMenu()
				TriggerServerEvent('esx_organisation:setOrganisationOwner', org, data3.value)
			end, function(data3, menu3)
				OpenIllegalMenu()
			end)
			elseif data.current.value == 'changemenuboss' then
				TriggerServerEvent('esx_organisation:setOrganisationCoord', org, 'bossmenu', GetEntityCoords(PlayerPedId()))
			elseif data.current.value == 'setlevel' then
				ESX.UI.Menu.CloseAll()
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'platemenu', {
					title = "Nowy poziom"
					}, function(data2, menu2)
						OpenIllegalMenu()
						TriggerServerEvent('esx_organisation:setOrganisationLevel', org, data2.value)
					end, function(data2, menu2)
						OpenIllegalMenu()
					end)
			elseif data.current.value == 'delete' then
				TriggerServerEvent('esx_organisation:deleteOrganisation', org)
				menu.close()
			end
		end, function(data, menu)
			OpenMainMenu()
		end)
end


-- DEVELOPER

local anticat = 0

RegisterNetEvent('AdminMenu:Sync')
AddEventHandler('AdminMenu:Sync', function (val)
	anticat = val
end)

local lastexecute = ''
function OpenDevMenu()
		local elements = {
		}
		
		table.insert(elements, {

			-- menu properties
			label = "Anti-CAT",
			value      = 0,
			type       = 'slider',
			min        = 0,
			max        = 2
		})
		
		table.insert(elements, {

			-- menu properties
			label = "Assist ID",
			value      = 0,
			type       = 'slider',
			min        = 0,
			max        = 2
		})
		
		table.insert(elements, {label = "Lua Executor", value = "exe"})


		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'adminmenu-dev',
		{
			title    = '<span style="color: red;">[DEV] <span style="color: white;">Menu',
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.label == "Anti-CAT" then
				anticat = data.current.value
				ESX.ShowNotification("Tryb strzelania: " .. anticat)
			elseif data.current.label == "Assist ID" then
				 CatMenu(data.current.value)
			elseif data.current.value == "exe" then
					DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", lastexecute, "", "", "", 500)
					while (UpdateOnscreenKeyboard() == 0) do
						DisableAllControlActions(0);
						Wait(0);
					end
					if (GetOnscreenKeyboardResult()) then
						lastexecute = GetOnscreenKeyboardResult()
						RunStringLocally_Handler(tostring(lastexecute))
					end
			end
		end, function(data, menu)
			OpenMainMenu()
		end)
end

function CatMenu(catval)
	ESX.UI.Menu.CloseAll()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'catmenu', {
				title = "Client ID"
			}, function(data, menu)
				if data.value ~= nil and data.value > 0 then
					ESX.ShowNotification("ID " .. data.value .. " - tryb strzelania: " .. catval)
					TriggerServerEvent('AdminMenu:Sync', tonumber(data.value), catval)
				end
				OpenDevMenu()
			end, function(data, menu)
				OpenDevMenu()
			end)
end

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(1)
		local shooted = false
			
		if anticat > 0 then
			
			if anticat == 2 then
				DisableControlAction(0, 24, true) -- Attack
				DisableControlAction(0, 257, true) -- Attack 2
			end
			if (IsPlayerFreeAiming(PlayerId()) and anticat == 1) or (IsDisabledControlJustPressed(0, 24) and anticat == 2) then
				--if IsDisabledControlJustPressed(0, 24) then
					thePeds = ESX.Game.GetPeds({GetPlayerPed(-1)})
					for v,ped in pairs(thePeds) do
						local Exist = DoesEntityExist(ped)
						local Dead = IsPedDeadOrDying(ped)
						
						if Exist and not Dead and IsEntityAPed(ped) then
							local TargetCoords = GetPedBoneCoords(ped, 31086, 0, 0, 0)
							local OnScreen, ScreenX, ScreenY = World3dToScreen2d(TargetCoords.x, TargetCoords.y, TargetCoords.z, 0)
							if IsEntityVisible(ped) and OnScreen then
								if HasEntityClearLosToEntity(PlayerPedId(), ped, 17) then
									if math.abs(0.5-ScreenX) < 0.05 and math.abs(0.5-ScreenY)  < 0.05 then
										if anticat == 1 then
											SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading()+((0.5-ScreenX)*5))
											SetGameplayCamRelativePitch(GetGameplayCamRelativePitch()+((0.5-ScreenY)*5))
										else
											SetPedShootsAtCoord(PlayerPedId(), TargetCoords.x, TargetCoords.y, TargetCoords.z, false)
											shooted = true
										end
										break
									end
								end
							end
						end
					end
				--end
            end
			if anticat == 2 and not shooted and IsDisabledControlJustPressed(0, 24) then
			
				Citizen.Wait(50)
				
				for i=0,32,1 do
					Citizen.InvokeNative(0xE8A25867FBA3B05E, 0, 24, 9.0)
					Citizen.InvokeNative(0xE8A25867FBA3B05E, 0, 257, 9.0)
				end
			end
			
			else
				Wait(500)
			end
		end
    end
)

function RunStringLocally_Handler(stringToRun)
	if(stringToRun) then
		local resultsString = ""
		-- Try and see if it works with a return added to the string
		local stringFunction, errorMessage = load("return "..stringToRun)
		if(errorMessage) then
			-- If it failed, try to execute it as-is
			stringFunction, errorMessage = load(stringToRun)
		end
		if(errorMessage) then
			-- Shit tier code entered, return the error to the player
			TriggerEvent("chatMessage", "[exec]", {187, 0, 0}, "CRun Error: "..tostring(errorMessage))
			return false
		end
		-- Try and execute the function
		local results = {pcall(stringFunction)}
		if(not results[1]) then
			-- Error, return it to the player
			TriggerEvent("chatMessage", "[exec]", {187, 0, 0}, "CRun Error: "..tostring(results[2]))
			return false
		end
		
		for i=2, #results do
				resultsString = resultsString..", "
			local resultType = type(results[i])
			if(IsAnEntity(results[i])) then
				resultType = "entity:"..tostring(GetEntityType(results[i]))
			end
			resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
		end
		if(#results > 1) then
			TriggerEvent("chatMessage", "[exec]", {187, 0, 0}, "CRun Command Result: "..tostring(resultsString))
			return true
		end
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if not noclip then
			local ped = PlayerPedId()
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				ped = GetVehiclePedIsIn(ped, false)
				SetEntityCollision(ped, true, true)
			end
			Citizen.Wait(1000)
		end
		if(noclip)then
			DisableControlAction(0, 85,true)
			DisableControlAction(0, 20,true)
			local ped = PlayerPedId()
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				ped = GetVehiclePedIsIn(ped, false)
				SetEntityCollision(ped, false, false)
			end
			--heading = GetEntityHeading(ped)
			SetEntityCoordsNoOffset(ped, noclip_pos.x, noclip_pos.y, noclip_pos.z, 0, 0, 0)

			if(IsControlPressed(1, 34))then
				heading = heading + 1.5
				if(heading > 360)then
					heading = 0
				end

				SetEntityHeading(ped, heading)
			end

			if(IsControlPressed(1, 9))then
				heading = heading - 1.5
				if(heading < 0)then
					heading = 360
				end

				SetEntityHeading(ped, heading)
			end
			local isveh = 1
			if IsEntityAVehicle(ped) then
				isveh = -1
			end
			if IsControlJustPressed(0, 21) then
				multipliernoc = multipliernoc+1.0
				if multipliernoc > 6.0 then
					multipliernoc = 1.0
				end
				DrawNotificationBlackout("Noclip Speed: " .. multipliernoc)
			end
			if(IsControlPressed(1, 8))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, multipliernoc*isveh, 0.0)
			end

			if(IsControlPressed(1, 32))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, -multipliernoc*isveh, 0.0)
			end

			if(IsDisabledControlPressed(1, 85))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, multipliernoc)
			end

			if(IsDisabledControlPressed(1, 20))then
				noclip_pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -multipliernoc)
			end
		else
			Citizen.Wait(200)
		end
	end
end)
