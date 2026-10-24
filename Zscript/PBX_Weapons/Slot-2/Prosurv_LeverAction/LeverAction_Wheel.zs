Class LeverActionWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Laser Sight (1) + Ammo Types (2) + Coin (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.5,0.5));
		mDisabled = PBX_BackPack_filter & DisablePBX_LeverActionUpgrade;

		// Magnum
		PBX_AddWheel(spw,     img:"LeverAction/Magnum",	  alias:"$PBX_LeverAction_Magnum", token:"LA_Select_Magnum");
		
		// Marlin
		if(PBX_CheckInv("LA_Upgraded")) 
			PBX_AddWheel(spw, img:"LeverAction/Marlin",	  alias:"$PBX_LeverAction_Marlin", token:"LA_Select_Marlin");
		else
			PBX_AddWheel(spw, img:"LeverAction/NoMarlin", alias:"$PBX_AmmoNotAvailable",   token:"LA_Select_No");

		// Coin
		PBX_AddWheel(spw, img:"LeverAction/CoinToss", 	  alias:"$PBX_Coin_Toss",   	   token:"LA_Select_Coin");
	
		// Laser
		PBX_LaserWheel(spw,"LeverAction",laserWheelScale:(0.5,0.5));
	}
}