local activeBlips = {}
local activeRadiusBlips = {}

local blips = {}
local radiusBlips = {}

local function getOptions()
    return {
        { label = Config.Labels.create_zone, value = "create_zone" },
        { label = Config.Labels.view_zones,  value = "view_zones" },
    }
end

local function getSubOptions()
    return {
        { label = Config.Labels.yes, value = "yes_delete" },
        { label = Config.Labels.no,  value = "no_delete" },
    }
end

local function getNoZonesOptions()
    return {
        { label = Config.Labels.no_active_zones, value = "get_back" },
    }
end

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    Wait(1000)
    TriggerEvent("vyntra-restrictedzones:client:refreshBlips")
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
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

            for i = 1, #zoneData, 1 do
                table.insert(activeBlips, {
                    z = zoneData[i].z, y = zoneData[i].y, x = zoneData[i].x, id = zoneData[i].id
                })
                table.insert(activeRadiusBlips, {
                    radius = zoneData[i].radius,
                    z = zoneData[i].z,
                    y = zoneData[i].y,
                    x = zoneData[i].x,
                    description = zoneData[i].description,
                    title = zoneData[i].title,
                    id = zoneData[i].id
                })
            end

            for index, entry in pairs(activeRadiusBlips) do
                if radiusBlips["radiusBlip" .. entry.id] then RemoveBlip(radiusBlips["radiusBlip" .. entry.id]) end
                if blips["blip" .. entry.id] then RemoveBlip(blips["blip" .. entry.id]) end

                local formattedRadius = entry.radius + .0

                local rBlip = AddBlipForRadius(tonumber(entry.x), tonumber(entry.y), tonumber(entry.z), formattedRadius)
                SetBlipColour(rBlip, Config.Blip.color)
                SetBlipAlpha(rBlip, Config.Blip.alpha)
                radiusBlips["radiusBlip" .. entry.id] = rBlip

                local iBlip = AddBlipForCoord(tonumber(entry.x), tonumber(entry.y), tonumber(entry.z))
                SetBlipSprite(iBlip, Config.Blip.sprite)
                SetBlipColour(iBlip, Config.Blip.color)
                SetBlipDisplay(iBlip, Config.Blip.display)
                SetBlipScale(iBlip, Config.Blip.scale)
                SetBlipAsShortRange(iBlip, Config.Blip.shortRange)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(Config.Blip.name or entry.title)
                EndTextCommandSetBlipName(iBlip)

                blips["blip" .. entry.id] = iBlip
            end
        end
    end)
end)

RegisterNetEvent("vyntra-restrictedzones:client:deleteZone")
AddEventHandler("vyntra-restrictedzones:client:deleteZone", function(id)
    for k, entry in pairs(activeBlips) do
        if id == entry.id then
            if blips["blip" .. entry.id] then RemoveBlip(blips["blip" .. entry.id]) end
            table.remove(activeBlips, k)
        end
    end
    for k, entry in pairs(activeRadiusBlips) do
        if id == entry.id then
            if radiusBlips["radiusBlip" .. entry.id] then RemoveBlip(radiusBlips["radiusBlip" .. entry.id]) end
            table.remove(activeRadiusBlips, k)
        end
    end
end)

RegisterNetEvent("vyntra-restrictedzones:client:sendNotification")
AddEventHandler("vyntra-restrictedzones:client:sendNotification", function(description)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)

    local msg = string.format(Config.Labels.notification_body, description, streetName)
    ShowPictureNotification(Config.NotificationIcon, Config.Labels.notification_title,
        Config.Labels.notification_subtitle, msg)
end)

function openMenu()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), 'main_menu', {
        title = Config.Labels.menu_title,
        align = "left",
        elements = getOptions()
    }, function(data, menu)
        if data.current.value == "create_zone" then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'sub_dialog', {
                title = Config.Labels.enter_title
            }, function(data2, menu2)
                local title = data2.value
                -- FIX: Check for nil AND empty string
                if title == nil or title == "" then
                    return ESX.ShowNotification(Config.Labels.missing_title)
                end
                menu2.close()

                ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'sub_dialog2', {
                    title = Config.Labels.enter_desc
                }, function(data3, menu3)
                    local description = data3.value
                    -- FIX: Check for nil AND empty string
                    if description == nil or description == "" then
                        return ESX.ShowNotification(Config.Labels.missing_desc)
                    end
                    menu3.close()

                    ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), 'sub_dialog3', {
                        title = string.format(Config.Labels.enter_radius, Config.Radius.min, Config.Radius.max)
                    }, function(data4, menu4)
                        local range = tonumber(data4.value)

                        if not range then
                            ESX.ShowNotification(Config.Labels.valid_radius)
                        elseif range < Config.Radius.min or range > Config.Radius.max then
                            ESX.ShowNotification(string.format(Config.Labels.radius_range, Config.Radius.min,
                                Config.Radius.max))
                        elseif range % 1 ~= 0 then
                            ESX.ShowNotification(Config.Labels.radius_whole)
                        else
                            menu4.close()
                            local playerCoords = GetEntityCoords(PlayerPedId())

                            TriggerServerEvent('vyntra-restrictedzones:server:insertZone', title, description,
                                playerCoords.x, playerCoords.y, playerCoords.z, range)
                            TriggerServerEvent("vyntra-restrictedzones:server:refreshBlips")
                            TriggerServerEvent("vyntra-restrictedzones:server:sendNotification", description)

                            ESX.UI.Menu.CloseAll()
                        end
                    end, function(data4, menu4) menu4.close() end)
                end, function(data3, menu3) menu3.close() end)
            end, function(data2, menu2) menu2.close() end)
        elseif data.current.value == "view_zones" then
            ESX.TriggerServerCallback("vyntra-restrictedzones:server:getActiveZones", function(zoneData)
                if not zoneData or #zoneData == 0 then
                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "no_zones_menu", {
                        title = Config.Labels.active_zones_title,
                        align = "left",
                        elements = getNoZonesOptions(),
                    }, function(data2, menu2) menu2.close() end, function(data2, menu2) menu2.close() end)
                else
                    local activeZones = {}
                    for _, zone in pairs(zoneData) do
                        table.insert(activeZones, {
                            id = zone.id,
                            label = string.format("%s | %d Meters", zone.title, math.floor(zone.radius)),
                            value = "view_zone"
                        })
                    end

                    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "active_zones_menu", {
                        title = Config.Labels.active_zones_title,
                        align = "left",
                        elements = activeZones,
                    }, function(data3, menu3)
                        if data3.current.value == "view_zone" then
                            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "view_zone_confirm", {
                                title = Config.Labels.delete_confirm,
                                align = "left",
                                elements = getSubOptions(),
                            }, function(data4, menu4)
                                if data4.current.value == "yes_delete" then
                                    TriggerServerEvent("vyntra-restrictedzones:server:deleteZone", data3.current.id)
                                    ESX.ShowNotification(Config.Labels.zone_deleted)
                                    ESX.UI.Menu.CloseAll()
                                else
                                    menu4.close()
                                end
                            end, function(data4, menu4) menu4.close() end)
                        end
                    end, function(data3, menu3) menu3.close() end)
                end
            end)
        end
    end, function(data, menu) menu.close() end)
end

function ShowPictureNotification(icon, title, subtitle, msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    SetNotificationMessage(icon, icon, true, 1, title, subtitle)
    DrawNotification(false, true)
end
