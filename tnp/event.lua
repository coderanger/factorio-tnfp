-- tnp_handle_gui_check()
--   Handles a gui checkbox/radiobutton being selected
function tnp_handle_gui_check(event)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if event.element.name == "tnp-stationlist-stationtypetnfp" or event.element.name == "tnp-stationlist-stationtypetrain" or event.element.name == "tnp-stationlist-stationtypeall" then
        tnp_gui_stationlist_switch(player, event.element)
    end
end

-- tnp_handle_gui_click()
--   Handles a gui click
function tnp_handle_gui_click(event)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if event.element.name == "tnp-stationlist-headingbutton-close" then
        tnp_action_stationselect_cancel(player)
    elseif event.element.name == "tnp-stationlist-headingbutton-railtool" then
        tnp_action_stationselect_railtoolmap(player)
    elseif string.find(event.element.name, "tnp-stationlist-dest", 1, true) ~= nil then
        tnp_action_stationselect_redispatch(player, event.element)
    elseif string.find(event.element.name, "tnp-stationlist-pin", 1, true) ~= nil then
        tnp_action_stationselect_pin(player, event.element)
    end
end

-- tnp_handle_gui_text()
--   Handles text input via gui elements
function tnp_handle_gui_text(event)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if event.element.name == "tnp-stationlist-search" then
        tnp_gui_stationlist_search(player, event.element)
    end
end

-- tnp_handle_input()
--   Handles a request via the custom input
function tnp_handle_input(event)
    if event.input_name == "tnp-handle-request" then
        tnp_handle_request(event, false)
    elseif event.input_name == "tnp-handle-railtool" then
        tnp_handle_railtool(event, false, false)
    elseif event.input_name == "tnp-handle-railtool-map" then
        tnp_handle_railtool(event, false, true)
    elseif event.input_name == "tnp-handle-train-manual" then
        tnp_handle_train_manual(event)
    end
end

-- tnp_handle_ltn_stops()
--   Handles the event from LTN advertising its available stops to us
function tnp_handle_ltn_stops(event)
    if event.logistic_train_stops then
        tnp_state_ltnstop_destroy()
        for _, ltndata in pairs(event.logistic_train_stops) do
            -- We are currently only tracking depot stops
            if ltndata['isDepot'] then
                tnp_state_ltnstop_set(ltndata['entity'], 'depot', true)
            end
        end
    end
end

-- tnp_handle_player_dropped()
--   Handles a player dropping an object
function tnp_handle_player_droppeditem(event)
    if event.entity and event.entity.stack and event.entity.stack.valid and event.entity.stack.valid_for_read and event.entity.stack.name == "tnp-railtool" then
        event.entity.stack.clear()
    end
end

-- tnp_handle_railtool()
--   Handles a request to provide a railtool
function tnp_handle_railtool(event, shortcut, openmap)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if openmap then
        player.open_map(player.position)
    end

    tnp_action_railtool(player)
end

-- tnp_handle_request()
--   Handles a request for a TNfP Train via input
function tnp_handle_request(event, shortcut)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if not player.surface then
        tnp_message(tnpdefines.loglevel.core, player, {"tnp_error_location_surface", player.name})
        return
    end

    if not player.position then
        tnp_message(tnpdefines.loglevel.core, player, {"tnp_error_location_position", player.name})
        return
    end

    local train = tnp_state_player_get(player, 'train')
    if train then
        tnp_action_player_cancel(player, train)
    else
        if player.vehicle and player.vehicle.train then
            tnp_action_player_request_boarded(player, player.vehicle.train)
        else
            tnp_action_player_request(player)
        end
    end
end

-- tnp_handle_selectiontool()
--   Handles a selection tool being used
function tnp_handle_selectiontool(event)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if event.item == "tnp-railtool" then
        tnp_action_player_railtool(player, event.entities)
    end
end

-- tnp_handle_shortcut()
--   Handles a shortcut being pressed
function tnp_handle_shortcut(event)
    if event.prototype_name == "tnp-handle-request" then
        tnp_handle_request(event, true)
    elseif event.prototype_name == "tnp-handle-railtool" then
        tnp_handle_railtool(event, true, false)
    end
end

-- tnp_handle_tick_prune()
--   Triggers a period prune of invalid data
function tnp_handle_tick_prune(event)
    _tnp_state_gui_prune()
    _tnp_state_player_prune()
    _tnp_state_train_prune()
    _tnp_state_dynamicstop_prune()
end

-- tnp_handle_tick_timeout()
--   Handle a per-second event to timeout train deliveries
function tnp_handle_tick_timeout(event)
    tnp_action_timeout()
end

-- tnp_handle_player_vehicle()
--   Handles a player entering or exiting a vehicle
function tnp_handle_player_vehicle(event)
    local player = game.players[event.player_index]
    local vehicle = event.entity

    if not player.valid or not vehicle or not vehicle.valid then
        return
    end

    -- This is a non-train vehicle
    if not vehicle.train then
        return
    end

    tnp_action_player_train(player, vehicle.train)
end

-- tnp_handle_train_manual()
--   Handles a player requesting a train is switched to manual mode
function tnp_handle_train_manual(event)
    local player = game.players[event.player_index]

    if not player.valid then
        return
    end

    if not player.vehicle or not player.vehicle.valid or not player.vehicle.train then
        return
    end

    player.vehicle.train.manual_mode = true
end

-- tnp_handle_train_schedulechange()
--   Handles a trains schedule being changed
function tnp_handle_train_schedulechange(event)
    -- A train we're not tracking
    if not tnp_state_train_query(event.train) then
        return
    end

    local player = nil
    if event.player_index and game.players[event.player_index] then
        player = game.players[event.player_index]
    end

    tnp_action_train_schedulechange(event.train, player)
end

-- tnp_handle_train_statechange()
--   Handles a trains state being changed
function tnp_handle_train_statechange(event)
    if not event.train.valid then
        return
    end

    -- A train we're not tracking
    if not tnp_state_train_query(event.train) then
        return
    end

    tnp_action_train_statechange(event.train)
end