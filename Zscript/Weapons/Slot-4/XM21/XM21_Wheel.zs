Class XM21Wheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Toggle Fire (1) + Scope Wheel (3)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.9,0.9));
		let snp = PBX_XM21(mWeap); if(!snp) return;
		
		// Toggle Fire
		if(snp.mSemiAuto)
		{
			PBX_AddWheel(spw, img:"XM21/XM21_Burst",	alias:"$PB_WHEEL_BURST",	token:"XM21_Toggle_Firemode");
		}
		else
		{
			PBX_AddWheel(spw, img:"XM21/XM21_Semi",		alias:"$PB_WHEEL_SEMI",		token:"XM21_Toggle_Firemode");	
		}

		// Toggle CLoak
		if(snp.mCloakEngaged)
		{
			PBX_AddWheel(spw, img:"XM21/XM21_CloakOff",	alias:"$PBX_XM21_CloakOff",	token:"XM21_Toggle_Cloak", scale:(0.3,0.3));
		}
		else
		{
			PBX_AddWheel(spw, img:"XM21/XM21_CloakOn",	alias:"$PBX_XM21_CloakOn",	token:"XM21_Toggle_Cloak", scale:(0.3,0.3));	
		}

		PBX_GenericWheel(spw,"XM21");
	}

}