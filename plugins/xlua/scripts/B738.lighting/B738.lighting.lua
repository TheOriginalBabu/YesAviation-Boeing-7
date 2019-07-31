--[[
*****************************************************************************************
* Program Script Name	:	B738.lighting
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



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_compass_brightness_switch  = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[6]")

simDR_taxi_light_brightness_switch  = find_dataref("sim/cockpit2/switches/generic_lights_switch[4]") 

simDR_landing_light_on_0 = find_dataref("sim/cockpit2/switches/landing_lights_switch[0]")
simDR_landing_light_on_1 = find_dataref("sim/cockpit2/switches/landing_lights_switch[1]")
simDR_landing_light_on_2 = find_dataref("sim/cockpit2/switches/landing_lights_switch[2]")
simDR_landing_light_on_3 = find_dataref("sim/cockpit2/switches/landing_lights_switch[3]")

simDR_cockpit_dome_switch = find_dataref("sim/cockpit2/switches/generic_lights_switch[9]")

simDR_seatbelt_sign_switch = find_dataref("sim/cockpit2/switches/fasten_seat_belts")

simDR_beacon_on				= find_dataref("sim/cockpit2/switches/beacon_on")
simDR_wing_lights_on		= find_dataref("sim/cockpit2/switches/generic_lights_switch[0]")
simDR_logo_lights_on		= find_dataref("sim/cockpit2/switches/generic_lights_switch[1]")

--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_nav_lights_on				= find_command("sim/lights/nav_lights_on") 
simCMD_nav_lights_off				= find_command("sim/lights/nav_lights_off")

simCMD_strobe_lights_on				= find_command("sim/lights/strobe_lights_on")
simCMD_strobe_lights_off			= find_command("sim/lights/strobe_lights_off")

simCMD_seatbelt_toggle				= find_command("sim/systems/seatbelt_sign_toggle")


--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

B738DR_position_light_switch_pos	= create_dataref("laminar/B738/toggle_switch/position_light_pos", "number")

B738DR_compass_brighness_switch_pos	= create_dataref("laminar/B738/toggle_switch/compass_brightness_pos", "number")

B738DR_cockpit_dome_switch_pos	= create_dataref("laminar/B738/toggle_switch/cockpit_dome_pos", "number")

B738DR_taxi_light_brightness_switch_pos = create_dataref("laminar/B738/toggle_switch/taxi_light_brightness_pos", "number")

B738DR_landing_lights_all_on_pos = create_dataref("laminar/B738/spring_switch/landing_lights_all_on", "number")

B738DR_seatbelt_sign_switch_pos = create_dataref("laminar/B738/toggle_switch/seatbelt_sign_pos", "number")

B738DR_init_lighting_CD = create_dataref("laminar/B738/init_CD/lighting", "number")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--




--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

-- POSITION LIGHT SWITCH
function B738_position_light_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_position_light_switch_pos == -1 then
            B738DR_position_light_switch_pos = 0
            simCMD_nav_lights_off:once()
            simCMD_strobe_lights_off:once()
        elseif B738DR_position_light_switch_pos == 0 then
            B738DR_position_light_switch_pos = 1
            simCMD_nav_lights_on:once()
            simCMD_strobe_lights_on:once()
        end		
	end	
end	


function B738_position_light_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_position_light_switch_pos == 1 then
            B738DR_position_light_switch_pos = 0
            simCMD_nav_lights_off:once()
            simCMD_strobe_lights_off:once()
        elseif B738DR_position_light_switch_pos == 0 then
            B738DR_position_light_switch_pos = -1
            simCMD_nav_lights_on:once()          
        end		
	end			
end	





-- COMPASS LIGHT SWITCH
function B738_compass_brightness_switch_rgt_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_compass_brighness_switch_pos == -1 then
            B738DR_compass_brighness_switch_pos = 0
            simDR_compass_brightness_switch = 0
        elseif B738DR_compass_brighness_switch_pos == 0 then
            B738DR_compass_brighness_switch_pos = 1
            simDR_compass_brightness_switch = 1
        end		
	end	
end	


function B738_compass_brightness_switch_lft_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_compass_brighness_switch_pos == 1 then
            B738DR_compass_brighness_switch_pos = 0
            simDR_compass_brightness_switch = 0
        elseif B738DR_compass_brighness_switch_pos == 0 then
            B738DR_compass_brighness_switch_pos = -1
            simDR_compass_brightness_switch = 0.33          
        end		
	end			
end	


-- COCKPIT DOME LIGHT SWITCH
function B738_cockpit_dome_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_cockpit_dome_switch_pos == -1 then
            B738DR_cockpit_dome_switch_pos = 0
            simDR_cockpit_dome_switch = 0
        elseif B738DR_cockpit_dome_switch_pos == 0 then
            B738DR_cockpit_dome_switch_pos = 1
            simDR_cockpit_dome_switch = 0.4
        end		
	end	
end	


function B738_cockpit_dome_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_cockpit_dome_switch_pos == 1 then
            B738DR_cockpit_dome_switch_pos = 0
            simDR_cockpit_dome_switch = 0
        elseif B738DR_cockpit_dome_switch_pos == 0 then
            B738DR_cockpit_dome_switch_pos = -1
            simDR_cockpit_dome_switch = 1          
        end		
	end			
end	



-- TAXI LIGHT SWITCH
function B738_taxi_light_brightness_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_taxi_light_brightness_switch_pos == 2 then
            B738DR_taxi_light_brightness_switch_pos = 1
            simDR_taxi_light_brightness_switch = 0.5
        elseif B738DR_taxi_light_brightness_switch_pos == 1 then
            B738DR_taxi_light_brightness_switch_pos = 0
            simDR_taxi_light_brightness_switch = 0
        end		
	end	
end	


function B738_taxi_light_brightness_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_taxi_light_brightness_switch_pos == 0 then
            B738DR_taxi_light_brightness_switch_pos = 1
            simDR_taxi_light_brightness_switch = 0.5
        elseif B738DR_taxi_light_brightness_switch_pos == 1 then
            B738DR_taxi_light_brightness_switch_pos = 2
            simDR_taxi_light_brightness_switch = 1         
        end		
	end			
end	


-- LANDING LIGHT ALL
function B738_landing_lights_all_on_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_landing_lights_all_on_pos == 0 then
			B738DR_landing_lights_all_on_pos = 1
			simDR_landing_light_on_0 = 1
			simDR_landing_light_on_1 = 1
			simDR_landing_light_on_2 = 1
			simDR_landing_light_on_3 = 1
			end
	elseif phase == 2 then
		if B738DR_landing_lights_all_on_pos == 1 then
			B738DR_landing_lights_all_on_pos = 0
		end
	end
end
			
	
-- SEAT BELT SIGN SWITCH
function B738_seatbelt_sign_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_seatbelt_sign_switch_pos == 2 then
			B738DR_seatbelt_sign_switch_pos = 1
			simDR_seatbelt_sign_switch = 1
		elseif B738DR_seatbelt_sign_switch_pos == 1 then
			B738DR_seatbelt_sign_switch_pos = 0
			simDR_seatbelt_sign_switch = 0
		end
	end
end		

function B738_seatbelt_sign_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_seatbelt_sign_switch_pos == 0 then
			B738DR_seatbelt_sign_switch_pos = 1
			simCMD_seatbelt_toggle:once()
		elseif B738DR_seatbelt_sign_switch_pos == 1 then
			B738DR_seatbelt_sign_switch_pos = 2
			simCMD_seatbelt_toggle:once()
			simDR_seatbelt_sign_switch = 2
		end
	end
end

function B738_ai_lighting_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	B738_set_lighting_all_modes()
	  	B738_set_lighting_CD() 
	  	B738_set_lighting_ER()
	end 	
end	

			
--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

-- POSITION LIGHT SWITCH
B738CMD_position_light_switch_up 	= create_command("laminar/B738/toggle_switch/position_light_up", "Position Light Switch Up", B738_position_light_switch_up_CMDhandler)
B738CMD_position_light_switch_dn 	= create_command("laminar/B738/toggle_switch/position_light_down", "Position Light Switch Down", B738_position_light_switch_dn_CMDhandler)


-- COMPASS LIGHT SWITCH
B738CMD_compass_brightness_switch_lft 	= create_command("laminar/B738/toggle_switch/compass_brightness_lft", "Standby Compass Light Switch Left", B738_compass_brightness_switch_lft_CMDhandler)
B738CMD_compass_brightness_switch_rgt	= create_command("laminar/B738/toggle_switch/compass_brightness_rgt", "Standby Compass Light Switch Right", B738_compass_brightness_switch_rgt_CMDhandler)


-- COCKPIT DOME LIGHT SWITCH
B738CMD_cockpit_dome_switch_up 	= create_command("laminar/B738/toggle_switch/cockpit_dome_up", "Cockpit Dome Light Switch Up", B738_cockpit_dome_switch_up_CMDhandler)
B738CMD_cockpit_dome_switch_dn	= create_command("laminar/B738/toggle_switch/cockpit_dome_dn", "Cockpit Dome LIght Switch Down", B738_cockpit_dome_switch_dn_CMDhandler)


-- TAXI LIGHT SWITCH
B738CMD_taxi_light_brightness_switch_up	= create_command("laminar/B738/toggle_switch/taxi_light_brightness_pos_up", "Taxi Light Brightness Up", B738_taxi_light_brightness_switch_up_CMDhandler)
B738CMD_taxi_light_brightness_switch_dn	= create_command("laminar/B738/toggle_switch/taxi_light_brightness_pos_dn", "Taxi Light Brightness Down", B738_taxi_light_brightness_switch_dn_CMDhandler)

-- LANDING LIGHT ALL
B738CMD_landing_lights_all_on = create_command("laminar/B738/spring_switch/landing_lights_all", "All Landing Lights On", B738_landing_lights_all_on_CMDhandler)

-- SEAT BELT SIGN SWITCH
B738CMD_seatbelt_sign_switch_up = create_command("laminar/B738/toggle_switch/seatbelt_sign_up", "Seat Belt Switch Up", B738_seatbelt_sign_switch_up_CMDhandler)
B738CMD_seatbelt_sign_switch_dn = create_command("laminar/B738/toggle_switch/seatbelt_sign_dn", "Seat Belt Switch Down", B738_seatbelt_sign_switch_dn_CMDhandler)

-- AI

B738CMD_ai_lighting_quick_start		= create_command("laminar/B738/ai/lighting_quick_start", "number", B738_ai_lighting_quick_start_CMDhandler)


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



----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function B738_lighting_monitor_AI()

    if B738DR_init_lighting_CD == 1 then
        B738_set_lighting_all_modes()
        B738_set_lighting_CD()
        B738DR_init_lighting_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function B738_set_lighting_all_modes()
	
	B738DR_init_lighting_CD = 0
	
		simDR_compass_brightness_switch = 0
    	B738DR_compass_brighness_switch_pos = 0
    	simDR_landing_light_on_0 = 0
    	simDR_landing_light_on_1 = 0
    	simDR_landing_light_on_2 = 0
    	simDR_landing_light_on_3 = 0
    	simCMD_strobe_lights_off:once()
    	B738DR_cockpit_dome_switch_pos = 0
    	simDR_cockpit_dome_switch = 0
		simDR_wing_lights_on = 0
		simDR_logo_lights_on = 0
		B738DR_taxi_light_brightness_switch_pos = 0
		simDR_taxi_light_brightness_switch = 0


end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function B738_set_lighting_CD()

		B738DR_seatbelt_sign_switch_pos = 0
		simDR_seatbelt_sign_switch = 0
		B738DR_position_light_switch_pos = 0
		simCMD_nav_lights_off:once()
		simDR_beacon_on = 0

		
end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------

function B738_set_lighting_ER()



end



----- FLIGHT START ---------------------------------------------------------------------

function B738_flight_start_lighting()

    -- ALL MODES ------------------------------------------------------------------------
    B738_set_lighting_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B738_set_lighting_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B738_set_lighting_ER()

    end

end






--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	B738_flight_start_lighting()

end


--function flight_crash() end

--function before_physics() end

function after_physics()

	B738_lighting_monitor_AI()
	
end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



