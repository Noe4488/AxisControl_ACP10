(*********************************************************************************
 * Copyright:   
 * Author:    NoVi 
 * Created:   March 28, 2024/4:33 PM 
 *********************************************************************************)

PROGRAM _CYCLIC
	
	//------ Subrutinas ------//
	
	Config;
	
	///////////////////////////
	
	
	//----- Habilita Eje ------//
	
	AxisBasic.Enable 	:= gAxis[AxisIndex].Enable;
	AxisConfig.Enable 	:= AxisBasic.Active;
	AxisCam.Enable 		:= AxisBasic.Active AND AxisIndex <> MASTER;
	
	////////////////////////////////
	
	
	
	CASE StAxis OF
		
		STATE_INIT: ////////////////////////////////////////
			
			(* inicializacion del Eje *)
			
			IF AxisBasic.Active AND AxisBasic.Info.BootState = mpAXIS_BLP_DONE AND AxisBasic.Info.ReadyToPowerOn AND AxisConfig.Active THEN 
				StConfig := CONFIG_LOAD_REQ;
				StAxis := STATE_CONFIG;
			END_IF
			
		STATE_CONFIG: ////////////////////////////////////////
			
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
					
					AxisConfig.Save := FALSE;
					gAxis[AxisIndex].Cmd.ConfigReq := FALSE;
				
					IF gAxis[AxisIndex].Sts.ConfigDone AND AxisBasic.Info.ReadyToPowerOn THEN 
						StAxis := STATE_POWER_ON;
					END_IF
				
			END_CASE
			
		STATE_POWER_ON:	////////////////////////////////////////
			
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
			
		STATE_HOME: ////////////////////////////////////////
			
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
					
					IF AxisBasic.Info.AxisInitialized THEN 
						StAxis := STATE_IDLE;
					END_IF
				
			END_CASE
			
		STATE_IDLE: ////////////////////////////////////////
			
			(* seleccion modo operacion *)
			
			IF gAxis[AxisIndex].Cmd.JogModeReq THEN 
				StJog 	:= JOG_CONFIG_REQ;
				StAxis 	:= STATE_JOG;
			ELSIF gAxis[AxisIndex].Cmd.MoveAbsoluteModeReq THEN 
				StMoveAbsolute := MOVE_ABSOLUTE_CONFIG;
				StAxis := STATE_MOVE_ABSOLUTE;
			ELSIF gAxis[AxisIndex].Cmd.MoveAdditiveModeReq THEN 
				StMoveAdditive := MOVE_ADDITIVE_CONFIG;
				StAxis := STATE_MOVE_ADDITIVE;
			ELSIF gAxis[AxisIndex].Cmd.MoveVelocityModeReq THEN 
				StMoveVelocity := MOVE_VELOCITY_CONFIG;
				StAxis := STATE_MOVE_VELOCITY;
			END_IF
			
		STATE_JOG: ////////////////////////////////////////
		
			CASE StJog OF
				
				JOG_CONFIG_REQ:
					
					(* Configuracion parametros Jog *)
					
					AxisBasicPar.Jog.Acceleration 	:= gAxis[AxisIndex].Par.Jog.Acc;	
					AxisBasicPar.Jog.Deceleration 	:= gAxis[AxisIndex].Par.Jog.Decel;	
					AxisBasicPar.Jog.Velocity		:= gAxis[AxisIndex].Par.Jog.Speed;	
					AxisBasicPar.Jog.LowerLimit		:= 0.0;
					AxisBasicPar.Jog.UpperLimit		:= 0.0;
					TON_Jog.PT 						:= JOG_TIME;
					
					AxisBasic.Update := TRUE;
					
					IF AxisBasic.UpdateDone THEN 
						StJog := JOG_CONFIG_DONE;
					END_IF
					
				JOG_CONFIG_DONE: 
				
					(* Actualiza Configuracion *)
					
					AxisBasic.Update := FALSE;
					StJog := JOG_WAIT;
				
			
					
				JOG_WAIT:
					
					(* A espera de comando Jog *)
					
					AxisBasic.JogNegative := FALSE;
					AxisBasic.JogPositive := FALSE;
					
					TON_Jog.IN := gAxis[AxisIndex].Cmd.Jog;
					
					IF TON_Jog.Q THEN 
						StJog := JOG_EXECUTE;
					END_IF
				
				JOG_EXECUTE:
				
					(* Jog Ejecutandose *)
					
					IF AxisBasicPar.Direction = mpAXIS_DIR_POSITIVE THEN 
						AxisBasic.JogPositive := TRUE;
					ELSE
						AxisBasic.JogNegative := TRUE;
					END_IF
				
					IF NOT gAxis[AxisIndex].Cmd.Jog THEN 
						StJog := JOG_WAIT;
					END_IF
					
				JOG_DONE:
					
					(* secuencia jog terminada *)
					
					AxisBasic.JogNegative 	:= FALSE;
					AxisBasic.JogPositive 	:= FALSE;
					TON_Jog.IN 				:= FALSE;
					StAxis 					:= STATE_IDLE;
					
				JOG_SAFE_STOP: 
				
					(* Paro de seguridad del eje antes de actualizacion de parametros *)
					
					AxisBasic.JogNegative 	:= FALSE;
					AxisBasic.JogPositive 	:= FALSE;
					TON_Jog.IN 				:= FALSE;
				
					IF NOT AxisBasic.MoveActive AND NOT gAxis[AxisIndex].Cmd.Jog THEN
						StJog := JOG_CONFIG_REQ;
					END_IF

			END_CASE
			
			
			////--- Verifica cambio de parametrso jog
			
			IF (StJog = JOG_WAIT OR StJog = JOG_EXECUTE) AND (AxisBasicPar.Jog.Acceleration <> gAxis[AxisIndex].Par.Jog.Acc OR
				AxisBasicPar.Jog.Deceleration <> gAxis[AxisIndex].Par.Jog.Decel	OR AxisBasicPar.Jog.Velocity <> gAxis[AxisIndex].Par.Jog.Speed) THEN 
		
				StJog := JOG_SAFE_STOP;
				
			END_IF
			
			//// ---- Modo Jog desactivado
			
			IF NOT gAxis[AxisIndex].Cmd.JogModeReq THEN 
				StJog := JOG_DONE;
			END_IF	
			
		STATE_MOVE_ABSOLUTE: ////////////////////////////////////////
			
			CASE StMoveAbsolute OF
				
				MOVE_ABSOLUTE_CONFIG:
			
					(* Asignacion posicion del Eje *)

					AxisBasicPar.Position := gAxis[AxisIndex].Par.AbsolutePosition;
					AxisBasic.Update := TRUE;
					
					IF AxisBasic.UpdateDone THEN 
						StMoveAbsolute := MOVE_ABSOLUTE_WAIT;
					END_IF
					
				MOVE_ABSOLUTE_WAIT:
					
					(* Espera comando de movimiento absoluto *)
					
					AxisBasic.Update := FALSE;
					
					IF gAxis[AxisIndex].Cmd.MoveAbsolute THEN 
						StMoveAbsolute := MOVE_ABSOLUTE_EXECUTE;
					END_IF
				
				MOVE_ABSOLUTE_EXECUTE:
					
					(* Executa movimiento absoluto *)
							
					gAxis[AxisIndex].Cmd.MoveAbsolute := FALSE; 
					AxisBasic.MoveAbsolute := TRUE;
					
					IF AxisBasic.Position = gAxis[AxisIndex].Par.AbsolutePosition AND NOT AxisBasic.MoveActive THEN 
						StMoveAbsolute := MOVE_ASOLUTE_IN_POSITION;
					END_IF
					
				MOVE_ASOLUTE_IN_POSITION:
					
					(* Posicion Absoluta alcanzada *)
					
					AxisBasic.MoveAbsolute := FALSE;
					
					IF AxisBasicPar.Position <> gAxis[AxisIndex].Par.AbsolutePosition THEN
						StMoveAbsolute := MOVE_ABSOLUTE_CONFIG;
					END_IF
					
				MOVE_ABSOLUTE_DONE:
					
					(* Modo movimineto absoluto terminado *) 
					
					AxisBasic.Update := FALSE;
					AxisBasic.MoveAbsolute := FALSE;
					StAxis := STATE_IDLE;
					
			END_CASE
			
			////---- Cambio modo de operacion
			IF NOT gAxis[AxisIndex].Cmd.MoveAbsoluteModeReq THEN 
				StMoveAbsolute := MOVE_ABSOLUTE_DONE;
			END_IF
				
		STATE_MOVE_ADDITIVE: ////////////////////////////////////////
			
		
			CASE StMoveAdditive OF 
			
				MOVE_ADDITIVE_CONFIG:
					
					(* Asignacion posicion del Eje *)

					AxisBasicPar.Distance := gAxis[AxisIndex].Par.AdditivePosition;
					AxisBasic.Update := TRUE;
					
					IF AxisBasic.UpdateDone THEN 
						StMoveAdditive := MOVE_ADDITIVE_WAIT;
					END_IF
				
								
				MOVE_ADDITIVE_WAIT:
					
					(* Espera comando de movimiento aditivo *)
					
					AxisBasic.Update := FALSE;
					
					IF gAxis[AxisIndex].Cmd.MoveAdditive THEN 
						StMoveAdditive := MOVE_ADDITIVE_EXECUTE;
					END_IF
						
					
				MOVE_ADDITIVE_EXECUTE:
					
					(* Executa movimiento aditvo *)
					
					AxisBasic.MoveAdditive := TRUE;
					gAxis[AxisIndex].Cmd.MoveAdditive := FALSE;
					
					IF AxisBasic.InPosition AND NOT AxisBasic.MoveActive THEN 
						StMoveAdditive := MOVE_ADDITIVE_IN_POSITION;
					END_IF
					
				
				MOVE_ADDITIVE_IN_POSITION:
					
					(* Posicion aditivo alcanzada *)
					
					AxisBasic.MoveAdditive := FALSE;
					
					IF AxisBasic.Position <> gAxis[AxisIndex].Par.AdditivePosition THEN 
						StMoveAdditive := MOVE_ADDITIVE_CONFIG;
					END_IF
					
				MOVE_ADDITIVE_DONE:
					
					(* Modo movimineto aditivo terminado *)
					
					StAxis := STATE_IDLE;
	
			END_CASE
			
			
			////---- Cambio modo de operacion
			IF NOT gAxis[AxisIndex].Cmd.MoveAdditiveModeReq THEN 
				StMoveAdditive := MOVE_ADDITIVE_DONE;
			END_IF
			
		
		STATE_MOVE_VELOCITY: ////////////////////////////////////////
			
			CASE StMoveVelocity OF 
				
				
				MOVE_VELOCITY_CONFIG:
					
					(* Asignacion y actualizacion parametros *)
					
					AxisBasicPar.Velocity := gAxis[AxisIndex].Par.Speed;
					AxisBasicPar.Acceleration := gAxis[AxisIndex].Par.Acc;
					AxisBasicPar.Deceleration := gAxis[AxisIndex].Par.Decel;
				
					AxisBasic.Update := TRUE;
				
					IF AxisBasic.UpdateDone THEN 
						StMoveVelocity := MOVE_VELOCITY_WAIT;
					END_IF
				
				MOVE_VELOCITY_WAIT:
					
					(* Eje en espera de comando velocity *)
					
					AxisBasic.Update := FALSE;
					
					IF gAxis[AxisIndex].Cmd.MoveVelocity THEN 
						AxisBasic.MoveVelocity := TRUE;
						StMoveVelocity := MOVE_VELOCITY_EXECUTE;
						
					ELSIF AxisBasicPar.Velocity <> gAxis[AxisIndex].Par.Speed OR AxisBasicPar.Acceleration <> gAxis[AxisIndex].Par.Acc 
						OR AxisBasicPar.Deceleration <> gAxis[AxisIndex].Par.Decel THEN 
						StMoveVelocity := MOVE_VELOCITY_CONFIG;
						
					ELSE
						
						AxisBasic.MoveVelocity := FALSE;
						
					END_IF
				
				MOVE_VELOCITY_EXECUTE:
					
					(* Eje ejecutandose, verifica si hay cambios de parametros *)
					
					IF AxisBasicPar.Velocity <> gAxis[AxisIndex].Par.Speed OR AxisBasicPar.Acceleration <> gAxis[AxisIndex].Par.Acc 
						OR AxisBasicPar.Deceleration <> gAxis[AxisIndex].Par.Decel THEN 
						StMoveVelocity := MOVE_VELOCITY_CONFIG;
					ELSIF NOT gAxis[AxisIndex].Cmd.MoveVelocity THEN 
						StMoveVelocity := MOVE_VELOCITY_WAIT;
					END_IF
				
				MOVE_VELOCITY_DONE:
				
					(* Funcion move velocity terminada *)
					
					AxisBasic.MoveVelocity := FALSE;
					 
					IF NOT AxisBasic.MoveActive THEN 
						StAxis := STATE_IDLE;
					END_IF
				
			END_CASE	
				
			////----- Cambio modo de operacion	
			IF NOT gAxis[AxisIndex].Cmd.MoveVelocityModeReq THEN
				StMoveVelocity := MOVE_VELOCITY_DONE;
			END_IF
			
			
		STATE_ERROR: ////////////////////////////////////////
		
			
		
			AxisBasic.Stop := AxisBasic.MoveActive ;
			
			IF NOT gAxis[AxisIndex].Sts.Error AND (NOT AxisBasic.MoveActive OR AxisBasic.Stopped) THEN 
				AxisBasic.JogNegative 	:= FALSE;
				AxisBasic.JogPositive 	:= FALSE;
				AxisBasic.MoveAbsolute 	:= FALSE;
				AxisBasic.MoveAdditive 	:= FALSE;
				AxisBasic.MoveVelocity 	:= FALSE;
				AxisBasic.Stop 			:= FALSE;
				StAxis 					:= STATE_IDLE;
			END_IF
		
		
	END_CASE
	
	
	//----- Administracion de Errores ------//
	
	gAxis[AxisIndex].Sts.Error := AxisBasic.Error OR AxisConfig.Error OR AxisCam.Error OR NOT gAxis[AxisIndex].Enable;
	
	IF gAxis[AxisIndex].Sts.Error THEN
		StAxis := STATE_ERROR;
	END_IF
	
	//-- Reset
	R_Reset.CLK 			:= gAxis[AxisIndex].Cmd.Reset;
	AxisBasic.ErrorReset 	:= AxisBasic.Error AND R_Reset.Q;
	AxisConfig.ErrorReset 	:= AxisConfig.Error AND R_Reset.Q;
	AxisCam.ErrorReset		:= AxisCam.Error AND R_Reset.Q;
	
	///////////////////////////////////////////
		
	//----- Status del eje -----//
	
	gAxis[AxisIndex].Sts.PowerOn 	:= AxisBasic.PowerOn;
	gAxis[AxisIndex].Sts.HomeDone 	:= AxisBasic.IsHomed;
	gAxis[AxisIndex].Sts.Idle		:= StAxis = STATE_IDLE;
	gAxis[AxisIndex].Sts.Jog		:= StAxis = STATE_JOG;
	
	///////////////////////////////////////////
	
	//----- FB Auxiliares -----//
	
	R_Reset();
	TON_Jog();
	
	///////////////////////////////////////////
	
END_PROGRAM
