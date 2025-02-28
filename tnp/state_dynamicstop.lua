--[[
    State Table:
        altstop         - LuaEntity, alternate stop we're tracking
        dynamicstop     - LuaEntity, dynamic stop we're tracking
        player          - LuaPlayer, player we're tracking the request for
]]

function _tnp_state_dynamicstop_prune()
    for id, ent in pairs(global.dynamicstop_data) do
        if not ent.dynamicstop.valid then
            global.dynamicstop_data[id] = nil
        elseif not ent.player.valid then
            -- The player has become invalid, destroy all the stops we were tracking 
            -- and the train pruning will restore the schedule
            if ent.dynamicstop.valid then
                ent.dynamicstop.destroy()
            end
            if ent.altstop.valid then
                ent.altstop.destroy()
            end

            global.dynamicstop_data[id] = nil
        end
    end
end

-- tnp_state_dynamicstop_delete()
--   Deletes state information about a LuaEntity
function tnp_state_dynamicstop_delete(ent, key)
    _tnp_state_dynamicstop_prune()

    if not ent.valid then
        return
    end

    if global.dynamicstop_data[ent.unit_number] then
        if key then
            global.dynamicstop_data[ent.unit_number][key] = nil
        else
            global.dynamicstop_data[ent.unit_number] = nil
        end
    end
end

-- tnp_state_dynamicstop_get()
--   Gets state information about a LuaEntity
function tnp_state_dynamicstop_get(ent, key)
    _tnp_state_dynamicstop_prune()

    if not ent.valid then
        return false
    end

    if global.dynamicstop_data[ent.unit_number] and global.dynamicstop_data[ent.unit_number][key] then
        return global.dynamicstop_data[ent.unit_number][key]
    end

    return nil
end

-- tnp_state_dynamicstop_set()
--   Sets state information about a LuaEntity
function tnp_state_dynamicstop_set(ent, key, value)
    _tnp_state_dynamicstop_prune()

    if not ent.valid then
        return false
    end

    if not global.dynamicstop_data[ent.unit_number] then
        global.dynamicstop_data[ent.unit_number] = {}
        global.dynamicstop_data[ent.unit_number]['dynamicstop'] = ent
    end

    global.dynamicstop_data[ent.unit_number][key] = value
    return true
end