Class Spas12Wheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 4; // Close Wheel (1) + Various Toggles (3)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(0.8,0.8));
		let sp12 = PBX_SPAS12(mWeap); if(!sp12) return;

        //Toggle Secondary, Placeholder icons
        if(sp12.mDualBlast)
        {
            PBX_AddWheel(spw, img:sp12.mStockIsFolded ? "SPAS-12/SP12_Fold_Zoom" : "SPAS-12/SP12_Unfold_Zoom",	    alias:"$PBX_SPAS12_ADS",	    token:"SP12_Toggle_Secondary");
        }
        else
        {
            PBX_AddWheel(spw, img:sp12.mStockIsFolded ? "SPAS-12/SP12_Fold_Blast" : "SPAS-12/SP12_Unfold_Blast",    alias:"$PBX_SPAS12_DUALFIRE",	token:"SP12_Toggle_Secondary");
        }

		// Fold/Unfold Stock
        if(sp12.mStockIsFolded)
        {
            PBX_AddWheel(spw, img:"SPAS-12/SP12_Unfold",	alias:"$PBX_SPAS12_UNFOLD_STOCK_WW",	token:"SP12_Toggle_Stock");
        }
        else
        {
            PBX_AddWheel(spw, img:"SPAS-12/SP12_Fold",	    alias:"$PBX_SPAS12_FOLD_STOCK_WW",	token:"SP12_Toggle_Stock");
        }

		// Toggle Semi
        if(sp12.mSemiAuto)
        {
            PBX_AddWheel(spw, img:"SPAS-12/SG_Slug",	alias:"$PBX_SPAS12_MANUAL_WW",	token:"SP12_Toggle_Type", scale:(0.5,0.5));
        }
        else
        {
            PBX_AddWheel(spw, img:"SPAS-12/SG_Buck",	alias:"$PBX_SPAS12_SEMI_WW",	token:"SP12_Toggle_Type", scale:(0.5,0.5));
        }
	}
}