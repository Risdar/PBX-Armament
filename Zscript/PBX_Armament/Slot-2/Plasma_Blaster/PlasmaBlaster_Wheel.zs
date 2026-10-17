Class PlasmaBlasterWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Primary Modes (2) + Secondary Modes (2)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(1.2, 1.2));

		// Primary
		PBX_AddWheel(spw, img:"PlasmaBlaster/semi",		alias:"$PBX_PlasmaBlaster_Semi",	token:"Plasma_Select_Semi");
		PBX_AddWheel(spw, img:"PlasmaBlaster/fullauto",	alias:"$PBX_PlasmaBlaster_Auto",	token:"Plasma_Select_Auto");

		// Secondary
		PBX_AddWheel(spw, img:"PlasmaBlaster/burst",	alias:"$PBX_PlasmaBlaster_Burst",	token:"Plasma_Select_Burst");
		PBX_AddWheel(spw, img:"PlasmaBlaster/blast",	alias:"$PBX_PlasmaBlaster_Charge",	token:"Plasma_Select_Charge");
	}
}