--[[
*****************************************************************************************
* Program Script Name	:	B738.gear
* Author Name			:	Jim Gregory, Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2016-04-26	0.01a				Start of Dev
*
*
*
*
*****************************************************************************************
*        COPYRIGHT � 2017 Alex Unruh / LAMINAR RESEARCH - ALL RIGHTS RESERVED	        *
*****************************************************************************************
--]]


--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD - this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.

IN_REPLAY - evaluates to 0 if replay is off, 1 if replay mode is on

--]]


--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local B738_landing_gear_handle_max_pos = 2.0
local B738_landing_gear_handle_pos_target = 0.0
local B738_gear_handle_lock_override = 0
local B738_gear_handle_lock = 0




--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_startup_running       = find_dataref("sim/operation/prefs/startup_running")
simDR_aircraft_on_ground    = find_dataref("sim/flightmodel/failures/onground_all")
simDR_gear_deploy_ratio     = find_dataref("sim/flightmodel2/gear/deploy_ratio")
simDR_tire_steer_deg        = find_dataref("sim/flightmodel2/gear/tire_steer_actual_deg")

simDR_gear_handle_down      = find_dataref("sim/cockpit2/controls/gear_handle_down")




--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

B738DR_gear_handle_position     = create_dataref("laminar/B738/gear_handle/position", "number")
B738DR_gear_lock_override_pos   = create_dataref("laminar/B738/gear_lock_ovrd/position", "number")

B738DR_init_gear_CD             = create_dataref("laminar/B738/init_CD/gear", "number")



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

function B738_gear_lock_override_CMDhandler(phase, duration)

    if phase == 0 then
        B738_gear_handle_lock_override = 1
        B738DR_gear_lock_override_pos = 1
    elseif phase == 1 then
        B738_gear_handle_lock_override = 1
        B738DR_gear_lock_override_pos = 1
    elseif phase == 2 then
        B738_gear_handle_lock_override = 0
        B738DR_gear_lock_override_pos = 0
    end
end


----- GEAR HANDLE DATAREF HANDLER -------------------------------------------------------
function B738DR_gear_handle_DRhandler()

    -- GEAR HANDLE LOCK IS DISENGAGED
    if B738_gear_handle_lock == 0 then

        if B738DR_gear_handle <= 0.1 then
            B738_landing_gear_handle_pos_target = 0.0   -- DETENT (GEAR HANDLE "DOWN")
        elseif B738DR_gear_handle >= 0.9 and B738DR_gear_handle <= 1.1 then
            B738_landing_gear_handle_pos_target = 1.0   -- DETENT (GEAR HANDLE "OFF")
        elseif B738DR_gear_handle >= 1.9 then
            B738_landing_gear_handle_pos_target = 2.0   -- DETENT (GEAR HANDLE "UP")
        else
            B738_landing_gear_handle_pos_target = B738DR_gear_handle
        end


    -- GEAR HANDLE LOCK IS ENGAGED
    else

        if B738DR_gear_handle <= 0.1 then
            B738_landing_gear_handle_pos_target = 0.0   -- DETENT (GEAR HANDLE "DOWN")
        elseif B738DR_gear_handle >= 0.9 then
            B738DR_gear_handle = 1.0            -- PREVENT MOVEMENT OF GEAR HANDLE TO 'UP' POSITION
            B738_landing_gear_handle_pos_target = 1.0
        else
            B738_landing_gear_handle_pos_target = B738DR_gear_handle
        end

    end

end






--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--


----- LANDING GEAR HANDLE ---------------------------------------------------------------
B738DR_gear_handle = create_dataref("laminar/B738/actuator/gear_handle", "number", B738DR_gear_handle_DRhandler)


--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--

function sim_landing_gear_up_CMDhandler(phase, duration)
    if phase == 0 then
        -- GEAR HANDLE LOCK IS DISENGAGED
        if B738_gear_handle_lock == 0 then
            B738DR_gear_handle = 2.0
        -- GEAR HANDLE LOCK IS ENGAGED
        else
            B738DR_gear_handle = 1.0            -- PREVENT MOVEMENT OF GEAR HANDLE TO 'UP' POSITION
        end
        B738_landing_gear_handle_pos_target = B738DR_gear_handle
    end
end

function sim_landing_gear_down_CMDhandler(phase, duration)
    if phase == 0 then
        B738DR_gear_handle = 0.0
        B738_landing_gear_handle_pos_target = B738DR_gear_handle
    end
end

function sim_landing_gear_toggle_CMDhandler(phase, duration)
    if phase == 0 then
        -- GEAR HANDLE LOCK IS DISENGAGED
        if B738_gear_handle_lock == 0 then
            if simDR_gear_deploy_ratio[0] >= 0.5
                    and simDR_gear_deploy_ratio[1] >= 0.5
                    and simDR_gear_deploy_ratio[2] >= 0.5
                    and B738DR_gear_handle <= 1.0
            then
                B738DR_gear_handle = 2.0
            else
                B738DR_gear_handle = 0.0
            end
        -- GEAR HANDLE LOCK IS ENGAGED
        else
            if simDR_gear_deploy_ratio[0] >= 0.5
                    and simDR_gear_deploy_ratio[1] >= 0.5
                    and simDR_gear_deploy_ratio[2] >= 0.5
                    and B738DR_gear_handle < 1.0
            then
                B738DR_gear_handle = 1.0        -- PREVENT MOVEMENT OF GEAR HANDLE TO 'UP' POSITION
            else
                B738DR_gear_handle = 0.0
            end
        end
        B738_landing_gear_handle_pos_target = B738DR_gear_handle
    end
end






--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_landing_gear_up = replace_command("sim/flight_controls/landing_gear_up", sim_landing_gear_up_CMDhandler)
simCMD_landing_gear_down = replace_command("sim/flight_controls/landing_gear_down", sim_landing_gear_down_CMDhandler)
simCMD_landing_gear_toggle = replace_command("sim/flight_controls/landing_gear_toggle", sim_landing_gear_toggle_CMDhandler)




--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

function B738_gear_lock_override_CMDhandler(phase, duration)

    if phase == 0 then
        B738_gear_handle_lock_override = 1
        B738DR_gear_lock_override_pos = 1
    elseif phase == 1 then
        B738_gear_handle_lock_override = 1
        B738DR_gear_lock_override_pos = 1
    elseif phase == 2 then
        B738_gear_handle_lock_override = 0
        B738DR_gear_lock_override_pos = 0
    end
end


-- AI
function B738_ai_gear_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
		B738_set_gear_all_modes()
		B738_set_gear_CD()
		B738_set_gear_ER()    
	end    	
end	




--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--

-- GEAR LOCK OVERRIDE
B738CMD_gear_lock_override      = create_command("laminar/B738/gear_lock/override", "Gear Lock Override", B738_gear_lock_override_CMDhandler)

-- AI
B738CMD_ai_gear_quick_start			= create_command("laminar/B738/ai/gear_quick_start", "number", B738_ai_gear_quick_start_CMDhandler)



--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- ANIMATION UTILITY -----------------------------------------------------------------
function B738_set_animation_position(current_value, target, min, max, speed)

    local fps_factor = math.min(1.0, speed * SIM_PERIOD)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
       return min
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end




----- RESCALE ---------------------------------------------------------------------------
function B738_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end






----- SET GEAR HANDLE LOCK VALUE --------------------------------------------------------
function B738_set_gear_handle_lock()

    B738_landing_gear_handle_max_pos = 2.0

    -- OVERRIDE LOCK BUTTON IS PRESSED
    if B738_gear_handle_lock_override == 1 then
        B738_gear_handle_lock = 0

    -- OVERRIDE LOCK BUTTON IS NOT PRESSED
    else

        -- AIRCRAFT WHEELS ARE ON THE GROUND
        if simDR_aircraft_on_ground == 1 then
            B738_gear_handle_lock = 1
            B738_landing_gear_handle_max_pos = 1.0

        -- AIRCRAFT IS IN THE AIR
        else
            if simDR_aircraft_on_ground == 0 then
                B738_gear_handle_lock = 0
            end
        end
    end

end





----- GEAR HANDLE ANIMATION -------------------------------------------------------------
function B738_gear_handle_animation()

    B738DR_gear_handle_position = B738_set_animation_position(B738DR_gear_handle_position, B738_landing_gear_handle_pos_target, 0.0, B738_landing_gear_handle_max_pos, 20.0)

end





----- SET SIM GEAR HANDLE STATE ---------------------------------------------------------
function B738_sim_gear_handle_status()

    if B738DR_gear_handle_position <= 0.05 then
        simDR_gear_handle_down = 1
    elseif B738DR_gear_handle_position >= 0.95 then
        simDR_gear_handle_down = 0
    end

end





----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function B738_gear_monitor_AI()

    if B738DR_init_gear_CD == 1 then
        B738_set_gear_all_modes()
        B738_set_gear_CD()
        B738DR_init_gear_CD = 2
    end

end





----- SET STATE FOR ALL MODES -----------------------------------------------------------
function B738_set_gear_all_modes()

	B738DR_init_gear_CD = 0

end





----- SET STATE TO COLD & DARK ----------------------------------------------------------
function B738_set_gear_CD()



end





----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
function B738_set_gear_ER()
	
	
	
end





----- FLIGHT START ---------------------------------------------------------------------
function B738_flight_start_gear()

    -- ALL MODES ------------------------------------------------------------------------
    B738_set_gear_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B738_set_gear_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B738_set_gear_ER()


    end

end







--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

    B738_flight_start_gear()

end

--function flight_crash() end

--function before_physics() end

function after_physics()

    B738_set_gear_handle_lock()
    B738_gear_handle_animation()
    B738_sim_gear_handle_status()
    B738_gear_monitor_AI()
    
end

--function after_replay() end



