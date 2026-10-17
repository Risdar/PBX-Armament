// Tesla Gun 
// From Schism by Lord_Lothar and the Schism Team
// Base Sprites is by IAmCarrotMaster
// Hands is from Brutal Doom by Sergeant_Mark_IV (need to know who actually made the hand sprites)
// Animations by ikdfa
// New pickup sprites by agus4578

// Includes
// #include "./PlasmaBlaster_Functions.zs"

// class Detonate_Lightning_Ball : inventory {default{inventory.maxamount PBX_TeslaGun.LIGHTBALL_CHARGE;}}

// Actual Weapon
class PBX_TeslaGun : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.AltHUDIcon "ETROA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Cell";
        Weapon.AmmoType2 "TeslaAmmo";
        Weapon.AmmoGive1 50;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_TeslaGun_Pickup";
        Inventory.PickupSound "PLSDRAW";
        Obituary "$OB_WEAP_TESLAGUN";
        AttackSound "None";
        Tag "$PBX_TeslaGun_Tag";
        Scale 1.0;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    int mTeslaCancelAnimation; // Used for the cancel animation since its just a loop
    int mTeslaAltFireAnimation; // Used for the altfire animation

    const CELL_SIZE = 100;
    const ARCFIRE_DAMAGE = 15;

    const ALTFIRE_AMMOTAKE = 25;
    const DECHARGE_GIVE = 5; // MAKE SURE THIS VALUE CAN CLEANLY DIVIDE ALTFIRE_AMMOTAKE
    const DECHARGE_LOOP = ALTFIRE_AMMOTAKE/DECHARGE_GIVE;

    const LIGHTNING_SPECIAL_NAME = "Tesla_LightningCharge";
    const LIGHTNING_SPECIAL_MAXCHARGE = 100;
    const LIGHTNING_SPECIAL_MINIMUM = 50; // How many charges it'll take

    const LIGHTNING_RANGE = 716; // How long is the normal fire length
    const LIGHTBALL_DAMAGE = 200; // How much damage does the lightball do per bounce
    const LIGHTBALL_LIGHTNING_DAMAGE = 20; // How much damage does the lightball do per arc
    const LIGHTBALL_MAXCHARGE = 20; // How much charges does the lightball need before summoning lightning
    const LIGHTBALL_LIFETIME = 10; // How long should the lightball stay in flight
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////

    action void Tesla_ChargeLightningBall()
    {
        FLineTraceData traceData;
        double pz = height * 0.5 - floorclip + player.mo.AttackZOffset * player.crouchFactor;
        bool hit = LineTrace(Angle, LIGHTNING_RANGE, Pitch, 0, offsetz: pz, data: traceData);
        
        if(hit && traceData.HitActor && traceData.HitActor is "Tesla_LightningBall")
        {
            let lightball = Tesla_LightningBall(traceData.HitActor);
            if(lightball)
            {
                lightball.increaseCharge();
            }
        }
    }

    action void Tesla_FireLightningBall()
    {
        A_ZoomFactor(1.0);
        A_FireCustomMissile("ElectroBlastTrail2", 0, 0, 0, 0);
        // A_StartSound("TESLAH", CHAN_WEAPON, CHANF_LOOPING, starttime: frandom[sfx](0, 0.5));
        A_StartSound("PLSULT", CHAN_WEAPON);
        A_FireCustomMissile("Tesla_LightningBall",0,0,0,0);
        A_FlashOverlay();
        A_GiveInventory(LIGHTNING_SPECIAL_NAME,LIGHTNING_SPECIAL_MINIMUM);
        // Effects
        A_SetBlend("Blue", 0.6, 12);
        EventHandler.SendInterfaceEvent(PlayerNumber(), "PB_HUDInterference", 20);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
    }

    action state Tesla_LightningSpecial()
    {
        if(CountInv(LIGHTNING_SPECIAL_NAME) < LIGHTNING_SPECIAL_MINIMUM)
        {
            A_Print(String.Format(StringTable.Localize("$PBX_TeslaGun_NoLightningCharge"),LIGHTNING_SPECIAL_MINIMUM));
            return ResolveState("Ready3");
        }
        return ResolveState(null);
    }

    action void PBX_FireLightningStorm(
        int damage = 100, 
        int numrays = 32, 
        double coneAngle = 90, 
        double distance = 1024, 
        double vrange = 0, 
        int duration = 5, 
        int delay = 0, 
        int maxChains = 1, 
        int maxlinks = 5,
        name damageType = 'plasma'
    )
    {
        Vector3 beamstart = PBX_LightningController.L_GetBeamAttachPos(self);
        Array<Actor> alreadyChained;

        for (int i = 0; i < numrays; i++)
        {
            double an = angle - coneAngle * 0.5 + (numrays > 1 ? coneAngle / (numrays - 1) * i : 0);

            FTranslatedLineTarget t;
            AimLineAttack(an, distance, t, vrange);

            Vector3 beamEnd;
            if (t.linetarget && PBX_LightningController.L_IsValidVictim(t.linetarget, self))
            {
                beamEnd = PBX_LightningController.L_GetBeamAttachPos(t.linetarget);

                if (alreadyChained.Find(t.linetarget) == alreadyChained.Size())
                {
                    PBX_LightningController.L_StartChain(self, t.linetarget, damage, distance, duration, delay, maxChains, maxlinks, damageType:damageType);
                    Spawn("LightningBolt", t.linetarget.pos);
                    S_StartSound("Thunder",0);
                    alreadyChained.Push(t.linetarget);
                }
            }
            else
            {
                beamEnd = beamstart + (cos(an), sin(an), 0) * distance;
            }

            PBX_LightningController.L_DrawLightning(beamstart, beamEnd, spawnSpark: (t.linetarget != null), playersource: player);
        }
        A_TakeInventory(LIGHTNING_SPECIAL_NAME,LIGHTNING_SPECIAL_MINIMUM);
        // Effects
        A_SetBlend("Blue", 0.6, 12);
        EventHandler.SendInterfaceEvent(PlayerNumber(), "PB_HUDInterference", 20);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
        A_FireProjectile("GunFireSmokeBig", 0, 0, 0, 0, 0, 0);
    }

    action void Tesla_ArcFire()
    {
        A_SetWeaponFrame(random[sfx](4,7));
        A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
        A_FireProjectile("BlueFlareSpawn",0,0,0,0);
        A_FireCustomMissile("PlasmaFlareSpawner", 0, 0, 0,spawnheight:-5);
        A_StartSound("TESLAH2", CHAN_WEAPON, CHANF_LOOPING);
        PBX_FireLightningGun(ARCFIRE_DAMAGE, spawnheight:-10, range:LIGHTNING_RANGE, duration:1, delay:0, maxChains:1, maxlinks:5);
        PB_TakeAmmo(invoker.ammotype2,emptyMag:0);
        A_WeaponOffset(frandom[sfx](-0.5, 0.5), WEAPONTOP + frandom(0, 0.75), WOF_INTERPOLATE);
        A_FlashOverlay();
        Tesla_ChargeLightningBall();
        A_GiveInventory(LIGHTNING_SPECIAL_NAME,1);
    }
 
    action state Tesla_CheckDecharge()
    {
        A_FireCustomMissile("PlasmaFlareSpawner",0,0,0,0);
        A_FireProjectile("BlueFlareSpawn",0,0,0,0);
        A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-2,2), -15, 0, random(-2,2));
        A_FlashOverlay();
        if(JustPressed(BT_RELOAD))
            return resolvestate("DeCharge");
        return resolvestate(null);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            ETRO A -1;
            Stop;

        WeaponRespect:
            ETRG A 1 offset(-20, 46) A_DoPBWeaponAction();
			ETRG A 1 offset(-12, 42) A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("weapons/plasma/startup", 16,CHANF_OVERLAP);
			ETRG A 1 offset(-4, 38) A_DoPBWeaponAction();
			ETRG AAAAAAAAAAAAAA 1 A_DoPBWeaponAction();
            ET1R ABC 2 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("PLSCOOL",CHAN_WEAPON);
			ETRR K 15 A_DoPBWeaponAction();
            TNT1 A 0 {
                A_FireProjectile("PlasmaFlareSpawner",0,0,-15,3);
				A_FireProjectile("BlueFlareSpawn",0,0,-15,5);
                A_StartSound("BEPBEP",CHAN_WEAPON);
                return A_DoPBWeaponAction();
            }
            TNT1 A 0 A_StartSound("weapons/plasma/cellin",17,CHANF_OVERLAP);
			ETRR LMNOP 2 A_DoPBWeaponAction();
            TNT1 A 0 {
                A_StartSound("PLSCOOL",CHAN_WEAPON,CHANF_OVERLAP);
                // A_FireProjectile("BluePlasmaParticle",random(340,350),0,6,0,0,-random(7,18));
                A_FireProjectile("SmokeSpawner",0,0,0,5);
                return A_DoPBWeaponAction();
            }
			ETRR EDCBA 2 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("ULTCHAR",CHAN_WEAPON,CHANF_OVERLAP);
            Goto Ready3;

        WeaponInspect:
            TNT1 A 0 A_StartSound("BEP", 16,CHANF_OVERLAP);
            ETRR AABBCCDD 1 A_DoPBWeaponAction();
            ETRR EEEEEEEEE 1 A_DoPBWeaponAction();
        HoldInspect:
            ETRR E 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            TNT1 A 0 {
                A_StartSound("PLSCOOL",CHAN_WEAPON,CHANF_OVERLAP);
                // A_FireProjectile("PlasmaFlareSpawner",0,0,-15,3);
                A_FireProjectile("SmokeSpawner",0,0,0,5);
                return A_DoPBWeaponAction();
            }
			ETRR EDCBA 2 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("BEPBEP", 16,CHANF_OVERLAP);
            Goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
			ETRG A 1 offset(-4,38);
			ETRG A 1 offset(-12,42);
			ETRG A 1 offset(-20,46);
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(18);
                PBX_WeaponRaise("PLSDRAW");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            ETRG A 1 offset(-20, 46);
			ETRG A 1 offset(-12, 42);
			ETRG A 1 offset(-4, 38);
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 PBX_CheckInspect();
			ETRG A 1 {
                PB_HandleCrosshair(18);
                return A_DoPBWeaponAction();
            }
            loop;

        CoolDown:
            ETRG ABCDEF 1;
            TNT1 A 0 A_StartSound("BEPBEP",CHAN_WEAPON,CHANF_OVERLAP);
            ETRG G 15 {
                A_StartSound("PLSCOOL",CHAN_VOICE);
                A_FireProjectile("PlasmaFlareSpawner",0,0,10,5);
				A_FireProjectile("BlueFlareSpawn",0,0,10,5);
                A_FireProjectile("BluePlasmaParticle",random(340,350),0,6,0,0,-random(7,18));
                A_FireProjectile("SmokeSpawner",0,0,0,5);
            }
            ETRG EDCBA 1;
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			Goto Ready3;

        Decharge:
			PLSN A 0 A_StopSound(6);
            PLSN A 0 A_StartSound("PLSDEARG",1);
            PLSN A 0 {invoker.mTeslaCancelAnimation = 0;}
        DechargeLoop:
            ETRF A 1 BRIGHT A_FireCustomMissile("PlasmaFlareSpawner",0,0,0,0);
            ETRF B 1 BRIGHT A_GiveInventory(invoker.ammotype2,DECHARGE_GIVE);
            ETRF C 1 BRIGHT A_FireCustomMissile("PlasmaFlareSpawner",0,0,0,0);
            ETRF D 1 BRIGHT {
                invoker.mTeslaCancelAnimation++;
                if (invoker.mTeslaCancelAnimation == Int(DECHARGE_LOOP/2))
                    A_StartSound("PLSCOOL",CHAN_VOICE);
                if (invoker.mTeslaCancelAnimation < DECHARGE_LOOP) // Loop this until all the taken ammo is given
                    return ResolveState("DechargeLoop");
                return ResolveState(null);
            }
            PLSN A 0 A_PlaySound("BEPBEP", 5, 1.2);
            PLSN A 0 A_ClearReFire();
			Goto Ready3;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 PB_jumpIfNoAmmo(chamber:false,emptysound:"BEP");
			TNT1 A 0 A_StartSound("ULTCHAR",CHAN_WEAPON,CHANF_OVERLAP);
			ETRF ABCB 1 BRIGHT A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
			ETRF CBE 1 BRIGHT A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
			ETRF BD 1 BRIGHT A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
		Hold:
            TNT1 A 0 PB_jumpIfNoAmmo(chamber:false,emptysound:"BEP");
			ETRF D 1 BRIGHT;
            ETRF F 1 BRIGHT Tesla_ArcFire();
			ETRF A 1 BRIGHT PB_ReFire();
			ETRF BC 1 BRIGHT A_StartSound("LGEnd1",CHAN_WEAPON);
			ETRF ABCB 1 BRIGHT A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-5,5), -15, 0, random(-2,2));
			Goto CoolDown;

//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 PB_jumpIfNoAmmo(min:ALTFIRE_AMMOTAKE,chamber:false,emptysound:"BEP");
			TNT1 A 0 {
                PB_HandleCrosshair(90);
			    A_StartSound("ULTCHAR",CHAN_AUTO,CHANF_OVERLAP);
                invoker.mTeslaAltFireAnimation = 0;
            }
        AltFireAnimation:
			ETRF A 1 BRIGHT {
                frame = random[sfx](0,7);
				A_StartSound("PLSC_1",CHAN_AUTO,CHANF_OVERLAP);
                A_FireProjectile("RailGunTrailSpark_Fast", random(-2,2), 0, random(-2,2), -15, 0, random(-2,2));
                A_FireCustomMissile("PlasmaFlareSpawner",0,0,0,0);
                PB_TakeAmmo(invoker.ammotype2,takeNum:DECHARGE_GIVE,emptyMag:0);
                invoker.mTeslaAltFireAnimation++;
                
                if(invoker.mTeslaAltFireAnimation < DECHARGE_LOOP)
                    return resolvestate("AltFireAnimation");
                return resolvestate(null);
            }
        AltHold:
			ETRF A 0 A_StartSound("PLSFULL",1,CHANF_LOOPING);
			ETRF F 1 BRIGHT offset (0, 32) Tesla_CheckDecharge();
			ETRF G 1 BRIGHT offset (0, 33) Tesla_CheckDecharge();
			ETRF H 1 BRIGHT offset (1, 32) Tesla_CheckDecharge();
			ETRF F 1 BRIGHT offset (-1, 32) Tesla_CheckDecharge();
			PLSN A 0 PB_ReFire();
        FireElectricBall:
			ETRF A 0 A_ZoomFactor(0.9);
			ETRF EFF 2 BRIGHT A_Recoil3D(5);
			TNT1 A 0 Tesla_FireLightningBall();
			Goto CoolDown;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        Reload:
            TNT1 A 0 A_StopSound(1);
            TNT1 A 0 A_StopSound(6);
			TNT1 A 0 A_ClearReFire();
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null,null,"Ready3","Ready3",CELL_SIZE);
            TNT1 A 0 A_PlaySound("IronSights", CHAN_WEAPON);
            TNT1 A 0 A_ZoomFactor(1.0);
            ETRR AABBCCDDEFGHHHIJ 1;
            TNT1 A 0 {
                A_StartSound("weapons/plasma/cellout",CHAN_WEAPON,CHANF_OVERLAP);
                if(PB_GetMagEmpty())
					PB_SpawnCasing("EmptyCell",29,random(10,12),20,0,random(-4,-2),2);
                PB_SetMagUnloaded(true);
                PB_SetChamberEmpty(true);
            }
        ContinueReload:
			ETRR K 10;
			ETRR LMNOP 2;
            TNT1 A 0 {
                A_StartSound("weapons/plasma/cellin",CHAN_WEAPON,CHANF_OVERLAP);
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    CELL_SIZE);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
                PB_SetChamberEmpty(false);
            }
        FinishReload:
			ETRR EDCBA 2;
            TNT1 A 0 A_StartSound("BEPBEP", CHAN_WEAPON);
            Goto Ready3;
        
        RaiseFromEmpty:
            ET1R ABC 2;
            Goto ContinueReload;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            TNT1 A 0 A_StartSound("IronSights", CHAN_WEAPON,CHANF_OVERLAP);
            TNT1 A 0 A_ZoomFactor(1.0);
            ETRR AABBCCDDEFGHHHIJ 1;
            TNT1 A 0 {
                A_StartSound("weapons/plasma/cellout",CHAN_WEAPON,CHANF_OVERLAP);
				PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname());
                PB_SetMagEmpty(true);
				PB_SetMagUnloaded(true);
				PB_SetChamberEmpty(true);
			}
			ETRR K 12;
            ET1R CBA 2;
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 {
                A_TakeInventory("GoWeaponSpecialAbility", 1);
                A_StartSound("weapons/plasma/startup", 16,CHANF_OVERLAP);
            }
            TNT1 A 0 Tesla_LightningSpecial();
        FireLightning:
			ETRF A 0 A_StopSound(6);
            TNT1 A 0 A_StartSound("PLSULT", CHAN_WEAPON);
			ETRF A 0 A_ZoomFactor(0.9);
			ETRF I 2 BRIGHT;
			ETRF J 2 BRIGHT;
			TNT1 A 0 {
                PBX_FireLightningStorm();
                A_FlashOverlay();
            }
			ETRF KL 2 BRIGHT;
			ETRF A 0 A_StopSound(6);
			ETRF A 0 A_ZoomFactor(1.0);
			ETRF EBCDBCACABAA 1 BRIGHT;
			Goto CoolDown;

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
			P1SF D 1 BRIGHT {A_SetWeaponFrame(3 + random[sfx](0, 2)); A_GunFlash();}
			P1SF G 1 BRIGHT {A_SetWeaponFrame(6 + random[sfx](0, 2)); A_GunFlash();}
            stop;

        FlashPunching:
            ETRG ABCDEFFFFEDCBA 1;      // 14 frames
            goto Ready3;

        FlashKicking:
            ETRG ABCDEFFFFFEDCBA 1;     // 15 frames
            goto Ready3;

        FlashAirKicking:
            ETRG ABCDEFFFFFFEDCBA 1;    // 16 frames
            goto Ready3;

        FlashSlideKicking:
            ETRG ABCDE 1;
            ETRG F 17;
            ETRG EDCBA 1; // 27 frames
            goto Ready3;

        FlashSlideKickingStop:
            ETRG FFEDCBA 1;             // 7 frames
            goto Ready3;
    }
}