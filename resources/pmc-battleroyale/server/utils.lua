
function EnsureClientEvent(_e, _s, ...)
    if type(_s) == 'table' then
        for _, _i in pairs(_s) do
            TriggerClientEvent(_e, _i, ...)
        end
    elseif type(_s) == 'number' then
        TriggerClientEvent(_e, _s, ...)
    elseif type(_s) ~= 'table' and tonumber(_s) ~= nil then
        EnsureClientEvent(_e, tonumber(_s), ...)
    end
end

--[[ RegisterNetEvent('pmc-battleroyale:save:lp')
AddEventHandler('pmc-battleroyale:save:lp', function(lootpos)
    local file, err, errC = io.open('lootpos.txt', "a")
    assert(file, err)
    for _, pos in pairs(lootpos) do
        file:write(("vector3(%s, %s, %s),\n"):format(pos.x, pos.y, pos.z))
    end
    file:close()
end) ]]
