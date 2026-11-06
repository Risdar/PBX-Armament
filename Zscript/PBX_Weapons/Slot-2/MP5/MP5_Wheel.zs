Class MP5Wheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Fire Modes (3) + Laser Sight (1) + Throw Smoke (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.8,0.8));
		let mp5 = PBX_MP5(mWeap); if(!mp5) return;
		
		// Toggle Fire
        PBX_AddWheel(spw, img:"MP5/Semiauto",	alias:"$PB_FIREMODE_SEMI", 	token:"MP5_Select_Semi");
        PBX_AddWheel(spw, img:"MP5/Burst",	    alias:"$PB_FIREMODE_BURST", token:"MP5_Select_Burst");
        PBX_AddWheel(spw, img:"MP5/Fullauto",	alias:"$PB_FIREMODE_FULL", 	token:"MP5_Select_FullAuto");

		// Smoke Grenade
        PBX_AddWheel(spw, img:"MP5/Smoke",	alias:"$PBX_MP5_ThrowSmoke", token:"MP5_Throw_Smoke");

		// Laser
		PBX_LaserWheel(spw,"MP5",mIconScale);
		
	}
}