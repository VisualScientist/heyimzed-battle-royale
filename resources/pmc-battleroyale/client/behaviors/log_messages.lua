
function SendScreenLog(message)
    SendNUIMessage({
        action = 'log',
        text = message,
    })
end

function SendScreenNotification(message)
    SendNUIMessage({
        action = 'notification',
        text = message,
    })
end
