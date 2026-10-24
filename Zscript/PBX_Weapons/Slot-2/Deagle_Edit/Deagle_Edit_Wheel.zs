Class DeagleEditWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 4; // Close Wheel (1) + Toggle Coin (1) + Toggle Dual Wield (1) + Laser (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.8,0.8));
		let deag = PBX_DeagleEdited(mWeap); if(!deag) return;
		
		// Toggle Secondary
		if(deag.mCoinSecondary)
		{
			PBX_AddWheel(spw, img:"DeagleEdit/Deag_Zoom",	alias:"$PBX_SECONDARY_ZOOM",	token:"Deagle_Toggle_Secondary");
		}
		else
		{
			PBX_AddWheel(spw, img:"DeagleEdit/Deag_Coin",	alias:"$PBX_Coin_Select",	    token:"Deagle_Toggle_Secondary");	
		}

        // Dual Wield
		if(deag.akimboMode)
		{
			PBX_AddWheel(spw, img:"DeagleEdit/LaserOff",	alias:"$PBX_RevEdit_Single",	token:"Deagle_Toggle_DualWield");
		}
		else
		{
			PBX_AddWheel(spw, img:"DeagleEdit/dualwield",	alias:"$PBX_RevEdit_Akimbo",	token:"Deagle_Toggle_DualWield");
		}
		
		// Laser
		PBX_LaserWheel(spw,"DeagleEdit",mIconScale);
	}

}