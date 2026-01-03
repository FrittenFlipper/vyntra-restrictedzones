local activeBlips = {}
local activeRadiusBlips = {}

local blips = {}
local radiusBlips = {}

local options = {
    { label = "Create Restricted Zone", value = "create_zone" },
    { label = "View Restricted Zones",  value = "view_zones" },
}

local sub_options = {
    { label = "Yes", value = "yes_delete" },
    { label = "No",  value = "no_delete" },
}

local noZonesOptions = {
    { label = "No active restricted zones", value = "get_back" },
}

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    Wait(1000)

    TriggerEvent("vyntra-restrictedzones:client:refreshBlips")
end)

-- Automatisches Laden wenn der Spieler dem Server beitritt (Join/Spawn)
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    -- Kurze Wartezeit, um sicherzustellen, dass der Charakter geladen ist
    Wait(2000)
    TriggerEvent("vyntra-restrictedzones:client:refreshBlips")
end)

RegisterNetEvent("vyntra-restrictedzones:client:openMenu")
AddEventHandler("vyntra-restrictedzones:client:openMenu", function()
    openMenu()
end)

RegisterNetEvent("vyntra-restrictedzones:client:refreshBlips")
AddEventHandler("vyntra-restrictedzones:client:refreshBlips", function()
    Wait(1000)

    ESX.TriggerServerCallback("vyntra-restrictedzones:server:getActiveZones", function(zoneData)
        if zoneData then
            activeBlips = {}
            activeRadiusBlips = {}

            -- Daten vorbereiten
            for i = 1, #zoneData, 1 do
                table.insert(activeBlips, {
                    z  = zoneData[i].z,
                    y  = zoneData[i].y,
                    x  = zoneData[i].x,
                    id = zoneData[i].id,
                })
            end

            for i = 1, #zoneData, 1 do
                table.insert(activeRadiusBlips, {
                    radius      = zoneData[i].radius,
                    z           = zoneData[i].z,
                    y           = zoneData[i].y,
                    x           = zoneData[i].x,
                    description = zoneData[i].description,
                    title       = zoneData[i].title,
                    id          = zoneData[i].id,
                })
            end

            -- Alte Blips entfernen und neue setzen
            for index, entry in pairs(activeRadiusBlips) do
                -- Sicherstellen, dass alte Blips weg sind, bevor neue kommen
                if radiusBlips["radiusBlip" .. entry.id] then RemoveBlip(radiusBlips["radiusBlip" .. entry.id]) end
                if blips["blip" .. entry.id] then RemoveBlip(blips["blip" .. entry.id]) end

                local formattedRadius                 = entry.radius + .0
                radiusBlips["radiusBlip" .. entry.id] = AddBlipForRadius(tonumber(entry.x), tonumber(entry.y),
                    tonumber(entry.z), formattedRadius)
                blips["blip" .. entry.id]             = AddBlipForCoord(tonumber(entry.x), tonumber(entry.y),
                    tonumber(entry.z))

                SetBlipColour(radiusBlips["radiusBlip" .. entry.id], 1)
                SetBlipAlpha(radiusBlips["radiusBlip" .. entry.id], 128)

                SetBlipSprite(blips["blip" .. entry.id], 60)
                SetBlipColour(blips["blip" .. entry.id], 1)
                SetBlipDisplay(blips["blip" .. entry.id], 4)
                SetBlipScale(blips["blip" .. entry.id], 1.0)
                SetBlipAsShortRange(blips["blip" .. entry.id], true)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Restricted Zone")
                EndTextCommandSetBlipName(blips["blip" .. entry.id])
            end
        end
    end)
end)

RegisterNetEvent("vyntra-restrictedzones:client:deleteZone")
AddEventHandler("vyntra-restrictedzones:client:deleteZone", function(id)
    -- Bereinigen der lokalen Tabellen und Blips
    for k, entry in pairs(activeBlips) do
        if id == entry.id then
            if blips["blip" .. entry.id] then
                RemoveBlip(blips["blip" .. entry.id])
                blips["blip" .. entry.id] = nil
            end
            table.remove(activeBlips, k)
        end
    end

    for k, entry in pairs(activeRadiusBlips) do
        if id == entry.id then
            if radiusBlips["radiusBlip" .. entry.id] then
                RemoveBlip(radiusBlips["radiusBlip" .. entry.id])
                radiusBlips["radiusBlip" .. entry.id] = nil
            end
            table.remove(activeRadiusBlips, k)
        end
    end
end)

RegisterNetEvent("vyntra-restrictedzones:client:sendNotification")
AddEventHandler("vyntra-restrictedzones:client:sendNotification", function(description)
    local playerPed                    = PlayerPedId()
    local coords                       = GetEntityCoords(playerPed)
    local streetHash, crossingRoadHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName                   = GetStreetNameFromHashKey(streetHash)

    showPictureNotification("CHAR_CALL911", "Restricted Zone", "Attention",
        description .. ". The restricted zone is located at ~y~" .. streetName .. "~w~.")
end)

function openMenu()
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), 'main_menu', {
        title = "Restricted Zone Menu",
        align = "left",
        elements = options
    }, function(data, menu)
        if data.current.value == "create_zone" then
            menu.close()

            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'sub_dialog', {
                title = "Enter Title"
            }, function(data2, menu2)
                menu2.close()

                local title = data2.value

                if title == nil then
                    ESX.ShowNotification("You must specify a title!")
                else
                    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'sub_dialog2', {
                        title = "Enter Description"
                    }, function(data3, menu3)
                        menu3.close()

                        local description = data3.value

                        if description == nil then
                            ESX.ShowNotification("You must specify a description!")
                        else
                            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'sub_dialog3', {
                                title = "Enter Radius (1-500)"
                            }, function(data4, menu4)
                                menu4.close()

                                local range = tonumber(data4.value)

                                -- Input Validation
                                if range == nil then
                                    ESX.ShowNotification("You must specify a valid number for the radius!")
                                elseif range < 1 or range > 500 then
                                    ESX.ShowNotification("Radius must be between 1 and 500!")
                                elseif range % 1 ~= 0 then
                                    ESX.ShowNotification("Radius must be a whole number!")
                                else
                                    local formattedRange = range + .0
                                    local playerPed = PlayerPedId()
                                    local playerCoords = GetEntityCoords(playerPed)
                                    local x, y, z = playerCoords.x, playerCoords.y, playerCoords.z

                                    TriggerServerEvent('vyntra-restrictedzones:server:insertZone', title, description, x,
                                        y, z,
                                        range)
                                    TriggerServerEvent("vyntra-restrictedzones:server:refreshBlips")
                                    TriggerServerEvent("vyntra-restrictedzones:server:sendNotification", description)

                                    ESX.UI.Menu.CloseAll()
                                end
                            end, function(data4, menu4)
                                menu4.close()
                            end)
                        end
                    end, function(data3, menu3)
                        menu3.close()
                    end)
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        elseif data.current.value == "view_zones" then
            ESX.TriggerServerCallback("vyntra-restrictedzones:server:getActiveZones", function(zoneData)
                if zoneData == nil then -- No zones found
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "no_zones_menu", {
                        title = "Active Restricted Zones",
                        align = "left",
                        elements = noZonesOptions,
                    }, function(data, menu)
                        menu.close()

                        if data.current.value == "get_back" then
                            menu.close()
                        end
                    end, function(data, menu)
                        menu.close()
                    end)
                elseif zoneData ~= nil then -- Zones found
                    local activeZones = {}

                    for index, zone in pairs(zoneData) do
                        table.insert(activeZones,
                            {
                                id = zone.id,
                                label = (zone.title .. " | " .. zone.radius .. " Meters"),
                                value =
                                "view_zone"
                            })
                    end

                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "active_zones_menu", {
                        title = "Active Restricted Zones",
                        align = "left",
                        elements = activeZones,
                    }, function(data, menu)
                        if data.current.value == "view_zone" then
                            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "view_zone", {
                                title = "Delete Restricted Zone?",
                                align = "left",
                                elements = sub_options,
                            }, function(data2, menu2)
                                if data2.current.value == "yes_delete" then
                                    -- Korrektur: Keine Schleife über alle Zonen, nur die ausgewählte ID löschen
                                    local id = data.current.id

                                    TriggerServerEvent("vyntra-restrictedzones:server:deleteZone", id)
                                    ESX.ShowNotification("Restricted Zone deleted.")

                                    -- Schließt alle Menüs, damit man nicht in einer alten Liste hängt
                                    ESX.UI.Menu.CloseAll()
                                elseif data2.current.value == "no_delete" then
                                    menu2.close()
                                end
                            end, function(data2, menu2)
                                menu2.close()
                            end)
                        end
                    end, function(data, menu)
                        menu.close()
                    end)
                end
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function showPictureNotification(icon, title, subtitle, msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg);
    SetNotificationMessage(icon, icon, true, 1, title, subtitle);
    DrawNotification(false, true);
end
