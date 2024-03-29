(*********************************************************************************
 * Copyright:   
 * Author:    NoVi 
 * Created:   March 28, 2024/4:33 PM 
 *********************************************************************************)

PROGRAM _CYCLIC
	
	//------ Subrutinas ------//
	
	Config;
	
	///////////////////////////
	
	
	//----- Habilita el Eje ------//
	
	AxisBasic.Enable 	:= gAxis[AxisIndex].Enable;
	AxisConfig.Enable 	:= AxisBasic.Active;
	AxisCam.Enable 		:= AxisBasic.Active AND AxisIndex > VMASTER;
	
	////////////////////////////////
	
	
	
	CASE StAxis OF
		
		STATE_INIT:
			
			(* inicializacion del Eje *)
			
			IF AxisBasic.Active AND AxisBasic.Info.BootState = mpAXIS_BLP_DONE AND AxisBasic.Info.ReadyToPowerOn AND AxisConfig.Active THEN 
				StConfig := CONFIG_LOAD_REQ;
				StAxis := STATE_CONFIG;
			END_IF
			
		STATE_CONFIG:
			
			CASE StConfig OF
				
				CONFIG_LOAD_REQ:
					
					(* Carga la configuracion por default en Confing.mpaxisbasic*)
					
					AxisConfig.Load	:= TRUE;
					
					IF AxisConfig.CommandDone THEN 
						StConfig := CONFIG_LOAD_DONE;
					END_IF
					
				CONFIG_LOAD_DONE:
					
					(* Actualiza la configuracion, carga parametros asignados por el usuario *)
					
					AxisConfig.Load	:= FALSE;
					gAxis[AxisIndex].Cmd.ConfigReq 	:= TRUE;
					StConfig := CONFIG_SAVE_REQ;
					
				
				CONFIG_SAVE_REQ:
				
					(* Salva en el drive los parametros asignados por el usuario *)
					
					AxisConfig.Save := TRUE;
				
					IF AxisConfig.CommandDone THEN 
						StConfig := CONFIG_SAVE_DONE;
					END_IF
				
				CONFIG_SAVE_DONE:
					
					(* Configuracion terminada *)
					
					AxisConfig.Save := TRUE;
					gAxis[AxisIndex].Cmd.ConfigReq := FALSE;
				
					IF gAxis[AxisIndex].Sts.ConfigDone AND AxisBasic.Info.ReadyToPowerOn THEN 
						StAxis := STATE_POWER_ON;
					END_IF
				
			END_CASE
			
		STATE_POWER_ON:	
			
			(* Energiza el eje siemnpre y cunado no se a virtual *)
			
			IF AxisBasic.Info.HardwareInfo.DeviceType = mpAXIS_VIRTUAL THEN 
				StAxis := STATE_HOME;
			ELSE
				IF NOT AxisBasic.PowerOn THEN 
					AxisBasic.Power := TRUE;
				ELSIF AxisBasic.PowerOn THEN 
					StHome := HOME_CONFIG;
					StAxis := STATE_HOME;
				END_IF
			END_IF
			
		STATE_HOME:
			
			(* Ejecucion y configuracion del Home *)
			
			CASE StHome OF 
				
				(* Actualizacion del los parametros del home *)
				
				HOME_CONFIG: 
					
					AxisBasicPar.Home.Mode  							:= mpAXIS_HOME_MODE_DIRECT;
					AxisBasicPar.Home.Position 							:= 0.0;
					AxisBasicPar.Home.StartVelocity 					:= 50.0;
					AxisBasicPar.Home.HomingVelocity 					:= 5.0;
					AxisBasicPar.Home.SensorOffset 						:= 0.0;
					AxisBasicPar.Home.Acceleration 						:= 500.0;
					AxisBasicPar.Home.StartDirection 					:= mpAXIS_HOME_DIR_POSITIVE;
					AxisBasicPar.Home.HomingDirection 					:= mpAXIS_HOME_DIR_POSITIVE;
					AxisBasicPar.Home.NoDirectionChange 				:= mpAXIS_HOME_OPTION_OFF;
					AxisBasicPar.Home.SwitchEdge 						:= mpAXIS_HOME_DIR_POSITIVE;
					AxisBasicPar.Home.ReferencePulse 					:= mpAXIS_HOME_OPTION_OFF;
					AxisBasicPar.Home.ReferencePulseBlockingDistance 	:= 0.0;
					AxisBasicPar.Home.TorqueLimit 						:= 0.0;
					AxisBasicPar.Home.BlockDetectionPositionError 		:= 0.0;
					AxisBasicPar.Home.PositionErrorStopLimit 			:= 0.0;
					AxisBasicPar.Home.EndlessPositionDataRef 			:= 0;
					
					
					AxisBasic.Update := TRUE;
					
					IF AxisBasic.UpdateDone THEN 
						StHome := HOME_CONFIG_DONE;
					END_IF
					
				HOME_CONFIG_DONE:
					
					(* Configuracion Home Actualizada *)
					
					AxisBasic.Update := FALSE;
					StHome := HOME_REQ;
					
				HOME_REQ:
					
					(* Ejecucion del home *)
					
					AxisBasic.Home := TRUE;
					
					IF AxisBasic.IsHomed THEN 
						StHome := HOME_DONE;
					END_IF
					
				HOME_DONE:
					
					(* Ejecucion del home terminada *)
					
					AxisBasic.Home := FALSE;
					StAxis := STATE_IDLE;
				
			END_CASE
			
		STATE_IDLE:
			
					
					
					
					
							
			
		STATE_ERROR:
			
	END_CASE
	
	
	//----- Administracion de Errores ------//
	
	gAxis[AxisIndex].Sts.Error := AxisBasic.Error OR AxisConfig.Error OR AxisCam.Error OR NOT gAxis[AxisIndex].Enable;
	
	IF gAxis[AxisIndex].Sts.Error THEN
		StAxis := STATE_ERROR;
	END_IF
	
	//-- Reset
	AxisBasic.ErrorReset 	:= AxisBasic.Error AND gAxis[AxisIndex].Cmd.Reset;
	AxisConfig.ErrorReset 	:= AxisConfig.Error AND gAxis[AxisIndex].Cmd.Reset;
	AxisCam.ErrorReset		:= AxisCam.Error AND gAxis[AxisIndex].Cmd.Reset;
	
	///////////////////////////////////////////
		
	
	 
END_PROGRAM
