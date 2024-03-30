
TYPE
	Axis_type : 	STRUCT 
		Enable : BOOL; (*Habilita Control Global del eje*)
		Cmd : AxisComand_type;
		Sts : AxisStatus_type;
		Par : AxisParameters_type;
	END_STRUCT;
	AxisComand_type : 	STRUCT 
		Enable : BOOL;
		Reset : BOOL;
		ConfigReq : BOOL;
		JogModeReq : BOOL; (*Seleccion modo jog*)
		Jog : BOOL; (*Comando Movimiento en Jog*)
		MoveAbsoluteModeReq : BOOL;
		MoveAbsolute : BOOL;
	END_STRUCT;
	AxisStatus_type : 	STRUCT 
		ConfigDone : BOOL;
		Error : BOOL;
		PowerOn : BOOL;
		HomeDone : BOOL;
		Idle : BOOL;
		Jog : BOOL;
	END_STRUCT;
	AxisParameters_type : 	STRUCT 
		Jog : JogParameter_type;
		AbsolutePosition : LREAL := 0.0;
	END_STRUCT;
	JogParameter_type : 	STRUCT 
		Speed : REAL := 100.0;
		Acc : REAL := 400.0;
		Decel : REAL := 400.0;
	END_STRUCT;
END_TYPE
