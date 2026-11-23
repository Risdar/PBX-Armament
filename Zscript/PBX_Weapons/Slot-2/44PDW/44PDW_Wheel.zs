Class PDWWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;
	
	override int GetSPCount(actor requester)
	{
		return 5; // Close Wheel (1) + Fire Modes (3) + Laser Sight (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;
			
		PBX_InitializeWheel(spw,requester,scale:(1.2,1.2));

		// FireModes
		PBX_AddWheel(spw,     img:"44PDW/SingleAction",	  alias:"$PBX_44PDW_Single_WW", token:"PDW_Select_Single");
		PBX_AddWheel(spw,     img:"44PDW/DoubleAction",	  alias:"$PBX_44PDW_Double_WW", token:"PDW_Select_Double");
		PBX_AddWheel(spw,     img:"44PDW/TripleAction",	  alias:"$PBX_44PDW_Triple_WW", token:"PDW_Select_Triple");
		PBX_AddWheel(spw,     img:"44PDW/QuadAction",	  alias:"$PBX_44PDW_Quad_WW", 	token:"PDW_Select_Quad");

		// Laser
		PBX_LaserWheel(spw,"44PDW",(0.8,0.8));
	}
}