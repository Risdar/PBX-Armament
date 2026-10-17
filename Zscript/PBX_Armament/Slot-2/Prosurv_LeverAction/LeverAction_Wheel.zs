Class LeverActionWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 4; // Close Wheel (1) + Laser Sight (1) + Ammo Types (2)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.5,0.5));
		mDisabled = PBX_Weapons_backpack_filter & DisablePBX_LeverActionUpgrade;

		// Magnum
		PBX_AddWheel(spw,     img:"LeverAction/Magnum",	  alias:"$PBX_LeverAction_Magnum", token:"LA_Select_Magnum");
		
		// Marlin
		if(PBX_CheckInv("LA_Upgraded")) 
			PBX_AddWheel(spw, img:"LeverAction/Marlin",	  alias:"$PBX_LeverAction_Marlin", token:"LA_Select_Marlin");
		else
			PBX_AddWheel(spw, img:"LeverAction/NoMarlin", alias:"$PBX_AmmoNotAvailable",   token:"LA_Select_No");
	
		// Laser
		PBX_LaserWheel(spw,"LeverAction",laserWheelScale:(0.5,0.5));
	}
}