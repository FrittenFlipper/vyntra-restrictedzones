RegisterCommand(Config.CommandName, function(source, args, raw)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer and Config.AllowedJobs[xPlayer.job.name] then
        TriggerClientEvent("vyntra-restrictedzones:client:openMenu", src)
    else
        TriggerClientEvent("b_notify", src, "error", Config.Labels.notification_title, Config.Labels.no_perms, 5000)
    end
end)

ESX.RegisterServerCallback("vyntra-restrictedzones:server:getActiveZones", function(source, cb)
    local result   = MySQL.query.await("SELECT * FROM vyntra_restrictedzones")
    local zoneData = {}

    if not result or #result == 0 then
        zoneData = nil
    else
        for i = 1, #result, 1 do
            table.insert(zoneData, {
                radius      = result[i].radius,
                z           = result[i].z,
                y           = result[i].y,
                x           = result[i].x,
                description = result[i].description,
                title       = result[i].title,
                id          = result[i].id,
            })
        end
    end

    cb(zoneData)
end)

RegisterServerEvent("vyntra-restrictedzones:server:sendNotification")
AddEventHandler("vyntra-restrictedzones:server:sendNotification", function(description)
    local xPlayers = ESX.GetExtendedPlayers()

    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent("vyntra-restrictedzones:client:sendNotification", xPlayer.source, description)
    end
end)

RegisterServerEvent("vyntra-restrictedzones:server:insertZone")
AddEventHandler("vyntra-restrictedzones:server:insertZone", function(title, description, x, y, z, radius)
    MySQL.insert("INSERT INTO vyntra_restrictedzones (title, description, x, y, z, radius) VALUES (?, ?, ?, ?, ?, ?)",
        { title, description, x, y, z, radius + .0 })
end)

RegisterServerEvent("vyntra-restrictedzones:server:refreshBlips")
AddEventHandler("vyntra-restrictedzones:server:refreshBlips", function()
    local xPlayers = ESX.GetExtendedPlayers()

    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent("vyntra-restrictedzones:client:refreshBlips", xPlayer.source)
    end
end)

RegisterServerEvent("vyntra-restrictedzones:server:deleteZone")
AddEventHandler("vyntra-restrictedzones:server:deleteZone", function(id)
    local xPlayers = ESX.GetExtendedPlayers()

    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent("vyntra-restrictedzones:client:deleteZone", xPlayer.source, id)
    end

    MySQL.query("DELETE FROM vyntra_restrictedzones WHERE id = ?", { id })
end)
