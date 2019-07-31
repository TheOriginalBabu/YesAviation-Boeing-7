--[[
*****************************************************************************************
* Program Script Name	:	B738.glaresheild
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
*        COPYRIGHT � 2017 ALEX URNUH / LAMINAR RESEARCH - ALL RIGHTS RESERVED
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
--** 			 		            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local AP_status = 0				-- 0 = off, 1 = mode any, 2 = FD any, 3 = CMD any
local AP_engagement_status = 0	-- 0 = cannot engage, 1 = can engage

local CMD_status = 0
local CWS_status = 0

local ap_disconnect = 0


--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_barometer_setting_capt 	= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot")
simDR_barometer_setting_fo		= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot")

simDR_decision_height_capt		= find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_pilot")
simDR_decision_height_fo		= find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_copilot")

simDR_map_mode_is_HSI			= find_dataref("sim/cockpit2/EFIS/map_mode_is_HSI")

simDR_vor1_capt					= find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_pilot")
simDR_vor2_capt					= find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_pilot")
simDR_vor1_fo					= find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_copilot")
simDR_vor2_fo					= find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_copilot")

simDR_efis_ndb					= find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on")

----- GPS RADIO STATUS

simDR_gps1_bearing				= find_dataref("sim/cockpit2/radios/indicators/gps_bearing_deg_mag")
simDR_gps1_dme_distance			= find_dataref("sim/cockpit2/radios/indicators/gps_dme_distance_nm")
simDR_gps1_dme_speed			= find_dataref("sim/cockpit2/radios/indicators/gps_dme_speed_kts")
simDR_gps1_dme_time				= find_dataref("sim/cockpit2/radios/indicators/gps_dme_time_min")

simDR_gps2_bearing				= find_dataref("sim/cockpit2/radios/indicators/gps2_bearing_deg_mag")
simDR_gps2_dme_distance			= find_dataref("sim/cockpit2/radios/indicators/gps2_dme_distance_nm")
simDR_gps2_dme_speed			= find_dataref("sim/cockpit2/radios/indicators/gps2_dme_speed_kts")
simDR_gps2_dme_time				= find_dataref("sim/cockpit2/radios/indicators/gps2_dme_time_min")

----- AUTOPILOT DATAREFS

simDR_autothrottle_status		= find_dataref("sim/cockpit2/autopilot/autothrottle_on")
simDR_autothrottle_mode			= find_dataref("sim/cockpit2/autopilot/autothrottle_enabled") -- 0 = arm, 1 = airspeed hold, 2 = N1 Target hold
simDR_autopilot_altitude_mode	= find_dataref("sim/cockpit2/autopilot/altitude_mode")
simDR_autopilot_heading_mode	= find_dataref("sim/cockpit2/autopilot/heading_mode")
simDR_bank_angle				= find_dataref("sim/cockpit2/autopilot/bank_angle_mode")

simDR_servos_A_on				= find_dataref("sim/cockpit2/autopilot/servos_on")
simDR_servos_B_on				= find_dataref("sim/cockpit2/autopilot/servos2_on")
simDR_ap_on_A					= find_dataref("sim/cockpit2/autopilot/autopilot_on_or_cws")
simDR_ap_on_B					= find_dataref("sim/cockpit2/autopilot/autopilot2_on_or_cws")
simDR_flight_dir_mode_capt		= find_dataref("sim/cockpit2/autopilot/flight_director_mode")
simDR_flight_dir_mode_fo		= find_dataref("sim/cockpit2/autopilot/flight_director2_mode")
simDR_master_flight_dir			= find_dataref("sim/cockpit2/autopilot/master_flight_director") -- 0 = capt, 1 = fo, 2 = both (for dual channel)...needs to be set

simDR_approach_status			= find_dataref("sim/cockpit2/autopilot/approach_status")
simDR_glideslope_status			= find_dataref("sim/cockpit2/autopilot/glideslope_status")
simDR_alt_hold_status			= find_dataref("sim/cockpit2/autopilot/altitude_hold_status")

-- CWS

simDR_pitch_status				= find_dataref("sim/cockpit2/autopilot/pitch_status")
simDR_roll_status				= find_dataref("sim/cockpit2/autopilot/roll_status")

simDR_autopilot_source			= find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_pilot")
simDR_autopilot_fo_source		= find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_copilot")

simDR_vorloc_status				= find_dataref("sim/cockpit2/autopilot/nav_status")
simDR_lnav_status				= find_dataref("sim/cockpit2/autopilot/gpss_status")
simDR_vnav_status				= find_dataref("sim/cockpit2/autopilot/fms_vnav")
simDR_autopilot_on				= find_dataref("sim/cockpit2/autopilot/autopilot_on")
simDR_gps_GS_status				= find_dataref("sim/cockpit/radios/gps_has_glideslope")

simDR_ap_capt_heading			= find_dataref("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot")
simDR_ap_fo_heading				= find_dataref("sim/cockpit2/autopilot/heading_dial_deg_mag_copilot")

simDR_airspeed_dial				= find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts_mach")

simDR_ap_disconnect_status		= find_dataref("sim/cockpit2/annunciators/autopilot_disconnect")

simDR_EFIS_mode					= find_dataref("sim/cockpit2/EFIS/map_mode")
simDR_EFIS_WX					= find_dataref("sim/cockpit2/EFIS/EFIS_weather_on")
simDR_EFIS_TCAS					= find_dataref("sim/cockpit2/EFIS/EFIS_tcas_on")

simDR_engine1_n1_limit			= find_dataref("sim/cockpit2/engine/actuators/N1_target_bug[0]")
simDR_engine2_n1_limit			= find_dataref("sim/cockpit2/engine/actuators/N1_target_bug[1]")

simDR_acf_has_fd				= find_dataref("sim/aircraft/overflow/acf_has_DC_fd")

simDR_eng1_reverse				= find_dataref("sim/cockpit2/engine/actuators/prop_mode[0]")
simDR_eng2_reverse				= find_dataref("sim/cockpit2/engine/actuators/prop_mode[1]")

simDR_toga_set					= find_dataref("sim/cockpit2/autopilot/TOGA_pitch_deg")
simDR_airspeed					= find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")

simDR_bus1_power				= find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_bus2_power				= find_dataref("sim/cockpit2/electrical/bus_volts[1]")
simDR_autopilot_comp_fail		= find_dataref("sim/operation/failures/rel_otto")

--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_efis_wxr = find_command("sim/instruments/EFIS_wxr")
simCMD_efis_sta = find_command("sim/instruments/EFIS_vor")
simCMD_efis_wpt = find_command("sim/instruments/EFIS_fix")
simCMD_efis_arpt = find_command("sim/instruments/EFIS_apt")
simCMD_efis_tfc = find_command("sim/instruments/EFIS_tcas")


---- AUTOPILOT COMMANDS

simCMD_autothrottle			= find_command("sim/autopilot/autothrottle_toggle")
simCMD_autopilot_vnav		= find_command("sim/autopilot/FMS")
simCMD_autopilot_lvl_chg	= find_command("sim/autopilot/level_change")
simCMD_autopilot_hdg		= find_command("sim/autopilot/heading")
simCMD_autopilot_vorloc		= find_command("sim/autopilot/NAV")						-- VOR/LOC
simCMD_autopilot_lnav		= find_command("sim/autopilot/gpss")					-- LNAV
simCMD_autopilot_app		= find_command("sim/autopilot/approach")
simCMD_autopilot_alt_hold	= find_command("sim/autopilot/altitude_hold")
simCMD_autopilot_vs			= find_command("sim/autopilot/vertical_speed")
simCMD_autopilot_speed		= find_command("sim/autopilot/autothrottle_toggle")
simCMD_autopilot_n1			= find_command("sim/autopilot/autothrottle_n1epr_toggle")

simCMD_autopilot_co			= find_command("sim/autopilot/knots_mach_toggle")
simCMD_autothrottle_discon	= find_command("sim/autopilot/autothrottle_off")

simCMD_servos_on_a			= find_command("sim/autopilot/servos_on")
simCMD_flight_director_a	= find_command("sim/autopilot/fdir_toggle")
simCMD_flight_director_a_on	= find_command("sim/autopilot/fdir_on")
simCMD_autopilot_cws_a		= find_command("sim/autopilot/CWSA")
simCMD_servos_off_a			= find_command("sim/autopilot/fdir_servos_down_one")
simCMD_servos_fdir_off_a	= find_command("sim/autopilot/servos_fdir_off")

simCMD_servos_on_b			= find_command("sim/autopilot/servos2_on")
simCMD_flight_director_b	= find_command("sim/autopilot/fdir2_toggle")
simCMD_flight_director_b_on	= find_command("sim/autopilot/fdir2_on")
simCMD_autopilot_cws_b		= find_command("sim/autopilot/CWSB")
simCMD_servos_off_b			= find_command("sim/autopilot/fdir2_servos_down_one")
simCMD_servos_fdir_off_b	= find_command("sim/autopilot/servos_fdir2_off")

simCMD_ap_disconnect		= find_command("sim/autopilot/servos_off_any")

simCMD_toga					= find_command("sim/autopilot/take_off_go_around")
simCMD_toga_engine			= find_command("sim/engines/TOGA_power")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

-- CAPT EFIS DATAREFS

B738DR_efis_wxr_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/wxr", "number")
B738DR_efis_sta_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/sta", "number")
B738DR_efis_wpt_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/wpt", "number")
B738DR_efis_arpt_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/arpt", "number")
B738DR_efis_data_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/data", "number")
B738DR_efis_pos_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/pos", "number")
B738DR_efis_terr_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/terr", "number")

B738DR_efis_rst_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/rst", "number")
B738DR_efis_ctr_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/ctr", "number")
B738DR_efis_tfc_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/tfc", "number")
B738DR_efis_std_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/std", "number")

B738DR_efis_mtrs_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/mtrs", "number")
B738DR_efis_fpv_capt	= create_dataref("laminar/B738/EFIS_control/capt/push_button/fpv", "number")

B738DR_efis_baro_mode_capt	= create_dataref("laminar/B738/EFIS_control/capt/baro_in_hpa", "number")
B738DR_efis_vor1_capt_pos	= create_dataref("laminar/B738/EFIS_control/capt/vor1_off_pos", "number")
B738DR_efis_vor2_capt_pos	= create_dataref("laminar/B738/EFIS_control/capt/vor2_off_pos", "number")

B738DR_capt_alt_mode_meters		= create_dataref("laminar/B738/PFD/capt/alt_mode_is_meters", "number")
B738DR_capt_fpv_on				= create_dataref("laminar/B738/PFD/capt/fpv_on", "number")

-- FO EFIS DATAREFS

B738DR_efis_wxr_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/wxr", "number")
B738DR_efis_sta_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/sta", "number")
B738DR_efis_wpt_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/wpt", "number")
B738DR_efis_arpt_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/arpt", "number")
B738DR_efis_data_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/data", "number")
B738DR_efis_pos_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/pos", "number")
B738DR_efis_terr_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/terr", "number")

B738DR_efis_rst_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/rst", "number")
B738DR_efis_ctr_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/ctr", "number")
B738DR_efis_tfc_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/tfc", "number")
B738DR_efis_std_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/std", "number")

B738DR_efis_mtrs_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/mtrs", "number")
B738DR_efis_fpv_fo	= create_dataref("laminar/B738/EFIS_control/fo/push_button/fpv", "number")

B738DR_efis_baro_mode_fo	= create_dataref("laminar/B738/EFIS_control/fo/baro_in_hpa", "number")
B738DR_efis_vor1_fo_pos		= create_dataref("laminar/B738/EFIS_control/fo/vor1_off_pos", "number")
B738DR_efis_vor2_fo_pos		= create_dataref("laminar/B738/EFIS_control/fo/vor2_off_pos", "number")

B738DR_fo_alt_mode_meters		= create_dataref("laminar/B738/PFD/fo/alt_mode_is_meters", "number")
B738DR_fo_fpv_on				= create_dataref("laminar/B738/PFD/fo/fpv_on", "number")


-- N1 LIMIT KNOBS

B738DR_n1_set_mode_pos				= create_dataref("laminar/B738/knobs/n1_set_mode_pos", "number")
B738DR_n1_set_pos					= create_dataref("laminar/B738/knobs/n1_set_pos", "number")
B738DR_n1_lim_display_EICAS1		= create_dataref("laminar/B738/EICAS/disp/n1_limit_eng1", "number")
B738DR_n1_lim_display_EICAS2		= create_dataref("laminar/B738/EICAS/disp/n1_limit_eng2", "number")


-- AP BUTTON / SWITCH POSITION DRS

B738DR_autopilot_n1_pos				= create_dataref("laminar/B738/autopilot/n1_pos", "number")
B738DR_autopilot_speed_pos			= create_dataref("laminar/B738/autopilot/speed_pos", "number")
B738DR_autopilot_lvl_chg_pos		= create_dataref("laminar/B738/autopilot/lvl_chg_pos", "number")
B738DR_autopilot_vnav_pos			= create_dataref("laminar/B738/autopilot/vnav_pos", "number")
B738DR_autopilot_co_pos				= create_dataref("laminar/B738/autopilot/change_over_pos", "number")

B738DR_autopilot_lnav_pos			= create_dataref("laminar/B738/autopilot/lnav_pos", "number")
B738DR_autopilot_vorloc_pos			= create_dataref("laminar/B738/autopilot/vorloc_pos", "number")
B738DR_autopilot_app_pos			= create_dataref("laminar/B738/autopilot/app_pos", "number")
B738DR_autopilot_hdg_sel_pos		= create_dataref("laminar/B738/autopilot/hdg_sel_pos", "number")

B738DR_autopilot_alt_hld_pos		= create_dataref("laminar/B738/autopilot/alt_hld_pos", "number")
B738DR_autopilot_vs_pos				= create_dataref("laminar/B738/autopilot/vs_pos", "number")

B738DR_autopilot_cmd_a_pos			= create_dataref("laminar/B738/autopilot/cmd_a_pos", "number")
B738DR_autopilot_cmd_b_pos			= create_dataref("laminar/B738/autopilot/cmd_b_pos", "number")
B738DR_autopilot_cws_a_pos			= create_dataref("laminar/B738/autopilot/cws_a_pos", "number")
B738DR_autopilot_cws_b_pos			= create_dataref("laminar/B738/autopilot/cws_b_pos", "number")
B738DR_autopilot_disconnect_pos		= create_dataref("laminar/B738/autopilot/disconnect_pos", "number")

B738DR_autopilot_fd_pos				= create_dataref("laminar/B738/autopilot/flight_director_pos", "number")
B738DR_autopilot_fd_fo_pos			= create_dataref("laminar/B738/autopilot/flight_director_fo_pos", "number")
B738DR_autopilot_bank_angle_pos		= create_dataref("laminar/B738/autopilot/bank_angle_pos", "number")

B738DR_autopilot_autothr_arm_pos	= create_dataref("laminar/B738/autopilot/autothrottle_arm_pos", "number")

B738DR_autothro_capt_discon			= create_dataref("laminar/B738/autopilot/capt_autothro_discon_pos", "number")
B738DR_autothro_fo_discon			= create_dataref("laminar/B738/autopilot/fo_autothro_discon_pos", "number")

B738DR_autopilot_capt_thro_toga		= create_dataref("laminar/B738/autopilot/capt_thro_toga_pos", "number")
B738DR_autopilot_fo_thro_toga		= create_dataref("laminar/B738/autopilot/fo_thro_toga_pos", "number")


-- AP STATUS LIGHT DRS

B738DR_autopilot_n1_status				= create_dataref("laminar/B738/autopilot/n1_status", "number")
B738DR_autopilot_speed_status			= create_dataref("laminar/B738/autopilot/speed_status1", "number")
B738DR_autopilot_lvl_chg_status			= create_dataref("laminar/B738/autopilot/lvl_chg_status", "number")
B738DR_autopilot_vnav_status			= create_dataref("laminar/B738/autopilot/vnav_status1", "number")
	
B738DR_autopilot_lnav_status			= create_dataref("laminar/B738/autopilot/lnav_status", "number")
B738DR_autopilot_vorloc_status			= create_dataref("laminar/B738/autopilot/vorloc_status", "number")
B738DR_autopilot_app_status				= create_dataref("laminar/B738/autopilot/app_status", "number")
B738DR_autopilot_hdg_sel_status			= create_dataref("laminar/B738/autopilot/hdg_sel_status", "number")

B738DR_autopilot_alt_hld_status			= create_dataref("laminar/B738/autopilot/alt_hld_status", "number")
B738DR_autopilot_vs_status				= create_dataref("laminar/B738/autopilot/vs_status", "number")

B738DR_autopilot_cmd_a_status			= create_dataref("laminar/B738/autopilot/cmd_a_status", "number")
B738DR_autopilot_cmd_b_status			= create_dataref("laminar/B738/autopilot/cmd_b_status", "number")
B738DR_autopilot_cws_a_status			= create_dataref("laminar/B738/autopilot/cws_a_status", "number")
B738DR_autopilot_cws_b_status			= create_dataref("laminar/B738/autopilot/cws_b_status", "number")
B738DR_autopilot_cws_roll				= create_dataref("laminar/B738/autopilot/cws_roll", "number")
B738DR_autopilot_cws_pitch				= create_dataref("laminar/B738/autopilot/cws_pitch", "number")

B738DR_capt_fd_cmd_pfd_status			= create_dataref("laminar/B738/autopilot/capt_fd_cmd_pfd_status", "number")
B738DR_fo_fd_cmd_pfd_status				= create_dataref("laminar/B738/autopilot/fo_fd_cmd_pfd_status", "number")


B738DR_autopilot_autothrottle_status	= create_dataref("laminar/B738/autopilot/autothrottle_status", "number")
B738DR_autopilot_master_capt_status		= create_dataref("laminar/B738/autopilot/master_capt_status", "number")
B738DR_autopilot_master_fo_status		= create_dataref("laminar/B738/autopilot/master_fo_status", "number")

B738DR_autopilot_vhf_source_pos			= create_dataref("laminar/B738/toggle_switch/vhf_nav_source", "number")

B738DR_init_glare_CD					= create_dataref("laminar/B738/init_CD/glare", "number")

B738DR_capt_gps_active_status			= create_dataref("laminar/B738/radios/capt_gps_status", "number")
B738DR_fo_gps_active_status				= create_dataref("laminar/B738/radios/fo_gps_status", "number")

B738DR_capt_nps_active_status			= create_dataref("laminar/B738/autopilot/capt_nps_status", "number")
B738DR_fo_nps_active_status				= create_dataref("laminar/B738/autopilot/fo_nps_status", "number")


B738DR_AP_status						= create_dataref("laminar/B738/autopilot/status_test", "number")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--




--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

-- CAPTAIN EFIS CONTROLS

function B738_efis_wxr_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_wxr_capt = 1
		simCMD_efis_wxr:once()
	elseif phase == 2 then
		B738DR_efis_wxr_capt = 0
	end
end

function B738_efis_sta_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_sta_capt = 1
		simCMD_efis_sta:once()
	elseif phase == 2 then
		B738DR_efis_sta_capt = 0
	end
end

function B738_efis_wpt_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_wpt_capt = 1
		simCMD_efis_wpt:once()
	elseif phase == 2 then
		B738DR_efis_wpt_capt = 0
	end
end

function B738_efis_arpt_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_arpt_capt = 1
		simCMD_efis_arpt:once()
	elseif phase == 2 then
		B738DR_efis_arpt_capt = 0
	end
end

function B738_efis_data_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_data_capt = 1
	elseif phase == 2 then
		B738DR_efis_data_capt = 0
	end
end

function B738_efis_pos_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_pos_capt = 1
	elseif phase == 2 then
		B738DR_efis_pos_capt = 0
	end
end

function B738_efis_terr_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_terr_capt = 1
	elseif phase == 2 then
		B738DR_efis_terr_capt = 0
	end
end

function B738_efis_rst_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_rst_capt = 1
		simDR_decision_height_capt = 0
	elseif phase == 2 then
		B738DR_efis_rst_capt = 0
	end
end

function B738_efis_ctr_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_ctr_capt = 1
		if simDR_map_mode_is_HSI == 0 then
			simDR_map_mode_is_HSI = 1
		elseif simDR_map_mode_is_HSI == 1 then
			simDR_map_mode_is_HSI = 0
		end
	elseif phase == 2 then
		B738DR_efis_ctr_capt = 0
	end
end

function B738_efis_tfc_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_tfc_capt = 1
		simCMD_efis_tfc:once()
	elseif phase == 2 then
		B738DR_efis_tfc_capt = 0
	end
end

function B738_efis_std_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_std_capt = 1
		simDR_barometer_setting_capt = 29.92
	elseif phase == 2 then
		B738DR_efis_std_capt = 0
	end
end

function B738_efis_mtrs_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_mtrs_capt = 1
		if B738DR_capt_alt_mode_meters == 0 then
			B738DR_capt_alt_mode_meters = 1
		elseif B738DR_capt_alt_mode_meters == 1 then
			B738DR_capt_alt_mode_meters = 0
		end
	elseif phase == 2 then
		B738DR_efis_mtrs_capt = 0
	end
end

function B738_efis_fpv_capt_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_fpv_capt = 1
		if B738DR_capt_fpv_on == 0 then
			B738DR_capt_fpv_on = 1
		elseif B738DR_capt_fpv_on == 1 then
			B738DR_capt_fpv_on = 0
		end
	elseif phase == 2 then
		B738DR_efis_fpv_capt = 0
	end
end

function B738_efis_baro_mode_capt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_baro_mode_capt == 0 then
			B738DR_efis_baro_mode_capt = 1
		end
	end
end

function B738_efis_baro_mode_capt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_baro_mode_capt == 1 then
			B738DR_efis_baro_mode_capt = 0
		end
	end
end

function B738_efis_vor1_capt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor1_capt_pos == -1 then
			B738DR_efis_vor1_capt_pos = 0
			simDR_vor1_capt = 1
		elseif B738DR_efis_vor1_capt_pos == 0 then
			B738DR_efis_vor1_capt_pos = 1
			simDR_vor1_capt = 2
		end
	end
end
			
function B738_efis_vor1_capt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor1_capt_pos == 1 then
			B738DR_efis_vor1_capt_pos = 0
			simDR_vor1_capt = 1
		elseif B738DR_efis_vor1_capt_pos == 0 then
			B738DR_efis_vor1_capt_pos = -1
			simDR_vor1_capt = 1
		end
	end
end

function B738_efis_vor2_capt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor2_capt_pos == -1 then
			B738DR_efis_vor2_capt_pos = 0
			simDR_vor2_capt = 1
		elseif B738DR_efis_vor2_capt_pos == 0 then
			B738DR_efis_vor2_capt_pos = 1
			simDR_vor2_capt = 2
		end
	end
end
			
function B738_efis_vor2_capt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor2_capt_pos == 1 then
			B738DR_efis_vor2_capt_pos = 0
			simDR_vor2_capt = 1
		elseif B738DR_efis_vor2_capt_pos == 0 then
			B738DR_efis_vor2_capt_pos = -1
			simDR_vor2_capt = 1
		end
	end
end

-- FIRST OFFICER EFIS CONTROLS

function B738_efis_wxr_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_wxr_fo = 1
		simCMD_efis_wxr:once()
	elseif phase == 2 then
		B738DR_efis_wxr_fo = 0
	end
end

function B738_efis_sta_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_sta_fo = 1
		simCMD_efis_sta:once()
	elseif phase == 2 then
		B738DR_efis_sta_fo = 0
	end
end

function B738_efis_wpt_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_wpt_fo = 1
		simCMD_efis_wpt:once()
	elseif phase == 2 then
		B738DR_efis_wpt_fo = 0
	end
end

function B738_efis_arpt_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_arpt_fo = 1
		simCMD_efis_arpt:once()
	elseif phase == 2 then
		B738DR_efis_arpt_fo = 0
	end
end

function B738_efis_data_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_data_fo = 1
	elseif phase == 2 then
		B738DR_efis_data_fo = 0
	end
end

function B738_efis_pos_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_pos_fo = 1
	elseif phase == 2 then
		B738DR_efis_pos_fo = 0
	end
end

function B738_efis_terr_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_terr_fo = 1
	elseif phase == 2 then
		B738DR_efis_terr_fo = 0
	end
end

function B738_efis_rst_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_rst_fo = 1
		simDR_decision_height_fo = 0
	elseif phase == 2 then
		B738DR_efis_rst_fo = 0
	end
end

function B738_efis_ctr_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_ctr_fo = 1
		if simDR_map_mode_is_HSI == 0 then
			simDR_map_mode_is_HSI = 1
		elseif simDR_map_mode_is_HSI == 1 then
			simDR_map_mode_is_HSI = 0
		end
	elseif phase == 2 then
		B738DR_efis_ctr_fo = 0
	end
end

function B738_efis_tfc_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_tfc_fo = 1
		simCMD_efis_tfc:once()
	elseif phase == 2 then
		B738DR_efis_tfc_fo = 0
	end
end

function B738_efis_std_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_std_fo = 1
		simDR_barometer_setting_fo = 29.92
	elseif phase == 2 then
		B738DR_efis_std_fo = 0
	end
end

function B738_efis_mtrs_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_mtrs_fo = 1
		if B738DR_fo_alt_mode_meters == 0 then
			B738DR_fo_alt_mode_meters = 1
		elseif B738DR_fo_alt_mode_meters == 1 then
			B738DR_fo_alt_mode_meters = 0
		end
	elseif phase == 2 then
		B738DR_efis_mtrs_fo = 0
	end
end

function B738_efis_fpv_fo_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_efis_fpv_fo = 1
		if B738DR_fo_fpv_on == 0 then
			B738DR_fo_fpv_on = 1
		elseif B738DR_fo_fpv_on == 1 then
			B738DR_fo_fpv_on = 0
		end
	elseif phase == 2 then
		B738DR_efis_fpv_fo = 0
	end
end

function B738_efis_baro_mode_fo_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_baro_mode_fo == 0 then
			B738DR_efis_baro_mode_fo = 1
		end
	end
end

function B738_efis_baro_mode_fo_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_baro_mode_fo == 1 then
			B738DR_efis_baro_mode_fo = 0
		end
	end
end

function B738_efis_vor1_fo_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor1_fo_pos == -1 then
			B738DR_efis_vor1_fo_pos = 0
			simDR_vor1_fo = 1
		elseif B738DR_efis_vor1_fo_pos == 0 then
			B738DR_efis_vor1_fo_pos = 1
			simDR_vor1_fo = 2
		end
	end
end
			
function B738_efis_vor1_fo_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor1_fo_pos == 1 then
			B738DR_efis_vor1_fo_pos = 0
			simDR_vor1_fo = 1
		elseif B738DR_efis_vor1_fo_pos == 0 then
			B738DR_efis_vor1_fo_pos = -1
			simDR_vor1_fo = 1
		end
	end
end

function B738_efis_vor2_fo_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor2_fo_pos == -1 then
			B738DR_efis_vor2_fo_pos = 0
			simDR_vor2_fo = 1
		elseif B738DR_efis_vor2_fo_pos == 0 then
			B738DR_efis_vor2_fo_pos = 1
			simDR_vor2_fo = 2
		end
	end
end
			
function B738_efis_vor2_fo_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_efis_vor2_fo_pos == 1 then
			B738DR_efis_vor2_fo_pos = 0
			simDR_vor2_fo = 1
		elseif B738DR_efis_vor2_fo_pos == 0 then
			B738DR_efis_vor2_fo_pos = -1
			simDR_vor2_fo = 1
		end
	end
end



------------ AUTOPILOT ------------------------------------------------------------------


function B738_autopilot_n1_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_n1_pos = 1
		if B738DR_autopilot_autothr_arm_pos == 1 and AP_engagement_status == 1 then
			simCMD_autopilot_n1:once()
		end
	elseif phase == 2 then
		B738DR_autopilot_n1_pos = 0
		
	end
end

function B738_autopilot_speed_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_speed_pos = 1
		if B738DR_autopilot_autothr_arm_pos == 1 and AP_engagement_status == 1 then
			simCMD_autopilot_speed:once()
		end
	elseif phase == 2 then
		B738DR_autopilot_speed_pos = 0
	end
end

function B738_autopilot_lvl_chg_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_lvl_chg_pos = 1
		if AP_engagement_status == 1 then
			simCMD_autopilot_lvl_chg:once()
			CMD_status = 1
			CWS_status = 0
		end
	elseif phase == 2 then
		B738DR_autopilot_lvl_chg_pos = 0
	end
end

function B738_autopilot_vnav_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_vnav_pos = 1
		if AP_engagement_status == 1 then
			simCMD_autopilot_vnav:once()
			CMD_status = 1
			CWS_status = 0
		end
	elseif phase == 2 then
		B738DR_autopilot_vnav_pos = 0
	end
end

function B738_autopilot_co_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_co_pos = 1
		simCMD_autopilot_co:once()
	elseif phase == 2 then
		B738DR_autopilot_co_pos = 0
	end
end

--------

function B738_autopilot_lnav_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_lnav_pos = 1
		if AP_engagement_status == 1 then
			simCMD_autopilot_lnav:once()
			CMD_status = 1
			CWS_status = 0
			if AP_status <= 1 then
				AP_status = 1
			elseif AP_status > 1 then
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_lnav_pos = 0
	end
end


function B738_autopilot_vorloc_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_vorloc_pos = 1
		if AP_engagement_status == 1 then
			simCMD_autopilot_vorloc:once()
			CMD_status = 1
			CWS_status = 0
			if AP_status <= 1 then
				AP_status = 1
			elseif AP_status > 1 then
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_vorloc_pos = 0
	end
end

function B738_autopilot_app_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_app_pos = 1
		if AP_engagement_status == 1 then
			simCMD_autopilot_app:once()
			CMD_status = 1
			CWS_status = 0
			if AP_status <= 1 then
				AP_status = 1
			elseif AP_status > 1 then
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_app_pos = 0
	end
end

function B738_autopilot_hdg_sel_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_hdg_sel_pos = 1
		if AP_engagement_status == 1 then
			simCMD_autopilot_hdg:once()
			CMD_status = 1
			CWS_status = 0
			if AP_status <= 1 then
				AP_status = 1
			elseif AP_status > 1 then
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_hdg_sel_pos = 0
	end
end


function B738_autopilot_alt_hld_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_alt_hld_pos = 1
		if AP_engagement_status == 1 then
			simCMD_autopilot_alt_hold:once()
			CMD_status = 1
			CWS_status = 0
			if AP_status <= 1 then
				AP_status = 1
			elseif AP_status > 1 then
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_alt_hld_pos = 0
	end
end


function B738_autopilot_vs_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_vs_pos = 1
		if AP_engagement_status == 1 then
			simCMD_autopilot_vs:once()
			CMD_status = 1
			CWS_status = 0
			if AP_status <= 1 then
				AP_status = 1
			elseif AP_status > 1 then
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_vs_pos = 0
	end
end

function B738_autopilot_disconnect_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_disconnect_pos == 0 then
			B738DR_autopilot_disconnect_pos = 1
			simCMD_ap_disconnect:once()
			CWS_status = 0
			ap_disconnect = 1
			if AP_status == 3 then
				if B738DR_autopilot_fd_pos == 0 and B738DR_autopilot_fd_fo_pos == 0 then
					AP_status = 0
					simCMD_servos_fdir_off_b:once()
					simCMD_servos_fdir_off_a:once()
				elseif B738DR_autopilot_fd_pos == 1 and B738DR_autopilot_fd_fo_pos == 0 then
					AP_status = 2
					simCMD_servos_fdir_off_b:once()
				elseif B738DR_autopilot_fd_pos == 0 and B738DR_autopilot_fd_fo_pos == 1 then
					AP_status = 2
					simCMD_servos_fdir_off_a:once()
				end
			elseif AP_status < 3 then
			end				
		elseif B738DR_autopilot_disconnect_pos == 1 then
			B738DR_autopilot_disconnect_pos = 0
			ap_disconnect = 0
		end
	end
end

	B738_autothrottle_return = function()
		B738DR_autopilot_autothr_arm_pos = 0
	end

function B738_autopilot_autothr_arm_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_autopilot_on == 1 then
			if B738DR_autopilot_autothr_arm_pos == 0 then
				B738DR_autopilot_autothr_arm_pos = 1
				B738DR_autopilot_autothrottle_status = 1
			elseif B738DR_autopilot_autothr_arm_pos == 1 then
				B738DR_autopilot_autothr_arm_pos = 0
				B738DR_autopilot_autothrottle_status = 0
				simCMD_autothrottle_discon:once()
			end
		elseif simDR_autopilot_on == 0 then
			if B738DR_autopilot_autothr_arm_pos == 0 then
				B738DR_autopilot_autothr_arm_pos = 1
				run_after_time(B738_autothrottle_return, 0.2)
			elseif B738DR_autopilot_autothr_arm_pos == 1 then
				B738DR_autopilot_autothr_arm_pos = 0
				B738DR_autopilot_autothrottle_status = 0
				simCMD_autothrottle_discon:once()
			end
		end
	end
end


---- FLIGHT DIRECTORS ------------------------------------------



function B738_autopilot_flight_dir_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_fd_pos == 0 then
			B738DR_autopilot_fd_pos = 1
			if simDR_flight_dir_mode_capt == 2 then
			elseif simDR_flight_dir_mode_capt == 1 then
				AP_status = 2
			elseif simDR_flight_dir_mode_capt == 0 then
				if B738DR_autopilot_fd_fo_pos == 0 and simDR_flight_dir_mode_fo < 2 then
					simDR_master_flight_dir = 0
					simCMD_flight_director_a_on:once()
					if AP_status < 3 then
						AP_status = 2
					end
				elseif B738DR_autopilot_fd_fo_pos == 0 and simDR_flight_dir_mode_fo == 2 then
					simCMD_flight_director_a_on:once()
				elseif B738DR_autopilot_fd_fo_pos == 1 then
					simCMD_flight_director_a_on:once()
				end
			end
		elseif B738DR_autopilot_fd_pos == 1 then
			B738DR_autopilot_fd_pos = 0
			if simDR_flight_dir_mode_fo ~= 2 and simDR_flight_dir_mode_capt ~= 2 then
				simCMD_servos_fdir_off_a:once()
				if B738DR_autopilot_fd_fo_pos == 0 then
					AP_status = 1
				end
			end
		end
	end
end


function B738_autopilot_flight_dir_fo_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_fd_fo_pos == 0 then
			B738DR_autopilot_fd_fo_pos = 1
			if simDR_flight_dir_mode_fo == 2 then
			elseif simDR_flight_dir_mode_fo == 1 then
				AP_status = 2
			elseif simDR_flight_dir_mode_fo == 0 then
				if B738DR_autopilot_fd_pos == 0 and simDR_flight_dir_mode_capt < 2 then
					simDR_master_flight_dir = 1
					simCMD_flight_director_b_on:once()
					if AP_status < 3 then
						AP_status = 2
					end
				elseif B738DR_autopilot_fd_pos == 0 and simDR_flight_dir_mode_capt == 2 then
					simCMD_flight_director_b_on:once()
				elseif B738DR_autopilot_fd_pos == 1 then
					simCMD_flight_director_b_on:once()
				end
			end
		elseif B738DR_autopilot_fd_fo_pos == 1 then
			B738DR_autopilot_fd_fo_pos = 0
			if simDR_flight_dir_mode_fo ~= 2 and simDR_flight_dir_mode_capt ~= 2 then
				simCMD_servos_fdir_off_b:once()
				if B738DR_autopilot_fd_pos == 0 then
					AP_status = 1
				end
			end
		end
	end
end


---- BANK ANGLE ---------------------------------------------

function B738_autopilot_bank_angle_up_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_bank_angle_pos == 0 then
			B738DR_autopilot_bank_angle_pos = 1
			simDR_bank_angle = 3
		elseif B738DR_autopilot_bank_angle_pos == 1 then
			B738DR_autopilot_bank_angle_pos = 2
			simDR_bank_angle = 4
		elseif B738DR_autopilot_bank_angle_pos == 2 then
			B738DR_autopilot_bank_angle_pos = 3
			simDR_bank_angle = 5
		elseif B738DR_autopilot_bank_angle_pos == 3 then
			B738DR_autopilot_bank_angle_pos = 4
			simDR_bank_angle = 6
		end
	end
end
		
function B738_autopilot_bank_angle_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_bank_angle_pos == 4 then
			B738DR_autopilot_bank_angle_pos = 3
			simDR_bank_angle = 5
		elseif B738DR_autopilot_bank_angle_pos == 3 then
			B738DR_autopilot_bank_angle_pos = 2
			simDR_bank_angle = 4
		elseif B738DR_autopilot_bank_angle_pos == 2 then
			B738DR_autopilot_bank_angle_pos = 1
			simDR_bank_angle = 3
		elseif B738DR_autopilot_bank_angle_pos == 1 then
			B738DR_autopilot_bank_angle_pos = 0
			simDR_bank_angle = 2
		end
	end
end	

-- COMMAND A&B
		
function B738_autopilot_cmd_a_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_cmd_a_pos = 1
		if ap_disconnect == 0 and AP_engagement_status == 1 then
			if simDR_flight_dir_mode_capt ~= 2 or CWS_status == 1 then
				simCMD_servos_on_a:once()
				CMD_status = 1
				CWS_status = 0
				AP_status = 3
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_cmd_a_pos = 0
	end
end

function B738_autopilot_cmd_b_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_cmd_b_pos = 1
		if ap_disconnect == 0 and AP_engagement_status == 1 then
			if simDR_flight_dir_mode_fo ~= 2 or CWS_status == 1 then
				simCMD_servos_on_b:once()
				CMD_status = 1
				CWS_status = 0
				AP_status = 3
			end
		end
	elseif phase == 2 then
		B738DR_autopilot_cmd_b_pos = 0
	end
end

-- CWS A&B

function B738_autopilot_cws_a_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_cws_a_pos = 1
		if ap_disconnect == 0 and AP_engagement_status == 1 then
			simCMD_autopilot_cws_a:once()
			CMD_status = 0
			CWS_status = 1
			AP_status = 3
		end
	elseif phase == 2 then
		B738DR_autopilot_cws_a_pos = 0
	end
end

function B738_autopilot_cws_b_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_cws_b_pos = 1
		if ap_disconnect == 0 and AP_engagement_status == 1 then
			simCMD_autopilot_cws_b:once()
			CMD_status = 0
			CWS_status = 1
			AP_status = 3
		end
	elseif phase == 2 then
		B738DR_autopilot_cws_b_pos = 0
	end
end


-- TOGA

function B738_capt_throttle_toga_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_capt_thro_toga = 1
		simCMD_toga:once()
		simCMD_toga_engine:once()
	elseif phase == 2 then
		B738DR_autopilot_capt_thro_toga = 0
	end
	
end

function B738_fo_throttle_toga_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autopilot_fo_thro_toga = 1
		simCMD_toga:once()
		simCMD_toga_engine:once()
	elseif phase == 2 then
		B738DR_autopilot_fo_thro_toga = 0
	end
end	


-- AUTOTHROTTLE DISCON

function B738_capt_autothro_disco_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autothro_capt_discon = 1
		simCMD_autothrottle_discon:once()
		B738DR_autopilot_autothrottle_status = 0
		run_after_time(B738_autothrottle_return, 0.2)
	elseif phase == 2 then
		B738DR_autothro_capt_discon = 0
	end
end
		
function B738_fo_autothro_disco_press_CMDhandler(phase, duration)
	if phase == 0 then
		B738DR_autothro_fo_discon = 1
		simCMD_autothrottle_discon:once()
		B738DR_autopilot_autothrottle_status = 0
		run_after_time(B738_autothrottle_return, 0.2)
	elseif phase == 2 then
		B738DR_autothro_fo_discon = 0
	end
end		


-- N1 LIMIT

local eng1_n1_limit = 104
local eng2_n1_limit = 104

		
function B738_n1_set_mode_lft_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_n1_set_mode_pos == 3 then
			B738DR_n1_set_mode_pos = 2
		elseif B738DR_n1_set_mode_pos == 2 then
			B738DR_n1_set_mode_pos = 1
		elseif B738DR_n1_set_mode_pos == 1 then
			B738DR_n1_set_mode_pos = 0
		end
	end
end

function B738_n1_set_mode_rgt_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_n1_set_mode_pos == 0 then
			B738DR_n1_set_mode_pos = 1
		elseif B738DR_n1_set_mode_pos == 1 then
			B738DR_n1_set_mode_pos = 2
		elseif B738DR_n1_set_mode_pos == 2 then
			B738DR_n1_set_mode_pos = 3
			eng1_n1_limit = (eng1_n1_limit + eng2_n1_limit) * 0.5
			eng2_n1_limit = eng1_n1_limit
		end
	end
end

function B738_n1_set_lft_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_n1_set_mode_pos == 0 then
			B738DR_n1_set_pos = B738DR_n1_set_pos - 1
			eng2_n1_limit = eng2_n1_limit - 0.1
		elseif B738DR_n1_set_mode_pos == 1 then
			B738DR_n1_set_pos = B738DR_n1_set_pos - 1
			eng1_n1_limit = eng1_n1_limit - 0.1
		elseif B738DR_n1_set_mode_pos == 2 then
			B738DR_n1_set_pos = B738DR_n1_set_pos - 1
		elseif B738DR_n1_set_mode_pos == 3 then
			B738DR_n1_set_pos = B738DR_n1_set_pos - 1
			eng1_n1_limit = eng1_n1_limit - 0.1
			eng2_n1_limit = eng2_n1_limit - 0.1
		end
	elseif phase == 1 then
		if duration > 0.5 then
			if B738DR_n1_set_mode_pos == 0 then
				B738DR_n1_set_pos = B738DR_n1_set_pos - 1
				eng2_n1_limit = eng2_n1_limit - 0.1
			elseif B738DR_n1_set_mode_pos == 1 then
				B738DR_n1_set_pos = B738DR_n1_set_pos - 1
				eng1_n1_limit = eng1_n1_limit - 0.1
			elseif B738DR_n1_set_mode_pos == 2 then
				B738DR_n1_set_pos = B738DR_n1_set_pos - 1
			elseif B738DR_n1_set_mode_pos == 3 then
				B738DR_n1_set_pos = B738DR_n1_set_pos - 1
				eng1_n1_limit = eng1_n1_limit - 0.1
				eng2_n1_limit = eng2_n1_limit - 0.1
			end
		end
	end
end

function B738_n1_set_rgt_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_n1_set_mode_pos == 0 then
			B738DR_n1_set_pos = B738DR_n1_set_pos + 1
			eng2_n1_limit = eng2_n1_limit + 0.1
		elseif B738DR_n1_set_mode_pos == 1 then
			B738DR_n1_set_pos = B738DR_n1_set_pos + 1
			eng1_n1_limit = eng1_n1_limit + 0.1
		elseif B738DR_n1_set_mode_pos == 2 then
			B738DR_n1_set_pos = B738DR_n1_set_pos + 1
		elseif B738DR_n1_set_mode_pos == 3 then
			B738DR_n1_set_pos = B738DR_n1_set_pos + 1
			eng1_n1_limit = eng1_n1_limit + 0.1
			eng2_n1_limit = eng2_n1_limit + 0.1
		end
	elseif phase == 1 then
		if duration > 0.5 then
			if B738DR_n1_set_mode_pos == 0 then
				B738DR_n1_set_pos = B738DR_n1_set_pos + 1
				eng2_n1_limit = eng2_n1_limit + 0.1
			elseif B738DR_n1_set_mode_pos == 1 then
				B738DR_n1_set_pos = B738DR_n1_set_pos + 1
				eng1_n1_limit = eng1_n1_limit + 0.1
			elseif B738DR_n1_set_mode_pos == 2 then
				B738DR_n1_set = B738DR_n1_set + 1
			elseif B738DR_n1_set_mode_pos == 3 then
				B738DR_n1_set_pos = B738DR_n1_set_pos + 1
				eng1_n1_limit = eng1_n1_limit + 0.1
				eng2_n1_limit = eng2_n1_limit + 0.1
			end
		end
	end
end
		
			
-- NAV SOURCE SWITCH


function B738_vhf_nav_source_switch_rgt_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_vhf_source_pos == -1 then
			B738DR_autopilot_vhf_source_pos = 0
		elseif B738DR_autopilot_vhf_source_pos == 0 then
			B738DR_autopilot_vhf_source_pos = 1
		end
	end
end

function B738_vhf_nav_source_switch_lft_CMDhandler(phase, duration)
	if phase == 0 then
		if B738DR_autopilot_vhf_source_pos == 1 then
			B738DR_autopilot_vhf_source_pos = 0
		elseif B738DR_autopilot_vhf_source_pos == 0 then
			B738DR_autopilot_vhf_source_pos = -1
		end
	end
end


function B738_ai_glare_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	B738_set_glare_all_modes()
	  	B738_set_glare_CD() 
	  	B738_set_glare_ER()
	end 	
end	


--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

-- N1 LIMIT KNOBS

B738CMD_n1_set_mode_lft		= create_command("laminar/B738/knob/n1_set_mode_lft", "N1 Set Mode Left", B738_n1_set_mode_lft_CMDhandler)
B738CMD_n1_set_mode_rgt		= create_command("laminar/B738/knob/n1_set_mode_rgt", "N1 Set Mode Right", B738_n1_set_mode_rgt_CMDhandler)

B738CMD_n1_set_lft			= create_command("laminar/B738/knob/n1_set_lft", "N1 Set Left", B738_n1_set_lft_CMDhandler)
B738CMD_n1_set_rgt			= create_command("laminar/B738/knob/n1_set_rgt", "N1 Set Right", B738_n1_set_rgt_CMDhandler)


-- CAPT EFIS COMMANDS

B738CMD_efis_wxr_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/wxr_press", "CAPT EFIS Weather", B738_efis_wxr_capt_CMDhandler)
B738CMD_efis_sta_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/sta_press", "CAPT EFIS Station", B738_efis_sta_capt_CMDhandler)
B738CMD_efis_wpt_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/wpt_press", "CAPT EFIS Waypoint", B738_efis_wpt_capt_CMDhandler)
B738CMD_efis_arpt_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/arpt_press", "CAPT EFIS Airport", B738_efis_arpt_capt_CMDhandler)
B738CMD_efis_data_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/data_press", "CAPT EFIS DATA", B738_efis_data_capt_CMDhandler)
B738CMD_efis_pos_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/pos_press", "CAPT EFIS Position", B738_efis_pos_capt_CMDhandler)
B738CMD_efis_terr_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/terr_press", "CAPT EFIS Terrain", B738_efis_terr_capt_CMDhandler)

B738CMD_efis_rst_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/rst_press", "CAPT EFIS Reset", B738_efis_rst_capt_CMDhandler)
B738CMD_efis_ctr_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/ctr_press", "CAPT EFIS Center", B738_efis_ctr_capt_CMDhandler)
B738CMD_efis_tfc_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/tfc_press", "CAPT EFIS Traffic", B738_efis_tfc_capt_CMDhandler)
B738CMD_efis_std_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/std_press", "CAPT EFIS Standard", B738_efis_std_capt_CMDhandler)

B738CMD_efis_mtrs_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/mtrs_press", "CAPT ALT in Meters", B738_efis_mtrs_capt_CMDhandler)
B738CMD_efis_fpv_capt 		= create_command("laminar/B738/EFIS_control/capt/push_button/fpv_press", "CAPT Flight Path Vector", B738_efis_fpv_capt_CMDhandler)

B738CMD_efis_baro_mode_capt_up 	= create_command("laminar/B738/EFIS_control/capt/baro_in_hpa_up", "CAPT Baro Mode HPA", B738_efis_baro_mode_capt_up_CMDhandler)
B738CMD_efis_baro_mode_capt_dn 	= create_command("laminar/B738/EFIS_control/capt/baro_in_hpa_dn", "CAPT Baro Mode IN", B738_efis_baro_mode_capt_dn_CMDhandler)

B738CMD_efis_vor1_capt_up 		= create_command("laminar/B738/EFIS_control/capt/vor1_off_up", "CAPT VOR1 Up", B738_efis_vor1_capt_up_CMDhandler)
B738CMD_efis_vor1_capt_dn 		= create_command("laminar/B738/EFIS_control/capt/vor1_off_dn", "CAPT VOR1 Down", B738_efis_vor1_capt_dn_CMDhandler)
B738CMD_efis_vor2_capt_up 		= create_command("laminar/B738/EFIS_control/capt/vor2_off_up", "CAPT VOR1 Up", B738_efis_vor2_capt_up_CMDhandler)
B738CMD_efis_vor2_capt_dn 		= create_command("laminar/B738/EFIS_control/capt/vor2_off_dn", "CAPT VOR1 Down", B738_efis_vor2_capt_dn_CMDhandler)


-- FO EFIS COMMANDS

B738CMD_efis_wxr_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/wxr_press", "fo EFIS Weather", B738_efis_wxr_fo_CMDhandler)
B738CMD_efis_sta_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/sta_press", "fo EFIS Station", B738_efis_sta_fo_CMDhandler)
B738CMD_efis_wpt_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/wpt_press", "fo EFIS Waypoint", B738_efis_wpt_fo_CMDhandler)
B738CMD_efis_arpt_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/arpt_press", "fo EFIS Airport", B738_efis_arpt_fo_CMDhandler)
B738CMD_efis_data_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/data_press", "fo EFIS DATA", B738_efis_data_fo_CMDhandler)
B738CMD_efis_pos_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/pos_press", "fo EFIS Position", B738_efis_pos_fo_CMDhandler)
B738CMD_efis_terr_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/terr_press", "fo EFIS Terrain", B738_efis_terr_fo_CMDhandler)

B738CMD_efis_rst_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/rst_press", "fo EFIS Reset", B738_efis_rst_fo_CMDhandler)
B738CMD_efis_ctr_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/ctr_press", "fo EFIS Center", B738_efis_ctr_fo_CMDhandler)
B738CMD_efis_tfc_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/tfc_press", "fo EFIS Traffic", B738_efis_tfc_fo_CMDhandler)
B738CMD_efis_std_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/std_press", "fo EFIS Standard", B738_efis_std_fo_CMDhandler)

B738CMD_efis_mtrs_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/mtrs_press", "fo ALT in Meters", B738_efis_mtrs_fo_CMDhandler)
B738CMD_efis_fpv_fo 		= create_command("laminar/B738/EFIS_control/fo/push_button/fpv_press", "fo Flight Path Vector", B738_efis_fpv_fo_CMDhandler)

B738CMD_efis_baro_mode_fo_up 	= create_command("laminar/B738/EFIS_control/fo/baro_in_hpa_up", "fo Baro Mode HPA", B738_efis_baro_mode_fo_up_CMDhandler)
B738CMD_efis_baro_mode_fo_dn 	= create_command("laminar/B738/EFIS_control/fo/baro_in_hpa_dn", "fo Baro Mode IN", B738_efis_baro_mode_fo_dn_CMDhandler)

B738CMD_efis_vor1_fo_up 		= create_command("laminar/B738/EFIS_control/fo/vor1_off_up", "fo VOR1 Up", B738_efis_vor1_fo_up_CMDhandler)
B738CMD_efis_vor1_fo_dn 		= create_command("laminar/B738/EFIS_control/fo/vor1_off_dn", "fo VOR1 Down", B738_efis_vor1_fo_dn_CMDhandler)

B738CMD_efis_vor2_fo_up 		= create_command("laminar/B738/EFIS_control/fo/vor2_off_up", "fo VOR1 Up", B738_efis_vor2_fo_up_CMDhandler)
B738CMD_efis_vor2_fo_dn 		= create_command("laminar/B738/EFIS_control/fo/vor2_off_dn", "fo VOR1 Down", B738_efis_vor2_fo_dn_CMDhandler)


----- AP COMMANDS

B738CMD_autopilot_n1_press				= create_command("laminar/B738/autopilot/n1_press", "N1 Mode", B738_autopilot_n1_press_CMDhandler)
B738CMD_autopilot_speed_press			= create_command("laminar/B738/autopilot/speed_press", "Speed Mode", B738_autopilot_speed_press_CMDhandler)
B738CMD_autopilot_lvl_chg_press			= create_command("laminar/B738/autopilot/lvl_chg_press", "Level Change Mode", B738_autopilot_lvl_chg_press_CMDhandler)
B738CMD_autopilot_vnav_press			= create_command("laminar/B738/autopilot/vnav_press", "Vertical NAV Mode", B738_autopilot_vnav_press_CMDhandler)
B738CMD_autopilot_co_press				= create_command("laminar/B738/autopilot/change_over_press", "IAS MACH Change Over", B738_autopilot_co_press_CMDhandler)

B738CMD_autopilot_lnav_press			= create_command("laminar/B738/autopilot/lnav_press", "FMS Lateral NAV Mode", B738_autopilot_lnav_press_CMDhandler)
B738CMD_autopilot_vorloc_press			= create_command("laminar/B738/autopilot/vorloc_press", "VOR Localizer Mode", B738_autopilot_vorloc_press_CMDhandler)
B738CMD_autopilot_app_press				= create_command("laminar/B738/autopilot/app_press", "Approach Mode", B738_autopilot_app_press_CMDhandler)
B738CMD_autopilot_hdg_sel_press			= create_command("laminar/B738/autopilot/hdg_sel_press", "Heading Select Mode", B738_autopilot_hdg_sel_press_CMDhandler)

B738CMD_autopilot_alt_hld_press			= create_command("laminar/B738/autopilot/alt_hld_press", "Altitude Hold Mode", B738_autopilot_alt_hld_press_CMDhandler)
B738CMD_autopilot_vs_press				= create_command("laminar/B738/autopilot/vs_press", "Vertical Speed Mode", B738_autopilot_vs_press_CMDhandler)

B738CMD_autopilot_disconnect_toggle		= create_command("laminar/B738/autopilot/disconnect_toggle", "AP Disconnect", B738_autopilot_disconnect_toggle_CMDhandler)
B738CMD_autopilot_autothr_arm_toggle	= create_command("laminar/B738/autopilot/autothrottle_arm_toggle", "Autothrottle ARM", B738_autopilot_autothr_arm_toggle_CMDhandler)
B738CMD_autopilot_flight_dir_toggle		= create_command("laminar/B738/autopilot/flight_director_toggle", "Flight Director", B738_autopilot_flight_dir_toggle_CMDhandler)
B738CMD_autopilot_flight_dir_fo_toggle	= create_command("laminar/B738/autopilot/flight_director_fo_toggle", "First Officer Flight Director", B738_autopilot_flight_dir_fo_toggle_CMDhandler)
B738CMD_autopilot_bank_angle_up			= create_command("laminar/B738/autopilot/bank_angle_up", "Bank Angle Increase", B738_autopilot_bank_angle_up_CMDhandler)
B738CMD_autopilot_bank_angle_dn			= create_command("laminar/B738/autopilot/bank_angle_dn", "Bank Angle Decrease", B738_autopilot_bank_angle_dn_CMDhandler)

B738CMD_autopilot_cmd_a_press			= create_command("laminar/B738/autopilot/cmd_a_press", "Command A", B738_autopilot_cmd_a_press_CMDhandler)
B738CMD_autopilot_cmd_b_press			= create_command("laminar/B738/autopilot/cmd_b_press", "Command B", B738_autopilot_cmd_b_press_CMDhandler)

B738CMD_autopilot_cws_a_press			= create_command("laminar/B738/autopilot/cws_a_press", "Control Wheel Steering A", B738_autopilot_cws_a_press_CMDhandler)
B738CMD_autopilot_cws_b_press			= create_command("laminar/B738/autopilot/cws_b_press", "Control Wheel Steering B", B738_autopilot_cws_b_press_CMDhandler)

B738CMD_vhf_nav_source_switch_lft		= create_command("laminar/B738/toggle_switch/vhf_nav_source_lft", "VHF SOURCE LEFT", B738_vhf_nav_source_switch_lft_CMDhandler)
B738CMD_vhf_nav_source_switch_rgt		= create_command("laminar/B738/toggle_switch/vhf_nav_source_rgt", "VHF SOURCE RIGHT", B738_vhf_nav_source_switch_rgt_CMDhandler)

B738CMD_capt_throttle_toga_press		= create_command("laminar/B738/autopilot/capt_toga_press", "CAPTAIN TO/GA", B738_capt_throttle_toga_press_CMDhandler)
B738CMD_fo_throttle_toga_press			= create_command("laminar/B738/autopilot/fo_toga_press", "F/O TO/GA", B738_fo_throttle_toga_press_CMDhandler)

B738CMD_capt_autothro_disco_press		= create_command("laminar/B738/autopilot/capt_autothro_disco_press", "CAPTAIN AUTOTHROTTLE_DISCONNECT", B738_capt_autothro_disco_press_CMDhandler)
B738CMD_fo_autothro_disco_press			= create_command("laminar/B738/autopilot/fo_autothro_disco_press", "F/O AUTOTHROTTLE_DISCONNECT", B738_fo_autothro_disco_press_CMDhandler)

-- AI

B738CMD_ai_glare_quick_start		= create_command("laminar/B738/ai/glare_quick_start", "number", B738_ai_glare_quick_start_CMDhandler)

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

function B738_rescale(in1, out1, in2, out2, x)
    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end


function auto_engagement_status()

	local ap_buses_powered = 0

	if simDR_bus1_power > 15 or simDR_bus2_power > 15 then
		ap_buses_powered = 1
	elseif simDR_bus1_power <= 15 and simDR_bus2_power <= 15 then
		ap_buses_powered = 0
	end

	if simDR_autopilot_comp_fail ~= 6 and ap_buses_powered == 1 then
		AP_engagement_status = 1
	elseif simDR_autopilot_comp_fail == 6 or ap_buses_powered == 0 then
		AP_engagement_status = 0
	end

end


function autopilot_system_lights()

-- SPEED MODES

B738DR_AP_status = AP_status

	if simDR_autothrottle_mode == 1 and simDR_autothrottle_status == 1 then
	B738DR_autopilot_speed_status = 1
	elseif simDR_autothrottle_mode ~=1 or simDR_autothrottle_status == 0 then
	B738DR_autopilot_speed_status = 0
	end

	if simDR_autothrottle_mode == 2 and simDR_autothrottle_status == 1 then
	B738DR_autopilot_n1_status = 1
	elseif simDR_autothrottle_mode ~= 2 or simDR_autothrottle_status == 0 then
	B738DR_autopilot_n1_status = 0
	end

-- LVL CHANGE
	
	local lvl_chg = 0
		if simDR_autopilot_altitude_mode == 5 then
		lvl_chg = 1
		end
		
	B738DR_autopilot_lvl_chg_status = lvl_chg

-- LNAV
	
	local lnav_status = 0
		if simDR_lnav_status == 2 then
		lnav_status = 1
	end

	B738DR_autopilot_lnav_status = lnav_status

-- VOR LOC

	local vorloc_status = 0
		if simDR_vorloc_status >= 1 and simDR_approach_status == 0 then
		vorloc_status = 1
		elseif simDR_vorloc_status >= 1 and simDR_approach_status >= 1 then
		vorloc_status = 0
		end

	B738DR_autopilot_vorloc_status = vorloc_status
	
-- APP	
	
	B738DR_autopilot_app_status	= simDR_approach_status

-- HDG SEL

	local hdg_sel_status = 0
		if simDR_autopilot_heading_mode == 1 then
		hdg_sel_status = 1
	end

	B738DR_autopilot_hdg_sel_status = hdg_sel_status
	
-- ALT HLD

	local alt_hld_status = 0
		if simDR_autopilot_altitude_mode == 6 then
		alt_hld_status = 1
	end

	B738DR_autopilot_alt_hld_status = alt_hld_status

-- V/S
	
	local vs_status = 0
		if simDR_autopilot_altitude_mode == 4 then
		vs_status = 1
	end
		
	B738DR_autopilot_vs_status = vs_status

-- VNAV

	local vnav_status = 0
		if simDR_vnav_status >= 1 then
		vnav_status = 1
	end

	B738DR_autopilot_vnav_status = vnav_status


-- MASTER CAPT / FO

	if AP_status <= 1 then
		B738DR_autopilot_master_capt_status = 0
		B738DR_autopilot_master_fo_status = 0
	elseif AP_status > 1 then
		if simDR_master_flight_dir == 0 then
			B738DR_autopilot_master_capt_status = 1
			B738DR_autopilot_master_fo_status = 0
		elseif simDR_master_flight_dir == 1 then
			B738DR_autopilot_master_capt_status = 0
			B738DR_autopilot_master_fo_status = 1
		elseif simDR_master_flight_dir == 2 then
			B738DR_autopilot_master_capt_status = 1
			B738DR_autopilot_master_fo_status = 1
		end
	end

-- CAPT FO PFD FD/CMD STATUS


	local command_status = 0
	
	if simDR_servos_A_on == 1 or simDR_servos_B_on == 1 then
		command_status = 1
	elseif simDR_servos_A_on == 0 and simDR_servos_B_on == 0 then
		command_status = 0
	end

	local servos_status = 0

	if simDR_ap_on_A == 1 or simDR_ap_on_B == 1 then
		servos_status = 1
	elseif simDR_ap_on_A == 0 and simDR_ap_on_B == 0 then
		servos_status = 0
	end


	if B738DR_autopilot_fd_pos == 0 then
		if command_status == 0 then
			B738DR_capt_fd_cmd_pfd_status = 0
		elseif command_status == 1 then
			if CWS_status == 0 then
				B738DR_capt_fd_cmd_pfd_status = 2
			elseif CWS_status == 1 then
				B738DR_capt_fd_cmd_pfd_status = 0
			end
		end
	elseif B738DR_autopilot_fd_pos == 1 then
		if CWS_status == 0 then
			if command_status == 0 then
				B738DR_capt_fd_cmd_pfd_status = 1
			elseif command_status == 1 then
				B738DR_capt_fd_cmd_pfd_status = 2
			end
		elseif CWS_status == 1 then
			if command_status == 0 then
				B738DR_capt_fd_cmd_pfd_status = 1
			elseif command_status == 1 then
				B738DR_capt_fd_cmd_pfd_status = 1
			end
		end			
	end

	if B738DR_autopilot_fd_fo_pos == 0 then
		if command_status == 0 then
			B738DR_fo_fd_cmd_pfd_status = 0
		elseif command_status == 1 then
			if CWS_status == 0 then
				B738DR_fo_fd_cmd_pfd_status = 2
			elseif CWS_status == 1 then
				B738DR_fo_fd_cmd_pfd_status = 0
			end
		end
	elseif B738DR_autopilot_fd_fo_pos == 1 then
		if CWS_status == 0 then
			if command_status == 0 then
				B738DR_fo_fd_cmd_pfd_status = 1
			elseif command_status == 1 then
				B738DR_fo_fd_cmd_pfd_status = 2
			end
		elseif CWS_status == 1 then
			if command_status == 0 then
				B738DR_fo_fd_cmd_pfd_status = 1
			elseif command_status == 1 then
				B738DR_fo_fd_cmd_pfd_status = 1
			end
		end			
	end


-- AUTOTHROTTLE DISCONNECT DUE TO LOSS OF POWER
	

-- CMD / CWS BUTTON STATUS LIGHTS


	B738DR_autopilot_cmd_a_status = simDR_servos_A_on * CMD_status
	B738DR_autopilot_cmd_b_status = simDR_servos_B_on * CMD_status
	B738DR_autopilot_cws_a_status = simDR_servos_A_on * CWS_status
	B738DR_autopilot_cws_b_status = simDR_servos_B_on * CWS_status


-- CWS PITCH/ROLL PFD

	if simDR_ap_on_A == 1 or simDR_ap_on_B == 1 then
		if simDR_pitch_status == 2 then
		B738DR_autopilot_cws_pitch = 1
		elseif simDR_pitch_status ~= 2 then
		B738DR_autopilot_cws_pitch = 0
		end
	elseif simDR_ap_on_A == 0 and simDR_ap_on_B == 0 then
		B738DR_autopilot_cws_pitch = 0
	end
	
	if simDR_ap_on_A == 1 or simDR_ap_on_B == 1 then
		if simDR_roll_status == 2 then
		B738DR_autopilot_cws_roll = 1
		elseif simDR_roll_status ~= 2 then
		B738DR_autopilot_cws_roll = 0
		end
	elseif simDR_ap_on_A == 0 and simDR_ap_on_B == 0 then
		B738DR_autopilot_cws_roll = 0
	end


-- HEADING SYNC


	simDR_ap_fo_heading = simDR_ap_capt_heading


-- EFIS MAP MODE DRAW LIMITS


	if simDR_EFIS_mode == 4 then
		simDR_EFIS_WX = 0
		simDR_EFIS_TCAS = 0
	end

-- N1 LIMIT EICAS DISPLAY

		B738DR_n1_lim_display_EICAS1 = 1
	if simDR_eng1_reverse == 3 or B738DR_n1_set_mode_pos == 2 then
		B738DR_n1_lim_display_EICAS1 = 0
	end
	
		B738DR_n1_lim_display_EICAS2 = 1
	if simDR_eng2_reverse == 3 or B738DR_n1_set_mode_pos == 2 then
		B738DR_n1_lim_display_EICAS2 = 0
	end

	


-- TESTING

-- B738DR_CMD_A_STATUS = autopilot_cmd_a_status
-- B738DR_disconnect_trigger = ap_disconnect_trigger
-- B738DR_disconnect_timer = ap_disconnect_timer

end


-- VHF SOURCE SWAP
	
	
function B738_nav_source_swap()

	if B738DR_autopilot_vhf_source_pos == -1 then
		simDR_autopilot_source = 0
		simDR_autopilot_fo_source = 0
	elseif B738DR_autopilot_vhf_source_pos == 0 then
		simDR_autopilot_source = 0
		simDR_autopilot_fo_source = 1
	elseif B738DR_autopilot_vhf_source_pos == 1 then
		simDR_autopilot_source = 1
		simDR_autopilot_fo_source = 1
	end

end


-- GPS / NPS status monitor

function B738_gps_status()


	if simDR_autopilot_heading_mode == 1 or
		simDR_lnav_status >= 1 or
		simDR_vnav_status >= 1 then
		B738DR_capt_nps_active_status = 1
	elseif simDR_autopilot_heading_mode == 0 and
		simDR_lnav_status == 0 and
		simDR_vnav_status == 0 then
		B738DR_capt_nps_active_status = 0
	end

	if simDR_autopilot_heading_mode == 1 or
		simDR_lnav_status >= 1 or
		simDR_vnav_status >= 1 then
		B738DR_fo_nps_active_status = 1
	elseif simDR_autopilot_heading_mode == 0 and
		simDR_lnav_status == 0 and
		simDR_vnav_status == 0 then
		B738DR_fo_nps_active_status = 0
	end


	if simDR_gps1_bearing == 0 and
		simDR_gps1_dme_distance == 0 and
		simDR_gps1_dme_speed == 0 and
		simDR_gps1_dme_time == 0 then
		B738DR_capt_gps_active_status = 0
		B738DR_fo_gps_active_status = 0
	elseif simDR_gps1_bearing > 0 or
		simDR_gps1_dme_distance > 0 or
		simDR_gps1_dme_speed > 0 or
		simDR_gps1_dme_time > 0 then
		B738DR_capt_gps_active_status = 1
		B738DR_fo_gps_active_status = 1
	end

end

-- N1 SET MODES

function B738_n1_set()

	eng1_n1_limit = B738_rescale(30, 30, 104, 104, eng1_n1_limit)
	eng2_n1_limit = B738_rescale(30, 30, 104, 104, eng2_n1_limit)

	if B738DR_n1_set_mode_pos ~= 2 then
		simDR_engine1_n1_limit = eng1_n1_limit
		simDR_engine2_n1_limit = eng2_n1_limit
	elseif B738DR_n1_set_mode_pos == 2 then
		simDR_engine1_n1_limit = 104
		simDR_engine2_n1_limit = 104
	end
		
end

-- TOGA SET PITCH

function B738_toga_pitch()
	
	if simDR_airspeed <= 60 then
		simDR_toga_set = -10
	elseif simDR_airspeed > 60 then
		simDR_toga_set = 15
	end
	
end


----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function B738_glare_monitor_AI()

    if B738DR_init_glare_CD == 1 then
        B738_set_glare_all_modes()
        B738_set_glare_CD()
        B738DR_init_glare_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function B738_set_glare_all_modes()
	
	B738DR_init_glare_CD = 0
	
	simDR_vor1_capt = 1	
	simDR_vor2_capt	= 1
	simDR_vor1_fo	= 1
	simDR_vor2_fo	= 1

	B738DR_efis_vor1_capt_pos = 0
	B738DR_efis_vor2_capt_pos = 0
	B738DR_efis_vor1_fo_pos = 0
	B738DR_efis_vor2_fo_pos = 0

	simDR_efis_ndb	= 0
	simDR_bank_angle = 4
	simDR_autopilot_source = 0
	simDR_autopilot_fo_source = 1
	simDR_autopilot_side = 0
	B738DR_autopilot_bank_angle_pos = 2

	simDR_flight_dir_mode_capt = 0
	simDR_flight_dir_mode_fo = 0
	B738DR_autopilot_fd_pos = 0
	B738DR_autopilot_fd_fo_pos = 0
	simDR_master_flight_dir = 0
	B738DR_autopilot_autothr_arm_pos = 0
	simDR_engine1_n1_limit = 104
	simDR_engine2_n1_limit = 104
  	B738DR_n1_set_mode_pos = 2
  
    simDR_acf_has_fd = 1

end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function B738_set_glare_CD()

		
end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------

function B738_set_glare_ER()

end



----- FLIGHT START ---------------------------------------------------------------------

function B738_flight_start_glare()

    -- ALL MODES ------------------------------------------------------------------------
    B738_set_glare_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        B738_set_glare_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		B738_set_glare_ER()

    end

end





--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

function aircraft_unload() 

	simDR_toga_set = 7

end

function flight_start()

	B738_flight_start_glare()

end

--function flight_crash() end

function before_physics()

	auto_engagement_status()	
	B738_nav_source_swap()
	autopilot_system_lights()
	B738_gps_status()
	B738_n1_set()
	
end

function after_physics()

	B738_glare_monitor_AI()
	B738_toga_pitch()

end

--function after_replay() end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



