function showInteraction(text , type)
    SendNUIMessage({
        type = "open",
        text = text,
        color = type,
    })
end

function hideInteraction()
    SendNUIMessage({
        type = "close",
    })
end

RegisterNetEvent('cl_ui_interaction:showInteraction')
AddEventHandler('cl_ui_interaction:showInteraction', function(text, type, tempDelay)
    showInteraction(text, type)

    if tempDelay then
        Citizen.Wait(tempDelay)
        hideInteraction()
    end
end)

RegisterNetEvent('cl_ui_interaction:hideInteraction')
AddEventHandler('cl_ui_interaction:hideInteraction', function()
    hideInteraction()
end)