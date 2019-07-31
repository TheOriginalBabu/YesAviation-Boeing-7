--[[
*****************************************************************************************
* Program Script Name	:	B738.switches
*
* Author Name			:	Alex Unruh, Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
* 
*
*
*
*
*****************************************************************************************
*        COPYRIGHT � 2017 ALEX UNRUH / LAMINAR RESEARCH - ALL RIGHTS RESERVED
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

NUM_BTN_SW_COVERS = 10




--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--


----- BUTTON SWITCH COVER(S) ------------------------------------------------------------
local B738_button_switch_cover_position_target = {}
for i = 0, NUM_BTN_SW_COVERS-1 do B738_button_switch_cover_position_target[i] = 0 end

local B738_close_button_cover = {}
local B738_button_switch_cover_CMDhandler = {}




--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--


----- BUTTON SWITCH COVER(S) ------------------------------------------------------------
B738DR_button_switch_cover_position = create_dataref("laminar/B738/button_switch/cover_position", "array[" .. tostring(NUM_BTN_SW_COVERS) .. "]")


--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

-- EYEBALL VENT
function B738DR_eyeball_vent_capt_x_pos_DRhandler() end
function B738DR_eyeball_vent_capt_y_pos_DRhandler() end

function B738DR_eyeball_vent_fo_x_pos_DRhandler() end
function B738DR_eyeball_vent_fo_y_pos_DRhandler() end

function B738DR_eyeball_vent_jump_x_pos_DRhandler() end
function B738DR_eyeball_vent_jump_y_pos_DRhandler() end

-- MAP LIGHTS
function B738DR_map_light_capt_x_pos_DRhandler() end
function B738DR_map_light_capt_y_pos_DRhandler() end

function B738DR_map_light_fo_x_pos_DRhandler() end
function B738DR_map_light_fo_y_pos_DRhandler() end

-- HANDLES

function B738DR_handle_capt_pos_DRhandler() end
function B738DR_handle_fo_pos_DRhandler() end


--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

-- EVEBALL VENT
B738DR_eyeball_vent_capt_x_pos	= create_dataref("laminar/B738/air/capt/eyeball_vent/x_pos", "number", B738DR_eyeball_vent_capt_x_pos_DRhandler)
B738DR_eyeball_vent_capt_y_pos	= create_dataref("laminar/B738/air/capt/eyeball_vent/y_pos", "number", B738DR_eyeball_vent_capt_y_pos_DRhandler)

B738DR_eyeball_vent_fo_x_pos	= create_dataref("laminar/B738/air/fo/eyeball_vent/x_pos", "number", B738DR_eyeball_vent_fo_x_pos_DRhandler)
B738DR_eyeball_vent_fo_y_pos	= create_dataref("laminar/B738/air/fo/eyeball_vent/y_pos", "number", B738DR_eyeball_vent_fo_y_pos_DRhandler)

B738DR_eyeball_vent_jump_x_pos	= create_dataref("laminar/B738/air/jump/eyeball_vent/x_pos", "number", B738DR_eyeball_vent_jump_x_pos_DRhandler)
B738DR_eyeball_vent_jump_y_pos	= create_dataref("laminar/B738/air/jump/eyeball_vent/y_pos", "number", B738DR_eyeball_vent_jump_y_pos_DRhandler)

-- MAP LIGHTS
B738DR_map_light_capt_x_pos	= create_dataref("laminar/B738/adjust/capt/map_light/x_pos", "number", B738DR_map_light_capt_x_pos_DRhandler)
B738DR_map_light_capt_y_pos	= create_dataref("laminar/B738/adjust/capt/map_light/y_pos", "number", B738DR_map_light_capt_y_pos_DRhandler)

B738DR_map_light_fo_x_pos	= create_dataref("laminar/B738/adjust/fo/map_light/x_pos", "number", B738DR_map_light_fo_x_pos_DRhandler)
B738DR_map_light_fo_y_pos	= create_dataref("laminar/B738/adjust/fo/map_light/y_pos", "number", B738DR_map_light_fo_y_pos_DRhandler)

-- HANDLES

B738DR_handle_capt_pos = create_dataref("laminar/B738/adjust/capt/handle_pos", "number", B738DR_handle_capt_pos_DRhandler)
B738DR_handle_fo_pos = create_dataref("laminar/B738/adjust/fo/handle_pos", "number", B738DR_handle_fo_pos_DRhandler)

--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

----- BUTTON SWITCH COVER(S) ------------------------------------------------------------
for i = 0, NUM_BTN_SW_COVERS-1 do

    -- CREATE THE CLOSE COVER FUNCTIONS
    B738_close_button_cover[i] = function()
        B738_button_switch_cover_position_target[i] = 0.0
    end


    -- CREATE THE COVER HANDLER FUNCTIONS
    B738_button_switch_cover_CMDhandler[i] = function(phase, duration)

        if phase == 0 then
            if B738_button_switch_cover_position_target[i] == 0.0 then
                B738_button_switch_cover_position_target[i] = 1.0
                if is_timer_scheduled(B738_close_button_cover[i]) then
                    stop_timer(B738_close_button_cover[i])
                end
                run_after_time(B738_close_button_cover[i], 5.0)
            elseif B738_button_switch_cover_position_target[i] == 1.0 then
                B738_button_switch_cover_position_target[i] = 0.0
                if is_timer_scheduled(B738_close_button_cover[i]) then
                    stop_timer(B738_close_button_cover[i])
                end
            end
        end
    end

end




--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

----- BUTTON SWITCH COVERS --------------------------------------------------------------
B738CMD_button_switch_cover = {}
for i = 0, NUM_BTN_SW_COVERS-1 do
    B738CMD_button_switch_cover[i] = create_command("laminar/B738/button_switch_cover" .. string.format("%02d", i), "Button Switch Cover" .. string.format("%02d", i), B738_button_switch_cover_CMDhandler[i])
end




--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					           OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- ANIMATION UTILITY -----------------------------------------------------------------
function B738_set_animation_position(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * SIM_PERIOD))
    end

end






----- BUTTON SWITCH COVER POSITION ANIMATION --------------------------------------------
function B738_button_switch_cover_animation()

    for i = 0, NUM_BTN_SW_COVERS-1 do
        B738DR_button_switch_cover_position[i] = B738_set_animation_position(B738DR_button_switch_cover_position[i], B738_button_switch_cover_position_target[i], 0.0, 1.0, 10.0)
    end

end






--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	math.randomseed( os.time() )
 
	B738DR_eyeball_vent_capt_x_pos = math.random(-35,35)
	B738DR_eyeball_vent_capt_y_pos = math.random(-35,35)
	B738DR_eyeball_vent_fo_x_pos = math.random(-35,35)
	B738DR_eyeball_vent_fo_y_pos = math.random(-35,35)
	B738DR_eyeball_vent_jump_x_pos = math.random(-35,35)
	B738DR_eyeball_vent_jump_y_pos = math.random(-35,35)
	
	B738DR_map_light_capt_x_pos = math.random(-10,10)
	B738DR_map_light_capt_y_pos = math.random(-10,10)
	B738DR_map_light_fo_x_pos = math.random(-10,10)
	B738DR_map_light_fo_y_pos = math.random(-10,10)

	B738DR_handle_capt_pos = math.random(0,90)
	B738DR_handle_fo_pos = math.random(0,90)
	
end

--function flight_crash() end

function before_physics() 
	
	B738_button_switch_cover_animation()	
		
end

--function after_physics() end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



