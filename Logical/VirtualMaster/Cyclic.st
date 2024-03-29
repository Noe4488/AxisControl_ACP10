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
			
			IF AxisBasic.Active AND AxisBasic.Info.BootState = mpAXIS_BLP_DONE AND AxisBasic.Info.ReadyToPowerOn AND AxisConfig.Active THEN 
				StAxis := STATE_CONFIG;
			END_IF
		
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
