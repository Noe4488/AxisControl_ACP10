
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
	END_STRUCT;
	AxisStatus_type : 	STRUCT 
		ConfigDone : BOOL;
		Error : BOOL;
	END_STRUCT;
	AxisParameters_type : 	STRUCT 
		New_Member : USINT;
	END_STRUCT;
END_TYPE
