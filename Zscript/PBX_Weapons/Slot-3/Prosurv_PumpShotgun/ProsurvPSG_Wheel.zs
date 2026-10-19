Class PSGWheel : wheelinfocontainer
{
	mixin PBX_GenericSpecialWheel;

	override int GetSPCount(actor requester)
	{
		return 7; // Close Wheel (1) + Laser (1) + Tripmine (1) + Charges (3) + Detonator (1)
	}
	
	override void GetSpecials(in out array <PB_SpecialWheel_Mode> spw, actor requester)
	{
		if(!spw || !requester)
			return;

		PBX_InitializeWheel(spw,requester,scale:(0.9,0.9));

		// Laser
		PBX_LaserWheel(spw,"ProsurvPSG",laserWheelScale:(1.1,1.1));

		// Equipments and Detonator
		PBX_AddWheel(spw, img:"ProsurvPSG/Tripmine",	alias:"$PBX_PSG_TRIPMINE",		token:"PSG_Select_Tripmine",	scale:(0.8,0.8));
		PBX_AddWheel(spw, img:"ProsurvPSG/LaserCharge",	alias:"$PBX_PSG_LASERCHARGE",	token:"PSG_Select_LaserCharge");
		PBX_AddWheel(spw, img:"ProsurvPSG/AcidCharge",	alias:"$PBX_PSG_ACIDCHARGE",	token:"PSG_Select_AcidCharge");
		PBX_AddWheel(spw, img:"ProsurvPSG/SwarmCharge",	alias:"$PBX_PSG_SWARMACHARGE",	token:"PSG_Select_SwarmCharge");
		PBX_AddWheel(spw, img:"ProsurvPSG/Detonator",	alias:"$PBX_PSG_DETONATOR",		token:"PSG_Select_Detonator");

	}
}