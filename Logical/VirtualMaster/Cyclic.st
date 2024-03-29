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
			
		STATE_ERROR:
			
	END_CASE
	
	
	//----- Administracion de Errores ------//
	
	gAxis[AxisIndex].Sts.Error := AxisBasic.Error OR AxisConfig.Error OR AxisCam.Error;
	
	IF gAxis[AxisIndex].Sts.Error THEN
		StAxis := STATE_ERROR;
	END_IF
	
	//-- Reset
	AxisBasic.ErrorReset 	:= AxisBasic.Error AND gAxis[AxisIndex].Cmd.Reset;
	AxisConfig.ErrorReset 	:= AxisConfig.Error AND gAxis[AxisIndex].Cmd.Reset;
	AxisCam.ErrorReset		:= AxisCam.Error AND gAxis[AxisIndex].Cmd.Reset;
	
	///////////////////////////////////////////
		
	
	 
END_PROGRAM
