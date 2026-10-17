Class NormalRifleWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 4; // Close Wheel (1) + Toggle Fire (1) + Dual Wield (1) + Laser Sight (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.8,0.8));
		let nr = PBX_NormalRifle(mWeap); if(!nr) return;
		
		// Toggle Fire
		if(!nr.doBurst)
			PBX_AddWheel(spw, img:"NormalRifle/Burst",	alias:"$PB_WHEEL_BURST",	token:"NR_Select_FireMode");
		else
			PBX_AddWheel(spw, img:"NormalRifle/fullauto",	alias:"PB_WHEEL_FULL",	token:"NR_Select_FireMode");

		// Dual Wield
		if(nr.akimboMode)
			PBX_AddWheel(spw, img:"NormalRifle/LaserOff",	alias:"$PBX_NormalRifle_Single",	token:"NR_Select_DualWield");
		else
			PBX_AddWheel(spw, img:"NormalRifle/dualwield",	alias:"$PBX_NormalRifle_Akimbo",	token:"NR_Select_DualWield");

		// Laser
		PBX_LaserWheel(spw,"NormalRifle",mIconScale);
		
	}
}