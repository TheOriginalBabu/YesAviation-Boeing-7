--[[
*****************************************************************************************
* Program Script Name	:	B738.fire
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
*        COPYRIGHT � 2017 ALEX UNRUH / LAMINAR RESEARCH - ALL RIGHTS RESERVED	        *
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

local fire_extiguisher_switch_lock = {}
for i = 1, 2 do
    fire_extiguisher_switch_lock[i] = 0
end

local fire_extinguisher_switch_pos_arm_target  = {}
for i = 1, 2 do
    fire_extinguisher_switch_pos_arm_target[i] = 0
end

local fire_extinguisher_switch_pos_disch_target = {}
for i = 1, 2 do
    fire_extinguisher_switch_pos_disch_target[i] = 0
end





--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_engine_fire           = find_dataref("sim/cockpit2/annunciators/engine_fires")
simDR_engine_fire_ext_on    = find_dataref("sim/cockpit2/engine/actuators/fire_extinguisher_on")


--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

B738DR_engine01_fire_ext_switch_pos_arm     = create_dataref("laminar/B738/fire/engine01/ext_switch/pos_arm", "number")
B738DR_engine02_fire_ext_switch_pos_arm     = create_dataref("laminar/B738/fire/engine02/ext_switch/pos_arm", "number")

B738DR_engine01_fire_ext_switch_pos_disch   = create_dataref("laminar/B738/fire/engine01/ext_switch/pos_disch", "number")
B738DR_engine02_fire_ext_switch_pos_disch   = create_dataref("laminar/B738/fire/engine02/ext_switch/pos_disch", "number")

B738DR_fire_ext_bottle_0102L_psi            = create_dataref("laminar/B738/fire/engine01_02L/ext_bottle/psi", "number")
B738DR_fire_ext_bottle_0102R_psi            = create_dataref("laminar/B738/fire/engine01_02R/ext_bottle/psi", "number")

B738DR_init_fire_CD							= create_dataref("laminar/B738/init_CD/fire", "number")


--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--





--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--





--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_generator1_off				= find_command("sim/electrical/generator_1_off")
simCMD_generator2_off				= find_command("sim/electrical/generator_2_off")

--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--



----- FIRE EXTINGUISHER SWITCHES --------------------------------------------------------
function B738_eng01_fire_ext_switch_arm_CMDhandler(phase, duration)
    if phase == 0 then
        if fire_extiguisher_switch_lock[1] == 0 then                    -- TODO:  CHANGE TOP ALLOW SIWTHC TO BE RETURNED TO "OFF" WHEN FIRE IS OUT
            if fire_extinguisher_switch_pos_disch_target[1] == 0 then
                fire_extinguisher_switch_pos_arm_target[1] = 1.0 - fire_extinguisher_switch_pos_arm_target[1]
            end
        end
    end
end

function B738_eng02_fire_ext_switch_arm_CMDhandler(phase, duration)
    if phase == 0 then
        if fire_extiguisher_switch_lock[2] == 0 then
            if fire_extinguisher_switch_pos_disch_target[2] == 0 then
                fire_extinguisher_switch_pos_arm_target[2] = 1.0 - fire_extinguisher_switch_pos_arm_target[2]
            end
        end
    end
end





function B738_eng01_fire_ext_switch_L_CMDhandler(phase, duration)
    if phase == 0 then
        if B738DR_engine01_fire_ext_switch_pos_arm == 1 then
            fire_extinguisher_switch_pos_disch_target[1] = math.max(fire_extinguisher_switch_pos_disch_target[1]-1, -1)
            simCMD_generator1_off:once()
        end
    end
end

function B738_eng01_fire_ext_switch_R_CMDhandler(phase, duration)
    if phase == 0 then
        if B738DR_engine01_fire_ext_switch_pos_arm == 1 then
            fire_extinguisher_switch_pos_disch_target[1] = math.min(fire_extinguisher_switch_pos_disch_target[1]+1, 1)
			simCMD_generator1_off:once()
        end
    end
end

function B738_eng02_fire_ext_switch_L_CMDhandler(phase, duration)
    if phase == 0 then
        if B738DR_engine02_fire_ext_switch_pos_arm == 1 then
            fire_extinguisher_switch_pos_disch_target[2] = math.max(fire_extinguisher_switch_pos_disch_target[2]-1, -1)
			simCMD_generator2_off:once()
        end
    end
end

function B738_eng02_fire_ext_switch_R_CMDhandler(phase, duration)
    if phase == 0 then
        if B738DR_engine02_fire_ext_switch_pos_arm == 1 then
            fire_extinguisher_switch_pos_disch_target[2] = math.min(fire_extinguisher_switch_pos_disch_target[2]+1, 1)
			simCMD_generator2_off:once()
        end
    end
end


function B738_ai_fire_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	B738_set_fire_all_modes()
	  	B738_set_fire_CD() 
	  	B738_set_fire_ER()
	end 	
end	



--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--


----- FIRE EXTINGUISHER SWITCHES --------------------------------------------------------
B738CMD_eng01_fire_ext_switch_arm   = create_command("laminar/B738/fire/engine01/ext_switch_arm", "Fire Extinguisher Switch 01 Arm", B738_eng01_fire_ext_switch_arm_CMDhandler)
B738CMD_eng02_fire_ext_switch_arm   = create_command("laminar/B738/fire/engine02/ext_switch_arm", "Fire Extinguisher Switch 02 Arm", B738_eng02_fire_ext_switch_arm_CMDhandler)


B738CMD_eng01_fire_ext_switch_L     = create_command("laminar/B738/fire/engine01/ext_switch_L", "Fire Extinguisher Switch L", B738_eng01_fire_ext_switch_L_CMDhandler)
B738CMD_eng01_fire_ext_switch_R     = create_command("laminar/B738/fire/engine01/ext_switch_R", "Fire Extinguisher Switch R", B738_eng01_fire_ext_switch_R_CMDhandler)
B738CMD_eng02_fire_ext_switch_L     = create_command("laminar/B738/fire/engine02/ext_switch_L", "Fire Extinguisher Switch L", B738_eng02_fire_ext_switch_L_CMDhandler)
B738CMD_eng02_fire_ext_switch_R     = create_command("laminar/B738/fire/engine02/ext_switch_R", "Fire Extinguisher Switch R", B738_eng02_fire_ext_switch_R_CMDhandler)

-- AI

B738CMD_ai_fire_quick_start		= create_command("laminar/B738/ai/fire_quick_start", "number", B738_ai_fire_quick_start_CMDhandler)

--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- TERNARY CONDITIONAL ---------------------------------------------------------------
function B738_ternary(condition, ifTrue, ifFalse)
    if condition then return ifTrue else return ifFalse end
end



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





----- FIRE EXTINGUISHER LOCKS -----------------------------------------------------------
function B738_fire_extingiuisher_locks()

    fire_extiguisher_switch_lock[1] = 0 --B738_ternary((simDR_engine_fire[0] == 6), 0, 1) -- TODO: ADD FUEL CUTOFF SWITCH TO LOGIC
    fire_extiguisher_switch_lock[2] = 0 --B738_ternary((simDR_engine_fire[1] == 6), 0, 1)


end





----- FIRE EXTINGUISHER SWITCH ANIMATION ------------------------------------------------
function B738_fire_ext_switch_animation()

    B738DR_engine01_fire_ext_switch_pos_arm = B738_set_animation_position(B738DR_engine01_fire_ext_switch_pos_arm, fire_extinguisher_switch_pos_arm_target[1], 0.0, 1.0, 10)
    B738DR_engine02_fire_ext_switch_pos_arm = B738_set_animation_position(B738DR_engine02_fire_ext_switch_pos_arm, fire_extinguisher_switch_pos_arm_target[2], 0.0, 1.0, 10)

    B738DR_engine01_fire_ext_switch_pos_disch = B738_set_animation_position(B738DR_engine01_fire_ext_switch_pos_disch, fire_extinguisher_switch_pos_disch_target[1],-1.0, 1.0, 10)
    B738DR_engine02_fire_ext_switch_pos_disch = B738_set_animation_position(B738DR_engine02_fire_ext_switch_pos_disch, fire_extinguisher_switch_pos_disch_target[2],-1.0, 1.0, 10)

end





----- FIRE EXTINGUISH LOGIC -------------------------------------------------------------
function B738_fire_extinguishers()

    ----- SET SIM FIRE EXTINGUISHER

    -- ENGINE #1
    if B738DR_engine01_fire_ext_switch_pos_disch < -0.95
        or B738DR_engine01_fire_ext_switch_pos_disch > 0.95
    then
        simDR_engine_fire_ext_on[0] = 1
    else
        simDR_engine_fire_ext_on[0] = 0
    end


    -- ENGINE #2
    if B738DR_engine02_fire_ext_switch_pos_disch < -0.95
        or B738DR_engine02_fire_ext_switch_pos_disch > 0.95
    then
        simDR_engine_fire_ext_on[1] = 1
    else
        simDR_engine_fire_ext_on[1] = 0
    end



    ----- SET BOTTLE PRESSURE ON DISCHARGE

    -- ENGINE #1 / BOTTLE L DISCHARGE
    if simDR_engine_fire_ext_on[0] == 1
        and B738DR_engine01_fire_ext_switch_pos_disch < -0.95
        and B738DR_fire_ext_bottle_0102L_psi > 0
    then
        B738DR_fire_ext_bottle_0102L_psi = math.max(0, B738DR_fire_ext_bottle_0102L_psi - (40.0 * SIM_PERIOD))
    end

    -- ENGINE #1 / BOTTLE R DISCHARGE
    if simDR_engine_fire_ext_on[0] == 1
        and B738DR_engine01_fire_ext_switch_pos_disch > 0.95
        and B738DR_fire_ext_bottle_0102R_psi > 0
    then
        B738DR_fire_ext_bottle_0102R_psi = math.max(0, B738DR_fire_ext_bottle_0102R_psi - (40.0 * SIM_PERIOD))
    end

    -- ENGINE #2 / BOTTLE L DISCHARGE
    if simDR_engine_fire_ext_on[1] == 1
        and B738DR_engine02_fire_ext_switch_pos_disch < -0.95
        and B738DR_fire_ext_bottle_0102L_psi > 0
    then
        B738DR_fire_ext_bottle_0102L_psi = math.max(0, B738DR_fire_ext_bottle_0102L_psi - (40.0 * SIM_PERIOD))
    end

    -- ENGINE #2 / BOTTLE R DISCHARGE
    if simDR_engine_fire_ext_on[1] == 1
        and B738DR_engine02_fire_ext_switch_pos_disch > 0.95
        and B738DR_fire_ext_bottle_0102R_psi > 0
    then
        B738DR_fire_ext_bottle_0102R_psi = math.max(0, B738DR_fire_ext_bottle_0102R_psi - (40.0 * SIM_PERIOD))
    end




end




----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function B738_fire_monitor_AI()

    if B738DR_init_fire_CD == 1 then
        B738_set_fire_all_modes()
        B738_set_fire_CD()
        B738DR_init_fire_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function B738_set_fire_all_modes()
	
	B738DR_init_fire_CD = 0

		B738DR_engine01_fire_ext_switch_pos_arm = 0
		B738DR_engine02_fire_ext_switch_pos_arm = 0
		B738DR_engine01_fire_ext_switch_pos_disch = 0
		B738DR_engine01_fire_ext_switch_pos_disch = 0
		B738DR_fire_ext_bottle_0102L_psi = 600.0
		B738DR_fire_ext_bottle_0102R_psi = 600.0


end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function B738_set_fire_CD()

		
end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------

function B738_set_fire_ER()


end


----- FLIGHT START ---------------------------------------------------------------------

function B738_flight_start_fire()

    -- ALL MODES ------------------------------------------------------------------------
    B738_set_fire_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B738_set_fire_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B738_set_fire_ER()

    end

end





--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

    B738DR_fire_ext_bottle_0102L_psi = 600.0
    B738DR_fire_ext_bottle_0102R_psi = 600.0

end

--function flight_crash() end

--function before_physics() end

function after_physics()

    B738_fire_extingiuisher_locks()
    B738_fire_ext_switch_animation()
    B738_fire_extinguishers()
    B738_fire_monitor_AI()

end

--function after_replay() end



