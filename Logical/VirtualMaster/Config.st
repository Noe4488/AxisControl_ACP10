
ACTION Config:
	
	//---- Numero del Eje ----///
	AxisIndex := VMASTER;
	
	//---- Nombre del eje ----//
	AxisName := 'Virtual Master';
	
	//---- Hablita el eje ----//
	gAxis[AxisIndex].Enable := TRUE; // ESTE DATA DEBERA SER USADO EN UN VARIABLE DE LA CONFIGURACION MAQUINA PARA HABILITAR O DESHABILITAR UN EJE.
	
	//---- Limite de velocidad -----//
	LimitSpeed 	:= 6600.0;
	
	//----- Limete de aceleracion/desaceleracion ----//
	LimitAccDec := 6600.0;
	
	//---- Relacion de velocoidad motor/reductor ----// 
	GearIn 	:= 1;
	GearOut := 1;
	
	//---- Seleccion direccion de rotacion del eje ----//
	AxisDirection := TRUE; // TRUE = sentido de las manesillas del reloj; FALSE = en contra de las manesillas del reloj;
	
	// ---- Definicion sentido de giro del eje ----//
	IF AxisDirection THEN
		Direction	:= mpAXIS_DIR_CLOCKWISE;
	ELSE
		Direction	:= mpAXIS_DIR_COUNTERCLOCKWISE;
	END_IF
	
	// ---- Definicion Paramentros de posicion del eje ----//
	Period :=  360.0;
	SectorNumber := 1;
	ReferenceDistance := Period * SectorNumber;
	
	
	IF gAxis[AxisIndex].Cmd.ConfigReq THEN 
		
		AxisConfigPar.AxisName := AxisName ;
		
		//Axis
		AxisConfigPar.Axis.BaseType 				:= mpAXIS_PERIODIC_ROTARY;
		AxisConfigPar.Axis.MeasurementUnit 			:= mpAXIS_UNIT_GENERIC;
		AxisConfigPar.Axis.MeasurementResolution 	:= 0.01;
		AxisConfigPar.Axis.PeriodSettings.Period	:= Period; // Valor con fines de prueba este deberia estar en 360 ya que es el VMaster 
			
		AxisConfigPar.Axis.MovementLimits.VelocityPositive	:= LimitSpeed;
		AxisConfigPar.Axis.MovementLimits.VelocityNegative	:= LimitSpeed;
		AxisConfigPar.Axis.MovementLimits.Acceleration		:= LimitAccDec;
		AxisConfigPar.Axis.MovementLimits.Deceleration		:= LimitAccDec;
	
		//Drive
		AxisConfigPar.Drive.Gearbox.Input			:= GearIn;
		AxisConfigPar.Drive.Gearbox.Output			:= GearOut;
		AxisConfigPar.Drive.Gearbox.Direction 		:= Direction;
		AxisConfigPar.Drive.Transformation.ReferenceDistance := ReferenceDistance;
		
		gAxis[AxisIndex].Sts.ConfigDone := TRUE;
			
	END_IF
	
			
	
	////---- FB Control del eje -----////
	
	AxisBasic.Axis 				:= ADR(gVMaster);
	AxisBasic.MpLink 			:= ADR(gVMasterLink);
	AxisBasic.Parameters 		:= ADR(AxisBasicPar);
	AxisBasic();
	
	AxisConfig.MpLink 			:= ADR(gVMasterLink);
	AxisConfig.Configuration 	:= ADR(AxisConfigPar);
	AxisConfig();
	
	AxisCam.MpLink				:= ADR(gVMasterLink);
	AxisCam.MpLinkMaster		:= 0;
	AxisCam.Parameters			:= ADR(AxisCamPar);
	AxisCam();

END_ACTION
