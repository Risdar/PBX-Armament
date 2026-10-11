//////////////////////////// TESLA GUN ////////////////////////////////////////////////////////////////////////////////////
class Tesla_LightningBall : PB_ProjectileAlt
{
    mixin PBX_LightningProjectile;

    Default
    {
        Radius 50;
        // Height 40;
        Speed 10;
        Translation "112:127=192:207", "224:231=80:87";
        DamageType "Plasma";
		PB_Projectile.BaseDamage PBX_TeslaGun.LIGHTBALL_DAMAGE;
		+PB_PROJECTILE.NOCRITICALS
        // Projectile;
        Decal "SmallerScorch";
        BounceType "Doom";
        BounceFactor 0.5;
        BounceSound "electrogun/hit";
        Species "Marines";
        Gravity 0;
        Scale 1;
        renderstyle "ADD";
        alpha 1.0;
        +NODAMAGE;
        // +INVULNERABLE;
        +MISSILE; +FRIENDLY;
        +THRUSPECIES; +MTHRUSPECIES;
        +FORCEXYBILLBOARD;
        -ALLOWBOUNCEONACTORS;
        -BOUNCEONFLOORS;
        +BLOODLESSIMPACT; +EXPLODEONWATER; +SKYEXPLODE;
        -NOBLOCKMAP; +SHOOTABLE;
        Tesla_LightningBall.DetectRange 320;
        Tesla_LightningBall.MaxVictims 20;
		Tesla_LightningBall.SplitRange 120;
		Tesla_LightningBall.Damage PBX_TeslaGun.LIGHTBALL_LIGHTNING_DAMAGE;
		Tesla_LightningBall.Duration 1;
		Tesla_LightningBall.Delay 0;
		Tesla_LightningBall.maxChains 10;
		Tesla_LightningBall.MaxLinks 0;
		Tesla_LightningBall.DamageType 'Plasma';
    }

    int mLightningCharge;
    int mLifetime;

    void increaseCharge()
    {
        mLightningCharge++;
    }

    void changeShade()
    {
        double nCharge = clamp(double(mLightningCharge / PBX_TeslaGun.LIGHTBALL_MAXCHARGE), 0.0, 1.0);
        int red = int(round(255 * nCharge));
        SetShade(color(red, 0, 0));
    }
    
    override void PostBeginPlay()
    {
        super.PostBeginPlay();
        mLifetime = PBX_TeslaGun.LIGHTBALL_LIFETIME;
    }

    override void Tick()
	{
		if (isFrozen() || level.isFrozen()) return;
        // changeShade(); // I'll just disable it for now

        if(mLightningCharge > 0)
        {
            L_ProjTick();
            pbxcore_debug.printInt("Detonate Amount %d",mLightningCharge);            
            if(mLightningCharge >= PBX_TeslaGun.LIGHTBALL_MAXCHARGE)
            {
                mLightningCharge = 0;
                SetStateLabel("SummonLightning");
                return;
            }
        }
		Super.Tick();

        pbxcore_debug.printInt("Lightball Lifetime %d",mLifetime);            
	}

    void A_SummonLightning(
        int damage = 200, 
        double radius = 512, 
        int duration = 1, 
        int delay = 0, 
        int maxChains = 1, 
        int maxlinks = 5, 
        name ac_damageType = 'Stun'
    )
    {
        Actor damageSource = self.target;
        Vector3 origin = PBX_LightningController.L_GetBeamAttachPos(self);

        Array<Actor> victims;
        PBX_LightningController.L_AddValidVictimsToArr(damageSource, self, victims, radius);

        foreach (v : victims)
        {
            pbxcore_debug.print("Lightning Spawned");            
            PBX_LightningController.L_StartChain(damageSource, v, damage, radius, duration, delay, maxChains, maxlinks, damageType:ac_damageType);
            PBX_LightningController.L_DrawLightning(origin, PBX_LightningController.L_GetBeamAttachPos(v));
            v.damagemobj(self,self.target,2,'stun');
            Spawn("LightningBolt", v.pos);
        }
        S_StartSound("Thunder",0);
    }

	States
	{
        Spawn:
            0DB0 A 1 NoDelay BRIGHT {
				A_Startsound("CacoBallLoop", CHAN_BODY , CHANF_LOOP, 1);
			}
        Fly:
            0DB0 BCDEFA 2 BRIGHT {
                A_SpawnProjectile("RailGunTrailSpark", 0, 0, random(0, 360), CMF_AIMDIRECTION|CMF_ABSOLUTEPITCH|CMF_OFFSETPITCH|CMF_BADPITCH|CMF_SAVEPITCH, random(0, 360));
                A_SpawnItemEx("ElectroBlastTrail",random(5,-5),random(5,-5));
            }
            TNT1 A 0 {
                mLifetime--;
                if(mLifetime < 1)
                    return resolvestate("Death");
                return resolvestate(null);
            }
            Loop;

        SummonLightning:
            TNT1 A 0 A_SummonLightning();
        Death:
            TNT1 A 0 {
				A_StopSound(CHAN_BODY);
				A_Startsound("CacoBallImpact", CHAN_AUTO);
				A_SpawnItem ("Plasma_Puff", 0);
				A_SpawnProjectile("BluePlasmaFire", 0, 0, random (0, 360), 2, random (0, 360));
			}
            TNT1 A 0 A_SetScale(1.5, 1.5);
            TNT1 A 0 A_PlaySound("electrogun/explode");
            BFSK ABCD 1 Bright;
            EXPL AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("BFGBlueBIGFOG", 0, 0, random (0, 360), 2, random (0, 360));
            EXPL AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("BFGBlueBIGFOG", 0, 0, random (0, 360), 2, random (0, 360));
            EXPL AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("BFGBlueSuperParticle", 0, 0, random (0, 360), 2, random (0, 360));
            EXPL AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("BFGBlueSuperParticle", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 A 0 Radius_Quake (5, 10, 0, 10, 0);
            TNT1 A 0 Bright A_SpawnItem ("LightningFog", 0,0);
            TNT1 A 0 A_PlaySoundEx("thunder/hit", "Voice", 0, 2);
            TNT1 AAAAA 0 A_CustomMissile ("BluePlasmaParticle", 0, 0, random (0, 360), 2, random (0, 360));
            EXPL AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_CustomMissile ("BigElectroBlastTrailX", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 A 0 A_SpawnItem("WhiteShockWaveSmall");
            TNT1 A 0 A_SpawnItem("TPortLightningWaveSpawner");
            TNT1 AAAAA 0;
            BFSK EFGH 1 Bright;
            TNT1 AAAAA 0 A_CustomMissile ("BigElectroBlastTrailX", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AAAAA 0;
            TNT1 A 1 A_Spawnitem("BlueFlare");
            TNTT AAAAAAA 1 A_CustomMissile ("BigElectroBlastTrailX", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AAAAA 0;
            TNTT AAAAA 0 A_CustomMissile ("BigElectroBlastTrailX", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AAAAA 1;
            TNTT AAA 0 A_CustomMissile ("BigElectroBlastTrailX", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AAAAAA 0;
            TNTT AAA 0 A_CustomMissile ("BigElectroBlastTrailX", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AAAAAAAAA 1;
            TNTT AAA 0 A_CustomMissile ("BigElectroBlastTrailX", 0, 0, random (0, 360), 2, random (0, 360));
            TNT1 AAAAAAAAA 1;
            EXPL AAA 0 A_SpawnProjectile ("PlasmaSmoke", 1, 0, random (0, 360), 2, random (0, 360));
            Stop;
	}
}

class BigElectroBlastTrailX : actor
{
    Default
    {
        +VISIBILITYPULSE;
        Radius 0;
        Height 0;
        +NOGRAVITY;
        +NOINTERACTION;
        Speed 0;
        +RANDOMIZE;
        +DontSplash;
        +THRUACTORS;
        +NOBLOOD;
        RenderStyle "Add";
        Scale 1.0;
    }

    States
    {
        Spawn:
            TNT1 A 0;
            TNT1 A 0 A_Jump (256, "Spawn2", "Spawn3", "Spawn4", "Spawn5", "Spawn6", "Spawn7", "Spawn8", "Spawn9", "Spawn10");
            DLI6 ABCDEFGHIJK 1 bright;
            Stop;
        Spawn2:
            TNT1 A 0;
            DLI7 ABCDEFGHIJK 1 bright;
            Stop;
        Spawn2:
            TNT1 A 0;
            DLI8 ABCDEFGHIJK 1 bright;
            Stop;
        Spawn3:
            TNT1 A 0;
            DLI9 ABCDEFGHIJK 1 bright;
            Stop;
        Spawn4:
            TNT1 A 0;
            DLI0 ABCDEFGHIJK 1 bright;
            Stop;
        Spawn5:
            TNT1 A 0;
            DLI6 ABCDEFGHIJK 1 bright;
            Stop;
        Spawn6:
            TNT1 A 0;
            DLI7 LMNOPQRSTUV 1 bright;
            Stop;
        Spawn7:
            TNT1 A 0;
            DLI8 LMNOPQRSTUV 1 bright;
            Stop;
        Spawn8:
            TNT1 A 0;
            DLI9 LMNOPQRSTUV 1 bright;
            Stop;
        Spawn9:
            TNT1 A 0;
            DLI0 LMNOPQRSTUV 1 bright;
            Stop;
        Spawn10:
            TNT1 A 0;
            DLI0 ABCDEFGHIJK 1 bright;
            Stop;
    }
}

class LightningFog : actor
{
    Default
    {
        Radius 1;
        Height 1;
        Alpha 0.9;
        RenderStyle "Add";
        Scale 1;
        Speed 8;
        Gravity 0;
        +NOBLOCKMAP
        +NOTELEPORT
        +DONTSPLASH
        +MISSILE
        +FORCEXYBILLBOARD
        +CLIENTSIDEONLY
    }
    States
    {
        Spawn:
            PFOG ABCDEF 2 BRIGHT A_SpawnItem("BlueFlare",0,0);
        Death:
            PFOG G 2 BRIGHT A_SpawnItem("BlueFlare",0,0);
            Stop;
    }
}

class BFGBlueBIGFOG : actor
{
    Default
    {
        Radius 1;
        Height 1;
        Alpha 0.7;
        RenderStyle "Add";
        Scale 0.6;
        Speed 4;
        Gravity 0;
        +NOBLOCKMAP
        +NOTELEPORT
        +DONTSPLASH
        +MISSILE
        +FORCEXYBILLBOARD
        +CLIENTSIDEONLY
    }

    States
    {
        Spawn:
            PFOG ABCDEF 6 BRIGHT A_SpawnItem("BlueFlareMedium",0,0);
            Stop;
    }
}

class BFGBlueSuperParticle : actor
{
    Default
    {
        Height 0;
        Radius 0;
        Mass 0;
        RenderStyle "Add";
        Scale 0.04;
        Speed 24;
        +Missile
        +NoBlockMap
        +NOGRAVITY
        +DontSplash
        +FORCEXYBILLBOARD
    }

    States
    {
        Spawn:
        Death:
            SPKB A 2 Bright A_FadeOut(0.02);
            Loop;
    }
}

class TPortLightning : actor
{
    Default
    {
        RenderStyle "Add";
        Alpha 0.7;
    }

    States
	{
        Spawn:
            TNT1 A 0; // Huh, that's the jump...
            TNT1 A 0 A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72);
        Select:
            BLL1 ABCDEFGHIJKLMNOPQR 0 A_Jump(256,"Fade");
            BLL2 ABCDEFGHIJKLMNOPQR 0 A_Jump(256,"Fade");
            BLL3 ABCDEFGHIJKLMNOPQR 0 A_Jump(256,"Fade");
            BLL4 ABCDEFGHIJKLMNOPQR 0 A_Jump(256,"Fade");
        Fade:
            "----" A 1 bright A_FadeOut(0.15);
            loop;
	}
}

// A wave of lightning
class TPortLightningWave : actor
{
	States
	{
        Spawn:
            TNT1 A 0 NoDelay {
                static const int    ofs[]        = { 2, 3, 4, 5 };
                static const int    spawnAngle[] = { 32, 56, 96, 144 };
                static const double scale[]      = { 0.2, 0.3, 0.4, 0.5 };

                for (int i = 0; i < 4; i++)
                {
                    let [spawned, actor] = A_SpawnItemEx("TPortLightning",
                        Random[sfx](-ofs[i], ofs[i]),
                        Random[sfx](-ofs[i], ofs[i]),
                        Random[sfx](-ofs[i], ofs[i]),
                        0, 0, 0, 0, 0, spawnAngle[i]);

                    if (actor)
                        actor.scale = (scale[i], scale[i]);
                }
            }
            Stop;
	}
}

// Spawns lightning waves
class TPortLightningWaveSpawner : actor
{
    Default
    {
        +CLIENTSIDEONLY
        +NOINTERACTION
        +NOBLOCKMAP
        +NOGRAVITY
        +NOTELEPORT
        +FORCEXYBILLBOARD
    }

	States
	{
        Spawn:
            TNT1 A 0;
            TNT1 A 0 A_PlaySound("TPortalZap");
            TNT1 A 1 Light("TPortZap") A_SpawnItem("TPortLightningWave");
            TNT1 A 1 Light("TPortZap") A_SpawnItem("TPortLightningWave");
            TNT1 A 2 Light("TPortZap") A_SpawnItem("TPortLightningWave");
            TNT1 A 1 Light("TPortZap") A_SpawnItem("TPortLightningWave");
            TNT1 A 1 Light("TPortZap") A_SpawnItem("TPortLightningWave");
            TNT1 A 1 Light("TPortZap") A_SpawnItem("TPortLightningWave");
            TNT1 A 2 A_SpawnItem("TPortLightningWave");
            stop;
	}
}