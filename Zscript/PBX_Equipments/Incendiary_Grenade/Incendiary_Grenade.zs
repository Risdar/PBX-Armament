class IncenGrenCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PB_INCENDIARYGRENADE_TAG");
		tokens.push("PB_IncendiaryGrenadeToken");
		ammotypes.push("PB_IncendiaryGrenadeAmmo");
		img.push("graphics/Equipments/Incendiary_Grenade/Equip_Incen.png");
		sx.push(0.5);
		sy.push(0.5);
	}
}

class PB_IncendiaryGrenadeToken : PBX_Equipment 
{
	Default 
    {
		Inventory.Icon "ALISTINC";
		PB_Equipment.AmmoType "PB_IncendiaryGrenadeAmmo";
		PB_Equipment.SelectString "$PB_INCENDIARYGRENADE_WHEEL";
		PB_Equipment.SelectSound "GRNPIN";
		PB_Equipment.FailString "$PB_INCENDIARYGRENADE_OUT";
		PB_Equipment.FontColor "Red";
	}
	
	States 
    {
        UseEquipment:
            ICND ABCDEFGH 1;
            TNT1 A 0 A_StartSound("OPNGRN",0);
            ICND IJKLMNOP 1;
            2RTH C 1 A_StartSound("THRGRN",0);
            2RTH D 1 {
                A_FireProjectile("PB_ThrownIncendiaryGrenade");
                EQ_TakeAmmo();
                A_FireProjectile("Alerter");
            }
            2RTH EFG 1;
            TNT1 A 0 PB_ReThrow();
            Stop;
	}
}

class PB_IncendiaryGrenadeAmmo : PB_Ammo
{
	Default
	{
		Scale 0.25;
		Tag "$PB_INCENDIARYGRENADE_TAG";
		Inventory.Amount 1;
		Inventory.MaxAmount 6;
		Inventory.PickupSound "GRNPIN";
		Inventory.Icon "IPKPA0";
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 12;
	}
	
	override void PB_SetAmmoSprite()
	{
		sprite = GetSpriteIndex("IPKP");
	}
	
	override void AttachToOwner(actor other) //we have to do this here so that cheats will give the tokens
	{
		other.GiveInventory("PB_IncendiaryGrenadeToken",1);
		Super.AttachToOwner(other);
	}
}

class PB_ThrownIncendiaryGrenade : PB_ThrownGrenade
{
	Default 
    {
		Scale 0.15;
		PB_ThrownGrenade.FlareActorName 'PB_GrenadeWarningFlare_Red';
		PB_ThrownGrenade.GrenadeBeepSound "pb/incendiary_grenade_beep";
	}

	States 
    {
        Spawn:
            IPKP A 1 NoDelay A_SetRoll(roll += 15, SPF_INTERPOLATE);
            Loop;
        Death:
            IPKP A 1 { 
                A_SetRoll(90);
                A_Explode(1, 128, XF_EXPLICITDAMAGETYPE, true, 128, 0, 0, NULL, 'Avoid');
            }
        DeathLoop:
            IPKP A 1;
            Loop;
        Explode:
            TNT1 A 0 {
                wentKaput = true;
                
                bBOUNCEONWALLS = bBOUNCEONFLOORS = bBOUNCEONCEILINGS = bALLOWBOUNCEONACTORS = bNOGRAVITY = false;
                
                if(flareActor) {
                    flareActor.Destroy();
                }
                A_Stop();
                A_StartSound("weapons/sgl/incendiary", 0);
                A_Explode(100, 100);
                A_SpawnItem("ExplosionParticleSpawner");
                A_SpawnItemEx("DetectFloorCrater");
                A_SpawnItemEx("DetectCeilCrater");
                A_SpawnItemEx("IncendiaryGrenadeFX");
                for(int i = 0; i < 3; i++) {
                    A_Spawnprojectile ("BigNeoSmoke", 2, 0, random (0, 360), 2, random (0, 360));
                }
                for(int i = 0; i < 4; i++) {
                    A_Spawnprojectile ("FireworkSFXType2", 64, 0, random (0, 360), 2, random (30, 60));
                }
                for(int i = 0; i < 5; i++) {
                    A_Spawnprojectile ("FireballExplosionFlamesBig", 6, 0, random (0, 360), 2, random (0, 360));
                    A_Spawnprojectile ("FT_GroundFireSpawner", 12, random(-32,32), random (0, 360), 2, random (40, 60));
                    A_Spawnprojectile ("FT_GroundFireSpawner", 0, random(-32,32), random (0, 360), 2, random (50, 130));
                    A_Spawnprojectile ("FT_GroundFireSpawner", 0, random(-32,32), random (0, 360), 2, random (50, 130));
                }
                for(int i = 0; i < 20; i++) {
                    A_SpawnProjectile("PB_Shrapnel", 0, 0, random (0, 360), 2, random (-90, 90));
                }
            }
            Stop;
	}
}
