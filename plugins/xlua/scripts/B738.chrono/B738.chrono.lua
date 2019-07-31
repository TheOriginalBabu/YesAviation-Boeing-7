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

B738_RESET  = -1
B738_HOLD   = 0
B738_RUN    = 1
B738_START  = 1
B738_STOP   = 0
B738_ET     = 0
B738_CHRONO = 1


--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



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

simCMD_timer_cycle = find_command("sim/instruments/timer_cycle")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--


B738DR_chrono_display_mode_capt					= create_dataref("laminar/B738/clock/chrono_display_mode_capt", "number")
B738DR_chrono_display_mode_fo					= create_dataref("laminar/B738/clock/chrono_display_mode_fo", "number")

B738DR_clock_captain_et_mode					= create_dataref("laminar/B738/clock/captain/et_mode", "number")
B738DR_clock_captain_et_seconds                 = create_dataref("laminar/B738/clock/captain/et_seconds", "number")
B738DR_clock_captain_et_minutes                 = create_dataref("laminar/B738/clock/captain/et_minutes", "number")
B738DR_clock_captain_et_hours                   = create_dataref("laminar/B738/clock/captain/et_hours", "number")

B738DR_clock_fo_et_mode 						= create_dataref("laminar/B738/clock/fo/et_mode", "number")
B738DR_clock_fo_et_seconds               		= create_dataref("laminar/B738/clock/fo/et_seconds", "number")
B738DR_clock_fo_et_minutes                      = create_dataref("laminar/B738/clock/fo/et_minutes", "number")
B738DR_clock_fo_et_hours                        = create_dataref("laminar/B738/clock/fo/et_hours", "number")

B738DR_clock_captain_chrono_mode             	= create_dataref("laminar/B738/clock/captain/chrono_mode", "number")
B738DR_clock_captain_chrono_seconds          	= create_dataref("laminar/B738/clock/captain/chrono_seconds", "number")
B738DR_clock_captain_chrono_minutes          	= create_dataref("laminar/B738/clock/captain/chrono_minutes", "number")

B738DR_clock_fo_chrono_mode              	 	= create_dataref("laminar/B738/clock/fo/chrono_mode", "number")
B738DR_clock_fo_chrono_seconds           	 	= create_dataref("laminar/B738/clock/fo/chrono_seconds", "number")
B738DR_clock_fo_chrono_minutes           	 	= create_dataref("laminar/B738/clock/fo/chrono_minutes", "number")


B738DR_clock_captain_CHR						= create_dataref("laminar/B738/clock/captain/chr", "number")
B738DR_clock_captain_TIME						= create_dataref("laminar/B738/clock/captain/time", "number")
B738DR_clock_captain_ET							= create_dataref("laminar/B738/clock/captain/et", "number")
B738DR_clock_captain_RESET						= create_dataref("laminar/B738/clock/captain/reset", "number")

B738DR_clock_fo_CHR								= create_dataref("laminar/B738/clock/fo/chr", "number")
B738DR_clock_fo_TIME							= create_dataref("laminar/B738/clock/fo/time", "number")
B738DR_clock_fo_ET								= create_dataref("laminar/B738/clock/fo/et", "number")
B738DR_clock_fo_RESET							= create_dataref("laminar/B738/clock/fo/reset", "number")

B738DR_init_chrono_CD							= create_dataref("laminar/B738/init_CD/chrono", "number")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--




--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

-- CREATE RETURN TO ACTIVE OR ET AFTER DURATION function

	B738_chrono_mode_zeroed_capt = function()
		if B738DR_clock_captain_chrono_mode == -1 then
			B738DR_chrono_display_mode_capt = 5
		elseif B738DR_clock_captain_chrono_mode >= 0 then
			B738DR_chrono_display_mode_capt = 0
		end
	end

function B738_chrono_display_mode_capt_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_chrono_display_mode_capt == 0
			or B738DR_chrono_display_mode_capt == 5 then
			B738DR_chrono_display_mode_capt = 1
			B738DR_clock_captain_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_capt) then
			stop_timer(B738_chrono_mode_zeroed_capt)
			end
			run_after_time(B738_chrono_mode_zeroed_capt, 5.0)
		elseif B738DR_chrono_display_mode_capt == 1 then
			B738DR_chrono_display_mode_capt = 2
			B738DR_clock_captain_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_capt) then
			stop_timer(B738_chrono_mode_zeroed_capt)
			end
			run_after_time(B738_chrono_mode_zeroed_capt, 5.0)
		elseif B738DR_chrono_display_mode_capt == 2 then
			B738DR_chrono_display_mode_capt = 3
			B738DR_clock_captain_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_capt) then
			stop_timer(B738_chrono_mode_zeroed_capt)
			end
			run_after_time(B738_chrono_mode_zeroed_capt, 5.0)
		elseif B738DR_chrono_display_mode_capt == 3 then
			B738DR_chrono_display_mode_capt = 4
			B738DR_clock_captain_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_capt) then
			stop_timer(B738_chrono_mode_zeroed_capt)
			end
			run_after_time(B738_chrono_mode_zeroed_capt, 5.0)
		elseif B738DR_chrono_display_mode_capt == 4 then
			B738DR_chrono_display_mode_capt = 1
			B738DR_clock_captain_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_capt) then
			stop_timer(B738_chrono_mode_zeroed_capt)
			end
			run_after_time(B738_chrono_mode_zeroed_capt, 5.0)
	elseif phase == 2 then
		B738DR_clock_captain_TIME = 0
		end
	end
end


-- CHRONO F/O

	B738_chrono_mode_zeroed_fo = function()
		if B738DR_clock_fo_chrono_mode == -1 then
			B738DR_chrono_display_mode_fo = 5
		elseif B738DR_clock_fo_chrono_mode >= 0 then
			B738DR_chrono_display_mode_fo = 0
		end
	end



function B738_chrono_display_mode_fo_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_chrono_display_mode_fo == 0
			or B738DR_chrono_display_mode_fo == 5 then
			B738DR_chrono_display_mode_fo = 1
			B738DR_clock_fo_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_fo) then
			stop_timer(B738_chrono_mode_zeroed_fo)
			end
			run_after_time(B738_chrono_mode_zeroed_fo, 5.0)
		elseif B738DR_chrono_display_mode_fo == 1 then
			B738DR_chrono_display_mode_fo = 2
			B738DR_clock_fo_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_fo) then
			stop_timer(B738_chrono_mode_zeroed_fo)
			end
			run_after_time(B738_chrono_mode_zeroed_fo, 5.0)
		elseif B738DR_chrono_display_mode_fo == 2 then
			B738DR_chrono_display_mode_fo = 3
			B738DR_clock_fo_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_fo) then
			stop_timer(B738_chrono_mode_zeroed_fo)
			end
			run_after_time(B738_chrono_mode_zeroed_fo, 5.0)
		elseif B738DR_chrono_display_mode_fo == 3 then
			B738DR_chrono_display_mode_fo = 4
			B738DR_clock_fo_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_fo) then
			stop_timer(B738_chrono_mode_zeroed_fo)
			end
			run_after_time(B738_chrono_mode_zeroed_fo, 5.0)
		elseif B738DR_chrono_display_mode_fo == 4 then
			B738DR_chrono_display_mode_fo = 1
			B738DR_clock_fo_TIME = 1
			if is_timer_scheduled(B738_chrono_mode_zeroed_fo) then
			stop_timer(B738_chrono_mode_zeroed_fo)
			end
			run_after_time(B738_chrono_mode_zeroed_fo, 5.0)
	elseif phase == 2 then
		B738DR_clock_fo_TIME = 0
		end
	end
end



-- ET CAPT

function B738_chrono_capt_et_mode_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_clock_captain_et_mode == B738_HOLD then
			B738DR_clock_captain_et_mode = B738_RUN
			B738DR_clock_captain_ET = 1
			B738DR_chrono_display_mode_capt = 5
			run_after_time(B738_chrono_mode_zeroed_capt, 5.0)
		elseif B738DR_clock_captain_et_mode == B738_RUN then
			B738DR_clock_captain_et_mode = B738_HOLD
			B738DR_clock_captain_ET = 1
			B738DR_chrono_display_mode_capt = 5
			run_after_time(B738_chrono_mode_zeroed_capt, 5.0)
		end
	elseif phase == 2 then
	B738DR_clock_captain_ET = 0
	end
end



function B738_et_reset_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_clock_captain_et_mode = B738_RESET
		B738DR_clock_captain_RESET = 1
	elseif phase == 2 then
		B738DR_clock_captain_et_mode = B738_HOLD
		B738DR_clock_captain_RESET = 0
	end
end



function B738_chrono_cycle_capt_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_clock_captain_chrono_mode == B738_START then
		 	B738DR_clock_captain_chrono_mode = B738_STOP
			B738DR_chrono_display_mode_capt = 0
			B738DR_clock_captain_CHR = 1
		elseif B738DR_clock_captain_chrono_mode == B738_STOP then
			B738DR_clock_captain_chrono_mode = B738_RESET
			run_after_time(B738_chrono_mode_zeroed_capt, 2.0)
			B738DR_clock_captain_CHR = 1
		elseif B738DR_clock_captain_chrono_mode == B738_RESET then
			B738DR_clock_captain_chrono_mode = B738_START
			B738DR_chrono_display_mode_capt = 0
			B738DR_clock_captain_CHR = 1
		end
	elseif phase == 2 then
	B738DR_clock_captain_CHR = 0
	end
end
		



-- ET FO

function B738_chrono_fo_et_mode_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_clock_fo_et_mode == B738_HOLD then
			B738DR_clock_fo_et_mode = B738_RUN
			B738DR_clock_fo_ET = 1
			B738DR_chrono_display_mode_fo = 5
			run_after_time(B738_chrono_mode_zeroed_fo, 5.0)
		elseif B738DR_clock_fo_et_mode == B738_RUN then
			B738DR_clock_fo_et_mode = B738_HOLD
			B738DR_clock_fo_ET = 1
			B738DR_chrono_display_mode_fo = 5
			run_after_time(B738_chrono_mode_zeroed_fo, 5.0)
		end
	elseif phase == 2 then
	B738DR_clock_fo_ET = 0
	end
end



function B738_et_reset_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_clock_fo_et_mode = B738_RESET
		B738DR_clock_fo_RESET = 1
	elseif phase == 2 then
		B738DR_clock_fo_et_mode = B738_HOLD
		B738DR_clock_fo_RESET = 0
	end
end


		
function B738_chrono_cycle_fo_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_clock_fo_chrono_mode == B738_START then
		 	B738DR_clock_fo_chrono_mode = B738_STOP
			B738DR_chrono_display_mode_fo = 0
			B738DR_clock_fo_CHR = 1
		elseif B738DR_clock_fo_chrono_mode == B738_STOP then
			B738DR_clock_fo_chrono_mode = B738_RESET
			run_after_time(B738_chrono_mode_zeroed_fo, 2.0)
			B738DR_clock_fo_CHR = 1
		elseif B738DR_clock_fo_chrono_mode == B738_RESET then
			B738DR_clock_fo_chrono_mode = B738_START
			B738DR_chrono_display_mode_fo = 0
			B738DR_clock_fo_CHR = 1
		end
	elseif phase == 2 then
	B738DR_clock_fo_CHR = 0
	end
end
 

--[[ IN ORDER bottom to top MODE 1 - MODE 4 HAVE PRIORITY TILL TIMEOUT. MODE 5 SHOWS IF MODE 0 is inactive. MODE 5 DISPLAYS OVER MODE 0 ON TIMEOUT LIKE MODES 1-4


		DISPLAY MODE 0 = CHRONO (DEFAULT MODE)
		DISPLAY MODE 5 = ET							----- TODO
		DISPLAY MODE 1 = GMT
		DISPLAY MODE 2 = DATE
		DISPLAY MODE 3 = LOCAL TIME
		DISPLAY MODE 4 = LOCAL DATE
		
		
--]]		
		
-- AI

function B738_ai_chrono_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	B738_set_chrono_all_modes()
	  	B738_set_chrono_CD() 
	  	B738_set_chrono_ER()
	end 	
end	


--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

B738CMD_chrono_display_mode_capt	= create_command("laminar/B738/push_button/chrono_disp_mode_capt", "CHRONO DISPLAY MODE CAPT", B738_chrono_display_mode_capt_CMDhandler)
B738CMD_chrono_display_mode_fo		= create_command("laminar/B738/push_button/chrono_disp_mode_fo", "CHRONO DISPLAY MODE FO", B738_chrono_display_mode_fo_CMDhandler)

B738CMD_chrono_capt_et_mode			= create_command("laminar/B738/push_button/chrono_capt_et_mode", "ELAPSED TIMER CAPTAIN", B738_chrono_capt_et_mode_CMDhandler)
B738CMD_chrono_fo_et_mode			= create_command("laminar/B738/push_button/chrono_fo_et_mode", "ELAPSED TIMER FO", B738_chrono_fo_et_mode_CMDhandler)

B738CMD_et_reset_capt				= create_command("laminar/B738/push_button/et_reset_capt", "ELAPSED TIME RESET CAPT", B738_et_reset_capt_CMDhandler)
B738CMD_et_reset_fo					= create_command("laminar/B738/push_button/et_reset_fo", "ELAPSED TIME RESET FO", B738_et_reset_fo_CMDhandler)

B738CMD_chrono_cycle_capt			= create_command("laminar/B738/push_button/chrono_cycle_capt", "CHRONO START STOP RESET CAPTAIN", B738_chrono_cycle_capt_CMDhandler)
B738CMD_chrono_cycle_fo				= create_command("laminar/B738/push_button/chrono_cycle_fo", "CHRONO START STOP RESET FO", B738_chrono_cycle_fo_CMDhandler)

-- AI

B738CMD_ai_chrono_quick_start		= create_command("laminar/B738/ai/chrono_quick_start", "number", B738_ai_chrono_quick_start_CMDhandler)

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

--[[SIM_PERIOD - this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.]]--


function B738_captain_clock_chrono_timer()

    B738DR_clock_captain_chrono_seconds = B738DR_clock_captain_chrono_seconds + SIM_PERIOD

    if B738DR_clock_captain_chrono_seconds > 60 then
        B738DR_clock_captain_chrono_seconds = 0.0
        B738DR_clock_captain_chrono_minutes = B738DR_clock_captain_chrono_minutes + 1

        if B738DR_clock_captain_chrono_minutes > 59.0 then
            B738DR_clock_captain_chrono_minutes = 0.0
        end
    end
   
end
   

function B738_captain_clock_et_timer()

    B738DR_clock_captain_et_seconds = B738DR_clock_captain_et_seconds + SIM_PERIOD

    if B738DR_clock_captain_et_seconds > 60 then
        B738DR_clock_captain_et_seconds = 0.0
        B738DR_clock_captain_et_minutes = B738DR_clock_captain_et_minutes + 1

        if B738DR_clock_captain_et_minutes > 59 then
            B738DR_clock_captain_et_minutes = 0.0
            B738DR_clock_captain_et_hours = B738DR_clock_captain_et_hours + 1

            if B738DR_clock_captain_et_hours > 23.0 then
                B738DR_clock_captain_et_hours = 0
            end
        end
    end

end




function B738_captain_clock()

    -- ELAPSED TIMER                TODO:  ELECTRICAL POWER REQ
    if B738DR_clock_captain_et_mode == B738_RUN then
        if is_timer_scheduled(B738_captain_clock_et_timer) == false then
            run_at_interval(B738_captain_clock_et_timer, SIM_PERIOD)
        end
    elseif B738DR_clock_captain_et_mode == B738_HOLD then
        if is_timer_scheduled(B738_captain_clock_et_timer) == true then
            stop_timer(B738_captain_clock_et_timer)
        end
    elseif B738DR_clock_captain_et_mode == B738_RESET then
        B738DR_clock_captain_et_seconds = 0
        B738DR_clock_captain_et_minutes = 0
        B738DR_clock_captain_et_hours = 0
    end

	if B738DR_clock_captain_chrono_mode == B738_START then
        if is_timer_scheduled(B738_captain_clock_chrono_timer) == false then
            run_at_interval(B738_captain_clock_chrono_timer, SIM_PERIOD)
        end
    elseif B738DR_clock_captain_chrono_mode == B738_STOP then
        if is_timer_scheduled(B738_captain_clock_chrono_timer) == true then
            stop_timer(B738_captain_clock_chrono_timer)
        end
    elseif B738DR_clock_captain_chrono_mode == B738_RESET then
        B738DR_clock_captain_chrono_seconds = 0
        B738DR_clock_captain_chrono_minutes = 0
    end

end





----- CLOCK (FIRST OFFICER) -------------------------------------------------------------


function B738_fo_clock_chrono_timer()

    B738DR_clock_fo_chrono_seconds = B738DR_clock_fo_chrono_seconds + SIM_PERIOD
    
    if B738DR_clock_fo_chrono_seconds > 60 then
        B738DR_clock_fo_chrono_seconds = 0.0
        B738DR_clock_fo_chrono_minutes = B738DR_clock_fo_chrono_minutes + 1

        if B738DR_clock_fo_chrono_minutes > 59.0 then
            B738DR_clock_fo_chrono_minutes = 0.0
        end
    end

end

function B738_fo_clock_et_timer()

    B738DR_clock_fo_et_seconds = B738DR_clock_fo_et_seconds + SIM_PERIOD
    
    if B738DR_clock_fo_et_seconds > 60 then
        B738DR_clock_fo_et_seconds = 0.0
        B738DR_clock_fo_et_minutes = B738DR_clock_fo_et_minutes + 1

        if B738DR_clock_fo_et_minutes > 59 then
            B738DR_clock_fo_et_minutes = 0.0
            B738DR_clock_fo_et_hours = B738DR_clock_fo_et_hours + 1

            if B738DR_clock_fo_et_hours > 23.0 then
                B738DR_clock_fo_et_hours = 0
            end
        end
    end
end


function B738_fo_clock()

    -- ELAPSED TIMER                TODO:  ELECTRICAL POWER REQ
    if B738DR_clock_fo_et_mode == B738_RUN then
        if is_timer_scheduled(B738_fo_clock_et_timer) == false then
            run_at_interval(B738_fo_clock_et_timer, SIM_PERIOD)
        end
    elseif B738DR_clock_fo_et_mode == B738_HOLD then
        if is_timer_scheduled(B738_fo_clock_et_timer) == true then
            stop_timer(B738_fo_clock_et_timer)
        end
    elseif B738DR_clock_fo_et_mode == B738_RESET then
        B738DR_clock_fo_et_seconds = 0
        B738DR_clock_fo_et_minutes = 0
        B738DR_clock_fo_et_hours = 0
    end


    if B738DR_clock_fo_chrono_mode == B738_START then
        if is_timer_scheduled(B738_fo_clock_chrono_timer) == false then
            run_at_interval(B738_fo_clock_chrono_timer, SIM_PERIOD)
        end
    elseif B738DR_clock_fo_chrono_mode == B738_STOP then
        if is_timer_scheduled(B738_fo_clock_chrono_timer) == true then
            stop_timer(B738_fo_clock_chrono_timer)
        end
    elseif B738DR_clock_fo_chrono_mode == B738_RESET then
        B738DR_clock_fo_chrono_seconds = 0
        B738DR_clock_fo_chrono_minutes = 0
    end

end





----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function B738_chrono_monitor_AI()

    if B738DR_init_chrono_CD == 1 then
        B738_set_chrono_all_modes()
        B738_set_chrono_CD()
        B738DR_init_chrono_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function B738_set_chrono_all_modes()
	
	B738DR_init_chrono_CD = 0

    B738DR_clock_captain_chrono_mode = B738_RESET
    B738DR_clock_fo_chrono_mode = B738_RESET
	B738DR_chrono_display_mode_capt = 5
	B738DR_chrono_display_mode_fo = 5


end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function B738_set_chrono_CD()

		
end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------

function B738_set_chrono_ER()


end


----- FLIGHT START ---------------------------------------------------------------------

function B738_flight_start_chrono()

    -- ALL MODES ------------------------------------------------------------------------
    B738_set_chrono_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B738_set_chrono_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B738_set_chrono_ER()

    end

end


--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function aircraft_load()

	B738_flight_start_chrono()

end

--function aircraft_unload() end

--function flight_start() end

--function flight_crash() end

--function before_physics()	end

function after_physics()

    B738_captain_clock()
	B738_fo_clock()
	B738_chrono_monitor_AI()
	
end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



