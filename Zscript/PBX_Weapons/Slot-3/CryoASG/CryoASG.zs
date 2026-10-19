// Cryo Auto Shotgun 
// From Cat's Frozen Addon Pack
// by SchrödingCat, Eriance/Amuscaria, Realm667
// Bloax, ZZrionTheInsect, Xaser & Ethrill, Tomtefar, SchrödingCat
// Dox778

// Includes
#include "./CryoASG_Wheel.zs"

class CryoASG_Select_PlasmaBlast : inventory {default{inventory.maxamount 1;}}
class CryoASG_Select_FreezeBlast : inventory {default{inventory.maxamount 1;}}
class CryoASG_Select_Lightning : inventory {default{inventory.maxamount 1;}}

class CryoASG_Select_PlasmaBreath : inventory {default{inventory.maxamount 1;}}
class CryoASG_Select_IceSpear : inventory {default{inventory.maxamount 1;}}
class CryoASG_Select_StunBomb : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_CryoASG : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "CryoASGWheel";
        PBX_WeaponBase.TakeWeaponDowngrade "PBX_CryoSG";
	    Inventory.AltHUDIcon "412PA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Cell";
        Weapon.AmmoType2 "CryoASGAmmo";
        Weapon.AmmoGive1 16;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_CryoASG_Pickup";
        Inventory.PickupSound "weapons/sgpump";
        Obituary "$OB_WEAP_CRYOASG";
        AttackSound "None";
        Tag "$PBX_CryoASG_Tag";
        Scale 0.8;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
		+WEAPON.CHEATNOTWEAPON;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    int mPrimaryMode;
    int mSecondaryMode;
    int mPumpAnimation; 

    const DRUM_SIZE = 24;
    const PRIMARY_AMMOTAKE = 1;
    const SECONDARY_AMMOTAKE = 2;

    enum CryoASGMode {
        ERROR_WHEEL = -2,
        CLOSE_WHEEL,
        //Primary
        PLASMA_BLAST,
        FREEZE_BLAST,
        LIGHTNING_ARC,
        //Secondary
        PLASMA_BREATH,
        ICE_SPEAR,
        STUN_BOMB,
        //Identifiers
        PRIMARY_MODE = 0,
        SECONDARY_MODE
    }

//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    override void PostBeginPlay()
    {
        mPrimaryMode = PLASMA_BLAST;
        mSecondaryMode = PLASMA_BREATH;
    }

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void PBX_FireLightningShotgun(
        int damage = 25,
        int numrays = 32,
        double coneAngle = 40,
        double distance = 1024,
        double vrange = 30,
        int duration = 1,
        int delay = 0,
        int maxChains = 5,
        int maxLinks = 0,
        name damageType = 'plasma'
    )
    {
        Vector3 beamstart = PBX_LightningController.L_GetBeamAttachPos(self);
        Array<Actor> hitTargets;

        for (int i = 0; i < numrays; i++)
        {
            double an = angle - coneAngle * 0.5 + (numrays > 1 ? coneAngle / (numrays - 1) * i : 0);

            FTranslatedLineTarget t;
            AimLineAttack(an, distance, t, vrange);

            if (t.linetarget && PBX_LightningController.L_IsValidVictim(t.linetarget, self)
                && hitTargets.Find(t.linetarget) == hitTargets.Size())
            {
                hitTargets.Push(t.linetarget);
            }
        }

        for (int i = 0; i < hitTargets.Size(); i++)
        {
            PBX_LightningController.L_StartChain(self, hitTargets[i], damage, distance, duration, delay, maxChains, maxLinks, damageType:damageType);

            Vector3 beamEnd = PBX_LightningController.L_GetBeamAttachPos(hitTargets[i]);
            PBX_LightningController.L_DrawLightning(beamstart, beamEnd, spawnSpark: true, playersource: player);
        }

    }

    action void FireWeapon(CryoASGMode mode)
    {
        A_AlertMonsters();
        A_StartSound("weapons/sg",CHAN_WEAPON,CHANF_OVERLAP);
        A_StartSound("weapons/CryoRifle/missile1",CHAN_AUTO,CHANF_OVERLAP);

        if(mode == PRIMARY_MODE)
            PB_SpawnCasing("SubZeroCasing",18,-6,24,0,3,3);

        PB_IncrementHeat();
        A_GunFlash();
        PB_FireOffset();
        PB_LowAmmoSoundWarning("shotgun");

        PB_TakeAmmo(invoker.ammo2.getClassName(),mode == PRIMARY_MODE ? PRIMARY_AMMOTAKE : SECONDARY_AMMOTAKE);
        A_SpawnItemEx("BlueFlareSpawn", 0, 0, -3);
        A_SpawnItemEx("BlueFlareSpawn", 0, 0, 3);

        switch(getCurrentMode(mode))
        {
            case PLASMA_BLAST:
                PB_FireBullets("Plasma_Ball",4,4,0,0,4);
                break;

            case FREEZE_BLAST:
                PB_FireBullets("SubZeroProjectile",4,4,0,0,4);
         		A_FireBullets(8, 6, 6, 18, "SubZ_Puff",FBF_NORANDOM,8192,"CSSG_FrozenTracer",-12);
                break;
                
            case LIGHTNING_ARC:
                A_StartSound("PLSULT", CHAN_WEAPON, CHANF_OVERLAP);
                PB_FireM2Lightning();
                PBX_FireLightningShotgun();
                break;

            case PLASMA_BREATH:
                A_StartSound("PLSTHRW",CHAN_WEAPON,CHANF_OVERLAP);
                for(int i = 0; i < 2; i++)
                {
                    A_FireCustomMissile("HotPlasmaGas",random(27,33),0,8);
                    A_FireCustomMissile("HotPlasmaGas",random(20,27),0,8);
                    A_FireCustomMissile("HotPlasmaGas",random(12,18),0,4);
                    A_FireCustomMissile("HotPlasmaGas",random(5,10),0,4);
                    A_FireCustomMissile("HotPlasmaGas",random(-3,3));
                    A_FireCustomMissile("HotPlasmaGas",random(-12,-18),0,-4);
                    A_FireCustomMissile("HotPlasmaGas",random(-20,-27),0,-4);
                    A_FireCustomMissile("HotPlasmaGas",random(-27,-33),0,-8);
                }
                break;

            case ICE_SPEAR:
                A_StartSound("weapons/CryoRifle/spearfire", CHAN_WEAPON, CHANF_OVERLAP);
                PBX_FireBullets("IceSpear",1,4,0,0,4);
                break;
                
            case STUN_BOMB:
                A_StartSound("STNBOMB", CHAN_WEAPON, CHANF_OVERLAP);
                PBX_FireBullets("StunBomb",1,4,0,0,4);
                break;
        }

        if(mode == SECONDARY_MODE)
        {
            A_SetInventory("CantDoAction",1);
            PB_SetChamberEmpty(true);
        }

        A_FlashOverlay();
        A_ZoomFactor(0.95);
        PB_DynamicTail("shotgun", "shotgun");
        PB_WeaponRecoil(-2.8,frandom[sfx](-1.6, 1.6));
    }

    action state handleWheel()
    {
        A_TakeInventory("GoWeaponSpecialAbility", 1);
        CryoASGMode tokens = getTokens();
        CryoASGMode currPrimary = getCurrentMode(PRIMARY_MODE);
        CryoASGMode currSecondary = getCurrentMode(SECONDARY_MODE);

        if(tokens == currPrimary || tokens == currSecondary || tokens == CLOSE_WHEEL)
        {
            cleanTokens();
			if(tokens == currPrimary || tokens == currSecondary) 
                A_Print("$PB_ALREADYSELECTED");
            return ResolveState("Ready3");
        }

        switch(tokens)
        {
            case PLASMA_BLAST: case FREEZE_BLAST: case LIGHTNING_ARC:
                setCurrentMode(tokens,PRIMARY_MODE);
                break;

            case PLASMA_BREATH: case ICE_SPEAR: case STUN_BOMB:
                setCurrentMode(tokens,SECONDARY_MODE);
                break;
        }

        printMode(tokens);
        cleanTokens();
        A_StartSound("BEPBEP",CHAN_WEAPON,CHANF_OVERLAP);
        return ResolveState(null);
    }

    action void printMode(CryoASGMode mode)
    {
        string str;
        switch(mode)
        {
            case PLASMA_BLAST:  str = "$PBX_CryoASG_PlasmaBlast";   break;
            case FREEZE_BLAST:  str = "$PBX_CryoASG_FreezeBlast";   break;
            case LIGHTNING_ARC: str = "$PBX_CryoASG_LightningArc";  break;
            case PLASMA_BREATH: str = "$PBX_CryoASG_PlasmaBreath";  break;
            case ICE_SPEAR:     str = "$PBX_CryoASG_IceSpear";      break;
            case STUN_BOMB:     str = "$PBX_CryoASG_StunBomb";      break;
        }
        A_Print(str);
    }
    
    action CryoASGMode getCurrentMode(bool checkSecondary = true)
	{
		return checkSecondary ? invoker.mSecondaryMode : invoker.mPrimaryMode;
	}

	action void setCurrentMode(CryoASGMode set, bool checkSecondary = true)
	{
        if(checkSecondary)
            invoker.mSecondaryMode = set;
        else
            invoker.mPrimaryMode = set;
	}
    
    action CryoASGMode getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("CryoASG_Select_PlasmaBlast"))
			return PLASMA_BLAST;
        else if (FindInventory("CryoASG_Select_FreezeBlast"))
			return FREEZE_BLAST;
        else if (FindInventory("CryoASG_Select_Lightning"))
            return LIGHTNING_ARC;
        else if(FindInventory("CryoASG_Select_PlasmaBreath"))
            return PLASMA_BREATH;
        else if (FindInventory("CryoASG_Select_IceSpear"))
			return ICE_SPEAR;
        else if (FindInventory("CryoASG_Select_StunBomb"))
			return STUN_BOMB;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}
        
    action void cleanTokens()
    {
        A_SetInventory("CryoASG_Select_PlasmaBlast",0);
        A_SetInventory("CryoASG_Select_FreezeBlast",0);
        A_SetInventory("CryoASG_Select_Lightning",0);
        A_SetInventory("CryoASG_Select_PlasmaBreath",0);
        A_SetInventory("CryoASG_Select_IceSpear",0);
        A_SetInventory("CryoASG_Select_StunBomb",0);
        A_SetInventory("PBX_CloseWheel",0);
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            412P A -1;
            Stop;

        WeaponRespect:
            A12R ABCD 1 A_DoPBWeaponAction();
            A12G TGGGGHIJK 1 A_DoPBWeaponAction();
            "####" L 6 A_DoPBWeaponAction();
            "####" X 0 A_StartSound("MS/Button",CHAN_WEAPON, CHANF_OVERLAP);
            "####" MNOON 1 A_DoPBWeaponAction();
            "####" X 0 A_StartSound("MS/Button",CHAN_WEAPON, CHANF_OVERLAP);
            "####" NOONN 1 A_DoPBWeaponAction();
            "####" X 0 A_StartSound("MS/Button",CHAN_WEAPON, CHANF_OVERLAP);
            "####" NOOO 1 A_DoPBWeaponAction();
            // "####" A 0 A_StopSound(1);
            "####" PQRSGGG 1 A_DoPBWeaponAction();
            "####" X 0 A_PlaySound("Shotgun/Pump2", 5);
            "####" T 1 A_DoPBWeaponAction();
            A12R DCBA 1 A_DoPBWeaponAction();
            Goto Ready3;

        WeaponInspect:
            A12R ABCD 1 A_DoPBWeaponAction();
            A12G T 1 A_DoPBWeaponAction();
            A12G GGG 1 A_DoPBWeaponAction();
        HoldInspect:
            A12G GHIJK 1 A_DoPBWeaponAction();
            "####" L 6 A_DoPBWeaponAction();
            "####" X 0 A_StartSound("MS/Button",CHAN_WEAPON, CHANF_OVERLAP);
            "####" MNOON 1 A_DoPBWeaponAction();
            "####" X 0 A_StartSound("MS/Button",CHAN_WEAPON, CHANF_OVERLAP);
            "####" NOONN 1 A_DoPBWeaponAction();
            "####" X 0 A_StartSound("MS/Button",CHAN_WEAPON, CHANF_OVERLAP);
            "####" NOOO 1 A_DoPBWeaponAction();
            "####" A 0 A_StopSound(1);
            "####" PQRSGG 1 A_DoPBWeaponAction();
            "####" A 0 A_JumpIf(PressingReload(),"HoldInspect");
            "####" G 1 A_DoPBWeaponAction();
            "####" X 0 A_PlaySound("Shotgun/Pump2", 5);
            "####" T 1 A_DoPBWeaponAction();
            A12R DCBA 1 A_DoPBWeaponAction();
            Goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            A12S ABCDE 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("weapons/smg_magfly1");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            A12S EDCBA 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 PBX_CheckInspect();
			A12G A 1 {
                PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
				A_SetInventory("CantDoAction",0);
                return A_DoPBWeaponAction();
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
            }
            TNT1 A 0 PB_JumpIfNoAmmo();
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty() && !PB_GetMagUnloaded(), "Pump");
            A12F A 1 BRIGHT FireWeapon(PRIMARY_MODE);
		    A12F B 1 BRIGHT;
            A12F C 1;
            A12F C 2;
            TNT1 A 0 A_ZoomFactor(1.0);
            A12F D 2;
            A12F EFG 1;
            TNT1 A 0 A_WeaponOffset(0,32);
            A12G A 1;
            TNT1 A 0 PB_Refire();
		    Goto Ready3;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
            }
            TNT1 A 0 PB_JumpIfNoAmmo(min:SECONDARY_AMMOTAKE);
            TNT1 A 0 FireWeapon(SECONDARY_MODE);
            A12F AB 1 BRIGHT;
            A12F C 1;
            A12F C 2;
            TNT1 A 0 A_ZoomFactor(1.0);
            A12F D 2;
            A12F EFG 1;
            TNT1 A 0 A_WeaponOffset(0,32);
            A12G A 1;
            TNT1 A 0 {invoker.mPumpAnimation = 0;}
		Pump:
            A12G A 6;
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback", CHAN_WEAPON);
            A1R1 K 1;
            A1R1 M 1;
            TNT1 A 0 {
                PB_SpawnCasing("SubZeroCasing",18,-6,24,0,3,3);
                invoker.mPumpAnimation++;
				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
            }
            A1R1 M 6;
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
            A1R1 L 1;
            A12G A 1;
            A12G A 3;
            TNT1 A 0 A_JumpIf(invoker.mPumpAnimation < SECONDARY_AMMOTAKE, "Pump");
		PumpEnd:
            TNT1 A 0 {
                invoker.mPumpAnimation = 0;
                A_SetInventory("CantDoAction",0);
				PB_SetReloading(false);
				PB_Refire();
            } 
            Goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
		Reload:
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null,"Pump","Ready3","Ready3",DRUM_SIZE);
            A12R ABC 1;
            A12R D 4;
            A1R1 DEFF 1;
            A1R1 G 3;
            A1R1 G 2 offset(0,34);
            A1R1 G 1 offset(0,33);
            A1R1 H 1 offset(0,32);
            TNT1 A 0 A_StartSound("weapons/autoshotgun/drumreload1",CHAN_WEAPON,CHANF_OVERLAP);
            A1R1 IJ 1;
            TNT1 A 0 {
                if(PB_GetMagEmpty()) PB_SpawnCasing("EmptyASGDrum");
                PB_SetMagUnloaded(true);
            }
		    A12R G 3;
            TNT1 A 0 A_StartSound("weapons/autoshotgun/drumreload2",CHAN_WEAPON,CHANF_OVERLAP);
        ContinueReload:
            TNT1 A 0 A_StartSound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
            A12R HIJ 1;
            A12R K 5;
            A12R LM 1;
            A12R NOOPQRS 1;
            A12R T 3;
            TNT1 A 0 A_StartSound("weapons/shotgun/detach", CHAN_WEAPON);
            A1R1 ABCCA 1;
            A12R UWW 1;
            TNT1 A 0 {
                A_StartSound("weapons/riflemagslap", CHAN_WEAPON);
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    PB_GetChamberEmpty() ? DRUM_SIZE-1 : DRUM_SIZE);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
            }
            A12R XY 1;
            A12R Z 12;
            A12R "[" 1;
            A12R "]" 1;
        FinishReload:
            A12R CBA 1;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"PumpReload");
            Goto Ready3;

        PumpReload:
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback", CHAN_WEAPON);
            A1R1 K 1;
            A1R1 M 1;
            TNT1 A 0 PB_SetChamberEmpty(false);
            A1R1 M 6;
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
            A1R1 L 1;
            A12G A 1;
            A12G A 3;
            Goto Ready3;

        RaiseFromEmpty:
            TNT1 A 0 A_StartSound("IronSights",CHAN_WEAPON,CHANF_OVERLAP);
            A12R ABG 1;
            Goto ContinueReload;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
            A12G A 1;
            A12R ABC 1;
            A12R D 4;
            A1R1 DEFF 1;
            A1R1 G 3;
            A1R1 G 2 offset(0,34);
            A1R1 G 1 offset(0,33);
            A1R1 H 1 offset(0,32);
            TNT1 A 0 {
                A_StartSound("weapons/autoshotgun/drumreload1", CHAN_WEAPON);
                PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname());
				PB_SetMagUnloaded(true);
				PB_SetChamberEmpty(true);
                PB_SetMagEmpty(true);
			}
            A1R1 IJ 1;
        FinishUnload:
            A12R G 4;
            TNT1 A 0 A_StartSound("weapons/autoshotgun/drumreload2", CHAN_WEAPON);
            A12R BA 1;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"Ready3");
        ChamberUnload:
            TNT1 A 0 A_StartSound("weapons/spas12/pumpback", CHAN_WEAPON);
            A1R1 K 1;
            A1R1 M 1;
            TNT1 A 0 {
                PB_SetChamberEmpty(true);
                PB_SpawnCasing("SubZeroCasing",18,-6,24,0,3,3);
            }
            A1R1 M 6;
            TNT1 A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_WEAPON);
            A1R1 L 1;
            A12G A 1;
            A12G A 3;
            goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 handleWheel();
            A12G BCDEF 1;
            A12G F 4;
            A12G FEDCB 1; 
            Goto Ready3;            

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
			P1SF D 1 BRIGHT {A_SetWeaponFrame(3 + random(0, 2)); A_GunFlash();}
			P1SF G 1 BRIGHT {A_SetWeaponFrame(6 + random(0, 2)); A_GunFlash();}
            stop;

        FlashPunching:
            // 14 frames
            A12G BCDEF 1;
            A12G F 4;
            A12G FEDCB 1;  
            goto Ready3;

        FlashKicking:
            // 15 frames
            A12G BCDEF 1;
            A12G F 5;
            A12G FEDCB 1; 
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            A12G BCDEF 1;
            A12G F 6;
            A12G FEDCB 1; 
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            A12G BCDEF 1;
            A12G F 17;
            A12G FEDCB 1; 
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            A12G FFFEDCB 1;             
            goto Ready3;
    }
}