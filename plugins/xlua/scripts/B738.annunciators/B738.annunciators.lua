--[[
*****************************************************************************************
* Program Script Name	:	B738.annunciators
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


local batt_discharge = 0
local extinguisher_circuit_annun2 = 0
local cargo_fire_annuns = 0
local fire_fault_inop_annun = 0

local eng1_fire_annun = 0
local eng2_fire_annun = 0
local eng1_ovht = 0
local eng2_ovht = 0
local apu_fire_annun = 0
local wheel_well_fire = 0
local fire_panel_annuns_test = 0
local fire_bell_annun = 0
local fire_bell_annun_reset = 1
local ovht_det_six_pack = 0

--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_parking_brake		= find_dataref("sim/cockpit2/controls/parking_brake_ratio")

simDR_reverser_fail_0	= find_dataref("sim/operation/failures/rel_revers0")
simDR_reverser_fail_1	= find_dataref("sim/operation/failures/rel_revers1")

-- ANTI ICE

simDR_window_heat		= find_dataref("sim/cockpit2/ice/ice_window_heat_on")

simDR_pitot_capt		= find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_pilot")
simDR_pitot_fo			= find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_copilot")
simDR_aoa_capt			= find_dataref("sim/cockpit2/ice/ice_AOA_heat_on")
simDR_aoa_fo			= find_dataref("sim/cockpit2/ice/ice_AOA_heat_on_copilot")

simDR_cowl_ice_detect_0 = find_dataref("sim/flightmodel/failures/inlet_ice_per_engine[0]")
simDR_cowl_ice_detect_1 = find_dataref("sim/flightmodel/failures/inlet_ice_per_engine[1]")

simDR_cowl_ice_0_on	= find_dataref("sim/cockpit2/ice/ice_inlet_heat_on_per_engine[0]")
simDR_cowl_ice_1_on	= find_dataref("sim/cockpit2/ice/ice_inlet_heat_on_per_engine[1]")

simDR_wing_ice_on = find_dataref("sim/cockpit2/ice/ice_surfce_heat_on")

simDR_wing_ice_detect_L = find_dataref("sim/flightmodel/failures/frm_ice")
simDR_wing_ice_detect_R = find_dataref("sim/flightmodel/failures/frm_ice2")

simDR_window_heat_fail = find_dataref("sim/operation/failures/rel_ice_window_heat")

-- APU FAULT

simDR_apu_fault	= find_dataref("sim/operation/failures/rel_APU_press")

-- ANNUN BRIGHTNESS

simDR_electrical_bus_volts0 = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_electrical_bus_volts1 = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
simDR_generic_brightness_ratio63 = find_dataref("sim/flightmodel2/lights/generic_lights_brightness_ratio[63]")
simDR_generic_brightness_ratio62 = find_dataref("sim/flightmodel2/lights/generic_lights_brightness_ratio[62]")
simDR_generic_brightness_switch63 = find_dataref("sim/cockpit2/switches/generic_lights_switch[63]")
simDR_generic_brightness_switch62 = find_dataref("sim/cockpit2/switches/generic_lights_switch[62]")

--GEAR LIGHTS

simDR_nose_gear_status	= find_dataref("sim/flightmodel2/gear/deploy_ratio[0]")
simDR_left_gear_status	= find_dataref("sim/flightmodel2/gear/deploy_ratio[1]")
simDR_right_gear_status	= find_dataref("sim/flightmodel2/gear/deploy_ratio[2]")

simDR_nose_gear_fail = find_dataref("sim/operation/failures/rel_collapse1")
simDR_left_gear_fail = find_dataref("sim/operation/failures/rel_collapse2")
simDR_right_gear_fail = find_dataref("sim/operation/failures/rel_collapse3")

-- LOW FUEL PRESSURE

simDR_fuel_quantity_l = find_dataref("sim/cockpit2/fuel/fuel_quantity[0]")
simDR_fuel_quantity_c = find_dataref("sim/cockpit2/fuel/fuel_quantity[1]")
simDR_fuel_quantity_r = find_dataref("sim/cockpit2/fuel/fuel_quantity[2]")

simDR_fuel_tank_l_on = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[0]")
simDR_fuel_tank_c_on = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[1]")
simDR_fuel_tank_r_on = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[2]")

simDR_low_fuel = find_dataref("sim/cockpit2/annunciators/fuel_quantity")
simDR_low_fuel_press1 = find_dataref("sim/cockpit2/annunciators/fuel_pressure_low[0]")
simDR_low_fuel_press2 = find_dataref("sim/cockpit2/annunciators/fuel_pressure_low[1]")


-- FADEC

simDR_fadec1 = find_dataref("sim/cockpit2/engine/actuators/fadec_on[0]")
simDR_fadec2 = find_dataref("sim/cockpit2/engine/actuators/fadec_on[1]")

simDR_fadec_fail_0		= find_dataref("sim/operation/failures/rel_fadec_0")
simDR_fadec_fail_1		= find_dataref("sim/operation/failures/rel_fadec_1")

-- GENERATOR FAILURE

simDR_generator1_fail = find_dataref("sim/operation/failures/rel_genera0")
simDR_generator2_fail = find_dataref("sim/operation/failures/rel_genera1")

-- ALT POWER ANNUN

simDR_battery2_status = find_dataref("sim/cockpit2/electrical/battery_on[1]")

-- BYPASS FILTER ANNUN

simDR_bypass_filter_1 = find_dataref("sim/operation/failures/failures[330]")
simDR_bypass_filter_2 = find_dataref("sim/operation/failures/failures[331]")

-- BATT DISCHARGE

simDR_battery_amps	= find_dataref("sim/cockpit2/electrical/battery_amps")

-- HYDRAULIC PRESSURE

simDR_hyd_press_a = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")
simDR_hyd_press_b = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2")

-- PACK ANNUN

simDR_pack_annun = find_dataref("sim/operation/failures/failures[153]")

-- SMOKE ANNUN

simDR_smoke = find_dataref("sim/operation/failures/rel_smoke_cpit")

-- APU GEN OFF BUS

simDR_apu_gen_amps = find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_apu_status = find_dataref("sim/cockpit2/electrical/APU_N1_percent")

-- GEN OFF BUS

simDR_gen_off_bus1 = find_dataref("sim/cockpit2/annunciators/generator_off[0]")
simDR_gen_off_bus2 = find_dataref("sim/cockpit2/annunciators/generator_off[1]")

simDR_engine1_on = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
simDR_engine2_on = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[1]")

-- GPU

simDR_gpu_amps = find_dataref("sim/cockpit/electrical/gpu_amps")

-- BUS VOLTS

simDR_bus_amps1 = find_dataref("sim/cockpit2/electrical/bus_load_amps[0]")
simDR_bus_amps2 = find_dataref("sim/cockpit2/electrical/bus_load_amps[1]")

-- DOORS

simDR_fwd_entry_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[0]")
simDR_left_fwd_overwing_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[1]")
simDR_left_aft_overwing_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[2]")
simDR_aft_entry_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[3]")

simDR_fwd_service_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[4]")
simDR_right_fwd_overwing_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[5]")
simDR_right_aft_overwing_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[6]")
simDR_aft_service_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[7]")

simDR_fwd_cargo_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[8]")
simDR_aft_cargo_status = find_dataref("sim/flightmodel2/misc/door_open_ratio[9]")

simDR_equipment_status = find_dataref("sim/flightmodel2/misc/custom_slider_ratio[21]")

-- PAX OXY

simDR_pax_oxy_status = find_dataref("sim/cockpit/warnings/annunciators/passenger_oxy_on")

-- BLEED TRIP OFF

simDR_bleed_trip_off1_annun = find_dataref("sim/cockpit/warnings/annunciators/bleed_air_fail[0]")
simDR_bleed_trip_off2_annun = find_dataref("sim/cockpit/warnings/annunciators/bleed_air_fail[1]")

simDR_wing_body_ovht_annun = find_dataref("sim/cockpit/warnings/annunciators/hvac")

-- YAW DAMPER

simDR_yaw_damper_annun			= find_dataref("sim/cockpit2/annunciators/yaw_damper")

-- DATAREFS FOR GROUND POWER AVAILABLE

simDR_aircraft_on_ground        = find_dataref("sim/flightmodel/failures/onground_all")
simDR_aircraft_groundspeed      = find_dataref("sim/flightmodel/position/groundspeed")

simDR_ext_pwr_1_on              = find_dataref("sim/cockpit/electrical/gpu_on")

simDR_axial_g_load				= find_dataref("sim/flightmodel/forces/g_axil")

simDR_N2_eng1_percent			= find_dataref("sim/cockpit2/engine/indicators/N2_percent[0]")
simDR_N2_eng2_percent			= find_dataref("sim/cockpit2/engine/indicators/N2_percent[1]")

-- CROSSFEED ANNUN

simDR_tank_selection			= find_dataref("sim/cockpit2/fuel/fuel_tank_selector")

-- FORWARD COCKPIT REFS

simDR_cabin_alt 				= find_dataref("sim/cockpit2/pressurization/indicators/cabin_altitude_ft")
simDR_speedbrake_status 		= find_dataref("sim/cockpit2/controls/speedbrake_ratio")
simDR_GPWS						= find_dataref("sim/cockpit2/annunciators/GPWS")

	-- TAKEOFF CONFIG
	
	simDR_elevator_trim			= find_dataref("sim/cockpit2/controls/elevator_trim")
	simDR_flap_ratio			= find_dataref("sim/cockpit2/controls/flap_ratio")
	simDR_throttle_ratio		= find_dataref("sim/cockpit2/engine/actuators/throttle_ratio_all")
	simDR_reverse_thrust1		= find_dataref("sim/cockpit2/engine/actuators/prop_mode[0]")
	simDR_reverse_thrust2		= find_dataref("sim/cockpit2/engine/actuators/prop_mode[1]")


simDR_gs_flag					= find_dataref("sim/cockpit2/radios/indicators/nav1_flag_glideslope")
simDR_nav1_vdef_dots			= find_dataref("sim/cockpit2/radios/indicators/nav1_vdef_dots_pilot")
simDR_nav1_vert_signal			= find_dataref("sim/cockpit2/radios/indicators/nav1_display_vertical")
simDR_slat_1_deploy				= find_dataref("sim/flightmodel2/controls/slat1_deploy_ratio")
simDR_slat_2_deploy				= find_dataref("sim/flightmodel2/controls/slat2_deploy_ratio")

simDR_engine1_fire				= find_dataref("sim/cockpit2/annunciators/engine_fires[0]")
simDR_engine2_fire				= find_dataref("sim/cockpit2/annunciators/engine_fires[1]")
simDR_engine1_egt				= find_dataref("sim/cockpit2/engine/indicators/EGT_deg_C[0]")
simDR_engine2_egt				= find_dataref("sim/cockpit2/engine/indicators/EGT_deg_C[1]")

	--EGT950°C for five minutes--

simDR_ap_disconnect				= find_dataref("sim/cockpit2/annunciators/autopilot_disconnect")

-- MASTER CAUTION

simDR_waster_caution_light		= find_dataref("sim/cockpit2/annunciators/master_caution")

-- SIX PACK EXTRAS

simDR_gps_fail					= find_dataref("sim/operation/failures/rel_gps")
simDR_elec_trim_off				= find_dataref("sim/cockpit/warnings/annunciators/electric_trim_off")
simDR_general_ice_detect		= find_dataref("sim/cockpit2/annunciators/ice")
simDR_chip_detect1				= find_dataref("sim/cockpit2/annunciators/chip_detected[0]")
simDR_chip_detect2				= find_dataref("sim/cockpit2/annunciators/chip_detected[1]")


-- AUDIO PANEL AUDIO SELECTIONS

simDR_audio_selection_com1		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_com1")
simDR_audio_selection_com2		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_com2")
simDR_audio_selection_nav1		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav1")
simDR_audio_selection_nav2		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav2")
simDR_audio_selection_marker	= find_dataref("sim/cockpit2/radios/actuators/audio_marker_enabled")

-- AUDIO PANEL AVAILABLE LEDS

simDR_nav1h_active				= find_dataref("sim/cockpit2/radios/indicators/nav1_display_horizontal")
simDR_nav1v_active				= find_dataref("sim/cockpit2/radios/indicators/nav1_display_vertical")
simDR_nav1dme_active			= find_dataref("sim/cockpit2/radios/indicators/nav1_has_dme")

simDR_nav2h_active				= find_dataref("sim/cockpit2/radios/indicators/nav2_display_horizontal")
simDR_nav2v_active				= find_dataref("sim/cockpit2/radios/indicators/nav2_display_vertical")
simDR_nav2dme_active			= find_dataref("sim/cockpit2/radios/indicators/nav2_has_dme")

simDR_outer_marker_active		= find_dataref("sim/cockpit2/radios/indicators/over_outer_marker")
simDR_middle_marker_active		= find_dataref("sim/cockpit2/radios/indicators/over_middle_marker")
simDR_inner_marker_active		= find_dataref("sim/cockpit2/radios/indicators/over_inner_marker")

simDR_com1_active				= find_dataref("sim/cockpit2/radios/actuators/com1_power")
simDR_com2_active				= find_dataref("sim/cockpit2/radios/actuators/com2_power")

simDR_transponder_fail			= find_dataref("sim/operation/failures/rel_xpndr")

--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_test_fire_1_annun		= find_command("sim/annunciator/test_fire_1_annun")
simCMD_test_fire_2_annun		= find_command("sim/annunciator/test_fire_2_annun")
simCMD_master_warning_accept	= find_command("sim/annunciator/clear_master_warning")
simCMD_master_caution_accept	= find_command("sim/annunciator/clear_master_caution")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

B738DR_l_bottle_psi	= find_dataref("laminar/B738/fire/engine01_02L/ext_bottle/psi")
B738DR_r_bottle_psi	= find_dataref("laminar/B738/fire/engine01_02R/ext_bottle/psi")
B738DR_dual_bleed	= find_dataref("laminar/B738/annunciator/dual_bleed")

-- FUEL VALVES

B738DR_condition_lever1 = find_dataref("laminar/B738/engine/slider/condition_lever1")
B738DR_condition_lever2 = find_dataref("laminar/B738/engine/slider/condition_lever2")

-- APU GENERATORS

B738DR_apu_genL_status			= find_dataref("laminar/B738/electrical/apu_genL_status")
B738DR_apu_genR_status			= find_dataref("laminar/B738/electrical/apu_genR_status")

--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

B738DR_parking_brake_annun	= create_dataref("laminar/B738/annunciator/parking_brake", "number")
B738DR_window_heat_annun	= create_dataref("laminar/B738/annunciator/window_heat", "number")

B738DR_fadec_fail_annun_0	= create_dataref("laminar/B738/annunciator/fadec_fail_0", "number")
B738DR_fadec_fail_annun_1	= create_dataref("laminar/B738/annunciator/fadec_fail_1", "number")

B738DR_reverser_fail_annun_0	= create_dataref("laminar/B738/annunciator/reverser_fail_0", "number")
B738DR_reverser_fail_annun_1	= create_dataref("laminar/B738/annunciator/reverser_fail_1", "number")

B738DR_capt_pitot_off		= create_dataref("laminar/B738/annunciator/capt_pitot_off", "number")
B738DR_fo_pitot_off			= create_dataref("laminar/B738/annunciator/fo_pitot_off", "number")
B738DR_capt_aoa_off			= create_dataref("laminar/B738/annunciator/capt_aoa_off", "number")
B738DR_fo_aoa_off			= create_dataref("laminar/B738/annunciator/fo_aoa_off", "number")

B738DR_window_heat_fail		= create_dataref("laminar/B738/annunciator/window_heat_ovht", "number")

-- COWL ANTI ICE

B738DR_cowl_ice_0			= create_dataref("laminar/B738/annunciator/cowl_ice_0", "number")
B738DR_cowl_ice_1			= create_dataref("laminar/B738/annunciator/cowl_ice_1", "number")
B738DR_cowl_ice_0_on		= create_dataref("laminar/B738/annunciator/cowl_ice_on_0", "number")
B738DR_cowl_ice_1_on		= create_dataref("laminar/B738/annunciator/cowl_ice_on_1", "number")

-- WING ANTI ICE

B738DR_wing_ice_on_L		= create_dataref("laminar/B738/annunciator/wing_ice_on_L", "number")
B738DR_wing_ice_on_R		= create_dataref("laminar/B738/annunciator/wing_ice_on_R", "number")

B738DR_apu_fault_annun		= create_dataref("laminar/B738/annunciator/apu_fault", "number")

B738DR_parking_brake_spill 	= create_dataref("laminar/B738/light/spill/ratio/parking_brake", "array[9]")

-- GEAR LIGHTS

B738DR_nose_gear_transit_annun	= create_dataref("laminar/B738/annunciator/nose_gear_transit", "number")
B738DR_nose_gear_safe_annun		= create_dataref("laminar/B738/annunciator/nose_gear_safe", "number")

B738DR_left_gear_transit_annun	= create_dataref("laminar/B738/annunciator/left_gear_transit", "number")
B738DR_left_gear_safe_annun		= create_dataref("laminar/B738/annunciator/left_gear_safe", "number")

B738DR_right_gear_transit_annun	= create_dataref("laminar/B738/annunciator/right_gear_transit", "number")
B738DR_right_gear_safe_annun	= create_dataref("laminar/B738/annunciator/right_gear_safe", "number")

-- LOW FUEL PRESSURE ANNUNS

B738DR_low_fuel_press_l1_annun	= create_dataref("laminar/B738/annunciator/low_fuel_press_l1", "number")
B738DR_low_fuel_press_l2_annun	= create_dataref("laminar/B738/annunciator/low_fuel_press_l2", "number")

B738DR_low_fuel_press_c1_annun	= create_dataref("laminar/B738/annunciator/low_fuel_press_c1", "number")
B738DR_low_fuel_press_c2_annun	= create_dataref("laminar/B738/annunciator/low_fuel_press_c2", "number")

B738DR_low_fuel_press_r1_annun	= create_dataref("laminar/B738/annunciator/low_fuel_press_r1", "number")
B738DR_low_fuel_press_r2_annun	= create_dataref("laminar/B738/annunciator/low_fuel_press_r2", "number")

-- FUEL VALVES

B738DR_eng1_valve_closed_annun	= create_dataref("laminar/B738/annunciator/eng1_valve_closed", "number")
B738DR_eng2_valve_closed_annun	= create_dataref("laminar/B738/annunciator/eng2_valve_closed", "number")

-- FADEC OFF

B738DR_fadec1_off			= create_dataref("laminar/B738/annunciator/fadec1_off", "number")
B738DR_fadec2_off			= create_dataref("laminar/B738/annunciator/fadec2_off", "number")

-- GENERATOR FAIL

B738DR_drive1_annun			= create_dataref("laminar/B738/annunciator/drive1", "number")
B738DR_drive2_annun			= create_dataref("laminar/B738/annunciator/drive2", "number")

-- ALT POWER ANNUN

B738DR_standby_pwr_off		= create_dataref("laminar/B738/annunciator/standby_pwr_off", "number")

-- BYPASS FILTER ANNUN

B738DR_bypass_filter_1		= create_dataref("laminar/B738/annunciator/bypass_filter_1", "number")
B738DR_bypass_filter_2		= create_dataref("laminar/B738/annunciator/bypass_filter_2", "number")

-- BATT DISCHAGE ANNUN

B738DR_battery_disch_annun	= create_dataref("laminar/B738/annunciator/bat_discharge", "number")

-- HYD PRESSURE ANNUNS

B738DR_hyd_press_a			= create_dataref("laminar/B738/annunciator/hyd_press_a", "number")
B738DR_hyd_press_b			= create_dataref("laminar/B738/annunciator/hyd_press_b", "number")

-- PACK ANNUN

B738DR_packs_annun			= create_dataref("laminar/B738/annunciator/pack", "number")

-- SMOKE ANNUN

B738DR_smoke				= create_dataref("laminar/B738/annunciator/smoke", "number")

-- APU GEN OFF BUS ANNUN

B738DR_apu_gen_off_bus		= create_dataref("laminar/B738/annunciator/apu_gen_off_bus", "number")

-- GEN OFF BUS ANNUN

B738DR_gen_off_bus1			= create_dataref("laminar/B738/annunciator/gen_off_bus1", "number")
B738DR_gen_off_bus2			= create_dataref("laminar/B738/annunciator/gen_off_bus2", "number")

-- SOURCE OFF ANNUN

B738DR_source_off_bus1		= create_dataref("laminar/B738/annunciator/source_off1", "number")
B738DR_source_off_bus2		= create_dataref("laminar/B738/annunciator/source_off2", "number")

-- TRANSFER BUS OFF ANNUN

B738DR_transfer_bus_off1		= create_dataref("laminar/B738/annunciator/trans_bus_off1", "number")
B738DR_transfer_bus_off2		= create_dataref("laminar/B738/annunciator/trans_bus_off2", "number")

-- DOOR ANNUNS

B738DR_fwd_entry			= create_dataref("laminar/B738/annunciator/fwd_entry", "number")
B738DR_left_fwd_overwing	= create_dataref("laminar/B738/annunciator/left_fwd_overwing", "number")
B738DR_left_aft_overwing	= create_dataref("laminar/B738/annunciator/left_aft_overwing", "number")
B738DR_aft_entry			= create_dataref("laminar/B738/annunciator/aft_entry", "number")

B738DR_fwd_service			= create_dataref("laminar/B738/annunciator/fwd_service", "number")
B738DR_right_fwd_overwing	= create_dataref("laminar/B738/annunciator/right_fwd_overwing", "number")
B738DR_right_aft_overwing	= create_dataref("laminar/B738/annunciator/right_aft_overwing", "number")
B738DR_aft_service			= create_dataref("laminar/B738/annunciator/aft_service", "number")

B738DR_fwd_cargo			= create_dataref("laminar/B738/annunciator/fwd_cargo", "number")
B738DR_aft_cargo			= create_dataref("laminar/B738/annunciator/aft_cargo", "number")

B738DR_equip_door			= create_dataref("laminar/B738/annunciator/equip_door", "number")

-- PAX OXY

B738DR_pax_oxy				= create_dataref("laminar/B738/annunciator/pax_oxy", "number")

-- BLEED TRIP OFF

B738DR_bleed_trip_off1		= create_dataref("laminar/B738/annunciator/bleed_trip_1", "number")
B738DR_bleed_trip_off2		= create_dataref("laminar/B738/annunciator/bleed_trip_2", "number")

-- WING-BODY OVERHEAT

B738DR_wing_body_ovht		= create_dataref("laminar/B738/annunciator/wing_body_ovht", "number")

-- GROUND POWER AVAILABLE

B738DR_ground_power_avail_annun	= create_dataref("laminar/B738/annunciator/ground_power_avail", "number")

B738DR_elt_switch_pos = create_dataref("laminar/B738/toggle_switch/elt", "number")

B738DR_elt_annun = create_dataref("laminar/B738/annunciator/elt", "number")

B738DR_fdr_off = create_dataref("laminar/B738/annunciator/fdr_off", "number")

-- YAW DAMPER

B738DR_yaw_damper = create_dataref("laminar/B738/annunciator/yaw_damp", "number")

-- CROSSFEED VALVE ANNUN

B738DR_crossfeed = create_dataref("laminar/B738/annunciator/crossfeed", "number")

-- GENERIC ANNUNS

B738DR_generic_annun = create_dataref("laminar/B738/annunciator/generic", "number")
B738DR_lights_test = create_dataref("laminar/B738/annunciator/test", "number")

-- LIGHTS TEST / BRIGHTNESS SWITCH

B738DR_bright_test_switch_pos = create_dataref("laminar/B738/toggle_switch/bright_test", "number")

-- EMER EXIT LIGHTS

B738DR_emer_exit_lights_switch 	= create_dataref("laminar/B738/toggle_switch/emer_exit_lights", "number")
B738DR_emer_exit_annun			= create_dataref("laminar/B738/annunciator/emer_exit", "number")

-- FORWARD PANEL ANNUNS

B738DR_cabin_alt_annun			= create_dataref("laminar/B738/annunciator/cabin_alt", "number")
B738DR_speedbrake_armed			= create_dataref("laminar/B738/annunciator/speedbrake_armed", "number")
B738DR_speedbrake_extend		= create_dataref("laminar/B738/annunciator/speedbrake_extend", "number")
B738DR_GPWS_annun				= create_dataref("laminar/B738/annunciator/gpws", "number")
B738DR_takeoff_config_annun		= create_dataref("laminar/B738/annunciator/takeoff_config", "number")
B738DR_below_gs					= create_dataref("laminar/B738/annunciator/below_gs", "number")

B738DR_slats_transit			= create_dataref("laminar/B738/annunciator/slats_transit", "number")
B738DR_slats_extended			= create_dataref("laminar/B738/annunciator/slats_extend", "number")

-- FIRE PANEL ANNUNS

B738DR_extinguisher_circuit_spill1		= create_dataref("laminar/B738/light/spill/ratio/extinguisher_circuit_spill1", "array[9]")
B738DR_extinguisher_circuit_spill2		= create_dataref("laminar/B738/light/spill/ratio/extinguisher_circuit_spill2", "array[9]")

B738DR_extinguisher_circuit_test_pos	= create_dataref("laminar/B738/toggle_switch/extinguisher_circuit_test", "number")
B738DR_extinguisher_circuit_annun1		= create_dataref("laminar/B738/annunciator/extinguisher_circuit_annun1", "number")
B738DR_extinguisher_circuit_annun2		= create_dataref("laminar/B738/annunciator/extinguisher_circuit_annun2", "number")
B738DR_cargo_fire_annuns				= create_dataref("laminar/B738/annunciator/cargo_fire", "number")

B738DR_cargo_fire_test_button_pos		= create_dataref("laminar/B738/push_botton/cargo_fire_test", "number")
B738DR_fire_test_switch_pos				= create_dataref("laminar/B738/toggle_switch/fire_test", "number")
B738DR_fire_fault_inop_annun			= create_dataref("laminar/B738/annunciator/fire_fault_inop", "number")


B738DR_apu_fire							= create_dataref("laminar/B738/annunciator/apu_fire", "number")
B738DR_engine1_fire						= create_dataref("laminar/B738/annunciator/engine1_fire", "number")
B738DR_engine2_fire						= create_dataref("laminar/B738/annunciator/engine2_fire", "number")
B738DR_engine1_ovht						= create_dataref("laminar/B738/annunciator/engine1_ovht", "number")
B738DR_engine2_ovht						= create_dataref("laminar/B738/annunciator/engine2_ovht", "number")
B738DR_l_bottle_discharge				= create_dataref("laminar/B738/annunciator/l_bottle_discharge", "number")
B738DR_r_bottle_discharge				= create_dataref("laminar/B738/annunciator/r_bottle_discharge", "number")
B738DR_wheel_well_fire					= create_dataref("laminar/B738/annunciator/wheel_well_fire", "number")

B738DR_fire_bell_annun					= create_dataref("laminar/B738/annunciator/fire_bell_annun", "number")
B738DR_fire_bell_pos1					= create_dataref("laminar/B738/push_button/fire_bell_cutout1", "number")
B738DR_fire_bell_pos2					= create_dataref("laminar/B738/push_button/fire_bell_cutout2", "number")

B738DR_master_caution_light				= create_dataref("laminar/B738/annunciator/master_caution_light", "number")
B738DR_master_caution_pos1				= create_dataref("laminar/B738/push_button/master_caution_accept1", "number")
B738DR_master_caution_pos2				= create_dataref("laminar/B738/push_button/master_caution_accept2", "number")

-- AP DISCONNECT PANEL --

B738DR_ap_disconnect1_annun				= create_dataref("laminar/B738/annunciator/ap_disconnect1", "number")
B738DR_at_fms_disconnect1_annun			= create_dataref("laminar/B738/annunciator/at_fms_disconnect1", "number")
B738DR_ap_disconnect1_test_switch_pos	= create_dataref("laminar/B738/toggle_switch/ap_discon_test1", "number")

B738DR_ap_disconnect2_annun				= create_dataref("laminar/B738/annunciator/ap_disconnect2", "number")
B738DR_at_fms_disconnect2_annun			= create_dataref("laminar/B738/annunciator/at_fms_disconnect2", "number")		
B738DR_ap_disconnect2_test_switch_pos	= create_dataref("laminar/B738/toggle_switch/ap_discon_test2", "number")


B738DR_six_pack_fuel					= create_dataref("laminar/B738/annunciator/six_pack_fuel", "number")
B738DR_six_pack_fire					= create_dataref("laminar/B738/annunciator/six_pack_fire", "number")
B738DR_six_pack_apu						= create_dataref("laminar/B738/annunciator/six_pack_apu", "number")
B738DR_six_pack_flt_cont				= create_dataref("laminar/B738/annunciator/six_pack_flt_cont", "number")
B738DR_six_pack_elec					= create_dataref("laminar/B738/annunciator/six_pack_elec", "number")
B738DR_six_pack_irs						= create_dataref("laminar/B738/annunciator/six_pack_irs", "number")

B738DR_six_pack_ice						= create_dataref("laminar/B738/annunciator/six_pack_ice", "number")
B738DR_six_pack_doors					= create_dataref("laminar/B738/annunciator/six_pack_doors", "number")
B738DR_six_pack_eng						= create_dataref("laminar/B738/annunciator/six_pack_eng", "number")
B738DR_six_pack_hyd						= create_dataref("laminar/B738/annunciator/six_pack_hyd", "number")
B738DR_six_pack_air_cond				= create_dataref("laminar/B738/annunciator/six_pack_air_cond", "number")
B738DR_six_pack_overhead				= create_dataref("laminar/B738/annunciator/six_pack_overhead", "number")



-- AUDIO PANEL STATUS LIGHTS

B738DR_transponder_fail_light			= create_dataref("laminar/B738/transponder/indicators/xpond_fail", "number")

	-- SELECTED

B738DR_audio_panel_indicator_com1		= create_dataref("laminar/B738/audio/indicators/audio_selection_com1", "number")
B738DR_audio_panel_indicator_com2		= create_dataref("laminar/B738/audio/indicators/audio_selection_com2", "number")
B738DR_audio_panel_indicator_nav1		= create_dataref("laminar/B738/audio/indicators/audio_selection_nav1", "number")
B738DR_audio_panel_indicator_nav2		= create_dataref("laminar/B738/audio/indicators/audio_selection_nav2", "number")
B738DR_audio_panel_indicator_marker		= create_dataref("laminar/B738/audio/indicators/audio_marker_enabled", "number")
	
	-- AVAILABLE

B738DR_audio_panel_com1_avail			= create_dataref("laminar/B738/audio/indicators/com1_avail", "number")
B738DR_audio_panel_com2_avail			= create_dataref("laminar/B738/audio/indicators/com2_avail", "number")
B738DR_audio_panel_nav1_avail			= create_dataref("laminar/B738/audio/indicators/nav1_avail", "number")
B738DR_audio_panel_nav2_avail			= create_dataref("laminar/B738/audio/indicators/nav2_avail", "number")
B738DR_audio_panel_mark_avail			= create_dataref("laminar/B738/audio/indicators/mark_avail", "number")

--------------------------------

	-- CAPTAIN MIC SELECTOR POSITION
	
B738DR_audio_panel_capt_mic1_pos		= create_dataref("laminar/B738/audio/capt/mic_button1", "number")
B738DR_audio_panel_capt_mic2_pos		= create_dataref("laminar/B738/audio/capt/mic_button2", "number")
B738DR_audio_panel_capt_mic3_pos		= create_dataref("laminar/B738/audio/capt/mic_button3", "number")
B738DR_audio_panel_capt_mic4_pos		= create_dataref("laminar/B738/audio/capt/mic_button4", "number")
B738DR_audio_panel_capt_mic5_pos		= create_dataref("laminar/B738/audio/capt/mic_button5", "number")
B738DR_audio_panel_capt_mic6_pos		= create_dataref("laminar/B738/audio/capt/mic_button6", "number")

	-- CAPTAIN MIC LIGHTS
	
B738DR_audio_panel_capt_mic1_light		= create_dataref("laminar/B738/audio/capt/mic_indicator1", "number")
B738DR_audio_panel_capt_mic2_light		= create_dataref("laminar/B738/audio/capt/mic_indicator2", "number")
B738DR_audio_panel_capt_mic3_light		= create_dataref("laminar/B738/audio/capt/mic_indicator3", "number")
B738DR_audio_panel_capt_mic4_light		= create_dataref("laminar/B738/audio/capt/mic_indicator4", "number")
B738DR_audio_panel_capt_mic5_light		= create_dataref("laminar/B738/audio/capt/mic_indicator5", "number")
B738DR_audio_panel_capt_mic6_light		= create_dataref("laminar/B738/audio/capt/mic_indicator6", "number")

	-- FIRST OFFICER MIC SELECTOR POSITION
	
B738DR_audio_panel_fo_mic1_pos			= create_dataref("laminar/B738/audio/fo/mic_button1", "number")
B738DR_audio_panel_fo_mic2_pos			= create_dataref("laminar/B738/audio/fo/mic_button2", "number")
B738DR_audio_panel_fo_mic3_pos			= create_dataref("laminar/B738/audio/fo/mic_button3", "number")
B738DR_audio_panel_fo_mic4_pos			= create_dataref("laminar/B738/audio/fo/mic_button4", "number")
B738DR_audio_panel_fo_mic5_pos			= create_dataref("laminar/B738/audio/fo/mic_button5", "number")
B738DR_audio_panel_fo_mic6_pos			= create_dataref("laminar/B738/audio/fo/mic_button6", "number")

	-- FIRST OFFICER MIC LIGHTS
	
B738DR_audio_panel_fo_mic1_light		= create_dataref("laminar/B738/audio/fo/mic_indicator1", "number")
B738DR_audio_panel_fo_mic2_light		= create_dataref("laminar/B738/audio/fo/mic_indicator2", "number")
B738DR_audio_panel_fo_mic3_light		= create_dataref("laminar/B738/audio/fo/mic_indicator3", "number")
B738DR_audio_panel_fo_mic4_light		= create_dataref("laminar/B738/audio/fo/mic_indicator4", "number")
B738DR_audio_panel_fo_mic5_light		= create_dataref("laminar/B738/audio/fo/mic_indicator5", "number")
B738DR_audio_panel_fo_mic6_light		= create_dataref("laminar/B738/audio/fo/mic_indicator6", "number")

	-- OBSERVER MIC SELECTOR POSITION
	
B738DR_audio_panel_obs_mic1_pos			= create_dataref("laminar/B738/audio/obs/mic_button1", "number")
B738DR_audio_panel_obs_mic2_pos			= create_dataref("laminar/B738/audio/obs/mic_button2", "number")
B738DR_audio_panel_obs_mic3_pos			= create_dataref("laminar/B738/audio/obs/mic_button3", "number")
B738DR_audio_panel_obs_mic4_pos			= create_dataref("laminar/B738/audio/obs/mic_button4", "number")
B738DR_audio_panel_obs_mic5_pos			= create_dataref("laminar/B738/audio/obs/mic_button5", "number")
B738DR_audio_panel_obs_mic6_pos			= create_dataref("laminar/B738/audio/obs/mic_button6", "number")

	-- OBSERVER MIC LIGHTS
	
B738DR_audio_panel_obs_mic1_light		= create_dataref("laminar/B738/audio/obs/mic_indicator1", "number")
B738DR_audio_panel_obs_mic2_light		= create_dataref("laminar/B738/audio/obs/mic_indicator2", "number")
B738DR_audio_panel_obs_mic3_light		= create_dataref("laminar/B738/audio/obs/mic_indicator3", "number")
B738DR_audio_panel_obs_mic4_light		= create_dataref("laminar/B738/audio/obs/mic_indicator4", "number")
B738DR_audio_panel_obs_mic5_light		= create_dataref("laminar/B738/audio/obs/mic_indicator5", "number")
B738DR_audio_panel_obs_mic6_light		= create_dataref("laminar/B738/audio/obs/mic_indicator6", "number")


B738DR_brightness2_export				= create_dataref("laminar/B738/brightness_level2", "number")

B738DR_init_annun_CD					= create_dataref("laminar/B738/init_CD/annun", "number")
	
--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--


function B738_elt_pos_on_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_elt_switch_pos == 0 then
		B738DR_elt_switch_pos = 1
		end
	end
end

function B738_elt_pos_arm_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_elt_switch_pos == 1 then
		B738DR_elt_switch_pos = 0
		end
	end
end

function B738_bright_test_switch_pos_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_bright_test_switch_pos == 1 then
		B738DR_bright_test_switch_pos = 0
		B738DR_lights_test = 0
		simDR_generic_brightness_switch63 = 1
	elseif B738DR_bright_test_switch_pos == 0 then
		B738DR_bright_test_switch_pos = -1
		simDR_generic_brightness_switch63 = 0.5
		end
	end
end

function B738_bright_test_switch_pos_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_bright_test_switch_pos == -1 then
		B738DR_bright_test_switch_pos = 0
		simDR_generic_brightness_switch63 = 1
	elseif B738DR_bright_test_switch_pos == 0 then
		B738DR_bright_test_switch_pos = 1
		simDR_generic_brightness_switch63 = 1
		B738DR_lights_test = 1
		end
	end
end

function B738_emer_exit_lights_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_emer_exit_lights_switch == 0 then
		B738DR_emer_exit_lights_switch = 1
	elseif B738DR_emer_exit_lights_switch == 1 then
		B738DR_emer_exit_lights_switch = 2
		end
	end
end

function B738_emer_exit_lights_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_emer_exit_lights_switch == 2 then
		B738DR_emer_exit_lights_switch = 1
	elseif B738DR_emer_exit_lights_switch == 1 then
		B738DR_emer_exit_lights_switch = 0
		end
	end
end	


function B738_ex_test_lft_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_extinguisher_circuit_test_pos == 1 then
		B738DR_extinguisher_circuit_test_pos = 0
	elseif B738DR_extinguisher_circuit_test_pos == 0 then
		B738DR_extinguisher_circuit_test_pos = -1
		end
	end
end

function B738_ex_test_rgt_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_extinguisher_circuit_test_pos == -1 then
		B738DR_extinguisher_circuit_test_pos = 0
	elseif B738DR_extinguisher_circuit_test_pos == 0 then
		B738DR_extinguisher_circuit_test_pos = 1
		end
	end
end
	
function B738_cargo_fire_test_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_cargo_fire_test_button_pos == 0 then
		B738DR_cargo_fire_test_button_pos = 1
		extinguisher_circuit_annun2 = 1
		cargo_fire_annuns = 1
		fire_bell_annun_reset = 1
		end
	elseif phase == 2 then
		if B738DR_cargo_fire_test_button_pos == 1 then
		B738DR_cargo_fire_test_button_pos = 0
		end
	end
end

function B738_fire_test_lft_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_fire_test_switch_pos == 1 then
		apu_fire_annun = 0
		wheel_well_fire = 0		
		B738DR_fire_test_switch_pos = 0
	elseif B738DR_fire_test_switch_pos == 0 then
		B738DR_fire_test_switch_pos = -1
		end
	end
end

function B738_fire_test_rgt_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_fire_test_switch_pos == -1 then
		B738DR_fire_test_switch_pos = 0
	elseif B738DR_fire_test_switch_pos == 0 then
		B738DR_fire_test_switch_pos = 1
		fire_panel_annuns_test = 1
		fire_bell_annun_reset = 1
		simCMD_test_fire_1_annun:start()
		simCMD_test_fire_2_annun:start()
		end
	end
end

function B738_ap_disconnect_test1_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_ap_disconnect1_test_switch_pos == -1 then
		B738DR_ap_disconnect1_test_switch_pos = 0
	elseif B738DR_ap_disconnect1_test_switch_pos == 0 then
		B738DR_ap_disconnect1_test_switch_pos = 1
		end
	end
end

function B738_ap_disconnect_test1_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_ap_disconnect1_test_switch_pos == 1 then
		B738DR_ap_disconnect1_test_switch_pos = 0
	elseif B738DR_ap_disconnect1_test_switch_pos == 0 then
		B738DR_ap_disconnect1_test_switch_pos = -1
		end
	end
end

function B738_ap_disconnect_test2_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_ap_disconnect2_test_switch_pos == -1 then
		B738DR_ap_disconnect2_test_switch_pos = 0
	elseif B738DR_ap_disconnect2_test_switch_pos == 0 then
		B738DR_ap_disconnect2_test_switch_pos = 1
		end
	end
end

function B738_ap_disconnect_test2_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_ap_disconnect2_test_switch_pos == 1 then
		B738DR_ap_disconnect2_test_switch_pos = 0
	elseif B738DR_ap_disconnect2_test_switch_pos == 0 then
		B738DR_ap_disconnect2_test_switch_pos = -1
		end
	end
end

function B738_fire_bell_light_button1_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_fire_bell_pos1 == 0 then
		B738DR_fire_bell_pos1 = 1
		simCMD_test_fire_1_annun:stop()
		simCMD_test_fire_2_annun:stop()
		simCMD_master_warning_accept:once()
		fire_bell_annun_reset = 0
		end
	elseif phase == 2 then
		B738DR_fire_bell_pos1 = 0
	end
end


function B738_fire_bell_light_button2_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_fire_bell_pos2 == 0 then
		B738DR_fire_bell_pos2 = 1
		simCMD_test_fire_1_annun:stop()
		simCMD_test_fire_2_annun:stop()
		simCMD_master_warning_accept:once()
		fire_bell_annun_reset = 0
		end
	elseif phase == 2 then
		B738DR_fire_bell_pos2 = 0	
	end
end

function B738_master_caution1_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_master_caution_pos1 == 0 then
		B738DR_master_caution_pos1 = 1
		fire_panel_annuns_test = 0
		cargo_fire_annuns = 0
		apu_fire_annun = 0
		wheel_well_fire = 0
		extinguisher_circuit_annun2 = 0
		fire_bell_annun_reset = 1
		ovht_det_six_pack = 0
		simCMD_master_caution_accept:once()
		end
	elseif phase == 2 then
		B738DR_master_caution_pos1 = 0
	end
end

function B738_master_caution2_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_master_caution_pos2 == 0 then
		B738DR_master_caution_pos2 = 1
		fire_panel_annuns_test = 0
		cargo_fire_annuns = 0
		apu_fire_annun = 0
		wheel_well_fire = 0
		extinguisher_circuit_annun2 = 0
		fire_bell_annun_reset = 1
		ovht_det_six_pack = 0
		simCMD_master_caution_accept:once()
		end
	elseif phase == 2 then
		B738DR_master_caution_pos2 = 0
	end
end

-----------------------------------------------------

-- CAPTAIN AUDIO PANEL MIC SELECTOR COMMAND HANDLERS

function B738_capt_push_mic1_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_capt_mic1_pos == 0 then
		B738DR_audio_panel_capt_mic1_pos = 1
		B738DR_audio_panel_capt_mic2_pos = 0
		B738DR_audio_panel_capt_mic3_pos = 0
		B738DR_audio_panel_capt_mic4_pos = 0
		B738DR_audio_panel_capt_mic5_pos = 0
		B738DR_audio_panel_capt_mic6_pos = 0
		end
	end
end

function B738_capt_push_mic2_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_capt_mic2_pos == 0 then
		B738DR_audio_panel_capt_mic1_pos = 0
		B738DR_audio_panel_capt_mic2_pos = 1
		B738DR_audio_panel_capt_mic3_pos = 0
		B738DR_audio_panel_capt_mic4_pos = 0
		B738DR_audio_panel_capt_mic5_pos = 0
		B738DR_audio_panel_capt_mic6_pos = 0
		end
	end
end

function B738_capt_push_mic3_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_capt_mic3_pos == 0 then
		B738DR_audio_panel_capt_mic1_pos = 0
		B738DR_audio_panel_capt_mic2_pos = 0
		B738DR_audio_panel_capt_mic3_pos = 1
		B738DR_audio_panel_capt_mic4_pos = 0
		B738DR_audio_panel_capt_mic5_pos = 0
		B738DR_audio_panel_capt_mic6_pos = 0
		end
	end
end

function B738_capt_push_mic4_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_capt_mic4_pos == 0 then
		B738DR_audio_panel_capt_mic1_pos = 0
		B738DR_audio_panel_capt_mic2_pos = 0
		B738DR_audio_panel_capt_mic3_pos = 0
		B738DR_audio_panel_capt_mic4_pos = 1
		B738DR_audio_panel_capt_mic5_pos = 0
		B738DR_audio_panel_capt_mic6_pos = 0
		end
	end
end

function B738_capt_push_mic5_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_capt_mic5_pos == 0 then
		B738DR_audio_panel_capt_mic1_pos = 0
		B738DR_audio_panel_capt_mic2_pos = 0
		B738DR_audio_panel_capt_mic3_pos = 0
		B738DR_audio_panel_capt_mic4_pos = 0
		B738DR_audio_panel_capt_mic5_pos = 1
		B738DR_audio_panel_capt_mic6_pos = 0
		end
	end
end
	
function B738_capt_push_mic6_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_capt_mic6_pos == 0 then
		B738DR_audio_panel_capt_mic1_pos = 0
		B738DR_audio_panel_capt_mic2_pos = 0
		B738DR_audio_panel_capt_mic3_pos = 0
		B738DR_audio_panel_capt_mic4_pos = 0
		B738DR_audio_panel_capt_mic5_pos = 0
		B738DR_audio_panel_capt_mic6_pos = 1
		end
	end
end

-- FIRST OFFICER AUDIO PANEL MIC SELECTOR COMMAND HANDLERS --------------

function B738_fo_push_mic1_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_fo_mic1_pos == 0 then
		B738DR_audio_panel_fo_mic1_pos = 1
		B738DR_audio_panel_fo_mic2_pos = 0
		B738DR_audio_panel_fo_mic3_pos = 0
		B738DR_audio_panel_fo_mic4_pos = 0
		B738DR_audio_panel_fo_mic5_pos = 0
		B738DR_audio_panel_fo_mic6_pos = 0
		end
	end
end

function B738_fo_push_mic2_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_fo_mic2_pos == 0 then
		B738DR_audio_panel_fo_mic1_pos = 0
		B738DR_audio_panel_fo_mic2_pos = 1
		B738DR_audio_panel_fo_mic3_pos = 0
		B738DR_audio_panel_fo_mic4_pos = 0
		B738DR_audio_panel_fo_mic5_pos = 0
		B738DR_audio_panel_fo_mic6_pos = 0
		end
	end
end

function B738_fo_push_mic3_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_fo_mic3_pos == 0 then
		B738DR_audio_panel_fo_mic1_pos = 0
		B738DR_audio_panel_fo_mic2_pos = 0
		B738DR_audio_panel_fo_mic3_pos = 1
		B738DR_audio_panel_fo_mic4_pos = 0
		B738DR_audio_panel_fo_mic5_pos = 0
		B738DR_audio_panel_fo_mic6_pos = 0
		end
	end
end

function B738_fo_push_mic4_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_fo_mic4_pos == 0 then
		B738DR_audio_panel_fo_mic1_pos = 0
		B738DR_audio_panel_fo_mic2_pos = 0
		B738DR_audio_panel_fo_mic3_pos = 0
		B738DR_audio_panel_fo_mic4_pos = 1
		B738DR_audio_panel_fo_mic5_pos = 0
		B738DR_audio_panel_fo_mic6_pos = 0
		end
	end
end

function B738_fo_push_mic5_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_fo_mic5_pos == 0 then
		B738DR_audio_panel_fo_mic1_pos = 0
		B738DR_audio_panel_fo_mic2_pos = 0
		B738DR_audio_panel_fo_mic3_pos = 0
		B738DR_audio_panel_fo_mic4_pos = 0
		B738DR_audio_panel_fo_mic5_pos = 1
		B738DR_audio_panel_fo_mic6_pos = 0
		end
	end
end

function B738_fo_push_mic6_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_fo_mic6_pos == 0 then
		B738DR_audio_panel_fo_mic1_pos = 0
		B738DR_audio_panel_fo_mic2_pos = 0
		B738DR_audio_panel_fo_mic3_pos = 0
		B738DR_audio_panel_fo_mic4_pos = 0
		B738DR_audio_panel_fo_mic5_pos = 0
		B738DR_audio_panel_fo_mic6_pos = 1
		end
	end
end

-- OBSERVER AUDIO PANEL MIC SELECTOR COMMAND HANDLERS --------------

function B738_obs_push_mic1_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_obs_mic1_pos == 0 then
		B738DR_audio_panel_obs_mic1_pos = 1
		B738DR_audio_panel_obs_mic2_pos = 0
		B738DR_audio_panel_obs_mic3_pos = 0
		B738DR_audio_panel_obs_mic4_pos = 0
		B738DR_audio_panel_obs_mic5_pos = 0
		B738DR_audio_panel_obs_mic6_pos = 0
		end
	end
end

function B738_obs_push_mic2_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_obs_mic2_pos == 0 then
		B738DR_audio_panel_obs_mic1_pos = 0
		B738DR_audio_panel_obs_mic2_pos = 1
		B738DR_audio_panel_obs_mic3_pos = 0
		B738DR_audio_panel_obs_mic4_pos = 0
		B738DR_audio_panel_obs_mic5_pos = 0
		B738DR_audio_panel_obs_mic6_pos = 0
		end
	end
end

function B738_obs_push_mic3_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_obs_mic3_pos == 0 then
		B738DR_audio_panel_obs_mic1_pos = 0
		B738DR_audio_panel_obs_mic2_pos = 0
		B738DR_audio_panel_obs_mic3_pos = 1
		B738DR_audio_panel_obs_mic4_pos = 0
		B738DR_audio_panel_obs_mic5_pos = 0
		B738DR_audio_panel_obs_mic6_pos = 0
		end
	end
end

function B738_obs_push_mic4_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_obs_mic4_pos == 0 then
		B738DR_audio_panel_obs_mic1_pos = 0
		B738DR_audio_panel_obs_mic2_pos = 0
		B738DR_audio_panel_obs_mic3_pos = 0
		B738DR_audio_panel_obs_mic4_pos = 1
		B738DR_audio_panel_obs_mic5_pos = 0
		B738DR_audio_panel_obs_mic6_pos = 0
		end
	end
end

function B738_obs_push_mic5_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_obs_mic5_pos == 0 then
		B738DR_audio_panel_obs_mic1_pos = 0
		B738DR_audio_panel_obs_mic2_pos = 0
		B738DR_audio_panel_obs_mic3_pos = 0
		B738DR_audio_panel_obs_mic4_pos = 0
		B738DR_audio_panel_obs_mic5_pos = 1
		B738DR_audio_panel_obs_mic6_pos = 0
		end
	end
end

function B738_obs_push_mic6_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_audio_panel_obs_mic6_pos == 0 then
		B738DR_audio_panel_obs_mic1_pos = 0
		B738DR_audio_panel_obs_mic2_pos = 0
		B738DR_audio_panel_obs_mic3_pos = 0
		B738DR_audio_panel_obs_mic4_pos = 0
		B738DR_audio_panel_obs_mic5_pos = 0
		B738DR_audio_panel_obs_mic6_pos = 1
		end
	end
end


-- AI

function B738_ai_annun_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	B738_set_annun_all_modes()
	  	B738_set_annun_CD() 
	  	B738_set_annun_ER()
	end 	
end	

----------------------------------------------------------------------------------------------------


--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

B738CMD_elt_pos_on		= create_command("laminar/B738/toggle_switch/elt_on", "ELT on", B738_elt_pos_on_CMDhandler)
B738CMD_elt_pos_arm		= create_command("laminar/B738/toggle_switch/elt_arm", "ELT arm", B738_elt_pos_arm_CMDhandler)

B738CMD_bright_test_switch_dn	= create_command("laminar/B738/toggle_switch/bright_test_dn", "Lights Test / Brightness", B738_bright_test_switch_pos_dn_CMDhandler)
B738CMD_bright_test_switch_up	= create_command("laminar/B738/toggle_switch/bright_test_up", "Lights Test / Brightness", B738_bright_test_switch_pos_up_CMDhandler)

B738CMD_emer_exit_lights_switch_dn	= create_command("laminar/B738/toggle_switch/emer_exit_lights_dn", "Emergency Exit Lights Switch", B738_emer_exit_lights_switch_dn_CMDhandler)
B738CMD_emer_exit_lights_switch_up	= create_command("laminar/B738/toggle_switch/emer_exit_lights_up", "Emergency Exit Lights Switch", B738_emer_exit_lights_switch_up_CMDhandler)

B738CMD_extinguisher_circuit_test_lft	= create_command("laminar/B738/toggle_switch/exting_test_lft", "Extinguisher Test Switch", B738_ex_test_lft_CMDhandler)
B738CMD_extinguisher_circuit_test_rgt	= create_command("laminar/B738/toggle_switch/exting_test_rgt", "Extinguisher Test Switch", B738_ex_test_rgt_CMDhandler)

B738CMD_cargo_fire_test_button			= create_command("laminar/B738/push_button/cargo_fire_test_push", "Cargo Fire Test", B738_cargo_fire_test_CMDhandler)

B738CMD_fire_test_switch_lft	= create_command("laminar/B738/toggle_switch/fire_test_lft", "Fire Panel Test", B738_fire_test_lft_CMDhandler)
B738CMD_fire_test_switch_rgt	= create_command("laminar/B738/toggle_switch/fire_test_rgt", "Fire Panel Test", B738_fire_test_rgt_CMDhandler)

B738CMD_ap_disconnect_test1_up	= create_command("laminar/B738/toggle_switch/ap_disconnect_test1_up", "Captain AP Disconnect Test", B738_ap_disconnect_test1_up_CMDhandler)
B738CMD_ap_disconnect_test1_dn	= create_command("laminar/B738/toggle_switch/ap_disconnect_test1_dn", "Captain AP Disconnect Test", B738_ap_disconnect_test1_dn_CMDhandler)

B738CMD_ap_disconnect_test2_up	= create_command("laminar/B738/toggle_switch/ap_disconnect_test2_up", "First Officer AP Disconnect Test", B738_ap_disconnect_test2_up_CMDhandler)
B738CMD_ap_disconnect_test2_dn	= create_command("laminar/B738/toggle_switch/ap_disconnect_test2_dn", "First Officer AP Disconnect Test", B738_ap_disconnect_test2_dn_CMDhandler)

B738CMD_fire_bell_light_button1	= create_command("laminar/B738/push_button/fire_bell_light1", "Captain Fire Warn Bell Cutout", B738_fire_bell_light_button1_CMDhandler)
B738CMD_fire_bell_light_button2	= create_command("laminar/B738/push_button/fire_bell_light2", "First Officer Fire Warn Bell Cutout", B738_fire_bell_light_button2_CMDhandler)

B738CMD_master_caution_button1	= create_command("laminar/B738/push_button/master_caution1", "Captain Fire Master Caution", B738_master_caution1_CMDhandler)
B738CMD_master_caution_button2	= create_command("laminar/B738/push_button/master_caution2", "First Officer Master Caution", B738_master_caution2_CMDhandler)

-- AUDIO PANEL MIC SELECTOR COMMANDS
	-- CAPT
	
B738CMD_capt_push_mic1			= create_command("laminar/B738/audio/capt/mic_push1", "Captain VHF1 Mic", B738_capt_push_mic1_CMDhandler)
B738CMD_capt_push_mic2			= create_command("laminar/B738/audio/capt/mic_push2", "Captain VHF2 Mic", B738_capt_push_mic2_CMDhandler)
B738CMD_capt_push_mic3			= create_command("laminar/B738/audio/capt/mic_push3", "Captain VHF3 Mic", B738_capt_push_mic3_CMDhandler)
B738CMD_capt_push_mic4			= create_command("laminar/B738/audio/capt/mic_push4", "Captain Interphone Mic", B738_capt_push_mic4_CMDhandler)
B738CMD_capt_push_mic5			= create_command("laminar/B738/audio/capt/mic_push5", "Captain Cabin Mic", B738_capt_push_mic5_CMDhandler)
B738CMD_capt_push_mic6			= create_command("laminar/B738/audio/capt/mic_push6", "Captain PA Mic", B738_capt_push_mic6_CMDhandler)

	-- F/O

B738CMD_fo_push_mic1			= create_command("laminar/B738/audio/fo/mic_push1", "First Officer VHF1 Mic", B738_fo_push_mic1_CMDhandler)
B738CMD_fo_push_mic2			= create_command("laminar/B738/audio/fo/mic_push2", "First Officer VHF2 Mic", B738_fo_push_mic2_CMDhandler)
B738CMD_fo_push_mic3			= create_command("laminar/B738/audio/fo/mic_push3", "First Officer VHF3 Mic", B738_fo_push_mic3_CMDhandler)
B738CMD_fo_push_mic4			= create_command("laminar/B738/audio/fo/mic_push4", "First Officer Interphone Mic", B738_fo_push_mic4_CMDhandler)
B738CMD_fo_push_mic5			= create_command("laminar/B738/audio/fo/mic_push5", "First Officer Cabin Mic", B738_fo_push_mic5_CMDhandler)
B738CMD_fo_push_mic6			= create_command("laminar/B738/audio/fo/mic_push6", "First Officer PA Mic", B738_fo_push_mic6_CMDhandler)

	-- OBS
	
B738CMD_obs_push_mic1			= create_command("laminar/B738/audio/obs/mic_push1", "Observer VHF1 Mic", B738_obs_push_mic1_CMDhandler)
B738CMD_obs_push_mic2			= create_command("laminar/B738/audio/obs/mic_push2", "Observer VHF2 Mic", B738_obs_push_mic2_CMDhandler)
B738CMD_obs_push_mic3			= create_command("laminar/B738/audio/obs/mic_push3", "Observer VHF3 Mic", B738_obs_push_mic3_CMDhandler)
B738CMD_obs_push_mic4			= create_command("laminar/B738/audio/obs/mic_push4", "Observer Interphone Mic", B738_obs_push_mic4_CMDhandler)
B738CMD_obs_push_mic5			= create_command("laminar/B738/audio/obs/mic_push5", "Observer Cabin Mic", B738_obs_push_mic5_CMDhandler)
B738CMD_obs_push_mic6			= create_command("laminar/B738/audio/obs/mic_push6", "Observer PA Mic", B738_obs_push_mic6_CMDhandler)

-- AI

B738CMD_ai_annun_quick_start		= create_command("laminar/B738/ai/annun_quick_start", "number", B738_ai_annun_quick_start_CMDhandler)

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


----- RESCALE FLOAT AND CLAMP TO OUTER LIMITS -------------------------------------------

function B738_rescale(in1, out1, in2, out2, x)
    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end


-- B738_external_power()

function B738_external_power()

    if B738DR_ground_power_switch_pos == 1
        and simDR_aircraft_on_ground == 1
        and simDR_aircraft_groundspeed < 0.05
        and simDR_ext_pwr_1_on == 0
    then
        simDR_ext_pwr_1_on = 1
    elseif B738DR_ground_power_switch_pos == 0 then
        simDR_ext_pwr_1_on = 0
    end
    
    if simDR_aircraft_groundspeed > 0.05 then
    simDR_ext_pwr_1_on = 0
    end
    
end


-- BATTERY DICHARGE

function B738_Amp5Exceed() 
	batt_discharge = 1
end	
	
function B738_Amp15Exceed() 
	batt_discharge = 1	
end	

function B738_Amp100Exceed() 
	batt_discharge = 1	
end	

function B738_battery_disch_annun()

	-- BATTERY DISHARGE IS LESS THAN 5.0 AMPS
	if simDR_battery_amps[0] > -5.0 then
		batt_discharge = 0	
		if is_timer_scheduled(B738_Amp5Exceed) == true then stop_timer(B738_Amp5Exceed) end
		if is_timer_scheduled(B738_Amp15Exceed) == true then stop_timer(B738_Amp15Exceed) end			
		if is_timer_scheduled(B738_Amp100Exceed) == true then stop_timer(B738_Amp100Exceed) end			
	
	-- BATTERY DISCHARGE EXCEEDS 5.0 AMPS
	elseif simDR_battery_amps[0] <= -5.0 and simDR_battery_amps[0] > -15.0 then
		if is_timer_scheduled(B738_Amp5Exceed) == false then run_after_time(B738_Amp5Exceed, 95.0) end
		if is_timer_scheduled(B738_Amp15Exceed) == true then stop_timer(B738_Amp15Exceed) end			
		if is_timer_scheduled(B738_Amp100Exceed) == true then stop_timer(B738_Amp100Exceed) end
						

	-- BATTERY DISCHARGE EXCEEDS 15.0 AMPS
	elseif simDR_battery_amps[0] <= -15.0 and simDR_battery_amps[0] > -100.0 then
		if is_timer_scheduled(B738_Amp15Exceed) == false then run_after_time(B738_Amp15Exceed, 25.0) end
		if is_timer_scheduled(B738_Amp5Exceed) == true then stop_timer(B738_Amp5Exceed) end			
		if is_timer_scheduled(B738_Amp100Exceed) == true then stop_timer(B738_Amp100Exceed) end
	
	-- BATTERY DISCHARGE EXCEEDS 100.0 AMPS
	elseif simDR_battery_amps[0] <= -100.0 then
		if is_timer_scheduled(B738_Amp100Exceed) == false then run_after_time(B738_Amp100Exceed, 1.2) end
		if is_timer_scheduled(B738_Amp5Exceed) == true then stop_timer(B738_Amp5Exceed) end			
		if is_timer_scheduled(B738_Amp15Exceed) == true then stop_timer(B738_Amp15Exceed) end		
	end	
		
end


----- ANNUNCIATORS -----------------------------------------------------------------------

function B738_annunciators()
	local bus1Power = B738_rescale(0.0, 0.0, 28.0, 1.0, simDR_electrical_bus_volts0)
	local bus2Power = B738_rescale(0.0, 0.0, 28.0, 1.0, simDR_electrical_bus_volts1)
	local busPower  = math.max(bus1Power, bus2Power)
	local brightness_level = simDR_generic_brightness_ratio63 * busPower
	local brightness_level2 = simDR_generic_brightness_ratio62 * busPower

	local parking_brake_annun_on = 0
		if simDR_parking_brake > 0.9 then
		parking_brake_annun_on = 1
		end

	B738DR_brightness2_export = brightness_level2

	B738DR_parking_brake_annun = parking_brake_annun_on * brightness_level2
	
	B738DR_window_heat_annun = simDR_window_heat * brightness_level



	local fadec_fail_0 = 0
		if simDR_fadec_fail_0 > 5.5 then
		fadec_fail_0 = 1
		end
	local fadec_fail_1 = 0
		if simDR_fadec_fail_1 > 5.5 then
		fadec_fail_1 = 1
		end
	
	local reverser_fail_0 = 0
		if simDR_reverser_fail_0 > 5.5 then
		reverser_fail_0 = 1
		end
	local reverser_fail_1 = 0
		if simDR_reverser_fail_1 > 5.5 then
		reverser_fail_1 = 1
		end


	B738DR_fadec_fail_annun_0 = fadec_fail_0 * brightness_level
	B738DR_fadec_fail_annun_1 = fadec_fail_1 * brightness_level
	B738DR_reverser_fail_annun_0 = reverser_fail_0 * brightness_level
	B738DR_reverser_fail_annun_1 = reverser_fail_1 * brightness_level
	
	local apu_fault = 0
		if simDR_apu_fault > 5.5 then
		apu_fault = 1
		end
	
	B738DR_apu_fault_annun = apu_fault * brightness_level

	B738DR_pax_oxy = simDR_pax_oxy_status * brightness_level
	
	B738DR_wing_body_ovht = simDR_wing_body_ovht_annun * brightness_level

	B738DR_bleed_trip_off1 = simDR_bleed_trip_off1_annun * brightness_level

	B738DR_bleed_trip_off2 = simDR_bleed_trip_off2_annun * brightness_level

	B738DR_battery_disch_annun = batt_discharge * brightness_level


	local transponder_fail = 0
		if simDR_transponder_fail == 6 then
		transponder_fail = 1
		end
		
	B738DR_transponder_fail_light = transponder_fail * brightness_level2
	

-- AUDIO PANEL

	B738DR_audio_panel_indicator_com1 = simDR_audio_selection_com1 * brightness_level
	B738DR_audio_panel_indicator_com2 = simDR_audio_selection_com2 * brightness_level
	B738DR_audio_panel_indicator_nav1 = simDR_audio_selection_nav1 * brightness_level
	B738DR_audio_panel_indicator_nav2 = simDR_audio_selection_nav2 * brightness_level
	B738DR_audio_panel_indicator_marker = simDR_audio_selection_marker * brightness_level


	B738DR_audio_panel_com1_avail = simDR_com1_active * brightness_level2
	B738DR_audio_panel_com2_avail = simDR_com2_active * brightness_level2
	
	local marker_indicator = 0
		if simDR_outer_marker_active == 1
		or simDR_outer_middle_active == 1
		or simDR_outer_inner_active == 1 then
		marker_indicator = 1
		end
		
	B738DR_audio_panel_mark_avail = marker_indicator * brightness_level2
	
	local nav1_indicator = 0
		if simDR_nav1h_active == 1
		or simDR_nav1v_active == 1
		or simDR_nav1dme_active == 1 then
		nav1_indicator = 1
		end
		
	B738DR_audio_panel_nav1_avail = nav1_indicator * brightness_level2
	
	local nav2_indicator = 0
		if simDR_nav2h_active == 1
		or simDR_nav2v_active == 1
		or simDR_nav2dme_active == 1 then
		nav2_indicator = 1
		end
		
	B738DR_audio_panel_nav2_avail = nav2_indicator * brightness_level2


-- AUDIO PANEL MIC LIGHTS

B738DR_audio_panel_capt_mic1_light = B738DR_audio_panel_capt_mic1_pos * brightness_level
B738DR_audio_panel_capt_mic2_light = B738DR_audio_panel_capt_mic2_pos * brightness_level
B738DR_audio_panel_capt_mic3_light = B738DR_audio_panel_capt_mic3_pos * brightness_level
B738DR_audio_panel_capt_mic4_light = B738DR_audio_panel_capt_mic4_pos * brightness_level
B738DR_audio_panel_capt_mic5_light = B738DR_audio_panel_capt_mic5_pos * brightness_level
B738DR_audio_panel_capt_mic6_light = B738DR_audio_panel_capt_mic6_pos * brightness_level

B738DR_audio_panel_fo_mic1_light = B738DR_audio_panel_fo_mic1_pos * brightness_level
B738DR_audio_panel_fo_mic2_light = B738DR_audio_panel_fo_mic2_pos * brightness_level
B738DR_audio_panel_fo_mic3_light = B738DR_audio_panel_fo_mic3_pos * brightness_level
B738DR_audio_panel_fo_mic4_light = B738DR_audio_panel_fo_mic4_pos * brightness_level
B738DR_audio_panel_fo_mic5_light = B738DR_audio_panel_fo_mic5_pos * brightness_level
B738DR_audio_panel_fo_mic6_light = B738DR_audio_panel_fo_mic6_pos * brightness_level

B738DR_audio_panel_obs_mic1_light = B738DR_audio_panel_obs_mic1_pos * brightness_level
B738DR_audio_panel_obs_mic2_light = B738DR_audio_panel_obs_mic2_pos * brightness_level
B738DR_audio_panel_obs_mic3_light = B738DR_audio_panel_obs_mic3_pos * brightness_level
B738DR_audio_panel_obs_mic4_light = B738DR_audio_panel_obs_mic4_pos * brightness_level
B738DR_audio_panel_obs_mic5_light = B738DR_audio_panel_obs_mic5_pos * brightness_level
B738DR_audio_panel_obs_mic6_light = B738DR_audio_panel_obs_mic6_pos * brightness_level


----- DOORS -------------------------------------------------------

	local fwd_entry = 0
		if simDR_fwd_entry_status > 0.01 then
		fwd_entry = 1
		end
		
	local aft_entry = 0
		if simDR_aft_entry_status > 0.01 then
		aft_entry = 1
		end	

	local fwd_service = 0
		if simDR_fwd_service_status > 0.01 then
		fwd_service = 1
		end
		
	local aft_service = 0
		if simDR_aft_service_status > 0.01 then
		aft_service = 1
		end	

	local fwd_cargo = 0
		if simDR_fwd_cargo_status > 0.01 then
		fwd_cargo = 1
		end
		
	local aft_cargo = 0
		if simDR_aft_cargo_status > 0.01 then
		aft_cargo = 1
		end	

	local left_fwd_overwing = 0
		if simDR_left_fwd_overwing_status > 0.01 then
		left_fwd_overwing = 1
		end
		
	local left_aft_overwing = 0
		if simDR_left_aft_overwing_status > 0.01 then
		left_aft_overwing = 1
		end

	local right_fwd_overwing = 0
		if simDR_right_fwd_overwing_status > 0.01 then
		right_fwd_overwing = 1
		end
		
	local right_aft_overwing = 0
		if simDR_right_aft_overwing_status > 0.01 then
		right_aft_overwing = 1
		end

	local equipment = 0
		if simDR_equipment_status > 0.01 then
		equipment = 1
		end

	B738DR_fwd_entry = fwd_entry * brightness_level
	B738DR_aft_entry = aft_entry * brightness_level
	B738DR_fwd_service = fwd_service * brightness_level
	B738DR_aft_service = aft_service * brightness_level
	B738DR_fwd_cargo = fwd_cargo * brightness_level
	B738DR_aft_cargo = aft_cargo * brightness_level
	B738DR_left_fwd_overwing = left_fwd_overwing * brightness_level
	B738DR_left_aft_overwing = left_aft_overwing * brightness_level
	B738DR_right_fwd_overwing = right_fwd_overwing * brightness_level
	B738DR_right_aft_overwing = right_aft_overwing * brightness_level

	B738DR_equip_door = equipment * brightness_level


-- YAW DAMPER

	local yaw_damper_off = 1
	if simDR_yaw_damper_annun == 1 then
	yaw_damper_off = 0
	end

	B738DR_yaw_damper = yaw_damper_off * brightness_level

-- FDR OFF

	local fdr_off = 0
		if simDR_aircraft_on_ground == 1
			and simDR_N2_eng1_percent < 50
			and simDR_N2_eng2_percent < 50
		then
			fdr_off = 1
		elseif simDR_aircraft_on_ground == 1
			and simDR_bus_amps1 < 0.3
		then
			fdr_off = 1
		elseif simDR_aircraft_on_ground == 0
			and simDR_bus_amps1 < 0.3
		then
			fdr_off = 1
		end
		
	B738DR_fdr_off = fdr_off * brightness_level


-- AP DISCONNECT


	local ap_disconnect1_test = 0
		if B738DR_ap_disconnect1_test_switch_pos == 1
		or B738DR_ap_disconnect1_test_switch_pos == -1
		then
		ap_disconnect1_test = 1
	end

	local ap_disconnect2_test = 0	
		if B738DR_ap_disconnect2_test_switch_pos == 1
		or B738DR_ap_disconnect2_test_switch_pos == -1
		then
		ap_disconnect2_test = 1
	end

	local ap_discon_annun1 = 0
		if ap_disconnect1_test == 1
		or simDR_ap_disconnect == 1
		then
		ap_discon_annun1 = 1
	end

	local ap_discon_annun2 = 0
		if ap_disconnect2_test == 1
		or simDR_ap_disconnect == 1
		then
		ap_discon_annun2 = 1
	end
	

	B738DR_ap_disconnect1_annun = ap_discon_annun1 * brightness_level
	B738DR_ap_disconnect2_annun = ap_discon_annun2 * brightness_level	
	B738DR_at_fms_disconnect1_annun = ap_disconnect1_test * brightness_level
	B738DR_at_fms_disconnect2_annun = ap_disconnect2_test * brightness_level


----------- FIRE PANEL -----------------------------------------------------


----- FIRE HANDLES -----

	eng1_fire_annun = 0
		if simDR_engine1_fire == 1 
		or B738DR_fire_test_switch_pos == 1 then
		eng1_fire_annun = 1
		end
	
	eng2_fire_annun = 0
		if simDR_engine2_fire == 1
		or B738DR_fire_test_switch_pos == 1 then
		eng2_fire_annun = 1
		end	

	eng1_ovht = 0
		if simDR_engine1_egt > 950
		or B738DR_fire_test_switch_pos == 1 then
		eng1_ovht = 1
		end

	eng2_ovht = 0
		if simDR_engine2_egt > 950
		or B738DR_fire_test_switch_pos == 1 then
		eng2_ovht = 1
		end

	if fire_panel_annuns_test == 1
	then
		apu_fire_annun = 1
		eng1_fire_annun = 1
		eng2_fire_annun = 1
		wheel_well_fire = 1
		eng1_ovht = 1
		eng2_ovht = 1
	end


	local l_bottle_discharge = 0
		if B738DR_l_bottle_psi == 0 then
		l_bottle_discharge = 1
		end
	
	local r_bottle_discharge = 0
		if B738DR_r_bottle_psi == 0 then
		r_bottle_discharge = 1
		end


-- FIRE ANNUNS

	B738DR_apu_fire = apu_fire_annun * brightness_level2
	B738DR_engine1_fire = eng1_fire_annun * brightness_level2
	B738DR_engine2_fire = eng2_fire_annun * brightness_level2
	B738DR_wheel_well_fire = wheel_well_fire * brightness_level
	B738DR_engine1_ovht	= eng1_ovht * brightness_level
	B738DR_engine2_ovht	= eng2_ovht * brightness_level	

	B738DR_l_bottle_discharge = l_bottle_discharge * brightness_level
	B738DR_r_bottle_discharge = r_bottle_discharge * brightness_level	

-- SIX PACK ANNUN

	ovht_det_six_pack = 0
	if eng1_fire_annun == 1
		or eng2_fire_annun == 1
		or eng1_ovht == 1
		or eng2_ovht == 1
		or cargo_fire_annuns == 1
		or fire_panel_annuns_test == 1 then
		ovht_det_six_pack = 1
	end

-- FIRE BELL LOGIC

	fire_bell_annun = 0
	if eng1_fire_annun == 1
		or eng2_fire_annun == 1
		or cargo_fire_annuns == 1
		or fire_panel_annuns_test == 1 then
		fire_bell_annun = 1
	end


	B738DR_six_pack_fire = ovht_det_six_pack * brightness_level


----- TEST SWITCHES -----

	local exting_circ_test = 0									-- EXTINGUISHER CIRCUIT TEST 1
	if B738DR_extinguisher_circuit_test_pos == 1
		or B738DR_extinguisher_circuit_test_pos == -1 then
		exting_circ_test = 1
		end
	
	if B738DR_extinguisher_circuit_test_pos == 0 then
		exting_circ_test = 0
		end

	B738DR_extinguisher_circuit_annun1 = exting_circ_test * brightness_level

-- CARGO FIRE ANNUNS

	B738DR_extinguisher_circuit_annun2 = extinguisher_circuit_annun2 * brightness_level
	B738DR_cargo_fire_annuns = cargo_fire_annuns * brightness_level	
	
	fire_fault_inop_annun = 0									-- CARGO FIRE TEST BUTTON
	if B738DR_fire_test_switch_pos == -1 then
	fire_fault_inop_annun = 1
	end
	
	B738DR_fire_fault_inop_annun = fire_fault_inop_annun * brightness_level

-- FIRE BELL ANNUNCIATOR

	B738DR_fire_bell_annun = fire_bell_annun * fire_bell_annun_reset * brightness_level2


---- MASTER CAUTION ----------------------------------------------------------------------

	local master_caution_light = 0
		if fire_panel_annuns_test == 1
		or cargo_fire_annuns == 1
		or simDR_waster_caution_light == 1 then
		master_caution_light = 1
		end
	
	
	B738DR_master_caution_light = master_caution_light * brightness_level2
 

-- MASTER CAUTION SIX PACK PILOT


-- FUEL

	local fuel_six_pack = 0
		if simDR_low_fuel == 1
		or simDR_low_fuel_press1 == 1
		or simDR_low_fuel_press2 == 1 then
		fuel_six_pack = 1
		end
		if simDR_low_fuel == 0
		and simDR_low_fuel_press1 == 0
		and simDR_low_fuel_press2 == 1 then
		fuel_six_pack = 1
		end
		
	B738DR_six_pack_fuel = fuel_six_pack * brightness_level

-- APU

	local apu_six_pack = 0
		if simDR_apu_fault == 1 then
		apu_six_pack = 1
		end
		
	B738DR_six_pack_apu = apu_six_pack * brightness_level

-- IRS

	local gps_fail = 0
		if simDR_gps_fail == 6 then
		gps_fail = 1
		end
		
	B738DR_six_pack_irs	= gps_fail * brightness_level
	
-- ELEC

	local elec_fail = 0
		if B738DR_source_off_bus1 > 0.1
		or B738DR_source_off_bus2 > 0.1
		or B738DR_transfer_bus_off1 > 0.1
		or B738DR_transfer_bus_off2 > 0.1
		or B738DR_battery_disch_annun > 0.1
		or B738DR_drive1_annun > 0.1
		or B738DR_drive2_annun > 0.1 then
		elec_fail = 1
		end
	
	B738DR_six_pack_elec = elec_fail * brightness_level
	
-- FLT CONTROLS

	local flt_cont = 0
		if yaw_damper_off == 1
		or simDR_elec_trim_off == 1 then
		flt_cont = 1
		end
	
	B738DR_six_pack_flt_cont = flt_cont * brightness_level

-- DOORS

	local door_open_status = 0
		if fwd_entry == 1
		or aft_entry == 1
		or fwd_service == 1
		or aft_service == 1
		or fwd_cargo == 1
		or aft_cargo == 1
		or left_fwd_overwing == 1
		or left_aft_overwing == 1
		or right_fwd_overwing == 1
		or right_aft_overwing == 1
		or equipment == 1 then
		door_open_status = 1
		end

	B738DR_six_pack_doors = door_open_status * brightness_level

-- ICE

	local six_pack_ice_status = 0
		if simDR_general_ice_detect == 1
		then six_pack_ice_status = 1
		end
	
	B738DR_six_pack_ice = six_pack_ice_status * brightness_level
	
-- AIR COND

	local dual_bleed = 0
		if B738DR_dual_bleed > 0 then
		dual_bleed = 1
		end

	local six_pack_air_cond = 0
		if simDR_wing_body_ovht_annun == 1
		or dual_bleed == 1
		or simDR_bleed_trip_off1_annun == 1
		or simDR_bleed_trip_off2_annun == 1
		or simDR_pack_annun == 6 then
		six_pack_air_cond = 1
		end
	
	B738DR_six_pack_air_cond = six_pack_air_cond * brightness_level
	
-- HYDRAULICS

	local six_pack_hydro = 0
		if simDR_hyd_press_a < 1300
		or simDR_hyd_press_b < 1300 then
		six_pack_hydro = 1
		end
	
	B738DR_six_pack_hyd = six_pack_hydro * brightness_level
	
-- OVERHEAD

	local six_pack_ovhd = 0
		if simDR_pax_oxy_status == 6
		or fdr_off == 1
		or simDR_smoke == 6 then
		six_pack_ovhd = 1
		end
	
	B738DR_six_pack_overhead = six_pack_ovhd * brightness_level
	
-- ENGINES

	local six_pack_eng = 0
		if simDR_fadec_fail_0 == 6
		or simDR_fadec_fail_1 == 6
		or simDR_chip_detect1 == 1
		or simDR_chip_detect2 == 1
		or simDR_reverser_fail_0 == 6
		or simDR_reverser_fail_1 == 6 then
		six_pack_eng = 1
		end

	B738DR_six_pack_eng = six_pack_eng * brightness_level


----- END MASTER CAUTION / SIX PACK ANNUNS ----------------------------------------

----- BELOW GS --------------------------------------------------------------------

	local below_gs = 0
		if simDR_nav1_vert_signal == 1
		and simDR_gs_flag == 0
		and simDR_nav1_vdef_dots < -1
		and simDR_aircraft_on_ground == 0 then
		below_gs = 1
		end
		
	B738DR_below_gs = below_gs * brightness_level


-- SLATS


	local slats_extended = 0
		if simDR_slat_1_deploy == 1
		and simDR_slat_2_deploy == 0.5 then
		slats_extended = 1
		elseif
		simDR_slat_1_deploy == 1
		and simDR_slat_2_deploy == 1 then
		slats_extended = 1
		end
	
	local slats_transit = 0
		if simDR_slat_1_deploy ~= 1
		and simDR_slat_1_deploy ~= 0 then
		slats_transit = 1
		elseif simDR_slat_2_deploy ~= 1
		and simDR_slat_2_deploy ~= 0.5
		and	simDR_slat_2_deploy ~= 0 then
		slats_transit = 1
		end
	
	B738DR_slats_extended = slats_extended * brightness_level
	B738DR_slats_transit = slats_transit * brightness_level	

-- TAKEOFF CONFIG

--[[  WE WANT TO NORMALIZE EVERY VARIABLE SO TRIGGER CONDITIONS ARE TURNED TO 0, SAFE CONDITIONS ARE 1

		simDR_aircraft_on_ground
		simDR_throttle_ratio
		simDR_elevator_trim
		simDR_parking_brake
		simDR_speedbrake_status
		simDR_flap_ratio
		simDR_reverse_thrust
		simDR_reverse_thrust1		
		simDR_reverse_thrust2		
]]--		

local takeoff_config_warn = 0

	local elev_trim_safe = 1
		if simDR_elevator_trim > 0.02941
		or simDR_elevator_trim < -0.7176 then
		elev_trim_safe = 0
		end

	local park_brake_safe = 0
		if simDR_parking_brake <= 0.5 then
		park_brake_safe = 1
		end

	local speedbrake_safe = 0
		if simDR_speedbrake_status == 0 then
		speedbrake_safe = 1
		end
		
	local flap_safe = 1
		if simDR_flap_ratio < 0.125
		or simDR_flap_ratio > 0.75 then
		flap_safe = 0
		end

	local throttle_trigger = 0
		if simDR_throttle_ratio > 0.5 then
		throttle_trigger = 1
		end

	local is_reverse = 0
		if simDR_reverse_thrust1 == 3
		or simDR_reverse_thrust2 == 3 then
		is_reverse = 1
		end

	local takeoff_config_safe = park_brake_safe * speedbrake_safe * flap_safe * elev_trim_safe
	
	if takeoff_config_safe == 0
		and simDR_throttle_ratio > 0.5
		and simDR_aircraft_on_ground == 1 then
		takeoff_config_warn = 1
		end
		
	if takeoff_config_safe == 1 then
		takeoff_config_warn = 0
		end

	if is_reverse == 1 then
	takeoff_config_warn = 0
	end
		
	B738DR_takeoff_config_annun = takeoff_config_warn * brightness_level

-- GPWS

	B738DR_GPWS_annun = simDR_GPWS * brightness_level

-- SPEEDBRAKE ANNUNS

	local spdbrk_armed = 0
		if simDR_speedbrake_status == -0.5 then
		spdbrk_armed = 1
		end
		
	B738DR_speedbrake_armed = spdbrk_armed * brightness_level

	local spdbrk_extend = 0
		if simDR_speedbrake_status > 0 then
		spdbrk_extend = 1
		end

	B738DR_speedbrake_extend = spdbrk_extend * brightness_level

-- CABIN ALT

	local cabin_alt_warn = 0
		if simDR_cabin_alt > 10000 then
		cabin_alt_warn = 1
		end
		
	B738DR_cabin_alt_annun = cabin_alt_warn * brightness_level

-- EMER EXIT NOT ARMED ANNUN

	local emer_exit_not_armed = 0
		if B738DR_emer_exit_lights_switch == 0 then
		emer_exit_not_armed = 1
		elseif B738DR_emer_exit_lights_switch == 2 then
		emer_exit_not_armed = 1
		end
	
	B738DR_emer_exit_annun = emer_exit_not_armed * brightness_level

-- FUEL CROSSFEED ANNUN

	local tank_select_status = 0
		if simDR_tank_selection == 4 then
		tank_select_status = 1
		end

	B738DR_crossfeed = tank_select_status * brightness_level

-- GENERIC ANNUNCIATOR ---- FOR THOSE THAT WONT BE CODED

	B738DR_generic_annun = brightness_level * B738DR_lights_test


-- ELT

	local elt_annun = 0
		if B738DR_elt_switch_pos == 1 then
		elt_annun = 1
		end
		
		if simDR_axial_g_load > 2.5 then
		B738CMD_elt_pos_on:once()
		end
		
	B738DR_elt_annun = elt_annun


-- EXTERNAL POWER

	local ext_power_annun = 0
		if simDR_aircraft_on_ground == 1
		and simDR_aircraft_groundspeed < 0.05 then
		ext_power_annun = 1
		end
		
		B738DR_ground_power_avail_annun = ext_power_annun
		

-- TRANSFER BUS ANNUN

	local trans_bus1 = 0
		if simDR_bus_amps1 < 0.3 then
		trans_bus1 = 1
		end
		
	local trans_bus2 = 0
		if simDR_bus_amps2 < 0.3 then
		trans_bus2 = 1
		end
		
	B738DR_transfer_bus_off1 = trans_bus1 * brightness_level
	B738DR_transfer_bus_off2 = trans_bus2 * brightness_level


-- APU GEN OFF BUS

	local apu_gen_off_bus = 0
		if simDR_apu_status > 95 then
		apu_gen_off_bus = 1
		end
		
		if simDR_apu_gen_amps > 0 then
		apu_gen_off_bus = 0
		end


	B738DR_apu_gen_off_bus = apu_gen_off_bus * brightness_level

-- GENS OFF BUS

	B738DR_gen_off_bus1 = simDR_gen_off_bus1 * simDR_engine1_on * brightness_level
	B738DR_gen_off_bus2 = simDR_gen_off_bus2 * simDR_engine2_on * brightness_level

-- SOURCE OFF


	local apu_genL_off = 0
		if B738DR_apu_genL_status == 0 then
			apu_genL_off = 1
		elseif B738DR_apu_genL_status == 1 and
			simDR_apu_gen_amps < 1 then
			apu_genL_off = 1
		end

	local apu_genR_off = 0
		if B738DR_apu_genR_status == 0 then
			apu_genR_off = 1
		elseif B738DR_apu_genR_status == 1 and
			simDR_apu_gen_amps < 1 then
			apu_genR_off = 1
		end
		
	local gpu_off = 0
		if simDR_gpu_amps < 1 then
		gpu_off = 1
		end
	

	B738DR_source_off_bus1 = apu_genL_off * simDR_gen_off_bus1 * gpu_off * brightness_level
	B738DR_source_off_bus2 = apu_genR_off * simDR_gen_off_bus2 * gpu_off * brightness_level
	

-- SMOKE

	local smoke_status = 0
		if simDR_smoke >= 1 then
		smoke_status = 1
		end
		
	B738DR_smoke = smoke_status * brightness_level


-- PACKS

	local pack_status = 0
		if simDR_pack_annun == 6 then
		pack_status = 1
		end
		
	B738DR_packs_annun = pack_status * brightness_level


-- HYD PRESSURE

	local hyd_press_a = 0
		if simDR_hyd_press_a < 1300 then
		hyd_press_a = 1
		end
		
	local hyd_press_b = 0
		if simDR_hyd_press_b < 1300 then
		hyd_press_b = 1
		end

	B738DR_hyd_press_a = hyd_press_a * brightness_level		
	B738DR_hyd_press_b = hyd_press_b * brightness_level


-- BYPASS FILTER ANNUN

	local bypass_1 = 0
		if simDR_bypass_filter_1 == 6 then
		bypass_1 = 1
		end
		
	local bypass_2 = 0
		if simDR_bypass_filter_2 == 6 then
		bypass_2 = 1
		end	

	B738DR_bypass_filter_1 = bypass_1 * brightness_level
	B738DR_bypass_filter_2 = bypass_2 * brightness_level


-- FADEC OFF

	local fadec1_status = 0
		if simDR_fadec1 == 0 then
		fadec1_status = 1
		end
		
	B738DR_fadec1_off = fadec1_status * brightness_level
	
	local fadec2_status = 0
		if simDR_fadec2 == 0 then
		fadec2_status = 1
		end
		
	B738DR_fadec2_off = fadec2_status * brightness_level

-- STANDBY BATT ANNUN

	local standby_bat_status = 0
		if simDR_battery2_status == 0 then
		standby_bat_status = 1
		end
		
	B738DR_standby_pwr_off = standby_bat_status * brightness_level	

 
-- IDG FAIL

	local drive1_status = 0
		if simDR_generator1_fail == 6 then
		drive1_status = 1
		end
		
	local drive2_status = 0
		if simDR_generator2_fail == 6 then
		drive2_status = 1
		end

	B738DR_drive1_annun	= drive1_status * brightness_level
	B738DR_drive2_annun	= drive2_status * brightness_level
		
		
-- ANTI ICE

	local capt_pitot_status = 1
		if simDR_pitot_capt == 1 then
		capt_pitot_status = 0
		end

	B738DR_capt_pitot_off = capt_pitot_status * brightness_level	

	local fo_pitot_status = 1
		if simDR_pitot_fo == 1 then
		fo_pitot_status = 0
		end

	B738DR_fo_pitot_off = fo_pitot_status * brightness_level

	local capt_aoa_status = 1
		if simDR_aoa_capt == 1 then
		capt_aoa_status = 0
		end

	B738DR_capt_aoa_off = capt_aoa_status * brightness_level

	local fo_aoa_status = 1
		if simDR_aoa_fo == 1 then
		fo_aoa_status = 0
		end

	B738DR_fo_aoa_off = fo_aoa_status * brightness_level
	
	local cowl_ice_0 = 0
		if simDR_cowl_ice_detect_0 > 0.005 then
		cowl_ice_0 = 1
		end
	local cowl_ice_1 = 0
		if simDR_cowl_ice_detect_1 > 0.005 then
		cowl_ice_1 = 1
		end
	local cowl_ice_status_0 = 0.5
		if simDR_cowl_ice_detect_0 > 0 then
		cowl_ice_status_0 = 1
		end
	local cowl_ice_status_1 = 0.5
		if simDR_cowl_ice_detect_1 > 0 then
		cowl_ice_status_1 = 1
		end
	local wing_ice_status_L = 0.5
		if simDR_wing_ice_detect_L > 0 then
		wing_ice_status_L = 1
		end
	local wing_ice_status_R = 0.5
		if simDR_wing_ice_detect_R > 0 then
		wing_ice_status_R = 1
		end

		
	B738DR_cowl_ice_0 = cowl_ice_0 * brightness_level
	B738DR_cowl_ice_1 = cowl_ice_1 * brightness_level
	
	B738DR_cowl_ice_0_on = simDR_cowl_ice_0_on * brightness_level * cowl_ice_status_0
	B738DR_cowl_ice_1_on = simDR_cowl_ice_1_on * brightness_level * cowl_ice_status_1
	
	B738DR_wing_ice_on_L = simDR_wing_ice_on * brightness_level * wing_ice_status_L
	B738DR_wing_ice_on_R = simDR_wing_ice_on * brightness_level * wing_ice_status_R

	local window_heat_fail = 0
		if simDR_window_heat_fail == 6 then
		window_heat_fail = 1
		end
			
	B738DR_window_heat_fail = window_heat_fail * brightness_level



-- GEAR LIGHT ANNUNCIATORS

	local nose_gear_safe_status = 0
	 	if simDR_nose_gear_status == 1 then
	 	nose_gear_safe_status = 1
	 end
	 
	local left_gear_safe_status = 0
	 	if simDR_left_gear_status == 1 then
	 	left_gear_safe_status = 1
	 end
	 
	local right_gear_safe_status = 0
	 	if simDR_right_gear_status == 1 then
	 	right_gear_safe_status = 1
	 end	

	local nose_gear_fail = 1
		if simDR_nose_gear_fail == 6 then
		nose_gear_fail = 0
	end
	
	local left_gear_fail = 1
		if simDR_left_gear_fail == 6 then
		left_gear_fail = 0
	end
	
	local right_gear_fail = 1
		if simDR_right_gear_fail == 6 then
		right_gear_fail = 0
	end
	
	B738DR_nose_gear_safe_annun = nose_gear_safe_status * brightness_level * nose_gear_fail
	B738DR_left_gear_safe_annun = left_gear_safe_status * brightness_level * left_gear_fail
	B738DR_right_gear_safe_annun = right_gear_safe_status * brightness_level * right_gear_fail


-- NOSE GEAR TRANSIT ANNUNCIATIOR

	local nose_gear_transit = 0
		if simDR_nose_gear_status > 0 then
		nose_gear_transit = 1
		end
		if simDR_nose_gear_fail == 6 then
		nose_gear_down = 1
	end
	
	local nose_gear_down = 1
		if simDR_nose_gear_status == 1 then
		nose_gear_down = 0
		end
		if simDR_nose_gear_fail == 6 then
		nose_gear_down = 1
	end

	B738DR_nose_gear_transit_annun = nose_gear_transit * nose_gear_down * brightness_level
	
-- LEFT GEAR TRANSIT ANNUNCIATIOR

	local left_gear_transit = 0
		if simDR_left_gear_status > 0 then
		left_gear_transit = 1
		end
		if simDR_left_gear_fail == 6 then
		left_gear_down = 1
	end
	
	local left_gear_down = 1
		if simDR_left_gear_status == 1 then
		left_gear_down = 0
		end
		if simDR_left_gear_fail == 6 then
		left_gear_down = 1
	end

	B738DR_left_gear_transit_annun = left_gear_transit * left_gear_down * brightness_level
	
-- RIGHT GEAR TRANSIT ANNUNCIATIOR

	local right_gear_transit = 0
		if simDR_right_gear_status > 0 then
		right_gear_transit = 1
		end
		if simDR_right_gear_fail == 6 then
		right_gear_down = 1
	end
	
	local right_gear_down = 1
		if simDR_right_gear_status == 1 then
		right_gear_down = 0
		end
		if simDR_right_gear_fail == 6 then
		right_gear_down = 1
	end
	
	B738DR_right_gear_transit_annun = right_gear_transit * right_gear_down * brightness_level
	
	
-- LOW FUEL PRESSURE ANNUNCIATORS TANK L

	local fuel_press_low_left1 = 0
		if simDR_fuel_tank_l_on == 1 then
			if simDR_fuel_quantity_l < 200 then
			fuel_press_low_left1 = 1
		end
	end

	B738DR_low_fuel_press_l1_annun = fuel_press_low_left1 * brightness_level



	local fuel_press_low_left2 = 0
		if simDR_fuel_tank_l_on == 1 then
			if simDR_fuel_quantity_l < 175 then
			fuel_press_low_left2 = 1
		end
	end

	B738DR_low_fuel_press_l2_annun = fuel_press_low_left2 * brightness_level


-- LOW FUEL PRESSURE ANNUNCIATORS TANK C

	local fuel_press_low_center1 = 0
		if simDR_fuel_tank_c_on == 1 then
			if simDR_fuel_quantity_c < 625 then
			fuel_press_low_center1 = 1
		end
	end

	B738DR_low_fuel_press_c1_annun = fuel_press_low_center1 * brightness_level
	


	local fuel_press_low_center2 = 0
		if simDR_fuel_tank_c_on == 1 then
			if simDR_fuel_quantity_c < 640 then
			fuel_press_low_center2 = 1
		end
	end

	B738DR_low_fuel_press_c2_annun = fuel_press_low_center2 * brightness_level

-- LOW FUEL PRESSURE ANNUNCIATORS TANK R

	local fuel_press_low_right1 = 0
		if simDR_fuel_tank_r_on == 1 then
			if simDR_fuel_quantity_r < 190 then
			fuel_press_low_right1 = 1
		end
	end

	B738DR_low_fuel_press_r1_annun = fuel_press_low_right1 * brightness_level
	
	local fuel_press_low_right2 = 0
		if simDR_fuel_tank_r_on == 1 then
			if simDR_fuel_quantity_r < 160 then
			fuel_press_low_right2 = 1
		end
	end

	B738DR_low_fuel_press_r2_annun = fuel_press_low_right2 * brightness_level	

--ENG VALVE ANNUNS

	local eng_valve_1_status = 0.5
		if B738DR_condition_lever1 > 0 then
		eng_valve_1_status = 1
		end
		if B738DR_condition_lever1 >= 0.95 then
		eng_valve_1_status = 0
	end

	B738DR_eng1_valve_closed_annun = eng_valve_1_status * brightness_level
	
	local eng_valve_2_status = 0.5
		if B738DR_condition_lever2 > 0 then
		eng_valve_2_status = 1
		end
		if B738DR_condition_lever2 >= 0.95 then
		eng_valve_2_status = 0
	end

	B738DR_eng2_valve_closed_annun = eng_valve_2_status * brightness_level

-- TEST

	if B738DR_lights_test == 1 then
		B738DR_parking_brake_annun			= 1 * brightness_level2
		B738DR_window_heat_annun			= 1 * brightness_level
		B738DR_fadec_fail_annun_0			= 1 * brightness_level
		B738DR_fadec_fail_annun_1			= 1 * brightness_level
		B738DR_reverser_fail_annun_0		= 1 * brightness_level
		B738DR_reverser_fail_annun_1		= 1 * brightness_level
		B738DR_capt_pitot_off				= 1 * brightness_level
		B738DR_fo_pitot_off					= 1 * brightness_level
		B738DR_capt_aoa_off					= 1 * brightness_level
		B738DR_fo_aoa_off					= 1 * brightness_level
		B738DR_window_heat_fail				= 1 * brightness_level
		B738DR_cowl_ice_0					= 1 * brightness_level
		B738DR_cowl_ice_1					= 1 * brightness_level
		B738DR_cowl_ice_0_on				= 1 * brightness_level
		B738DR_cowl_ice_1_on				= 1 * brightness_level
		B738DR_wing_ice_on_L				= 1 * brightness_level
		B738DR_wing_ice_on_R				= 1 * brightness_level
		B738DR_apu_fault_annun				= 1 * brightness_level
		B738DR_nose_gear_transit_annun		= 1 * brightness_level
		B738DR_nose_gear_safe_annun			= 1 * brightness_level
		B738DR_left_gear_transit_annun		= 1 * brightness_level
		B738DR_left_gear_safe_annun			= 1 * brightness_level
		B738DR_right_gear_transit_annun		= 1 * brightness_level
		B738DR_right_gear_safe_annun		= 1 * brightness_level
		B738DR_low_fuel_press_l1_annun		= 1 * brightness_level		
		B738DR_low_fuel_press_l2_annun		= 1 * brightness_level
		B738DR_low_fuel_press_c1_annun		= 1 * brightness_level
		B738DR_low_fuel_press_c2_annun		= 1 * brightness_level
		B738DR_low_fuel_press_r1_annun		= 1 * brightness_level
		B738DR_low_fuel_press_r2_annun		= 1 * brightness_level
		B738DR_eng1_valve_closed_annun		= 1 * brightness_level
		B738DR_eng2_valve_closed_annun		= 1 * brightness_level
		B738DR_fadec1_off					= 1 * brightness_level
		B738DR_fadec2_off					= 1 * brightness_level
		B738DR_drive1_annun					= 1 * brightness_level
		B738DR_drive2_annun					= 1 * brightness_level
		B738DR_standby_pwr_off				= 1 * brightness_level
		B738DR_bypass_filter_1				= 1 * brightness_level
		B738DR_bypass_filter_2				= 1 * brightness_level
		B738DR_hyd_press_a					= 1 * brightness_level
		B738DR_hyd_press_b					= 1 * brightness_level
		B738DR_packs_annun					= 1 * brightness_level
		B738DR_smoke						= 1 * brightness_level
		B738DR_apu_gen_off_bus				= 1 * brightness_level
		B738DR_gen_off_bus1					= 1 * brightness_level
		B738DR_gen_off_bus2					= 1 * brightness_level
		B738DR_source_off_bus1				= 1 * brightness_level
		B738DR_source_off_bus2				= 1 * brightness_level
		B738DR_transfer_bus_off1			= 1 * brightness_level
		B738DR_transfer_bus_off2			= 1 * brightness_level
		B738DR_fwd_entry					= 1 * brightness_level
		B738DR_left_fwd_overwing			= 1 * brightness_level
		B738DR_left_aft_overwing			= 1 * brightness_level
		B738DR_aft_entry					= 1 * brightness_level
		B738DR_fwd_service					= 1 * brightness_level
		B738DR_right_fwd_overwing			= 1 * brightness_level
		B738DR_right_aft_overwing			= 1 * brightness_level
		B738DR_aft_service					= 1 * brightness_level
		B738DR_fwd_cargo					= 1 * brightness_level
		B738DR_aft_cargo					= 1 * brightness_level
		B738DR_equip_door					= 1 * brightness_level
		B738DR_pax_oxy						= 1 * brightness_level
		B738DR_bleed_trip_off1				= 1 * brightness_level
		B738DR_bleed_trip_off2				= 1 * brightness_level
		B738DR_wing_body_ovht				= 1 * brightness_level
		B738DR_ground_power_avail_annun		= 1 * brightness_level
		B738DR_elt_annun 					= 1 * brightness_level
		B738DR_fdr_off 						= 1 * brightness_level
		B738DR_yaw_damper 					= 1 * brightness_level
		B738DR_crossfeed					= 1 * brightness_level
		B738DR_emer_exit_annun				= 1 * brightness_level
		B738DR_cabin_alt_annun				= 1 * brightness_level
		B738DR_speedbrake_armed				= 1 * brightness_level
		B738DR_speedbrake_extend			= 1 * brightness_level
		B738DR_battery_disch_annun			= 1 * brightness_level
		B738DR_GPWS_annun					= 1 * brightness_level
		B738DR_takeoff_config_annun			= 1 * brightness_level		
		B738DR_below_gs						= 1 * brightness_level
		B738DR_slats_extended				= 1 * brightness_level
		B738DR_slats_transit				= 1 * brightness_level
		B738DR_extinguisher_circuit_annun1	= 1 * brightness_level
		B738DR_extinguisher_circuit_annun2	= 1 * brightness_level
		B738DR_cargo_fire_annuns			= 1 * brightness_level
		B738DR_fire_fault_inop_annun		= 1 * brightness_level		
		B738DR_engine1_ovht					= 1 * brightness_level
		B738DR_engine2_ovht					= 1 * brightness_level
		B738DR_wheel_well_fire				= 1 * brightness_level
		B738DR_l_bottle_discharge			= 1 * brightness_level
		B738DR_r_bottle_discharge			= 1 * brightness_level

-- SIX PACK

		B738DR_six_pack_fuel				= 1 * brightness_level
		B738DR_six_pack_fire				= 1 * brightness_level
		B738DR_six_pack_apu					= 1 * brightness_level
		B738DR_six_pack_flt_cont			= 1 * brightness_level
		B738DR_six_pack_elec				= 1 * brightness_level
		B738DR_six_pack_irs					= 1 * brightness_level

		B738DR_six_pack_ice					= 1 * brightness_level
		B738DR_six_pack_doors				= 1 * brightness_level
		B738DR_six_pack_eng					= 1 * brightness_level
		B738DR_six_pack_hyd					= 1 * brightness_level
		B738DR_six_pack_air_cond			= 1 * brightness_level
		B738DR_six_pack_overhead			= 1 * brightness_level

	end
end

----- INITIALIZE LIGHTING ---------------------------------------------------------------
function B738_init_lighting()

    --[[   SPILL LIGHTS   
    
    NOTE: FOR SPILL LIGHTS...
    THE ORDER OF ARRAY DATA FOR THE OBJ FILE IS DIFFERENT THAN WHAT WE NEED TO USE TO SET THE DATAREF IN CODE.

    OBJ IS AS FOLLOWS:
    X	Y	Z	R	G	B	A	SIZE	Dx	Dy	Dz	SEMI	DATAREF

    SET DATAREF WITH CODE AS FOLLOWS:
    X	Y	Z	R	G	B	A	SIZE	SEMI	Dx	Dy	Dz
    
    --]]
 
 	local extinguisher_circuit_spill2 = {0.19, 1, 0.5, 0.0, 0.07, 1, 0, 0, 0} 
	local extinguisher_circuit_spill1 = {0.19, 1, 0.5, 0.0, 0.07, 1, 0, 0, 0}  
	local parking_brake_spill = {1.0, 0, 0, 0.0, 0.15, 1, 0, 0, 0}    
    
    
    for i = 0, 8 do
		B738DR_parking_brake_spill[i] = parking_brake_spill[i+1]
		B738DR_extinguisher_circuit_spill1[i] = extinguisher_circuit_spill1[i+1]
		B738DR_extinguisher_circuit_spill2[i] = extinguisher_circuit_spill2[i+1]
	end	
    
end    


----- SPILL LIGHTS ----------------------------------------------------------------------
function B738_spill_lights()
	
	B738DR_parking_brake_spill[3] = B738DR_parking_brake_annun
	B738DR_extinguisher_circuit_spill1[3] = B738DR_extinguisher_circuit_annun1
	B738DR_extinguisher_circuit_spill2[3] = B738DR_extinguisher_circuit_annun2
	
end




----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function B738_annun_monitor_AI()

    if B738DR_init_annun_CD == 1 then
        B738_set_annun_all_modes()
        B738_set_annun_CD()
        B738DR_init_annun_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function B738_set_annun_all_modes()
	
	B738DR_init_annun_CD = 0

	simDR_generic_brightness_switch63 = 1
	simDR_generic_brightness_switch62 = 1
	B738DR_elt_switch_pos = 0
	B738DR_emer_exit_lights_switch = 1
	B738DR_audio_panel_capt_mic1_pos = 1
	B738DR_audio_panel_fo_mic3_pos = 1
	B738DR_audio_panel_obs_mic6_pos = 1


end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function B738_set_annun_CD()

		
end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------

function B738_set_annun_ER()


end


----- FLIGHT START ---------------------------------------------------------------------

function B738_flight_start_annun()

    -- ALL MODES ------------------------------------------------------------------------
    B738_set_annun_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B738_set_annun_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B738_set_annun_ER()

    end

end


--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

function aircraft_load()

B738_init_lighting()

end


--function aircraft_unload() end

function flight_start()

	B738_flight_start_annun()

end

--function flight_crash() end

--function before_physics() end

function after_physics()

	B738_annunciators()
	B738_spill_lights()
	B738_external_power()
	B738_battery_disch_annun()
	B738_annun_monitor_AI()

end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



