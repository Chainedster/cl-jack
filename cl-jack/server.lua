local in_jack_zone = {}
RegisterNetEvent('Klownzz:EnteredZone')
AddEventHandler('Klownzz:EnteredZone', function()
    local src = source

    if not in_jack_zone[src] then
        in_jack_zone[src] = true
    end
end)

RegisterNetEvent('Klownzz:ExitedZone')
AddEventHandler('Klownzz:ExitedZone', function()
    local src = source

    if in_jack_zone[src] then
        in_jack_zone[src] = nil
    end
end)

local is_being_hugged = false
RegisterNetEvent('Klownzz:Hug')
AddEventHandler('Klownzz:Hug', function()
    local src = source

    if not in_jack_zone[src] then
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'You are not near me cunt!'})
        return
    end

    if not is_being_hugged then
        is_being_hugged = true

        TriggerClientEvent('Klownzz:HandleHug', src, 'self')
        for k,v in pairs(in_jack_zone) do
            TriggerClientEvent('Klownzz:HandleHug', k, 'jack')
        end

        Wait(6000)
        is_being_hugged = false
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'error', text = 'I am currently giving a hug, please wait'})
    end
end)