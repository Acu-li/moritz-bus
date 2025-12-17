ESX = nil

showtext = true
point = ""
onRoute = false
destinationSelected = ""
pointKey = ""

local options ={}

-- Load ESX
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent(Config.ESXShared, function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

-- Add stations to options variable
Citizen.CreateThread(function()
    for index, value in pairs(Config.Locations) do
        table.insert(options, {label = value.Name, value = index})
    end
end)

-- Create "schedule" interaction markers (replaces 3D text)
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if showtext then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            for index, value in pairs(Config.Locations) do
                local dist = #(value.Schedule - coords)

                if dist <= (Config.Marker.DrawDistance or 15.0) then
                    DrawMarker(
                        Config.Marker.Type or 2,
                        value.Schedule.x, value.Schedule.y, value.Schedule.z + 0.15,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        (Config.Marker.Size and Config.Marker.Size.x) or 0.35,
                        (Config.Marker.Size and Config.Marker.Size.y) or 0.35,
                        (Config.Marker.Size and Config.Marker.Size.z) or 0.35,
                        255, 255, 255, 170,
                        false, true, 2, nil, nil, false
                    )
                end

                if dist <= (Config.Marker.InteractDistance or 1.6) then
                    ESX.ShowHelpNotification(_U("schedule"))
                    if IsControlJustReleased(0, 38) then
                        point = value
                        pointKey = index
                        showtext = false
                        openStationMenu()
                    end
                end
            end
        end
    end
end)

-- Create blips
Citizen.CreateThread(function()
	for index, value in pairs(Config.Locations) do
		local blip = AddBlipForCoord(value.Schedule)

		SetBlipSprite (blip, Config.BlipSprite)
		SetBlipDisplay(blip, 2)
		SetBlipScale  (blip, Config.BlipScale)
		SetBlipColour (blip, Config.BlipColour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		local brand = (Config.Branding and Config.BrandPreset and Config.Branding[Config.BrandPreset]) or { Short = "NBV" }
		AddTextComponentSubstringPlayerName((brand.Short .. " – " .. _U("blip")))
		EndTextCommandSetBlipName(blip)
	end
end)


---------------
-- Functions --
---------------

function openStationMenu()
    local brand = (Config.Branding and Config.BrandPreset and Config.Branding[Config.BrandPreset]) or { Short = "NBV", Long = "Neuberg Verkehrsbund" }

    local ctxId = ("%s_bus_%s"):format(GetCurrentResourceName(), tostring(pointKey))
    local ctxOptions = {}

    for _, opt in ipairs(options) do
        table.insert(ctxOptions, {
            title = opt.label,
            description = ("%s $%s"):format(brand.Short, tostring(Config.Locations[opt.value].Price)),
            onSelect = function()
                destinationSelected = opt.value
                local price = Config.Locations[destinationSelected].Price
                TriggerServerEvent('ikipm_bus:log', 'ticket_bought', pointKey, destinationSelected, price)
                createRoute(point.Departure, point.DepHead, Config.Locations[destinationSelected].Arrival, price)
                showtext = true
            end
        })
    end

    lib.registerContext({
        id = ctxId,
        title = ("%s – %s"):format(brand.Short, _U("menu_title")),
        options = ctxOptions,
        onExit = function()
            showtext = true
        end
    })

    lib.showContext(ctxId)
end

function createRoute(departure, point, destination, money)
    onRoute = true
    player = PlayerPedId()

    ESX.Game.SpawnVehicle(Config.Vehicle, departure, point, function(vehicle)
        TaskWarpPedIntoVehicle(player, vehicle, 0)
        SetVehicleDoorsLockedForAllPlayers(vehicle, true)

        -- Create NPC
        npc = CreatePed(vehicle, -1, Config.NPC)
        SetEntityInvincible(npc, true)
        SetDriverAbility(npc, 1.0)
        SetDriverAggressiveness(npc, 0.0)

        -- Drive to coords
        TaskVehicleDriveToCoordLongrange(npc, vehicle, destination.x, destination.y, destination.z, Config.Speed, 786603, 10.0)

        Citizen.CreateThread(function()
            while onRoute do
                Wait(5000)
                if #(destination - GetEntityCoords(player)) <= 15 and onRoute then
                    FinRoute(vehicle, npc, money, 'arrived')
                    ESX.ShowNotification(_U("success", money))
                elseif not IsPedInVehicle(player, vehicle, true) and onRoute then
                    FinRoute(vehicle, npc, money, 'left')
                    ESX.ShowNotification(_U("error", money))
                end
            end
        end)
    end)
end

function DrawText3D(x, y, z, text)
    	coords = vector3(x, y, z)
	SetTextScale(0.35, 0.35)
    	SetTextFont(4)
    	SetTextProportional(1)
    	SetTextColour(255, 255, 255, 215)
    	SetTextEntry("STRING")
	SetTextCentre(true)
    	AddTextComponentString(text)
    	SetDrawOrigin(x,y,z, 0)
    	DrawText(0.0, 0.0)
    	local factor = (string.len(text)) / 370
    	DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    	ClearDrawOrigin()
end

function CreatePed(vehicle, pos, model)
	local model = GetHashKey(model)

	if DoesEntityExist(vehicle) then
		if IsModelValid(model) then
			RequestModel(model)
			while not HasModelLoaded(model) do
				Wait(100)
			end

			local ped = CreatePedInsideVehicle(vehicle, 26, model, pos, true, false)
			SetBlockingOfNonTemporaryEvents(ped, true)
			SetEntityAsMissionEntity(ped, true, true)

			SetModelAsNoLongerNeeded(model)
			return ped
		end
	end
end

function FinRoute(vehicle, npc, money, result)
    onRoute = false

    DeletePed(npc)
    ESX.Game.DeleteVehicle(vehicle)
    TriggerServerEvent('ikipm_bus:getMoney', money, pointKey, destinationSelected, result or "unknown")
end
