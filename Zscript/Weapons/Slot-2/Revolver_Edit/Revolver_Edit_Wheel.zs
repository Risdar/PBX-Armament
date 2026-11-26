Class RevolverEditWheel : wheelinfocontainer
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
		let rev = PBX_RevolverEdited(mWeap); if(!rev) return;
		
		// Toggle Secondary
		if(rev.mCoinSecondary)
		{
			PBX_AddWheel(spw, img:"RevolverEdit/Rev_Zoom",	alias:"$PBX_SECONDARY_ZOOM",	token:"Revolver_Toggle_Secondary");
		}
		else
		{
			PBX_AddWheel(spw, img:"RevolverEdit/Rev_Coin",	alias:"$PBX_Coin_Select",	token:"Revolver_Toggle_Secondary");	
		}

        // Dual Wield
		if(rev.akimboMode)
		{
			PBX_AddWheel(spw, img:"RevolverEdit/LaserOff",	alias:"$PBX_RevEdit_Single",	token:"Revolver_Toggle_DualWield");
		}
		else
		{
			PBX_AddWheel(spw, img:"RevolverEdit/dualwield",	alias:"$PBX_RevEdit_Akimbo",	token:"Revolver_Toggle_DualWield");
		}
		
		// Laser
		PBX_LaserWheel(spw,"RevolverEdit",mIconScale);
	}

}