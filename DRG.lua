-------------------------------------------------------------------------------------------------------------------
-- Initialization function that defines sets and variables to be used.
-------------------------------------------------------------------------------------------------------------------

-- IMPORTANT: Make sure to also get the Mote-Include.lua file (and its supplementary files) to go with this.

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2
	-- Load and initialize the include file.
	include('Mote-Include.lua')
end


-- Setup vars that are user-independent.
function job_setup()
	get_combat_form()
    include('Mote-TreasureHunter')
    state.TreasureMode:set('Tag')
    
    state.CapacityMode = M(false, 'Capacity Point Mantle')
	
    -- list of weaponskills that make better use of otomi helm in low acc situations
    wsList = S{'Drakesbane'}

	state.Buff = {}
	-- JA IDs for actions that always have TH: Provoke, Animated Flourish
	info.default_ja_ids = S{35, 204}
	-- Unblinkable JA IDs for actions that always have TH: Quick/Box/Stutter Step, Desperate/Violent Flourish
	info.default_u_ja_ids = S{201, 202, 203, 205, 207}
end


-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
	-- Options: Override default values
	state.OffenseMode:options('Normal', 'Mid', 'Acc')
	state.HybridMode:options('Normal', 'PDT', 'Reraise')
	state.WeaponskillMode:options('Normal', 'Mid', 'Acc')
	state.PhysicalDefenseMode:options('PDT', 'Reraise')
	state.MagicalDefenseMode:options('MDT')
    
    war_sj = player.sub_job == 'WAR' or false

	select_default_macro_book(1, 16)
    send_command('bind != gs c toggle CapacityMode')
	send_command('bind ^= gs c cycle treasuremode')
    send_command('bind ^[ input /lockstyle on')
    send_command('bind ![ input /lockstyle off')
end


-- Called when this job file is unloaded (eg: job change)
function file_unload()
	send_command('unbind ^[')
	send_command('unbind ![')
	send_command('unbind ^=')
	send_command('unbind !=')
end


-- Define sets and vars used by this job file.
function init_gear_sets()
-- gear located in DRG_gear.lua 
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks that are called to process player actions at specific points in time.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic target handling to be done.
function job_pretarget(spell, action, spellMap, eventArgs)
    if spell.english == "Spirit Jump" then
        if not pet.isvalid then
            cancel_spell()
            send_command('Jump')
        end
    elseif spell.english == "Soul Jump" then
        if not pet.isvalid then
            cancel_spell()
            send_command("High Jump")
        end
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
end

-- Run after the default precast() is done.
-- eventArgs is the same one used in job_precast, in case information needs to be persisted.
function job_post_precast(spell, action, spellMap, eventArgs)
	if player.hpp < 51 then
		classes.CustomClass = "Breath" 
	end
    if spell.type == 'WeaponSkill' then
        if state.CapacityMode.value then
            equip(sets.CapacityMantle)
        end
        if is_sc_element_today(spell) then
            if state.OffenseMode.current == 'Normal' and wsList:contains(spell.english) then
                --do nothing
            else
                equip(sets.WSDayBonus)
            end
        end
    end
end


-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
	if spell.action_type == 'Magic' then
	    equip(sets.midcast.FastRecast)
	    if player.hpp < 51 then
		    classes.CustomClass = "Breath" 
	    end
	end
end

-- Run after the default midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
end

function job_pet_precast(spell, action, spellMap, eventArgs)
end
-- Runs when a pet initiates an action.
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_pet_midcast(spell, action, spellMap, eventArgs)
    if spell.english:startswith('Healing Breath') or spell.english == 'Restoring Breath' or spell.english == 'Steady Wing' or spell.english == 'Smiting Breath' then
		equip(sets.HB)
	end
end

-- Run after the default pet midcast() is done.
-- eventArgs is the same one used in job_pet_midcast, in case information needs to be persisted.
function job_pet_post_midcast(spell, action, spellMap, eventArgs)
	
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
	if state.HybridMode.value == 'Reraise' or
    (state.HybridMode.value == 'Physical' and state.PhysicalDefenseMode.value == 'Reraise') then
		equip(sets.Reraise)
	end
end

-- Run after the default aftercast() is done.
-- eventArgs is the same one used in job_aftercast, in case information needs to be persisted.
function job_post_aftercast(spell, action, spellMap, eventArgs)

end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_pet_aftercast(spell, action, spellMap, eventArgs)

end

-- Run after the default pet aftercast() is done.
-- eventArgs is the same one used in job_pet_aftercast, in case information needs to be persisted.
function job_pet_post_aftercast(spell, action, spellMap, eventArgs)

end


-------------------------------------------------------------------------------------------------------------------
-- Customization hooks for idle and melee sets, after they've been automatically constructed.
-------------------------------------------------------------------------------------------------------------------

-- Called before the Include starts constructing melee/idle/resting sets.
-- Can customize state or custom melee class values at this point.
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_handle_equipping_gear(status, eventArgs)

end

-- Return a customized weaponskill mode to use for weaponskill sets.
-- Don't return anything if you're not overriding the default value.
function get_custom_wsmode(spell, action, spellMap)

end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.hpp < 90 then
        idleSet = set_combine(idleSet, sets.idle.Regen)
    end
	return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
	if state.TreasureMode.value == 'Fulltime' then
		meleeSet = set_combine(meleeSet, sets.TreasureHunter)
	end
    if state.CapacityMode.value then
        meleeSet = set_combine(meleeSet, sets.CapacityMantle)
    end
	return meleeSet
end

-------------------------------------------------------------------------------------------------------------------
-- General hooks for other events.
-------------------------------------------------------------------------------------------------------------------

-- Called when the player's status changes.
function job_status_change(newStatus, oldStatus, eventArgs)

end

-- Called when the player's pet's status changes.
function job_pet_status_change(newStatus, oldStatus, eventArgs)

end

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    if string.lower(buff) == "sleep" and gain and player.hp > 200 then
        equip(sets.Berserker)
    else
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
end

function job_update(cmdParams, eventArgs)
    war_sj = player.sub_job == 'WAR' or false
	classes.CustomMeleeGroups:clear()
	th_update(cmdParams, eventArgs)
	get_combat_form()
end
-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called for custom player commands.
function job_self_command(cmdParams, eventArgs)

end

function get_combat_form()
	--if areas.Adoulin:contains(world.area) and buffactive.ionis then
	--	state.CombatForm:set('Adoulin')
	--end

    if war_sj then
        state.CombatForm:set("War")
    else
        state.CombatForm:reset()
    end
end


-- Job-specific toggles.
function job_toggle(field)

end

-- Handle auto-targetting based on local setup.
function job_auto_change_target(spell, action, spellMap, eventArgs)

end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)

end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------
-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
            equip(sets.buff[buff_name] or {})
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
        eventArgs.handled = true
    end
end
-- Check for various actions that we've specified in user code as being used with TH gear.
-- This will only ever be called if TreasureMode is not 'None'.
-- Category and Param are as specified in the action event packet.
function th_action_check(category, param)
	if category == 2 or -- any ranged attack
		--category == 4 or -- any magic action
		(category == 3 and param == 30) or -- Aeolian Edge
		(category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
		(category == 14 and info.default_u_ja_ids:contains(param)) -- Quick/Box/Stutter Step, Desperate/Violent Flourish
		then return true
	end
end
-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'WAR' then
    	set_macro_page(8, 1)
    elseif player.sub_job == 'WHM' then
    	set_macro_page(8, 2)
    else
    	set_macro_page(8, 1)
    end
end
