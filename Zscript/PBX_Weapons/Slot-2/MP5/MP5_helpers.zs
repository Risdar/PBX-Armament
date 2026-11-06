// Mist code and sprite from Corruption Cards
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
            TNT1 A 0 A_RadiusGive("ChaosInfighter",PBX_MP5.SMOKE_INFIGHT_RADIUS,RGF_MONSTERS,1);
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

// Infighter code from BDP
Class ChaosInfighter : CustomInventory
{
	Default
	{
		Inventory.MaxAmount 0;
		+INVENTORY.AUTOACTIVATE
	}

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

// Modified Stun greande from Project Survival
// The sprites are probably from Litdoom
// Infighting code is from Brutal Doom Platinum (drpyspy also mentioned)
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
			}
			Stop;
	}
}