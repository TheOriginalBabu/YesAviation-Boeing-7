--[[
*****************************************************************************************
* Program Script Name	:	B738.systems
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

B738bleedAir            = {}

B738bleedAir.engine1    = {}
B738bleedAir.engine2    = {}
B738bleedAir.apu        = {}

B738bleedAir.engine1.psi	= 0
B738bleedAir.engine2.psi	= 0
B738bleedAir.apu.psi		= 0

B738bleedAir.engine1.bleed_air_valve        = {}
B738bleedAir.engine2.bleed_air_valve        = {}
B738bleedAir.apu.bleed_air_valve            = {}

B738bleedAir.engine1.bleed_air_valve.target_pos = 0.0
B738bleedAir.engine2.bleed_air_valve.target_pos = 0.0
B738bleedAir.apu.bleed_air_valve.target_pos     = 0.0

B738bleedAir.engine1.bleed_air_valve.pos        = create_dataref("laminar/B738/air/engine1/bleed_valve_pos", "number")
B738bleedAir.engine2.bleed_air_valve.pos        = create_dataref("laminar/B738/air/engine2/bleed_valve_pos", "number")
B738bleedAir.apu.bleed_air_valve.pos            = create_dataref("laminar/B738/air/apu/bleed_valve_pos", "number")


--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local B738_cross_feed_selector_knob_target = 0

local pax_oxy = 0

local ground_timer = 0

local B738_speedbrake_stop = 0

local austin_speedbrake_handle = 0

--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

-- ANNUNS

simDR_electrical_bus_volts0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_electrical_bus_volts1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
simDR_generic_brightness_ratio63 = find_dataref("sim/flightmodel2/lights/generic_lights_brightness_ratio[63]")

simDR_generic_brightness_switch63 = find_dataref("sim/cockpit2/switches/generic_lights_switch[63]")


simDR_startup_running               = find_dataref("sim/operation/prefs/startup_running")
simDR_electric_hyd_pump_switch		= find_dataref("sim/cockpit2/switches/electric_hydraulic_pump_on")
simDR_fuel_tank_pump1				= find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[0]")
simDR_fuel_tank_pump2				= find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[1]")
simDR_fuel_tank_pump3				= find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[2]")

--simDR_APU_starter_switch = find_dataref("sim/cockpit2/electrical/APU_starter_switch")

simDR_generator1_failure = find_dataref("sim/operation/failures/rel_genera0")
simDR_generator2_failure = find_dataref("sim/operation/failures/rel_genera1")

simDR_cross_tie = find_dataref("sim/cockpit2/electrical/cross_tie")

simDR_pax_oxy = find_dataref("sim/operation/failures/rel_pass_o2_on")

simDR_cabin_alt = find_dataref("sim/cockpit2/pressurization/indicators/cabin_altitude_ft")

simDR_bleed_air_mode = find_dataref("sim/cockpit2/pressurization/actuators/bleed_air_mode")

simDR_bleed_fail_1 = find_dataref("sim/operation/failures/rel_bleed_air_lft")
simDR_bleed_fail_2 = find_dataref("sim/operation/failures/rel_bleed_air_rgt")

-- DUCT PRESSURE

simDR_apu_N1_pct			= find_dataref("sim/cockpit2/electrical/APU_N1_percent")
simDR_engine_N1_pct1		= find_dataref("sim/cockpit2/engine/indicators/N1_percent[0]")
simDR_engine_N1_pct2		= find_dataref("sim/cockpit2/engine/indicators/N1_percent[1]")

simDR_elec_bus_volts0		= find_dataref("sim/cockpit2/electrical/bus_volts")

simDR_tank_l_status			= find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[0]")
simDR_tank_c_status			= find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[1]")
simDR_tank_r_status			= find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[2]")

simDR_fuel_selector_l		= find_dataref("sim/cockpit2/fuel/fuel_tank_selector_left")
simDR_fuel_selector_r		= find_dataref("sim/cockpit2/fuel/fuel_tank_selector_right")

simDR_center_tank_level		= find_dataref("sim/cockpit2/fuel/fuel_quantity[1]")
simDR_aircraft_on_ground    = find_dataref("sim/flightmodel/failures/onground_all")
simDR_aircraft_on_ground_any	= find_dataref("sim/flightmodel/failures/onground_any")
simDR_yaw_damper_switch		= find_dataref("sim/cockpit2/switches/yaw_damper_on")
simDR_apu_generator_switch	= find_dataref("sim/cockpit2/electrical/APU_generator_on")

simDR_avionics_switch		= find_dataref("sim/cockpit2/switches/avionics_power_on")

simDR_transponder_mode		= find_dataref("sim/cockpit2/radios/actuators/transponder_mode")

simDR_stby_power_volts		= find_dataref("sim/cockpit2/electrical/battery_voltage_indicated_volts[1]")
simDR_grd_power_volts		= find_dataref("sim/cockpit2/electrical/dc_voltmeter_selection")
simDR_gen1_amps				= find_dataref("sim/cockpit2/electrical/generator_amps[0]")
simDR_apu_gen_amps			= find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_gen2_amps				= find_dataref("sim/cockpit2/electrical/generator_amps[1]")
simDR_inverter_on			= find_dataref("sim/cockpit2/electrical/inverter_on[0]")
simDR_gpu_amps				= find_dataref("sim/cockpit/electrical/gpu_amps")

simDR_prop_mode0			= find_dataref("sim/cockpit2/engine/actuators/prop_mode[0]")
simDR_prop_mode1			= find_dataref("sim/cockpit2/engine/actuators/prop_mode[1]")

simDR_engine1_N2			= find_dataref("sim/cockpit2/engine/indicators/N2_percent[0]")
simDR_engine2_N2			= find_dataref("sim/cockpit2/engine/indicators/N2_percent[1]")

simDR_engine1_mixture		= find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[0]")
simDR_engine2_mixture		= find_dataref("sim/cockpit2/engine/actuators/mixture_ratio[1]")

simDR_bleed_air1_fail		= find_dataref("sim/operation/failures/rel_bleed_air_lft")
simDR_bleed_air2_fail		= find_dataref("sim/operation/failures/rel_bleed_air_rgt")

simDR_panel_brightness1		= find_dataref("sim/cockpit2/switches/panel_brightness_ratio[0]")
simDR_panel_brightness2		= find_dataref("sim/cockpit2/switches/panel_brightness_ratio[1]")
simDR_panel_brightness3		= find_dataref("sim/cockpit2/switches/panel_brightness_ratio[2]")
simDR_panel_brightness4		= find_dataref("sim/cockpit2/switches/panel_brightness_ratio[3]")

simDR_generator_1			= find_dataref("sim/cockpit2/electrical/generator_on[0]")
simDR_generator_2			= find_dataref("sim/cockpit2/electrical/generator_on[1]")

simDR_battery_on			= find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_stby_battery_on		= find_dataref("sim/cockpit2/electrical/battery_on[1]")

simDR_window_heat_on		= find_dataref("sim/cockpit2/ice/ice_window_heat_on")

simDR_engage_starter_1		= find_dataref("sim/cockpit2/engine/actuators/ignition_key[0]")
simDR_engage_starter_2		= find_dataref("sim/cockpit2/engine/actuators/ignition_key[1]")

simDR_throttle_pos_1		= find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[0]")
simDR_throttle_pos_2		= find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[1]")

simDR_speedbrake_ratio_control 	= find_dataref("sim/cockpit2/controls/speedbrake_ratio")

--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_capt_AOA_ice_on				= find_command("sim/ice/AOA_heat0_on")
simCMD_capt_AOA_ice_off				= find_command("sim/ice/AOA_heat0_off")

simCMD_fo_AOA_ice_on				= find_command("sim/ice/AOA_heat1_on")
simCMD_fo_AOA_ice_off				= find_command("sim/ice/AOA_heat1_off")

simCMD_capt_pitot_ice_on			= find_command("sim/ice/pitot_heat0_on")
simCMD_capt_pitot_ice_off			= find_command("sim/ice/pitot_heat0_off")

simCMD_fo_pitot_ice_on				= find_command("sim/ice/pitot_heat1_on")
simCMD_fo_pitot_ice_off				= find_command("sim/ice/pitot_heat1_off")

simCMD_capt_static_ice_on			= find_command("sim/ice/static_heat0_on")
simCMD_capt_static_ice_off			= find_command("sim/ice/static_heat0_off")

simCMD_fo_static_ice_on				= find_command("sim/ice/static_heat1_on")
simCMD_fo_static_ice_off			= find_command("sim/ice/static_heat1_off")

simCMD_apu_off						= find_command("sim/electrical/APU_off")
simCMD_apu_on						= find_command("sim/electrical/APU_on")
simCMD_apu_start					= find_command("sim/electrical/APU_start")

simCMD_hydro_pumps_toggle			= find_command("sim/flight_controls/hydraulic_tog")

simCMD_stall_test					= find_command("sim/annunciator/test_stall")
simCMD_xponder_ident				= find_command("sim/transponder/transponder_ident")

simCMD_nav1_standy_flip				= find_command("sim/radios/nav1_standy_flip")
simCMD_nav2_standy_flip				= find_command("sim/radios/nav2_standy_flip")

simCMD_dc_volt_left					= find_command("sim/electrical/dc_volt_lft")
simCMD_dc_volt_ctr					= find_command("sim/electrical/dc_volt_ctr")
simCMD_dc_volt_rgt					= find_command("sim/electrical/dc_volt_rgt")

simCMD_hi_lo_idle_toggle			= find_command("sim/engines/idle_hi_lo_toggle")

-- STARTER SWITCHES --

simCMD_igniter_contin_on_1			= find_command("sim/igniters/igniter_contin_on_1")
simCMD_igniter_contin_on_2			= find_command("sim/igniters/igniter_contin_on_2")
simCMD_igniter_contin_off_1			= find_command("sim/igniters/igniter_contin_off_1")
simCMD_igniter_contin_off_2			= find_command("sim/igniters/igniter_contin_off_2")

simCMD_set_takeoff_trim				= find_command("sim/flight_controls/pitch_trim_takeoff")

-- GENERATORS --

simCMD_generator1_off				= find_command("sim/electrical/generator_1_off")
simCMD_generator1_on				= find_command("sim/electrical/generator_1_on")

simCMD_generator2_off				= find_command("sim/electrical/generator_2_off")
simCMD_generator2_on				= find_command("sim/electrical/generator_2_on")

simCMD_gpu_off						= find_command("sim/electrical/GPU_off")
simCMD_gpu_on						= find_command("sim/electrical/GPU_on")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

B738DR_lights_test					= find_dataref("laminar/B738/annunciator/test")
B738DR_ground_power_avail			= find_dataref("laminar/B738/annunciator/ground_power_avail")

--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

B738DR_probes_capt_switch_pos		= create_dataref("laminar/B738/toggle_switch/capt_probes_pos", "number")
B738DR_probes_fo_switch_pos			= create_dataref("laminar/B738/toggle_switch/fo_probes_pos", "number")

B738DR_apu_start_switch_position	= create_dataref("laminar/B738/spring_toggle_switch/APU_start_pos", "number")

B738DR_hydro_pumps_switch_position	= create_dataref("laminar/B738/toggle_switch/hydro_pumps_pos", "number")

B738DR_drive_disconnect1_switch_position = create_dataref("laminar/B738/one_way_switch/drive_disconnect1_pos", "number")
B738DR_drive_disconnect2_switch_position = create_dataref("laminar/B738/one_way_switch/drive_disconnect2_pos", "number")

B738DR_pas_oxy_switch_position = create_dataref("laminar/B738/one_way_switch/pax_oxy_pos", "number")

B738DR_bleed_air_1_switch_position = create_dataref("laminar/B738/toggle_switch/bleed_air_1_pos", "number")
B738DR_bleed_air_2_switch_position = create_dataref("laminar/B738/toggle_switch/bleed_air_2_pos", "number")
B738DR_bleed_air_apu_switch_position = create_dataref("laminar/B738/toggle_switch/bleed_air_apu_pos", "number")

B738DR_dual_bleed_annun = create_dataref("laminar/B738/annunciator/dual_bleed", "number")

B738DR_trip_reset_button_pos = create_dataref("laminar/B738/push_button/trip_reset", "number")

B738DR_duct_pressure_L = create_dataref("laminar/B738/indicators/duct_press_L", "number")
B738DR_duct_pressure_R = create_dataref("laminar/B738/indicators/duct_press_R", "number")

B738DR_cross_feed_selector_knob = create_dataref("laminar/B738/knobs/cross_feed", "number")

B738DR_stall_test1	= create_dataref("laminar/B738/push_button/stall_test1", "number")
B738DR_stall_test2	= create_dataref("laminar/B738/push_button/stall_test2", "number")

B738DR_transponder_knob_pos = create_dataref("laminar/B738/knob/transponder_pos", "number")
B738DR_transponder_ident_button = create_dataref("laminar/B738/push_button/transponder_ident", "number")

B738DR_nav1_freq_flip_button = create_dataref("laminar/B738/push_button/switch_freq_nav1", "number")
B738DR_nav2_freq_flip_button = create_dataref("laminar/B738/push_button/switch_freq_nav2", "number")

B738DR_dc_power_knob_pos	= create_dataref("laminar/B738/knob/dc_power", "number")
B738DR_ac_power_knob_pos	= create_dataref("laminar/B738/knob/ac_power", "number")

B738DR_ac_freq_mode0		= create_dataref("laminar/B738/ac_freq_mode0", "number")
B738DR_ac_freq_mode1		= create_dataref("laminar/B738/ac_freq_mode1", "number")
B738DR_ac_freq_mode2		= create_dataref("laminar/B738/ac_freq_mode2", "number")
B738DR_ac_freq_mode3		= create_dataref("laminar/B738/ac_freq_mode3", "number")
B738DR_ac_freq_mode4		= create_dataref("laminar/B738/ac_freq_mode4", "number")
B738DR_ac_freq_mode5		= create_dataref("laminar/B738/ac_freq_mode5", "number")

B738DR_ac_volt_mode1		= create_dataref("laminar/B738/ac_volt_mode1", "number")
B738DR_ac_volt_mode2		= create_dataref("laminar/B738/ac_volt_mode2", "number")		
B738DR_ac_volt_mode3		= create_dataref("laminar/B738/ac_volt_mode3", "number")
B738DR_ac_volt_mode4		= create_dataref("laminar/B738/ac_volt_mode4", "number")
B738DR_ac_volt_mode5		= create_dataref("laminar/B738/ac_volt_mode5", "number")

B738DR_prop_mode_sync		= create_dataref("laminar/B738/engine/prop_mode_sync", "number")

B738DR_idle_mode_request	= create_dataref("laminar/B738/engine/idle_mode_request", "number")

-- STARTER SWITCH POSITIONS

B738DR_starter_1_pos		= create_dataref("laminar/B738/spring_knob/starter_1", "number")
B738DR_starter_2_pos		= create_dataref("laminar/B738/spring_knob/starter_2", "number")

--B738DR_ground_timer		= create_dataref("laminar/B738/diagnostics/ground_timer", "number")
--B738DR_air_mode			= create_dataref("laminar/B738/diagnostics/air_mode", "number")


B738DR_condition_lever1		= create_dataref("laminar/B738/engine/slider/condition_lever1", "number")
B738DR_condition_lever2		= create_dataref("laminar/B738/engine/slider/condition_lever2", "number")


-- GENERATOR SWITCH POSITIONS -1,0,1

-- GEN1/2

B738DR_generator1_switch_pos	= create_dataref("laminar/B738/electrical/gen1_pos", "number")
B738DR_generator2_switch_pos	= create_dataref("laminar/B738/electrical/gen2_pos", "number")

-- APU 

B738DR_apu_genL_switch_pos		= create_dataref("laminar/B738/electrical/apu_genL_pos", "number")
B738DR_apu_genR_switch_pos		= create_dataref("laminar/B738/electrical/apu_genR_pos", "number")

B738DR_apu_genL_status			= create_dataref("laminar/B738/electrical/apu_genL_status", "number")
B738DR_apu_genR_status			= create_dataref("laminar/B738/electrical/apu_genR_status", "number")

-- GPU

B738DR_gpu_switch_pos			= create_dataref("laminar/B738/electrical/gpu_pos", "number")

-- AI

B738DR_init_systems_CD          = create_dataref("laminar/B738/init_CD/systems", "number")

-- TEST

-- B738DR_austin_sb				= create_dataref("laminar/B738/test/austin_sb", "number")
-- B738DR_alex_sb				= create_dataref("laminar/B738/test/alex_sb", "number")


--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

-- LANDING ALTITUDE SELECTOR
function B738DR_landing_alt_sel_rheo_DRhandler() end


-- CONT CAB TEMP CONTROL
function B738DR_cont_cab_temp_ctrl_rheo_DRhandler() end


-- FWD CAB TEMP CONTROL
function B738DR_fwd_cab_temp_ctrl_rheo_DRhandler() end


-- AFT CAB TEMP CONTROL
function B738DR_aft_cab_temp_ctrl_rheo_DRhandler() end


function B738DR_land_alt_knob_DRhandler()end

function B738DR_condition_lever1_target_DRhandler()end
function B738DR_condition_lever2_target_DRhandler()end

function B738DR_flap_lever_stop_pos_DRhandler()end

----- SPEEDBRAKE LEVER ------------------------------------------------------------------
function B738_speedbrake_lever_DRhandler()
	


	if B738_speedbrake_stop == 1 then

		if B738DR_speedbrake_lever < 0.15 then
			if B738DR_speedbrake_lever < 0.07 then
				simDR_speedbrake_ratio_control = 0.0
			elseif B738DR_speedbrake_lever < 0.11 and B738DR_speedbrake_lever > 0.06 then
				B738DR_speedbrake_lever = 0.0889
		    	simDR_speedbrake_ratio_control = -0.5
		    elseif B738DR_speedbrake_lever > 0.11 then
		    	simDR_speedbrake_ratio_control = 0.0
			end
		elseif B738DR_speedbrake_lever > 0.15 then
			B738DR_speedbrake_lever = math.min(0.667, B738DR_speedbrake_lever)
			local spdbrake_lever_stopped = B738_rescale(0.15, 0, 0.667, 0.9899999, B738DR_speedbrake_lever)
		
			simDR_speedbrake_ratio_control = spdbrake_lever_stopped
		end

	elseif B738_speedbrake_stop == 0 then

		if B738DR_speedbrake_lever < 0.15 then
			if B738DR_speedbrake_lever < 0.07 then
				simDR_speedbrake_ratio_control = 0.0
			elseif B738DR_speedbrake_lever < 0.11 and B738DR_speedbrake_lever > 0.07 then
				B738DR_speedbrake_lever = 0.0889
		    	simDR_speedbrake_ratio_control = -0.5
		    elseif B738DR_speedbrake_lever > 0.11 then
		    	simDR_speedbrake_ratio_control = 0.0
			end
		elseif B738DR_speedbrake_lever > 0.15 and B738DR_speedbrake_lever <= 0.667 then
			local spdbrake_lever_open = B738_rescale(0.15, 0, 0.667, 0.9899999, B738DR_speedbrake_lever)

			simDR_speedbrake_ratio_control = spdbrake_lever_open

		elseif B738DR_speedbrake_lever > 0.667 then
			local spdbrake_lever_open_ground = B738_rescale(0.667, 0.99, 1, 1, B738DR_speedbrake_lever)

			simDR_speedbrake_ratio_control = spdbrake_lever_open_ground

		end

	end

end

function B738_speedbrake_stop_pos_DRhandler()end


--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

-- LANDING ALTITUDE SELECTOR
B738DR_landing_alt_sel_rheo		= create_dataref("laminar/B738/air/land_alt_sel/rheostat", "number", B738DR_landing_alt_sel_rheo_DRhandler)


-- CONT CAB TEMP CONTROL
B738DR_cont_cab_temp_ctrl_rheo	= create_dataref("laminar/B738/air/cont_cab_temp/rheostat", "number", B738DR_cont_cab_temp_ctrl_rheo_DRhandler)


-- FWD CAB TEMP CONTROL
B738DR_fwd_cab_temp_ctrl_rheo 	= create_dataref("laminar/B738/air/fwd_cab_temp/rheostat", "number", B738DR_fwd_cab_temp_ctrl_rheo_DRhandler)


-- AFT CAB TEMP CONTROL
B738DR_aft_cab_temp_ctrl_rheo	= create_dataref("laminar/B738/air/aft_cab_temp/rheostat", "number", B738DR_aft_cab_temp_ctrl_rheo_DRhandler)


B738DR_land_alt_knob 			= create_dataref("laminar/B738/pressurization/knobs/landing_alt", "number", B738DR_land_alt_knob_DRhandler)

B738DR_condition_lever1_target	= create_dataref("laminar/B738/engine/slider/condition_lever1_target", "number", B738DR_condition_lever1_target_DRhandler)
B738DR_condition_lever2_target	= create_dataref("laminar/B738/engine/slider/condition_lever2_target", "number", B738DR_condition_lever2_target_DRhandler)

B738DR_flap_lever_stop_pos		= create_dataref("laminar/B738/handles/flap_lever/stop_pos", "number", B738DR_flap_lever_stop_pos_DRhandler)

----- SPEEDBRAKE HANDLE -----------------------------------------------------------------

B738DR_speedbrake_lever     	= create_dataref("laminar/B738/flt_ctrls/speedbrake_lever", "number", B738_speedbrake_lever_DRhandler)

B738DR_speedbrake_stop_pos		= create_dataref("laminar/B738/flt_ctrls/speedbrake_lever_stop", "number", B738_speedbrake_stop_pos_DRhandler)

--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--




-- CAPTAIN ANTI ICE PROBES 
function B738_probes_capt_switch_pos_on_CMDhandler(phase, duration)
 	if phase == 0 then
 		if B738DR_probes_capt_switch_pos == 0 then
 			B738DR_probes_capt_switch_pos = 1
 			simCMD_capt_AOA_ice_on:once()
			simCMD_capt_pitot_ice_on:once()
			simCMD_capt_static_ice_on:once()
		end
	end
end

function B738_probes_capt_switch_pos_off_CMDhandler(phase, duration)
 	if phase == 0 then
 		if B738DR_probes_capt_switch_pos == 1 then
 			B738DR_probes_capt_switch_pos = 0
 			simCMD_capt_AOA_ice_off:once()
			simCMD_capt_pitot_ice_off:once()
			simCMD_capt_static_ice_off:once()
		end
	end
end

-- F/0 ANTI ICE PROBES 
function B738_probes_fo_switch_pos_on_CMDhandler(phase, duration)
 	if phase == 0 then
 		if B738DR_probes_fo_switch_pos == 0 then
 			B738DR_probes_fo_switch_pos = 1
 			simCMD_fo_AOA_ice_on:once()
			simCMD_fo_pitot_ice_on:once()
			simCMD_fo_static_ice_on:once()
		end
	end
end

function B738_probes_fo_switch_pos_off_CMDhandler(phase, duration)
 	if phase == 0 then
 		if B738DR_probes_fo_switch_pos == 1 then
 			B738DR_probes_fo_switch_pos = 0
 			simCMD_fo_AOA_ice_off:once()
			simCMD_fo_pitot_ice_off:once()
			simCMD_fo_static_ice_off:once()
		end
	end
end


-- APU START SWITCH


function B738_apu_starter_switch_pos_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_apu_start_switch_position == 1 then			-- ON
            B738DR_apu_start_switch_position = 0				-- OFF
            simCMD_apu_off:once()
        end		
    end
end


function B738_apu_starter_switch_neg_CMDhandler(phase, duration)
	if phase == 0 then
        if B738DR_apu_start_switch_position == 0 then			-- OFF
            B738DR_apu_start_switch_position = 1				-- ON
            simCMD_apu_on:once()
        elseif B738DR_apu_start_switch_position == 1 then		-- ON
            B738DR_apu_start_switch_position = 2				-- START
            simCMD_apu_start:start() 
        end
    elseif phase == 2 then
    	if B738DR_apu_start_switch_position == 2 then			-- START
    		B738DR_apu_start_switch_position = 1				-- ON
    		simCMD_apu_start:stop() 
    		simCMD_apu_on:once()           
        end		
	end			
end	


-- DRIVE DISCONNECT

function B738_drive_disconnect1_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_drive_disconnect1_switch_position == 0 then
		B738DR_drive_disconnect1_switch_position = 1
		simDR_generator1_failure = 6
		simCMD_generator1_off:once()
		end
	end
end


function B738_drive_disconnect2_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_drive_disconnect2_switch_position == 0 then
		B738DR_drive_disconnect2_switch_position = 1
		simDR_generator2_failure = 6
		simCMD_generator2_off:once()
		end
	end
end

function B738_drive_disconnect1_off_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_drive_disconnect1_switch_position == 1 then
		B738DR_drive_disconnect1_switch_position = 0
		end
	end
end

function B738_drive_disconnect2_off_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_drive_disconnect2_switch_position == 1 then
		B738DR_drive_disconnect2_switch_position = 0
		end
	end
end


function drive_disconnect_reset()

	if simDR_generator1_failure == 0 then
	B738DR_drive_disconnect1_switch_position = 0
	end
	
	if simDR_generator2_failure == 0 then
	B738DR_drive_disconnect2_switch_position = 0
	end
	
end
	

-- PAX OXYGEN

function B738_pax_oxy_on_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_pas_oxy_switch_position == 0 then
		B738DR_pas_oxy_switch_position = 1
		pax_oxy = 6
		end
	end
end

function B738_pax_oxy_norm_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_pas_oxy_switch_position == 1 then
		B738DR_pas_oxy_switch_position = 0
		pax_oxy = 0
		end
	end
end

function trip_oxy_on()
	
	local cab_alt_status = 0
		if simDR_cabin_alt > 14000 then
		cab_alt_status = 6
		end
		
	if pax_oxy == 6 then
	simDR_pax_oxy = 6
	elseif cab_alt_status == 6 then
	simDR_pax_oxy = 6
	end

end


-- ENGINE HYDRO PUMPS
function B738_hydro_pumps_switch_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_hydro_pumps_switch_position = 1 - B738DR_hydro_pumps_switch_position
		simCMD_hydro_pumps_toggle:once()					
	end	
end

-- BLEED AIR

function B738_bleed_air_1_on_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_bleed_air_1_switch_position == 0 then
		B738DR_bleed_air_1_switch_position = 1
		end
	end
end

function B738_bleed_air_1_off_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_bleed_air_1_switch_position == 1 then
		B738DR_bleed_air_1_switch_position = 0
		end
	end
end

function B738_bleed_air_2_on_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_bleed_air_2_switch_position == 0 then
		B738DR_bleed_air_2_switch_position = 1
		end
	end
end

function B738_bleed_air_2_off_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_bleed_air_2_switch_position == 1 then
		B738DR_bleed_air_2_switch_position = 0
		end
	end
end

function B738_bleed_air_apu_on_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_bleed_air_apu_switch_position == 0 then
		B738DR_bleed_air_apu_switch_position = 1
		end
	end
end

function B738_bleed_air_apu_off_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_bleed_air_apu_switch_position == 1 then
		B738DR_bleed_air_apu_switch_position = 0
		end
	end
end

function B738_trip_reset_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_trip_reset_button_pos == 0 then
			B738DR_trip_reset_button_pos = 1
			simDR_bleed_fail_1 = 0
			simDR_bleed_fail_2 = 0
		end
	elseif phase == 2 then
		if B738DR_trip_reset_button_pos == 1 then
			B738DR_trip_reset_button_pos = 0		
		end
	end
end
		
function B738_crossfeed_valve_on_CMDhandler(phase, duration)
	if phase == 0 then
		if B738_cross_feed_selector_knob_target == 0 then
		B738_cross_feed_selector_knob_target = 1
		end
	end
end

function B738_crossfeed_valve_off_CMDhandler(phase, duration)
	if phase == 0 then
		if B738_cross_feed_selector_knob_target == 1 then
		B738_cross_feed_selector_knob_target = 0
		end
	end
end

-- STALL TEST

function B738_stall_test1_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_aircraft_on_ground == 1 then
			B738DR_stall_test1 = 1
			simCMD_stall_test:start()
		elseif simDR_aircraft_on_ground == 0 then
			B738DR_stall_test1 = 1
		end
	elseif phase == 2 then
		B738DR_stall_test1 = 0
		simCMD_stall_test:stop()
	end
end

function B738_stall_test2_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_aircraft_on_ground == 1 then
			B738DR_stall_test2 = 1
			simCMD_stall_test:start()
		elseif simDR_aircraft_on_ground == 0 then
			B738DR_stall_test2 = 1
		end
	elseif phase == 2 then
		B738DR_stall_test2 = 0
		simCMD_stall_test:stop()
	end
end

function B738_xponder_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_transponder_knob_pos == 0 then
		B738DR_transponder_knob_pos = 1
		simDR_transponder_mode = 1
	elseif B738DR_transponder_knob_pos == 1 then
		B738DR_transponder_knob_pos = 2
		simDR_transponder_mode = 2
	elseif B738DR_transponder_knob_pos == 2 then
		B738DR_transponder_knob_pos = 3
		simDR_transponder_mode = 2
	elseif B738DR_transponder_knob_pos == 3 then
		B738DR_transponder_knob_pos = 4
		simDR_transponder_mode = 2
	elseif B738DR_transponder_knob_pos == 4 then
		B738DR_transponder_knob_pos = 5
		simDR_transponder_mode = 2
		end
	end
end

function B738_xponder_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_transponder_knob_pos == 5 then
		B738DR_transponder_knob_pos = 4
		simDR_transponder_mode = 2
	elseif B738DR_transponder_knob_pos == 4 then
		B738DR_transponder_knob_pos = 3
		simDR_transponder_mode = 2
	elseif B738DR_transponder_knob_pos == 3 then
		B738DR_transponder_knob_pos = 2
		simDR_transponder_mode = 2
	elseif B738DR_transponder_knob_pos == 2 then
		B738DR_transponder_knob_pos = 1
		simDR_transponder_mode = 1
	elseif B738DR_transponder_knob_pos == 1 then
		B738DR_transponder_knob_pos = 0
		simDR_transponder_mode = 3
		end
	end
end

function B738_xponder_ident_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_transponder_ident_button = 1
		simCMD_xponder_ident:once()
	elseif phase == 2 then
		B738DR_transponder_ident_button = 0
	end
end
	
function B738_nav1_freq_flip_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_nav1_freq_flip_button = 1
		simCMD_nav1_standy_flip:start()
	elseif phase == 2 then
		B738DR_nav1_freq_flip_button = 0
		simCMD_nav1_standy_flip:stop()
	end
end

function B738_nav2_freq_flip_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_nav2_freq_flip_button = 1
		simCMD_nav2_standy_flip:start()
	elseif phase == 2 then
		B738DR_nav2_freq_flip_button = 0
		simCMD_nav2_standy_flip:stop()
	end
end

-- AC POWER KNOB


function B738_ac_power_knob_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_ac_power_knob_pos == 0 then
			B738DR_ac_power_knob_pos = 1
		elseif B738DR_ac_power_knob_pos == 1 then
			B738DR_ac_power_knob_pos = 2
		elseif B738DR_ac_power_knob_pos == 2 then
			B738DR_ac_power_knob_pos = 3
		elseif B738DR_ac_power_knob_pos == 3 then
			B738DR_ac_power_knob_pos = 4
		elseif B738DR_ac_power_knob_pos == 4 then
			B738DR_ac_power_knob_pos = 5
		elseif B738DR_ac_power_knob_pos == 5 then
			B738DR_ac_power_knob_pos = 6
		end
	end
end

function B738_ac_power_knob_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_ac_power_knob_pos == 6 then
			B738DR_ac_power_knob_pos = 5
		elseif B738DR_ac_power_knob_pos == 5 then
			B738DR_ac_power_knob_pos = 4
		elseif B738DR_ac_power_knob_pos == 4 then
			B738DR_ac_power_knob_pos = 3
		elseif B738DR_ac_power_knob_pos == 3 then
			B738DR_ac_power_knob_pos = 2
		elseif B738DR_ac_power_knob_pos == 2 then
			B738DR_ac_power_knob_pos = 1
		elseif B738DR_ac_power_knob_pos == 1 then
			B738DR_ac_power_knob_pos = 0
		end
	end
end

-- DC POWER KNOB			


function B738_dc_power_knob_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_dc_power_knob_pos == 0 then
			B738DR_dc_power_knob_pos = 1
		elseif B738DR_dc_power_knob_pos == 1 then
			B738DR_dc_power_knob_pos = 2
		elseif B738DR_dc_power_knob_pos == 2 then
			B738DR_dc_power_knob_pos = 3
			simCMD_dc_volt_left:once()
		elseif B738DR_dc_power_knob_pos == 3 then
			B738DR_dc_power_knob_pos = 4
			simCMD_dc_volt_rgt:once()
		elseif B738DR_dc_power_knob_pos == 4 then
			B738DR_dc_power_knob_pos = 5
			simCMD_dc_volt_ctr:once()
		elseif B738DR_dc_power_knob_pos == 5 then
			B738DR_dc_power_knob_pos = 6
		end
	end
end

function B738_dc_power_knob_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_dc_power_knob_pos == 6 then
			B738DR_dc_power_knob_pos = 5
			simCMD_dc_volt_ctr:once()
		elseif B738DR_dc_power_knob_pos == 5 then
			B738DR_dc_power_knob_pos = 4
			simCMD_dc_volt_rgt:once()
		elseif B738DR_dc_power_knob_pos == 4 then
			B738DR_dc_power_knob_pos = 3
			simCMD_dc_volt_left:once()
		elseif B738DR_dc_power_knob_pos == 3 then
			B738DR_dc_power_knob_pos = 2
		elseif B738DR_dc_power_knob_pos == 2 then
			B738DR_dc_power_knob_pos = 1
		elseif B738DR_dc_power_knob_pos == 1 then
			B738DR_dc_power_knob_pos = 0
		end
	end
end

-- STARTER KNOBS --

function B738_starter1_knob_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_starter_1_pos == -1 then
			B738DR_starter_1_pos = 0
		elseif B738DR_starter_1_pos == 0 then
			B738DR_starter_1_pos = 1
			simCMD_igniter_contin_on_1:once()
		elseif B738DR_starter_1_pos == 1 then
			B738DR_starter_1_pos = 2
		end
	end
end

function B738_starter1_knob_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_starter_1_pos == 2 then
			B738DR_starter_1_pos = 1
		elseif B738DR_starter_1_pos == 1 then
			B738DR_starter_1_pos = 0
			simCMD_igniter_contin_off_1:once()
		elseif B738DR_starter_1_pos == 0 then
			B738DR_starter_1_pos = -1
		end
	end
end

function B738_starter2_knob_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_starter_2_pos == -1 then
			B738DR_starter_2_pos = 0
		elseif B738DR_starter_2_pos == 0 then
			B738DR_starter_2_pos = 1
			simCMD_igniter_contin_on_2:once()
		elseif B738DR_starter_2_pos == 1 then
			B738DR_starter_2_pos = 2
		end
	end
end

function B738_starter2_knob_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_starter_2_pos == 2 then
			B738DR_starter_2_pos = 1
		elseif B738DR_starter_2_pos == 1 then
			B738DR_starter_2_pos = 0
			simCMD_igniter_contin_off_2:once()
		elseif B738DR_starter_2_pos == 0 then
			B738DR_starter_2_pos = -1
		end
	end
end
		

function B738_starter1_engage_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_starter_1_pos ~= -1 then
			B738DR_starter_1_pos = -1
			simCMD_igniter_contin_off_1:once()
		elseif B738DR_starter_1_pos == -1 then
			B738DR_starter_1_pos = 0
		end
	end
end


function B738_starter2_engage_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_starter_2_pos ~= -1 then
			B738DR_starter_2_pos = -1
			simCMD_igniter_contin_off_2:once()
		elseif B738DR_starter_2_pos == -1 then
			B738DR_starter_2_pos = 0
		end
	end
end



-- GENERATOR SWITCH

function B738_gen1_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_generator1_switch_pos = -1
		simCMD_generator1_off:once()
	elseif phase == 2 then
		B738DR_generator1_switch_pos = 0
	end
end

function B738_gen1_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_generator1_switch_pos = 1
		simCMD_generator1_on:once()
		simCMD_gpu_off:once()
	elseif phase == 2 then
		B738DR_generator1_switch_pos = 0
	end
end

function B738_gen2_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_generator2_switch_pos = -1
		simCMD_generator2_off:once()
	elseif phase == 2 then
		B738DR_generator2_switch_pos = 0
	end
end

function B738_gen2_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_generator2_switch_pos = 1
		simCMD_generator2_on:once()
		simCMD_gpu_off:once()
	elseif phase == 2 then
		B738DR_generator2_switch_pos = 0
	end
end

-- APU GENERATORS

function B738_apuL_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_apu_genL_switch_pos = -1
		B738DR_apu_genL_status = 0
	elseif phase == 2 then
		B738DR_apu_genL_switch_pos = 0		
	end
end

function B738_apuL_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_apu_genL_switch_pos = 1
		B738DR_apu_genL_status = 1
		simCMD_gpu_off:once()
	elseif phase == 2 then
		B738DR_apu_genL_switch_pos = 0		
	end
end

function B738_apuR_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_apu_genR_switch_pos = -1
		B738DR_apu_genR_status = 0
	elseif phase == 2 then
		B738DR_apu_genR_switch_pos = 0		
	end
end

function B738_apuR_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_apu_genR_switch_pos = 1
		B738DR_apu_genR_status = 1
		simCMD_gpu_off:once()
	elseif phase == 2 then
		B738DR_apu_genR_switch_pos = 0		
	end
end

-- GPU

function B738_gpu_switch_pos_up_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_gpu_switch_pos = -1
		simCMD_gpu_off:once()
	elseif phase == 2 then
		B738DR_gpu_switch_pos = 0
	end
end		


function B738_gpu_switch_pos_dn_CMDhandler(phase, duration)
	if B738DR_ground_power_avail == 1 then
		if phase == 0 then
			B738DR_gpu_switch_pos = 1
			simCMD_gpu_on:once()
			B738DR_apu_genL_status = 0
			B738DR_apu_genR_status = 0
			simCMD_generator1_off:once()
			simCMD_generator2_off:once()
		elseif phase == 2 then
			B738DR_gpu_switch_pos = 0
		end
	elseif B738DR_ground_power_avail == 0 then
		if phase == 0 then
			B738DR_gpu_switch_pos = 1
		elseif phase == 2 then
			B738DR_gpu_switch_pos = 0
		end
	end
end

-- AI

function B738_ai_systems_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	B738_set_systems_all_modes()
	  	B738_set_systems_CD() 
	  	B738_set_systems_ER()
	end 	
end	
		


--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

-- FUEL CROSSFEED VALVE 

B738CMD_crossfeed_valve_on			= create_command("laminar/B738/toggle_switch/crossfeed_valve_on", "Fuel Crossfeed On", B738_crossfeed_valve_on_CMDhandler)
B738CMD_crossfeed_valve_off			= create_command("laminar/B738/toggle_switch/crossfeed_valve_off", "Fuel Crossfeed Off", B738_crossfeed_valve_off_CMDhandler)

-- CAPTAIN ANTI ICE PROBES
B738CMD_probes_capt_switch_pos_on 	= create_command("laminar/B738/toggle_switch/capt_probes_pos_on", "Probe Heat A On", B738_probes_capt_switch_pos_on_CMDhandler)
B738CMD_probes_capt_switch_pos_off 	= create_command("laminar/B738/toggle_switch/capt_probes_pos_off", "Probe Heat A Off", B738_probes_capt_switch_pos_off_CMDhandler)


-- F/O ANTI ICE PROBES
B738CMD_probes_fo_switch_pos_on 	= create_command("laminar/B738/toggle_switch/fo_probes_pos_on", "Probe Heat B On", B738_probes_fo_switch_pos_on_CMDhandler)
B738CMD_probes_fo_switch_pos_off	= create_command("laminar/B738/toggle_switch/fo_probes_pos_off", "Probe Heat B Off", B738_probes_fo_switch_pos_off_CMDhandler)


-- APU STARTER SWITCH
B738CMD_apu_starter_switch_up	= create_command("laminar/B738/spring_toggle_switch/APU_start_pos_up", "APU Start Switch UP", B738_apu_starter_switch_pos_CMDhandler)
B738CMD_apu_starter_switch_dn	= create_command("laminar/B738/spring_toggle_switch/APU_start_pos_dn", "APU Start Switch Down", B738_apu_starter_switch_neg_CMDhandler)

-- ENGINE HYDRO PUMPS
B738CMD_hydro_pumps_switch		= create_command("laminar/B738/toggle_switch/hydro_pumps", "Engine Hydraulic Pumps", B738_hydro_pumps_switch_CMDhandler)
		

-- DRIVE DISCONNECT

B738CMD_drive_disconnect1 = create_command("laminar/B738/one_way_switch/drive_disconnect1", "Drive Disconnect 1", B738_drive_disconnect1_CMDhandler)
B738CMD_drive_disconnect2 = create_command("laminar/B738/one_way_switch/drive_disconnect2", "Drive Disconnect 2", B738_drive_disconnect2_CMDhandler)

B738CMD_drive_disconnect1_off = create_command("laminar/B738/one_way_switch/drive_disconnect1_off", "Drive Disconnect 1 off", B738_drive_disconnect1_off_CMDhandler)
B738CMD_drive_disconnect2_off = create_command("laminar/B738/one_way_switch/drive_disconnect2_off", "Drive Disconnect 2 off", B738_drive_disconnect2_off_CMDhandler)

B738CMD_pax_oxy_on = create_command("laminar/B738/one_way_switch/pax_oxy_on", "Passenger Oxygen On", B738_pax_oxy_on_CMDhandler)
B738CMD_pax_oxy_norm = create_command("laminar/B738/one_way_switch/pax_oxy_norm", "Passenger Oxygen Normal", B738_pax_oxy_norm_CMDhandler)

-- BLEED AIR

B738CMD_bleed_air_1_on = create_command("laminar/B738/toggle_switch/bleed_air_1_on", "Bleed Air Eng1 On", B738_bleed_air_1_on_CMDhandler)
B738CMD_bleed_air_1_off = create_command("laminar/B738/toggle_switch/bleed_air_1_off", "Bleed Air Eng1 Off", B738_bleed_air_1_off_CMDhandler)
B738CMD_bleed_air_2_on = create_command("laminar/B738/toggle_switch/bleed_air_2_on", "Bleed Air Eng2 On", B738_bleed_air_2_on_CMDhandler)
B738CMD_bleed_air_2_off = create_command("laminar/B738/toggle_switch/bleed_air_2_off", "Bleed Air Eng2 Off", B738_bleed_air_2_off_CMDhandler)
B738CMD_bleed_air_apu_on = create_command("laminar/B738/toggle_switch/bleed_air_apu_on", "Bleed Air APU On", B738_bleed_air_apu_on_CMDhandler)
B738CMD_bleed_air_apu_off = create_command("laminar/B738/toggle_switch/bleed_air_apu_off", "Bleed Air APU Off", B738_bleed_air_apu_off_CMDhandler)

B738CMD_trip_reset = create_command("laminar/B738/push_button/bleed_trip_reset", "Bleed Air Trip Reset", B738_trip_reset_CMDhandler)

-- STALL TESTS

B738CMD_stall_test1 = create_command("laminar/B738/push_button/stall_test1_press", "Stall Test 1", B738_stall_test1_CMDhandler)
B738CMD_stall_test2 = create_command("laminar/B738/push_button/stall_test2_press", "Stall Test 2", B738_stall_test2_CMDhandler)

-- TRANSPONDER MODES

B738CMD_xponder_mode_up = create_command("laminar/B738/knob/transponder_mode_up", "Transponder Mode Up", B738_xponder_up_CMDhandler)
B738CMD_xponder_mode_dn = create_command("laminar/B738/knob/transponder_mode_dn", "Transponder Mode DN", B738_xponder_dn_CMDhandler)

B738CMD_xponder_ident = create_command("laminar/B738/push_button/transponder_ident_dn", "Transponder IDENT", B738_xponder_ident_CMDhandler)

B738CMD_nav1_freq_flip = create_command("laminar/B738/push_button/switch_freq_nav1_press", "NAV 1 Frequency Swap", B738_nav1_freq_flip_CMDhandler)
B738CMD_nav2_freq_flip = create_command("laminar/B738/push_button/switch_freq_nav2_press", "NAV 2 Frequency Swap", B738_nav2_freq_flip_CMDhandler)

-- ELECTRICAL PANEL KNOBS

B738CMD_ac_power_knob_up	= create_command("laminar/B738/knob/ac_power_up", "AC POWER PANEL Up", B738_ac_power_knob_up_CMDhandler)
B738CMD_ac_power_knob_dn	= create_command("laminar/B738/knob/ac_power_dn", "AC POWER PANEL Down", B738_ac_power_knob_dn_CMDhandler)

B738CMD_dc_power_knob_up	= create_command("laminar/B738/knob/dc_power_up", "DC POWER PANEL Up", B738_dc_power_knob_up_CMDhandler)
B738CMD_dc_power_knob_dn	= create_command("laminar/B738/knob/dc_power_dn", "DC POWER PANEL Down", B738_dc_power_knob_dn_CMDhandler)

-- STARTER KNOBS

B738CMD_starter1_knob_up	= create_command("laminar/B738/knob/starter1_up", "Starter 1 UP", B738_starter1_knob_up_CMDhandler)
B738CMD_starter1_knob_dn	= create_command("laminar/B738/knob/starter1_dn", "Starter 1 DOWN", B738_starter1_knob_dn_CMDhandler)

B738CMD_starter2_knob_up	= create_command("laminar/B738/knob/starter2_up", "Starter 2 UP", B738_starter2_knob_up_CMDhandler)
B738CMD_starter2_knob_dn	= create_command("laminar/B738/knob/starter2_dn", "Starter 2 DOWN", B738_starter2_knob_dn_CMDhandler)

-- GENERATOR SWITCHES

B738CMD_gen1_switch_up		= create_command("laminar/B738/switch/gen1_up", "Generator 1 OFF", B738_gen1_switch_up_CMDhandler)
B738CMD_gen1_switch_dn		= create_command("laminar/B738/switch/gen1_dn", "Generator 1 ON", B738_gen1_switch_dn_CMDhandler)

B738CMD_gen2_switch_up		= create_command("laminar/B738/switch/gen2_up", "Generator 2 OFF", B738_gen2_switch_up_CMDhandler)
B738CMD_gen2_switch_dn		= create_command("laminar/B738/switch/gen2_dn", "Generator 2 ON", B738_gen2_switch_dn_CMDhandler)

B738CMD_apuL_switch_up		= create_command("laminar/B738/switch/apuL_up", "APU Gen L OFF", B738_apuL_switch_up_CMDhandler)
B738CMD_apuL_switch_dn		= create_command("laminar/B738/switch/apuL_dn", "APU Gen L ON", B738_apuL_switch_dn_CMDhandler)

B738CMD_apuR_switch_up		= create_command("laminar/B738/switch/apuR_up", "APU Gen R OFF", B738_apuR_switch_up_CMDhandler)
B738CMD_apuR_switch_dn		= create_command("laminar/B738/switch/apuR_dn", "APU Gen R ON", B738_apuR_switch_dn_CMDhandler)

-- GPU

B738CMD_gpu_pos_up			= create_command("laminar/B738/toggle_switch/gpu_pos_up", "GPU Off", B738_gpu_switch_pos_up_CMDhandler)
B738CMD_gpu_pos_dn			= create_command("laminar/B738/toggle_switch/gpu_pos_dn", "GPU On", B738_gpu_switch_pos_dn_CMDhandler)

-- AI

B738CMD_ai_systems_quick_start		= create_command("laminar/B738/ai/systems_quick_start", "number", B738_ai_systems_quick_start_CMDhandler)

--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--

-- SPEEDBRAKE LEVER
function sim_speedbrake_lever_extend_one_CMDhandler(phase, duration)
    if phase == 0 then

	    -- MOVE FROM DOWN TO ARM
		if B738DR_speedbrake_lever < 0.06 then
	   		B738DR_speedbrake_lever = 0.0889
	    
	    -- MOVE FROM ARM TO FLIGHT DETENT
	    elseif B738DR_speedbrake_lever > 0.06 and B738DR_speedbrake_lever < 0.12 then
		    B738DR_speedbrake_lever = 0.667

		-- MOVE FROM ANY DEGREE TO FLIGHT DETENT
		elseif B738DR_speedbrake_lever >= 0.12 and B738DR_speedbrake_lever < 0.666 then
			B738DR_speedbrake_lever = 0.667
	    
	    -- MOVE FROM FLIGHT DETENT TO UP
	    elseif B738DR_speedbrake_lever >= 0.666 and B738DR_speedbrake_lever < 1.0 then
	    	B738DR_speedbrake_lever = 1.0
	    end
	    B738_speedbrake_lever_DRhandler()

    end
end

function sim_speedbrake_lever_retract_one_CMDhandler(phase, duration)
    if phase == 0 then
	    
	    -- MOVE FROM UP TO FLIGHT DETENT
		if B738DR_speedbrake_lever > 0.667 then
	   		B738DR_speedbrake_lever = 0.667
	    
	    -- MOVE FROM FLIGHT DETENT TO ARM 
	    elseif B738DR_speedbrake_lever > 0.12 and B738DR_speedbrake_lever <= 0.667 then
		    B738DR_speedbrake_lever = 0.0889
	    
	    -- MOVE FROM ARM DETENT TO DOWN
	    elseif B738DR_speedbrake_lever > 0.06 and B738DR_speedbrake_lever < 0.12 then
	    	B738DR_speedbrake_lever = 0.0
	    end
	    B738_speedbrake_lever_DRhandler()
	    
    end
end




function sim_speedbrake_lever_up_CMDhandler(phase, duration)
    if phase == 0 then
        B738DR_speedbrake_lever = 1.0
        B738_speedbrake_lever_DRhandler()
    end
end

function sim_speedbrake_lever_dn_CMDhandler(phase, duration)
    if phase == 0 then
        B738DR_speedbrake_lever = 0.0
        B738_speedbrake_lever_DRhandler()
    end
end




function sim_toggle_speedbrakes_CMDhandler(phase, duration)
	if phase == 0 then
		if B738_speedbrake_stop == 1 then
			if B738DR_speedbrake_lever < 0.666 then 
				B738DR_speedbrake_lever = 1.0
			elseif B738DR_speedbrake_lever >= 0.666 then 
		    	B738DR_speedbrake_lever = 0.0
	    	end	
		    B738_speedbrake_lever_DRhandler()
		elseif B738_speedbrake_stop == 0 then
			if B738DR_speedbrake_lever < 0.667 then 
				B738DR_speedbrake_lever = 1.0
			else
		    	B738DR_speedbrake_lever = 0.0
		    end	
		    B738_speedbrake_lever_DRhandler()
		end
	end    
end



--*************************************************************************************--
--** 				             REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--

B738CMD_starter1_engage		= replace_command("sim/starters/engage_starter_1", B738_starter1_engage_CMDhandler)
B738CMD_starter2_engage		= replace_command("sim/starters/engage_starter_2", B738_starter2_engage_CMDhandler)

-- SPEEDBRAKES
simCMD_speedbrakes_extend_one   = replace_command("sim/flight_controls/speed_brakes_down_one", sim_speedbrake_lever_extend_one_CMDhandler)
simCMD_speedbrakes_retract_one  = replace_command("sim/flight_controls/speed_brakes_up_one", sim_speedbrake_lever_retract_one_CMDhandler)
simCMD_speedbrakes_extend_full  = replace_command("sim/flight_controls/speed_brakes_down_all", sim_speedbrake_lever_up_CMDhandler)
simCMD_speedbrakes_retract_full = replace_command("sim/flight_controls/speed_brakes_up_all", sim_speedbrake_lever_dn_CMDhandler)
simCMD_speedbrakes_toggle       = replace_command("sim/flight_controls/speed_brakes_toggle", sim_toggle_speedbrakes_CMDhandler)

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



----- RESCALE FLOAT AND CLAMP TO OUTER LIMITS -------------------------------------------

function B738_rescale(in1, out1, in2, out2, x)
    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end


----- ANIMATION UTILITY -----------------------------------------------------------------

function B738_set_anim_value(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * SIM_PERIOD))
    end

end


---- CONDITION LEVER ANIMATION
	
	function B738_condition_lever_anim()
	
	local condition_lever1_target = B738DR_condition_lever1_target
	local condition_lever2_target = B738DR_condition_lever2_target
	
	B738DR_condition_lever1 	= B738_set_anim_value(B738DR_condition_lever1, condition_lever1_target, 0.0, 1.0, 5.0)
	B738DR_condition_lever2		= B738_set_anim_value(B738DR_condition_lever2, condition_lever2_target, 0.0, 1.0, 5.0)	
	
	
	
	end


----- THROTTLE SYNC ------

function B738_prop_mode_sync()

	if simDR_prop_mode0 == 1
	and simDR_prop_mode1 == 1 then
		B738DR_prop_mode_sync = 0
	elseif simDR_prop_mode0 == 3
	and simDR_prop_mode1 == 3 then
		B738DR_prop_mode_sync = 1
	elseif simDR_prop_mode0 ~= simDR_prop_mode1 then
		B738DR_prop_mode_sync = 2
	end
			
--[[

0 - both forward
1 - both reverse
2 - disagree

]]--
		
end

----- APU GENERATOR -----

function B738_APU_generator()

	if B738DR_apu_genL_status == 1 or B738DR_apu_genR_status == 1 then
		simDR_apu_generator_switch = 1
	elseif B738DR_apu_genL_status == 0 and B738DR_apu_genR_status == 0 then
		simDR_apu_generator_switch = 0
	end

end
	

----- STARTER RETURNS -----

function B738_starter_knob_return()

B738_starter_1_return = function()
	B738DR_starter_1_pos = 0
	end

B738_starter_2_return = function()
	B738DR_starter_2_pos = 0
	end


	if simDR_engine1_N2 < 56
	 	and B738DR_starter_1_pos == -1 then
	 	simDR_engage_starter_1 = 4
	elseif simDR_engine1_N2 > 56
		and B738DR_starter_1_pos == -1 then
		run_after_time(B738_starter_1_return, 0.15)
	end

	if simDR_engine2_N2 < 56
	 	and B738DR_starter_2_pos == -1 then
	 	simDR_engage_starter_2 = 4
	elseif simDR_engine2_N2 > 56
		and B738DR_starter_2_pos == -1 then
		run_after_time(B738_starter_2_return, 0.15)
	end
	
end	


----- CROSSFEED KNOB POSITION ANIMATION --------------------------------------------

function B738_crossfeed_knob_animation()

   B738DR_cross_feed_selector_knob = B738_set_anim_value(B738DR_cross_feed_selector_knob, B738_cross_feed_selector_knob_target, 0.0, 1.0, 5.0)

end

-- FUEL TANK SELECTION

function B738_fuel_tank_selection()

	local tank_r_status = simDR_tank_l_status
	local tank_c_status = simDR_tank_c_status
	local tank_l_status = simDR_tank_r_status

	--simDR_fuel_selector_l		0=off, 1=left, 2=center, 3=right, 4=all
	--simDR_fuel_selector_r		0=off, 1=left, 2=center, 3=right, 4=all	
	--simDR_center_tank_level	



	if tank_r_status == 0			----- CASE 1 (0 0 0 | 0 0)
		and tank_c_status == 0
		and tank_l_status == 0 then
		simDR_fuel_selector_l = 0
		simDR_fuel_selector_r = 0
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end	

	if tank_r_status == 1			----- CASE 2 (1 0 0 | 1 0)
		and tank_c_status == 0
		and tank_l_status == 0 then
		simDR_fuel_selector_l = 1
		simDR_fuel_selector_r = 0
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end	

	if tank_r_status == 0			----- CASE 3 (0 1 0 | 2 2)
		and tank_c_status == 1
		and tank_l_status == 0 then
		simDR_fuel_selector_l = 2
		simDR_fuel_selector_r = 2
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end	

	if tank_r_status == 0			----- CASE 4 (0 0 1 | 0 3)
		and tank_c_status == 0
		and tank_l_status == 1 then
		simDR_fuel_selector_l = 0
		simDR_fuel_selector_r = 3
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end	

	if tank_r_status == 1			----- CASE 5 (1 0 1 | 1 3)
		and tank_c_status == 0
		and tank_l_status == 1 then
		simDR_fuel_selector_l = 1
		simDR_fuel_selector_r = 3
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end	

---------------------

	if tank_r_status == 1			----- CASE 6a (1 1 0 | 2 2) -- CENTER HAS FUEL
		and tank_c_status == 1
		and tank_l_status == 0
		and simDR_center_tank_level > 10 then
		simDR_fuel_selector_l = 2
		simDR_fuel_selector_r = 2
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end
	
		if tank_r_status == 1			----- CASE 6b (1 1 0 | 1 0)  -- EMPTY CENTER
		and tank_c_status == 1
		and tank_l_status == 0
		and simDR_center_tank_level < 10 then
		simDR_fuel_selector_l = 1
		simDR_fuel_selector_r = 0
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end	

---------------------
	
	if tank_r_status == 0			----- CASE 7a (0 1 1 | 2 2) -- CENTER HAS FUEL
		and tank_c_status == 1
		and tank_l_status == 1
		and simDR_center_tank_level > 10 then
		simDR_fuel_selector_l = 2
		simDR_fuel_selector_r = 2
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end	

	if tank_r_status == 0			----- CASE 7b (0 1 1 | 0 3) -- EMPTY CENTER
		and tank_c_status == 1
		and tank_l_status == 1
		and simDR_center_tank_level < 10 then
		simDR_fuel_selector_l = 0
		simDR_fuel_selector_r = 3
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end	

---------------------

	if tank_r_status == 1			----- CASE 8a (1 1 1 | 2 2) -- CENTER HAS FUEL
		and tank_c_status == 1
		and tank_l_status == 1
		and simDR_center_tank_level > 10 then
		simDR_fuel_selector_l = 2
		simDR_fuel_selector_r = 2
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end

	if tank_r_status == 1			----- CASE 8b (1 1 1 | 1 3) -- EMPTY CENTER
		and tank_c_status == 1
		and tank_l_status == 1
		and simDR_center_tank_level < 10 then
		simDR_fuel_selector_l = 1
		simDR_fuel_selector_r = 3
		elseif B738DR_cross_feed_selector_knob == 1 then  -- CROSSFEED
		simDR_fuel_selector_l = 4
		simDR_fuel_selector_r = 4
	end



	
end		
	


-- BLEED AIR MODE

function B738_bleed_air_state()

	local eng1_bleed = B738DR_bleed_air_1_switch_position
	local apu_bleed = B738DR_bleed_air_apu_switch_position
	local eng2_bleed = B738DR_bleed_air_2_switch_position
	local dual_bleed = 0
	
-- simDR_bleed_air_mode    0=off, 1=left, 2=both, 3=right, 4=apu, 5=auto	

	if eng1_bleed == 0				-- CASE 1 (0 0 0 | 0)
		and apu_bleed == 0
		and eng2_bleed == 0 then
		simDR_bleed_air_mode = 0
		dual_bleed = 0
	end
	
	if eng1_bleed == 1				-- CASE 2 (1 0 0 | 1)
		and apu_bleed == 0
		and eng2_bleed == 0 then
		simDR_bleed_air_mode = 1
		dual_bleed = 0
	end
		
	if eng1_bleed == 0				-- CASE 3 (0 1 0 | 4)
		and apu_bleed == 1
		and eng2_bleed == 0 then
		simDR_bleed_air_mode = 4
		dual_bleed = 0
	end

	if eng1_bleed == 0				-- CASE 4 (0 0 1 | 3)
		and apu_bleed == 0
		and eng2_bleed == 1 then
		simDR_bleed_air_mode = 3
		dual_bleed = 0
	end

	if eng1_bleed == 1				-- CASE 5 (1 1 0 | 5)
		and apu_bleed == 1
		and eng2_bleed == 0 then
		simDR_bleed_air_mode = 5
		dual_bleed = 1
	end

	if eng1_bleed == 0				-- CASE 6 (0 1 1 | 5)
		and apu_bleed == 1
		and eng2_bleed == 1 then
		simDR_bleed_air_mode = 5
		dual_bleed = 1
	end
	
	if eng1_bleed == 1				-- CASE 7 (1 0 1 | 2)
		and apu_bleed == 0
		and eng2_bleed == 1 then
		simDR_bleed_air_mode = 2
		dual_bleed = 0
	end
	
	if eng1_bleed == 1				-- CASE 8 (1 1 1 | 5)
		and apu_bleed == 1
		and eng2_bleed == 1 then
		simDR_bleed_air_mode = 5
		dual_bleed = 1
	end

-- DUAL BLEED ANNUN

	local bus1Power = B738_rescale(0.0, 0.0, 28.0, 1.0, simDR_electrical_bus_volts0)
	local bus2Power = B738_rescale(0.0, 0.0, 28.0, 1.0, simDR_electrical_bus_volts1)
	local busPower  = math.max(bus1Power, bus2Power)
	local brightness_level = simDR_generic_brightness_ratio63 * busPower
	
	B738DR_dual_bleed_annun = dual_bleed * brightness_level


	if B738DR_lights_test == 1 then
		B738DR_dual_bleed_annun = 1 * brightness_level
	end

end


----- BLEED AIR SUPPLY ------------------------------------------------------------------
local int, frac = math.modf(os.clock())
local seed = math.random(1, frac*1000.0)
math.randomseed(seed)
local rndm_max_apu_bleed_psi    = math.random(35, 45) + math.random()
local rndm_max_eng1_bleed_psi   = math.random(44, 56) + math.random()
local rndm_max_eng2_bleed_psi   = math.random(45, 57) + math.random()

local freq_ac_mode0				= math.random(395, 405) + math.random()
local freq_ac_mode1				= math.random(395, 405) + math.random()
local freq_ac_mode2				= math.random(395, 405) + math.random()
local freq_ac_mode3				= math.random(395, 405) + math.random()
local freq_ac_mode4				= math.random(395, 405) + math.random()
local freq_ac_mode5				= math.random(395, 405) + math.random()

local volts_ac_mode1			= math.random(112, 118) + math.random()
local volts_ac_mode2			= math.random(112, 118) + math.random()
local volts_ac_mode3			= math.random(112, 118) + math.random()
local volts_ac_mode4			= math.random(112, 118) + math.random()
local volts_ac_mode5			= math.random(112, 118) + math.random()


-- ACDC

function B738_ac_dc_power()

	if simDR_stby_power_volts == 0 then
		B738DR_ac_freq_mode0 = 0
	elseif simDR_stby_power_volts > 0 then
		B738DR_ac_freq_mode0 = freq_ac_mode0
	end
	
	
	if simDR_gpu_amps == 0 then
		B738DR_ac_freq_mode1 = 0
		B738DR_ac_volt_mode1 = 0
	elseif simDR_gpu_amps > 0 then
		B738DR_ac_freq_mode1 = freq_ac_mode1
		B738DR_ac_volt_mode1 = volts_ac_mode1
	end
	
	if simDR_gen1_amps == 0 then
		B738DR_ac_freq_mode2 = 0
		B738DR_ac_volt_mode2 = 0
	elseif simDR_gen1_amps > 0 then
		B738DR_ac_freq_mode2 = freq_ac_mode2
		B738DR_ac_volt_mode2 = volts_ac_mode2
	end

	if simDR_apu_gen_amps == 0 then
		B738DR_ac_freq_mode3 = 0
		B738DR_ac_volt_mode3 = 0
	elseif simDR_apu_gen_amps > 0 then
		B738DR_ac_freq_mode3 = freq_ac_mode3
		B738DR_ac_volt_mode3 = volts_ac_mode3
	end
	
	if simDR_gen2_amps == 0 then
		B738DR_ac_freq_mode4 = 0
		B738DR_ac_volt_mode4 = 0
	elseif simDR_gen2_amps > 0 then
		B738DR_ac_freq_mode4 = freq_ac_mode4
		B738DR_ac_volt_mode4 = volts_ac_mode4
	end

	if simDR_inverter_on == 0 then
		B738DR_ac_freq_mode5 = 0
		B738DR_ac_volt_mode5 = 0
	elseif simDR_inverter_on == 1 then
		B738DR_ac_freq_mode5 = freq_ac_mode5
		B738DR_ac_volt_mode5 = volts_ac_mode5
	end

end

-- INVERTER CONTROL

function B738_inverter_control()

	simDR_inverter_on = simDR_stby_battery_on
	
end

-- BLEED AIR CON'T

function B738_bleed_air_supply()

    -- APU
    B738bleedAir.apu.psi = B738_rescale(0, 0, 100.0, rndm_max_apu_bleed_psi, simDR_apu_N1_pct)

    -- ENGINE 1
    B738bleedAir.engine1.psi = B738_rescale(0, 0, 100.0, rndm_max_eng1_bleed_psi, simDR_engine_N1_pct1)

    -- ENGINE 2
    B738bleedAir.engine2.psi = B738_rescale(0, 0, 100.0, rndm_max_eng2_bleed_psi, simDR_engine_N1_pct2)


end


----- BLEED VALVES -------
function B738_bleed_air_valves()

    -- POWER REQUIRED - ELECTRIC VALVES ARE NORMALLY CLOSED WHEN THERE IS NO POWER
    local bleed_valve_min_act_press = 7.0



    ----- APU VALVE ---------------------------------------------------------------------
    B738bleedAir.apu.bleed_air_valve.target_pos = 0.0							-- NORMALLY CLOSED
    if B738DR_bleed_air_apu_switch_position > 0.95
        and B738bleedAir.apu.psi > bleed_valve_min_act_press					-- BLEED AIR REQUIRED TO OPEN THE VALVE
    then
        B738bleedAir.apu.bleed_air_valve.target_pos = 1.0						-- OPERATED BY BLEED AIR PRESSURE (NO ELECTRIC REQUIREMENT)
    end


    ----- ENGINE #1 BLEED AIR VALVE -----------------------------------------------------
    B738bleedAir.engine1.bleed_air_valve.target_pos = 0.0						-- NORMALLY CLOSED
    if B738DR_bleed_air_1_switch_position > 0.95
        and B738bleedAir.engine1.psi >= bleed_valve_min_act_press				-- BLEED AIR REQUIRED TO OPEN THE VALVE
 		and simDR_bleed_air1_fail == 0
 	then
        B738bleedAir.engine1.bleed_air_valve.target_pos = 1.0					-- OPERATED BY BLEED AIR PRESSURE (NO ELECTRIC REQUIREMENT)
    end
 
    ----- ENGINE #2 BLEED AIR VALVE -----------------------------------------------------
    B738bleedAir.engine2.bleed_air_valve.target_pos = 0.0						-- NORMALLY CLOSED
    if B738DR_bleed_air_2_switch_position > 0.95
        and B738bleedAir.engine2.psi >= bleed_valve_min_act_press				-- BLEED AIR REQUIRED TO OPEN THE VALVE
		and simDR_bleed_air2_fail == 0
    then
        B738bleedAir.engine2.bleed_air_valve.target_pos = 1.0					-- OPERATED BY BLEED AIR PRESSURE (NO ELECTRIC REQUIREMENT)
    end


end 

----- BLEED AIR VALVE ANIMATION -------

function B738_bleed_air_valve_animation()
    local valve_anm_speed = 3.0

    -- APU BLEED VALVE
    B738bleedAir.apu.bleed_air_valve.pos	        = B738_set_anim_value(B738bleedAir.apu.bleed_air_valve.pos, B738bleedAir.apu.bleed_air_valve.target_pos, 0.0, 1.0, valve_anm_speed)

    -- ENGINE BLEED VALVES
    B738bleedAir.engine1.bleed_air_valve.pos        = B738_set_anim_value(B738bleedAir.engine1.bleed_air_valve.pos, B738bleedAir.engine1.bleed_air_valve.target_pos, 0.0, 1.0, valve_anm_speed)
    B738bleedAir.engine2.bleed_air_valve.pos        = B738_set_anim_value(B738bleedAir.engine2.bleed_air_valve.pos, B738bleedAir.engine2.bleed_air_valve.target_pos, 0.0, 1.0, valve_anm_speed)


end


----- BLEED AIR DUCT PRESSURE -----------------------------------------------------------

function B738_bleed_air_duct_pressure()


	-- LEFT DUCT
		B738DR_duct_pressure_L = math.max(
			(B738bleedAir.apu.psi * B738bleedAir.apu.bleed_air_valve.pos),
			(B738bleedAir.engine1.psi * B738bleedAir.engine1.bleed_air_valve.pos))
			
	
	-- RIGHT DUCT
		B738DR_duct_pressure_R = B738bleedAir.engine2.psi * B738bleedAir.engine2.bleed_air_valve.pos
 
	
end


---- ENGINE IDLE MODE ---------------------------------------------------------------------

function B738_ground_timer()

	if simDR_aircraft_on_ground == 1
		and simDR_prop_mode0 == 1
		and simDR_prop_mode1 == 1 then
		ground_timer = ground_timer + SIM_PERIOD
	elseif simDR_aircraft_on_ground == 0 then
		ground_timer = 0
	end
	
end

function B738_idle_mode_logic()

	local air_mode = 1

	if simDR_aircraft_on_ground_any == 0 then
		air_mode = 1
	elseif simDR_aircraft_on_ground == 1
		and ground_timer > 5 then
		air_mode = 0
	end


--- ENGINE 1 GROUND / FLIGHT IDLE ---

	if air_mode == 0 then
		if B738DR_condition_lever1 >= 0.75 then
			simDR_engine1_mixture = 0.5
		elseif B738DR_condition_lever1 < 0.75 then
			simDR_engine1_mixture = 0
		end
	elseif air_mode == 1 then
		if B738DR_condition_lever1 >= 0.75 then
			simDR_engine1_mixture = 1
		elseif B738DR_condition_lever1 < 0.75 then
			simDR_engine1_mixture = 0
		end
	end

--- ENGINE 2 GROUND / FLIGHT IDLE ---

	if air_mode == 0 then
		if B738DR_condition_lever2 >= 0.75 then
			simDR_engine2_mixture = 0.5
		elseif B738DR_condition_lever2 < 0.75 then
			simDR_engine2_mixture = 0
		end
	elseif air_mode == 1 then
		if B738DR_condition_lever2 >= 0.75 then
			simDR_engine2_mixture = 1
		elseif B738DR_condition_lever2 < 0.75 then
			simDR_engine2_mixture = 0
		end
	end

	B738DR_air_mode = air_mode
	B738DR_ground_timer = ground_timer


end

----- SPEEDBRAKE LEVER STOP -------------------------------------------------------------
function B738_speedbrake_lever_stop()

    B738_speedbrake_stop = 0
    if simDR_aircraft_on_ground < 1 then
        B738_speedbrake_stop = 1
    end

end

----- SPEEDBRAKE DISAGREE MONITOR -------------------------------------------------------

function B738_speedbrake_disagree_monitor()


	if simDR_speedbrake_ratio_control >= 0 then
		austin_speedbrake_handle = simDR_speedbrake_ratio_control
	elseif simDR_speedbrake_ratio_control < 0 then
		austin_speedbrake_handle = 0
	end
	
end


function B738_speedbrake_handle_animation()


	----- WHAT MY LEVER IS DOING MAPPED AS AUSTINS LEVER -----

	if B738_speedbrake_stop == 1 then
		if B738DR_speedbrake_lever >= 0.15 then
			local alex_speedbrake_handle = B738_rescale(0.15, 0, 0.667, 0.99, B738DR_speedbrake_lever)
		elseif B738DR_speedbrake_lever < 0.15 then
			alex_speedbrake_handle = 0
		end
	
	elseif B738_speedbrake_stop == 0 then

		if B738DR_speedbrake_lever >= 0.15 then	
			if B738DR_speedbrake_lever < 0.667 then
				alex_speedbrake_handle = B738_rescale(0.15, 0, 0.667, 0.99, B738DR_speedbrake_lever)
			elseif B738DR_speedbrake_lever >= 0.667 then
				alex_speedbrake_handle = B738_rescale(0.667, 0.99, 1, 1, B738DR_speedbrake_lever)
			end
		elseif B738DR_speedbrake_lever < 0.15 then
			alex_speedbrake_handle = 0
		end
		
	end


	----- MAPPING MY LEVER DATAREF TO AUSTINS LEVER IF DISAGREE -----

	if B738DR_speedbrake_lever >= 0.15 then
	
		if austin_speedbrake_handle == alex_speedbrake_handle then
		
		elseif austin_speedbrake_handle ~= alex_speedbrake_handle then
			if B738_speedbrake_stop == 1 then
				B738DR_speedbrake_lever = B738_rescale(0, 0.15, 0.99, 0.667, austin_speedbrake_handle)
			elseif B738_speedbrake_stop == 0 then
				if austin_speedbrake_handle < 0.99 then
					B738DR_speedbrake_lever = B738_rescale(0, 0.15, 0.99, 0.667, austin_speedbrake_handle)
				elseif austin_speedbrake_handle >= 0.99 then
					B738DR_speedbrake_lever = B738_rescale(0.99, 0.667, 1, 1, austin_speedbrake_handle)
				end
			end
		end
	
	elseif B738DR_speedbrake_lever < 0.15 then
		
		if austin_speedbrake_handle > 0 then
			B738DR_speedbrake_lever = 0.15
		end

	end

	if simDR_speedbrake_ratio_control == -0.5 then
	B738DR_speedbrake_lever = 0.0889
	end


-- B738DR_austin_sb = austin_speedbrake_handle
-- B738DR_alex_sb = alex_speedbrake_handle


end

--[[

----- SPEEDBRAKE LEVER ------------------------------------------------------------------
function B738_speedbrake_lever_DRhandler()
	


	if B738_speedbrake_stop == 1 then

		if B738DR_speedbrake_lever < 0.15 then
			if B738DR_speedbrake_lever < 0.07 then
				simDR_speedbrake_ratio_control = 0.0
			elseif B738DR_speedbrake_lever < 0.11 and B738DR_speedbrake_lever > 0.06 then
				B738DR_speedbrake_lever = 0.0889
		    	simDR_speedbrake_ratio_control = -0.5
		    elseif B738DR_speedbrake_lever > 0.11 then
		    	simDR_speedbrake_ratio_control = 0.0
			end
		elseif B738DR_speedbrake_lever > 0.15 then
			B738DR_speedbrake_lever = math.min(0.667, B738DR_speedbrake_lever)
			local spdbrake_lever_stopped = B738_rescale(0.15, 0, 0.667, 0.9899999, B738DR_speedbrake_lever)
		
			simDR_speedbrake_ratio_control = spdbrake_lever_stopped
		end

	elseif B738_speedbrake_stop == 0 then

		if B738DR_speedbrake_lever < 0.15 then
			if B738DR_speedbrake_lever < 0.07 then
				simDR_speedbrake_ratio_control = 0.0
			elseif B738DR_speedbrake_lever < 0.11 and B738DR_speedbrake_lever > 0.07 then
				B738DR_speedbrake_lever = 0.0889
		    	simDR_speedbrake_ratio_control = -0.5
		    elseif B738DR_speedbrake_lever > 0.11 then
		    	simDR_speedbrake_ratio_control = 0.0
			end
		elseif B738DR_speedbrake_lever > 0.15 and B738DR_speedbrake_lever <= 0.667 then
			local spdbrake_lever_open = B738_rescale(0.15, 0, 0.667, 0.9899999, B738DR_speedbrake_lever)

			simDR_speedbrake_ratio_control = spdbrake_lever_open

		elseif B738DR_speedbrake_lever > 0.667 then
			local spdbrake_lever_open_ground = B738_rescale(0.667, 0.99, 1, 1, B738DR_speedbrake_lever)

			simDR_speedbrake_ratio_control = spdbrake_lever_open_ground

		end

	end

end

function B738_speedbrake_stop_pos_DRhandler()end


		if simDR_aircraft_on_ground_any == 1 then
		if simDR_speedbrake_ratio_control == 1 then
			if B738DR_speedbrake_lever < 0.12 then
				B738DR_speedbrake_lever = 1
			end
		end
	end
end	
]]--


----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function B738_systems_monitor_AI()

    if B738DR_init_systems_CD == 1 then
        B738_set_systems_all_modes()
        B738_set_systems_CD()
        B738DR_init_systems_CD = 2
    end

end





----- SET STATE FOR ALL MODES -----------------------------------------------------------
function B738_set_systems_all_modes()
	
	B738DR_init_systems_CD = 0


end





----- SET STATE TO COLD & DARK ----------------------------------------------------------
function B738_set_systems_CD()

		simDR_electric_hyd_pump_switch = 0
		simDR_throttle_pos_1 = 0
		simDR_throttle_pos_2 = 0
		B738DR_condition_lever1 = 0
		B738DR_condition_lever2 = 0
		simDR_fuel_tank_pump1 = 0
		simDR_fuel_tank_pump2 = 0
		simDR_fuel_tank_pump3 = 0
		simCMD_hydro_pumps_toggle:once()
		B738DR_hydro_pumps_switch_position = 0
		simDR_cross_tie = 1
		B738DR_pas_oxy_switch_position = 0	
		B738DR_drive_disconnect1_switch_position = 0
		B738DR_drive_disconnect2_switch_position = 0
		simDR_apu_generator_switch = 0
		simCMD_apu_off:once()
		B738DR_apu_start_switch_position = 0
		B738DR_bleed_air_1_switch_position = 0
		B738DR_bleed_air_2_switch_position = 0
		B738DR_bleed_air_apu_switch_position = 0
		simDR_avionics_switch = 1
		B738DR_transponder_knob_pos = 1
		simDR_transponder_mode = 1	
		simDR_panel_brightness1 = 0
		simDR_panel_brightness2 = 0
		simDR_panel_brightness3 = 0
		simDR_panel_brightness4 = 0
		simDR_yaw_damper_switch	= 0
		simDR_generator_1 = 0
		simDR_generator_2 = 0
		simDR_battery_on = 0
		simDR_stby_battery_on = 0
		B738DR_starter_1_pos = 0
		B738DR_starter_2_pos = 0
		B738DR_condition_lever1_target = 0
		B738DR_condition_lever2_target = 0
		simCMD_gpu_off:once()
		simCMD_set_takeoff_trim:once()

-- ANTI ICE SETTINGS

		simDR_window_heat_on = 0
		B738DR_probes_capt_switch_pos = 0
		B738DR_probes_fo_switch_pos = 0
		simCMD_capt_AOA_ice_off:once()
		simCMD_fo_AOA_ice_off:once()
		simCMD_capt_pitot_ice_off:once()
		simCMD_fo_pitot_ice_off:once()	
		simCMD_capt_static_ice_off:once()
		simCMD_fo_static_ice_off:once()		

		B738DR_cont_cab_temp_ctrl_rheo = 0.525
		B738DR_fwd_cab_temp_ctrl_rheo = 0.525
		B738DR_aft_cab_temp_ctrl_rheo = 0.525

		
end





----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
function B738_set_systems_ER()


	B738_apu_start_timer = function()
		simCMD_apu_start:stop()
	end

	B738_trim_timer = function()
		if simDR_aircraft_on_ground == 1 then
			simCMD_set_takeoff_trim:once()
		end
	end

	
		--simCMD_apu_start:start()
		B738DR_hydro_pumps_switch_position = 1
		B738DR_apu_start_switch_position = 0
		simDR_throttle_pos_1 = 0
		simDR_throttle_pos_2 = 0
		simDR_cross_tie = 1
		B738DR_pas_oxy_switch_position = 0
		B738DR_drive_disconnect1_switch_position = 0
		B738DR_drive_disconnect2_switch_position = 0
		simDR_yaw_damper_switch	= 1
		simDR_apu_generator_switch = 1
		B738DR_bleed_air_1_switch_position = 1
		B738DR_bleed_air_2_switch_position = 1
		simDR_avionics_switch = 1
		B738DR_transponder_knob_pos = 1	
		simDR_transponder_mode = 1
		B738DR_condition_lever1_target = 1
		B738DR_condition_lever2_target = 1
		simDR_generator_1 = 1
		simDR_generator_2 = 1
		--run_after_time(B738_apu_start_timer, 0.25)
		simDR_window_heat_on = 1
		run_after_time(B738_trim_timer, 0.5)
	
	
end	






----- FLIGHT START ---------------------------------------------------------------------
function B738_flight_start_systems()

    -- ALL MODES ------------------------------------------------------------------------
    B738_set_systems_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B738_set_systems_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B738_set_systems_ER()

    end

end



--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start() 

	B738_flight_start_systems()
 
end

--function flight_crash() end

function before_physics() 

	drive_disconnect_reset()
	trip_oxy_on()
	 
	
end

function after_physics() 

	B738_ac_dc_power()
	B738_bleed_air_supply()
	B738_bleed_air_state()
	B738_bleed_air_duct_pressure()
	B738_bleed_air_valves()
	B738_bleed_air_valve_animation()
	B738_crossfeed_knob_animation()
	B738_fuel_tank_selection()
	B738_prop_mode_sync()
	B738_starter_knob_return()
	B738_idle_mode_logic()
	B738_ground_timer()
	B738_condition_lever_anim()
	B738_APU_generator()
	B738_inverter_control()	
	B738_systems_monitor_AI()
	B738_speedbrake_lever_stop()

	
	B738_speedbrake_handle_animation()
	B738_speedbrake_disagree_monitor()
	
end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



