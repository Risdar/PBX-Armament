Class DemonicExtWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;

	override int GetSPCount(actor requester)
	{
		return 4; // Close Wheel (1) + Laser Mode (1) + Upgraded Modes (2)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		PBX_InitializeWheel(spw,requester,scale:(0.6,0.6));
		mDisabled = PBX_BackPack_filter & DisablePBX_DemonExtArtifacts;

		// Laser Mode
		PBX_AddWheel(spw, img:"DemonExt/LaserAlt",				alias:"$PBX_DemonExt_Laser",	 token:"UMDE_Select_LaserMode");
		
		// Incinerator Mode
		if(PBX_CheckInv("ArtifactIncinerator"))
			PBX_AddWheel(spw, img:"DemonExt/IncinerationAlt",	alias:"$PBX_DemonExt_Incin",	 token:"UMDE_Select_IncinerationMode");
		else
			PBX_AddWheel(spw, img:"DemonExt/NoIncinerationAlt",	alias:"$PBX_ModeNotAvailable",	 token:"UMDE_Select_NoIncinerationMode");
		
		// Soul Lightning Mode
		if(PBX_CheckInv("ArtifactLightning"))
			PBX_AddWheel(spw, img:"DemonExt/LightningAlt",		alias:"$PBX_DemonExt_Lightning", token:"UMDE_Select_LightningMode");
		else
			PBX_AddWheel(spw, img:"DemonExt/NoLightningAlt",	alias:"$PBX_ModeNotAvailable",	 token:"UMDE_Select_NoLightningMode");
		
	}
}