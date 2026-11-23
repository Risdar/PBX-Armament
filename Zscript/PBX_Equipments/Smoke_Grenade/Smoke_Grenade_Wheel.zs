class SmokeGrenCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PBX_SMOKEGRENADE_TAG");
		tokens.push("PBX_SmokeGrenadeToken");
		ammotypes.push("PBX_SmokeGrenadeAmmo");
		img.push("graphics/Equipments/Smoke_Grenade/Equip_Smoke.png");
		sx.push(1.0);
		sy.push(1.0);
	}
}

class PBX_SmokeGrenadeToken : PBX_Equipment 
{
	Default 
    {
		Inventory.Icon "SMKGRICO";
		PB_Equipment.AmmoType "PBX_SmokeGrenadeAmmo";
		PB_Equipment.SelectString "$PBX_SMOKEGRENADE_WHEEL";
		PB_Equipment.SelectSound "GRNPIN";
		PB_Equipment.FailString "$PBX_SMOKEGRENADE_OUT";
		PB_Equipment.FontColor "Gray";
	}
	
	States 
    {
        UseEquipment:
            STGR MLKJIH 1 A_SetRoll(roll+0.5);
            TNT1 A 0 A_StartSound("OPNGRN",CHAN_AUTO,CHANF_OVERLAP);
            STGR GFE 1 A_SetRoll(roll+0.5);
            STGR DCB 1;
            TNT1 A 1 A_SetRoll(roll-18.0);
			HND1 I 1 A_StartSound("THRGRN",CHAN_AUTO,CHANF_OVERLAP);
			HND1 J 1;
            TNT1 A 0 {
				A_FireProjectile("PBX_ThrownSmokeGrenade",0,0,0,0,0,0);
				EQ_TakeAmmo();
				A_FireProjectile("Alerter",0,0,0,0,0,0);
			}
			HND1 KLMNOPQ 1 A_SetRoll(roll-5.0);
            TNT1 A 0 PB_ReThrow();
            Stop;
	}
}