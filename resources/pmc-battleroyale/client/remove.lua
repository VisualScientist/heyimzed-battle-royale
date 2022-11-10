
--[[CreateThread(function()
    while true do
        Wait(1)
        local pos = GetEntityCoords(PlayerPedId())
        local w = GetEntityHeading(PlayerPedId())
        DrawScreenText(0.1, 0.1,{
            ('X: %.3f'):format(tostring(pos.x)),
            ('Y: %.3f'):format(tostring(pos.y)),
            ('Z: %.3f'):format(tostring(pos.z)),
            ('W: %.3f'):format(tostring(w)),
        }, 0.3)
    end
end)]]

--[[ local savedLootPos = {}
RegisterCommand('setlp', function()
    table.insert(savedLootPos, GetEntityCoords(PlayerPedId()))
    print'saved pos'
end, true)

RegisterCommand('savelp', function()
    print'saving pos...'
    TriggerServerEvent('pmc-battleroyale:save:lp', savedLootPos)
    Wait(100)
    savedLootPos = {}
end, true)

RegisterKeyMapping('setlp', 'sets lp', 'keyboard', 'E')
RegisterKeyMapping('savelp', 'saves lp', 'keyboard', 'G') ]]
