Class BDPRailgun_Wheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Scope Wheel (3) + Hologram (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester);
		PBX_GenericWheel(spw,"PlatRailgun");
		PBX_AddWheel(spw, img:"PlatRailgun/spawnHologram",	alias:"$PBX_BDPRailgun_SpawnHologram",	token:"platRailgun_goHolo",	scale:(0.9,0.9));
		
	}
}