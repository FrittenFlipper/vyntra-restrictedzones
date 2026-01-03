RegisterCommand("restrictedzone", function(source, args, raw)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer.job.name == "police" or xPlayer.job.name == "fib" then
        TriggerClientEvent("vyntra-restrictedzones:client:openMenu", src)
    else
        -- Assuming 'b_notify' is your notification script
        TriggerClientEvent('b_notify', src, "error", "Restricted Zones", "You do not have permission to access the menu!",
            5000)
    end
end)

ESX.RegisterServerCallback('vyntra-restrictedzones:server:getActiveZones', function(source, cb)
    local result   = MySQL.query.await('SELECT * FROM vyntra_restrictedzones')
    local zoneData = {}

    if table.empty(result) then
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

RegisterServerEvent('vyntra-restrictedzones:server:insertZone')
AddEventHandler('vyntra-restrictedzones:server:insertZone', function(title, description, x, y, z, radius)
    MySQL.insert('INSERT INTO vyntra_restrictedzones (title, description, x, y, z, radius) VALUES (?, ?, ?, ?, ?, ?)',
        { title, description, x, y, z, radius + .0 })
end)

RegisterServerEvent("vyntra-restrictedzones:server:refreshBlips")
AddEventHandler("vyntra-restrictedzones:server:refreshBlips", function()
    local xPlayers = ESX.GetExtendedPlayers()

    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent("vyntra-restrictedzones:client:refreshBlips", xPlayer.source)
    end
end)

RegisterServerEvent('vyntra-restrictedzones:server:deleteZone')
AddEventHandler('vyntra-restrictedzones:server:deleteZone', function(id)
    local xPlayers = ESX.GetExtendedPlayers()

    for _, xPlayer in pairs(xPlayers) do
        TriggerClientEvent("vyntra-restrictedzones:client:deleteZone", xPlayer.source, id)
    end

    MySQL.query('DELETE FROM vyntra_restrictedzones WHERE id = ?', { id })
end)

function table.empty(self)
    for _, _ in pairs(self) do
        return false
    end

    return true
end
