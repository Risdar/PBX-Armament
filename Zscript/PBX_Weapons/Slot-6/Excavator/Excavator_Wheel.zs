Class ExcavatorWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Unupgraded Modes (2) + Upgraded Modes (2)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
		
		PBX_InitializeWheel(spw,requester,scale:(0.6,0.6));
		mDisabled = PBX_BackPack_filter & DisablePBX_ExcavatorUpgrade;

		if(PBX_CheckInv("Excavator_Upgraded")) 
		{
			PBX_AddWheel(spw, img:"Excavator/DropAltUpgraded",	alias:"$PBX_Excavator_DropMode",	token:"EX_Select_DropMode");
			PBX_AddWheel(spw, img:"Excavator/DrillAltUpgraded",	alias:"$PBX_Excavator_DrillMode",	token:"EX_Select_DrillMode");
			PBX_AddWheel(spw, img:"Excavator/BolaAlt",			alias:"$PBX_Excavator_BolaMode",	token:"EX_Select_BolaMode");
			PBX_AddWheel(spw, img:"Excavator/SawAlt",			alias:"$PBX_Excavator_SawMode",		token:"EX_Select_SawMode");
		}
		else
		{
			PBX_AddWheel(spw, img:"Excavator/DropAlt",		alias:"$PBX_Excavator_DropMode",	token:"EX_Select_DropMode");
			PBX_AddWheel(spw, img:"Excavator/DrillAlt",		alias:"$PBX_Excavator_DrillMode",	token:"EX_Select_DrillMode");
			PBX_AddWheel(spw, img:"Excavator/BolaAltNo",	alias:"$PBX_ModeNotAvailable",		token:"EX_Select_No");
			PBX_AddWheel(spw, img:"Excavator/SawAltNo",		alias:"$PBX_ModeNotAvailable",		token:"EX_Select_No");
		}
		
	}
}