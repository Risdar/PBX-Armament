// Chaos Field Grenade 
// from Brutal Doom Platinum
// by EmeraldCoasttt and the BDP Team
// Infighting code is from Brutal Doom Platinum (drpyspy also mentioned)

////// DATA /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ChaosGrenadeCard : equipmentCard
{
	override void InfoFiller(out array<string> tags,out array<string> tokens,out array<string> ammotypes,out array<string>img,out array<double>sx,out array<double>sy)
	{
		tags.push("$PBX_CHAOSGREN_TAG");
		tokens.push("PBX_ChaosGrenadeToken");
		ammotypes.push("PBX_ChaosGrenadeAmmo");
		img.push("graphics/Equipments/ChaosGrenade/ChaosGrenadeIcon.png");
		sx.push(0.5);
		sy.push(0.5);
	}
}

class PBX_ChaosGrenadeToken : PBX_Equipment 
{
	Default 
    {
		Inventory.Icon "CHSGREIC";
		PB_Equipment.AmmoType "PBX_ChaosGrenadeAmmo";
		PB_Equipment.SelectString "$PBX_CHAOSGREN_WHEEL";
		PB_Equipment.SelectSound "GRNPIN";
		PB_Equipment.FailString "$PBX_CHAOSGREN_OUT";
		PB_Equipment.FontColor "Purple";
	}

	States 
    {
        UseEquipment:
            4RTH EFGH 1;
            SYRI A 0 A_StartSound("GRNPIN",CHAN_AUTO);
            4RTH IJKLMN 1;
            TNT1 A 2;
            // TNT1 A 0 A_StartSound("CS16uwu");
            TNT1 A 0 A_Jump(2,2);
            TNT1 A 0 A_StartSound("GRNTOSS");
            GRTH OP 1;
            GRTH Q 1 {
                A_FireProjectile("StupidGrenade");
                EQ_TakeAmmo();
            }
            GRTH RSTU 1;
		    TNT1 A 0 PB_ReThrow();
            Stop;

	}
}

////// PICKUP /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class PBX_ChaosGrenadeAmmo : PB_Ammo
{
	Default
	{
        Scale 0.25;
		Tag "$PBX_CHAOSGREN_TAG";
		Inventory.Amount 1;
		Inventory.MaxAmount 3;
		Inventory.PickupSound "GRNPIN";
		Inventory.Icon "IPKPB0";
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 5;
	}
	
	override void PB_SetAmmoSprite()
	{
		sprite = GetSpriteIndex("GRND");
        frame = 2;
	}
	
	override void AttachToOwner(actor other) //we have to do this here so that cheats will give the tokens
	{
        Array<String> tips;
        tips.Push("$PBX_CHAOSGREN_TIP");
        PBX_Handler.SendTipArrayIfNeeded(tips,EQUIPMENTS_HELPTEXT,PBX_TIP_CHAOSGREN);
		other.GiveInventory("PBX_ChaosGrenadeToken",1);
		Super.AttachToOwner(other);
	}
}

////// ACTORS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Class ChaosInfighter : CustomInventory
{
	Default
	{
		Inventory.MaxAmount 0;
		+INVENTORY.AUTOACTIVATE
	}

    const INFIGHT_RANGE = 512;

	States
	{
		Use:
            TNT1 A 0;
            TNT1 A 1 {
                // Console.Printf("Chaos given to "..GetClassName());
                bool isNotPlayer = !(target is "PBXCore_Player");
                if(target && isNotPlayer)
                {
                    // Console.Printf(GetClassName().." already has a target, whomst is "..target.GetClassName());
                    return;
                }
                else
                {
                    // Console.Printf("Lets look...");
                    ThinkerIterator MonsterFinder = ThinkerIterator.Create("Actor");
                    Actor mo;
                    while (mo = Actor(MonsterFinder.Next()))
                    {
                        if(mo != self && mo.health > 0 && mo.bIsMonster && CheckSight(mo))
                        {
                            if((target && isNotPlayer) && Distance3D(mo) < Distance3D(target))
                            {
                                target=mo;
                            }
                            else if(!target||!isNotPlayer)
                            {
                                target=mo;
                            }
                        }
                    }
                }
                
            }
            Stop;
	}
}

class StupidGrenade : PB_ThrownGrenade
{
	Default
	{
		Scale 0.15;
		PB_ThrownGrenade.FlareActorName 'PBX_GrenadeWarningFlare_Purple';
		PB_ThrownGrenade.GrenadeBeepSound "pb/incendiary_grenade_beep";
	}

	States
	{
        Spawn:
            IPKP B 1 A_SetRoll(roll + 22.5);
            Loop;
        Death:
            IPKP B 16 A_SetRoll(0);
        Explode:
            TNT1 A 0 A_startsound("STUPGREN");
            TNT1 A 0 {
                wentKaput = true;
                
                bBOUNCEONWALLS = bBOUNCEONFLOORS = bBOUNCEONCEILINGS = bALLOWBOUNCEONACTORS = bNOGRAVITY = false;
                
                if(flareActor) {
                    flareActor.Destroy();
                }

                A_Stop();
                A_StartSound("weapons/sgl/incendiary", 0);
                A_Explode(100, 100);
                A_SpawnItem("WhiteShockWave",0,0,0);
                A_CustomMissile ("BFGDeathParticleSuperFast", 0, 0, random (0, 360), 2, random (0, 360));
                A_CustomMissile ("BFGDeathParticleFast", 0, 0, random (0, 360), 2, random (0, 360));
                A_CustomMissile ("BFGBIGFOG", 0, 0, random (0, 360), 2, random (0, 360));
                A_SpawnItemEx("DetectFloorCrater");
                A_SpawnItemEx("DetectCeilCrater");
                for(int i = 0; i < 20; i++) {
                    A_SpawnProjectile("PB_Shrapnel", 0, 0, random (0, 360), 2, random (-90, 90));
                }

                A_RadiusGive("ChaosInfighter",356,RGF_MONSTERS,1);
            }
            Stop;
    }
}

class PBX_GrenadeWarningFlare_Purple : PB_GrenadeWarningFlare_Green
{
	States
	{
		Spawn:
			LENP B 1 bright;
			Loop;
	}
}

Class ChaosParticles : Inventory
{
	int mDur;
	int mDuration;

	Default 
	{
		+INVENTORY.UNDROPPABLE;
		+INVENTORY.UNTOSSABLE;
		inventory.maxamount 1;
	}

	Override void postbeginplay()
    {
        mDuration = 35;
    }

	Override void Tick() {}

	Override void DoEffect() 
	{
		super.DoEffect();
		float rdepth, rwidth, rheight;
        rdepth = frandom(-1,1);
        rwidth = frandom(-1,1);
        rheight = frandom(0.01,0.70);
			
        If (owner)
        {
            owner.A_SpawnItemEx(
                "PlasmaParticle",
                xofs:(owner.radius*rdepth),
                yofs:(owner.radius*rdepth),
                zofs:(owner.height*rheight),
                xvel:(random(-1,1)),
                yvel:(random(-1,1)),
                zvel:(random(3,5))
            );
        }
        if (mDur < mDuration)
        {
            mDur++;
        }
        else 
        {
            DepleteOrDestroy();
            return;
        }
	}
}
