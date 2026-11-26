// Modified Stun greande from Project Survival
// The sprites are probably from Litdoom
// Infighting code is from Brutal Doom Platinum (drpyspy also mentioned)
// Mist code and sprite are from Corruption Cards
// Box of Smoke grenades is an edited sprite of Dr_Cosmobyte's by me

////// DATA /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

// Infighter code from BDP
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
            TNT1 A 1
            {
                //Console.Printf("Chaos given to "..GetClassName());
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

////// PICKUP /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class PBX_SmokeGrenadeAmmo : PB_Ammo
{
	Default
	{
		Scale 0.4;
		Tag "$PBX_SMOKEGRENADE_TAG";
		Inventory.Amount 1;
		Inventory.MaxAmount 5;
		Inventory.PickupSound "GRNPIN";
		Inventory.Icon "STNDA0";
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 10;
	}
	
	override void PB_SetAmmoSprite()
	{
		sprite = GetSpriteIndex("STNDA0");
	}
	
	override void AttachToOwner(actor other) //we have to do this here so that cheats will give the tokens
	{
		other.GiveInventory("PBX_SmokeGrenadeToken",1);
		Super.AttachToOwner(other);
	}
}

class PBX_SmokeGrenadePack : CustomInventory
{
    Default
    {
		Scale 0.3;
        Inventory.Amount 1;
        Inventory.PickupMessage "$PBX_SMOKEGRENADE_PICKUP";
		Inventory.PickupSound "GRNPIN";
		Tag "$PBX_SMOKEGRENADE_TAG2";
        +Inventory.AlwaysPickUp;
        +FLOORCLIP;
        +DONTGIB;
    }

    States
    {
        Spawn:
            STND I -1;
            Stop; 

        Pickup:
			TNT1 A 0 {
				Array<String> tips;
				tips.Push("$PBX_Repairkit_Tip1");
				PBXCore_TipsManager.SendTipArrayIfNeeded(tips,EQUIPMENTS_HELPTEXT,PBX_TIP_SMOKEGREN);
			}
            TNT1 A 0 A_GiveInventory("PBX_SmokeGrenadeAmmo",5);
            Stop;
    }
}

////// ACTORS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class PBX_ThrownSmokeGrenade : PB_ThrownGrenade 
{
	string explosionActor;
	property ExplosionActor : explosionActor;
	
	Default 
    {
		Scale 0.6;
		BounceSound "GBOUNCE";
		
		PB_ThrownGrenade.GrenadeExplosionParams 0, 0;
		PB_ThrownGrenade.FlareActorName 'PB_GrenadeWarningFlare_Blue';
		PB_ThrownGrenade.GrenadeBeepSound "";
		PB_ThrownGrenade.FuseLength 35;
		PB_ThrownGrenade.BeepDelay 8;
		PBX_ThrownSmokeGrenade.ExplosionActor "PBX_MistBurst";
	}

	States
	{

		Spawn:
			TNT1 A 0 NoDelay A_StartSound("pbx/smoke",CHAN_AUTO,CHANF_OVERLAP);
			STND ABCDEFGH 1 A_SetRoll(roll += 15, SPF_INTERPOLATE);
			Wait;
		Death:
			STND C 1 { 
				A_SetRoll(0);
				A_Explode(1, 128, XF_EXPLICITDAMAGETYPE, true, 128, 0, 0, NULL, 'Avoid');
			}
		DeathLoop:
			STND C 1;
			Loop;

		Explode:
			TNT1 A 0 {
				if(flareActor)
                {
                    flareActor.Destroy();
                }
				A_StopSound(4);
				A_SpawnItemEx(explosionActor,0,0,1,0,0,0,0,SXF_NOCHECKPOSITION,0);
                A_RadiusGive("ChaosInfighter",ChaosInfighter.INFIGHT_RANGE,RGF_MONSTERS,1);
			}
			Stop;
	}
}

class PBX_MistBurst : Actor
{
    Default
	{
        +NOINTERACTION
        +NOTIMEFREEZE
        +NOTELEPORT;
        -FLOORCLIP;
        -SOLID
	}

	States
	{
		Spawn:
            TNT1 A 1;
            TNT1 A 1 {
                for(int i; i<20; i++)
                {
                    A_SpawnItemEx("PBX_Mist", 0, 0, 0, frandom(2, 35), 0, frandom(1, 3), random(0,360), SXF_NOCHECKPOSITION);
                }
                A_StartSound("pbx/mist",CHAN_AUTO,CHANF_OVERLAP);
            }
            TNT1 A 80;
            stop;
	}
}

class PBX_Mist : Actor
{
	Default
	{
		renderstyle "STYLE_Translucent";
		alpha 0.5;
		+ROLLSPRITE;
		scale 2.0;
		+BRIGHT;
		Translation "PBX_Mist";

        +NOINTERACTION
        +NOTIMEFREEZE
        +NOTELEPORT;
        -FLOORCLIP;
        -SOLID
	}

	bool dir;

	states
	{
		Spawn:
            TNT1 A 0;
            TNT1 A 0 {
                if(random(0,1) == 0)
                {
                    dir = true;
                }
                roll = random(0, 359.0);
            }
		Fade:
            C_F2 A 1 {
                if(GetAge() > 150)
                {
                    A_FadeOut(0.002);
                }
                A_ScaleVelocity(0.9);
            }
            loop;
	}

	override void Tick()
	{
		A_ScaleVelocity(0.95);
		A_SetRoll(dir ? roll + 0.1 : roll - 0.1);
		Actor.Tick();
	}
}