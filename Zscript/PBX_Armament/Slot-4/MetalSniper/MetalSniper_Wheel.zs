Class MetalSniperWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;

	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Secondary Modes (2) + Laser (1) + Toggle Ammo Type (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;

		PBX_InitializeWheel(spw,requester,scale:(0.7, 0.7));
		mDisabled = PBX_BackPack_filter & DisablePBX_MetalSniperUpgrade;
		
		// Laser
		PBX_LaserWheel(spw,"MetalSniper");

		// Aim Mode and Grenade Mode
		PBX_AddWheel(spw, img:"MetalSniper/ADSAlt",		alias:"$PBX_MetalSniper_AimMode",	token:"MS_Select_AimMode");
		PBX_AddWheel(spw, img:"MetalSniper/GrenadeAlt",	alias:"$PBX_MetalSniper_GrenMode",	token:"MS_Select_GrenMode");

		let weap = PBX_MetalSniper(mWeap); if(!weap) return;
		
		// Resonance Ammo Toggle
		mIconScale = (1.0, 1.0);
		if(PBX_CheckInv("MetalSniperUpgraded")) 
		{
			if(weap && weap.resonanceAmmoLoaded)
				PBX_AddWheel(spw, img:"MetalSniper/StandardAlt",	alias:"$PBX_MetalSniper_Standard",	token:"MS_Select_Resonance");
			else
				PBX_AddWheel(spw, img:"MetalSniper/ResonanceAlt",	alias:"$PBX_MetalSniper_Resonance",	token:"MS_Select_Resonance");
		} 
		else 
		{
			PBX_AddWheel(spw, img:"MetalSniper/ResonanceNo",		alias:"$PBX_AmmoNotAvailable",		token:"MS_Select_NO");
		}
		
	}
}

Class MS_Zoomed_Wheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;

	override int GetSPCount(actor requester)
	{
		return 4; // Close Wheel (1) + Scope Wheel (3)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;

		PBX_InitializeWheel(spw,requester);
		PBX_GenericWheel(spw,"MetalSniper");
	}
}