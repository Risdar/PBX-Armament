Class BattleRifleWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 3; // Close Wheel (1) + Toggle Fire (1) + Laser (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.9,0.9));
		let br = PBX_BDPBattleRifle(mWeap); if(!br) return;
		
		// Toggle Fire
		if(br.mSemiAuto)
		{
			PBX_AddWheel(spw, img:"BattleRifle/BR_Burst",	alias:"$PB_WHEEL_BURST",	token:"BR_Select_FireMode");
		}
		else
		{
			PBX_AddWheel(spw, img:"BattleRifle/BR_Semi",	alias:"$PB_WHEEL_SEMI",		token:"BR_Select_FireMode");	
		}
		
		// Laser
		PBX_LaserWheel(spw,"BattleRifle",mIconScale);
	}

}