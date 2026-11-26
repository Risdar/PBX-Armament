Class CryoSGWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;

	override int GetSPCount(actor requester)
	{
		return 4; // Close Wheel (1) + Modes (3)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;

		PBX_InitializeWheel(spw,requester,scale:(0.8,0.8));

		// Modes
		PBX_AddWheel(spw, img:"CryoSG/PlasmaBlast",		alias:"$PBX_CryoSG_PlasmaBlast",	token:"CryoSG_Select_PlasmaBlast");
		PBX_AddWheel(spw, img:"CryoSG/PlasmaBreath",	alias:"$PBX_CryoSG_PlasmaBreath",	token:"CryoSG_Select_PlasmaBreath");
		PBX_AddWheel(spw, img:"CryoSG/FreezeBlast",		alias:"$PBX_CryoSG_Freeze",	        token:"CryoSG_Select_Freeze");

	}
}