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
	
	
	
	////////////////////////////////
	
	
	
	CASE StAxis OF
		
		STATE_INIT:
			
			IF AxisBasic.Active AND AxisBasic.Info.BootState = mpAXIS_BLP_DONE AND AxisBasic.Info.ReadyToPowerOn AND AxisConfig.Active AND AxisCam.Active THEN 
				
			END_IF
		
		
	END_CASE
	
			
	(* Motion FBs *)		
	
	AxisBasic.Axis 		:= ADR(gVMaster);
	AxisBasic.MpLink 	:= ADR(gVMasterLink);
	AxisBasic.Parameters	:= ADR(AxisBasicPar);
	
	 
END_PROGRAM
