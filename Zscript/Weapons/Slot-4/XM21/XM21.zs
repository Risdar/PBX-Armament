// Nuke Launcher 
// From Brutal Doom by Sergeant_Mark_IV
// Sprites by Tesefy
// Part of the stealth code is from the Phantom Veil Mod by ZAE5TT4

// Includes
#include "./XM21_Wheel.zs"

class XM21_Toggle_Firemode : inventory {default{inventory.maxamount 1;}}
class XM21_Toggle_Cloak : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_XM21 : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "XM21Wheel";
        PB_WeaponBase.ReserveToMagAmmoFactor 2;
        PBX_WeaponBase.ScopeConfiguration true, MINZOOM, MAXZOOM; 
        PBX_WeaponBase.TakeWeaponDowngrade "PBX_BDPBattleRifle";
	    Inventory.AltHUDIcon "WM14B0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_HighCalMag";
        Weapon.AmmoType2 "XM21Ammo";
        Weapon.AmmoGive1 22;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_XM21_Pickup";
        Inventory.PickupSound "CHGNPKUP";
        Obituary "$OB_WEAP_XM21";
        AttackSound "None";
        Tag "$PBX_XM21_Tag";
        Scale 0.8;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
		+WEAPON.CHEATNOTWEAPON;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    bool mSemiAuto;
	bool mSemiClear;
	bool mCloakEngaged;
	int mBurstCount;

    const MAGAZINE_SIZE = 11;
    const CLOAK_DURATION = 30; // In seconds
    const CLOAK_ENERGY_GIVE = 1; // Given every seconds
    const CLOAK_ENERGY_TAKE = 2; // Taken every seconds
    const CLOAK_ENERGY = "CloakEnergy"; // Just so its easier if I want to change the name later
    const CLOAK_CHAN = 11; // The sound channel of the cloak activation/deactivation/etc.
    const CLOAK_CHAN_LOOP = 12; // The sound channel of the cloak loop sound
    const CLOAK_MIN = 10; // Minimum energy to activate cloak

    // Change these if you want to edit how strong the zoom modes are
	const MAXZOOM = 12.0;
	const MINZOOM  = 1.25;

    enum SniperWheel
    {
        ERROR_WHEEL = -1,
        CLOSE_WHEEL,
        TOGGLE_FIREMODE,
        TOGGLE_LASER,
        TOGGLE_SCOPE,
        TOGGLE_NVG,
        TOGGLE_CLOAK
    }

//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    override void PostBeginPlay()
    {
        mSemiAuto = true;
        super.PostBeginPlay();
    }

    override void DoEffect() 
	{
        super.DoEffect();
		if(level.isFrozen() || !owner || !owner.player || !owner.player.readyweapon) 
		{
			return;
		}

        if(level.time % TICRATE != 0)
        {
            return;
        }

        if(CountInv(CLOAK_ENERGY) < CLOAK_DURATION && !mCloakEngaged)
        {
            GiveInventory(CLOAK_ENERGY,CLOAK_ENERGY_GIVE);
            if(CountInv(CLOAK_ENERGY) == CLOAK_DURATION)
            {
                PBXCore_Debug.Print("Cloak Full");
                owner.a_startsound("Sniper/CloakFull",CLOAK_CHAN,CHANF_OVERLAP,5,ATTN_NONE);
            }
        }
        else if(CountInv(CLOAK_ENERGY) != 0 && mCloakEngaged)
        {
            TakeInventory(CLOAK_ENERGY,CLOAK_ENERGY_TAKE);
            if(CountInv(CLOAK_ENERGY) < CLOAK_ENERGY_TAKE)
            {
                PBXCore_Debug.Print("Cloak Empty");
                owner.a_startsound("Sniper/CloakEmpty",CLOAK_CHAN,CHANF_OVERLAP,1,ATTN_NONE);
                mCloakEngaged = false;
                owner.A_SetRenderstyle(1.0, STYLE_Normal);
                owner.bShadow = false;
                owner.bCantSeek = false;
                owner.player.cheats &= ~CF_NOTARGET;
            }
        }
	}

    // Laser sight stuff
	mixin PBX_LaserSight;
	static const StateLabel blockedLaserStates[] = {
		"Reload", "ReloadFromADS", "ContinueReload", "RaiseFromEmpty", "WeaponInspect",
		"Unload", "SwitchAnimation","WeaponRespect", "Deselect", "SelectAnimation", "StartRechamber","Rechamber",
        "FinishUnload", "Dechamber",
		"FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop"
	};
	override void PBX_DoEffectWeaponReady()
	{
		PBX_SpawnLaserSight(GREEN_DOT);
	}

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void fireWeapon()
    {
        bool ads = PB_GetZoom();
        double recoilX = ads ? frandom[sfx](-1.0,1.0) : frandom[sfx](-1.3,1.3);
        double recoilY = ads ? -1 : -1.4;
        
        A_AlertMonsters();
		PBX_FireRicochet("PB_762x51mmAP","LMGCasingStandard",1,1,0,0,1,puffType:"BR45BulletPuff");
        PB_WeaponRecoil(recoilX,recoilY);
        PB_DynamicTail("sniper", "sniper");
        PB_LowAmmoSoundWarning("sniper", "SuperMario64ForTheXboxOne");
        PB_TakeAmmo(invoker.ammo2.getClassName());
        A_StartSound("weapons/rifle/sniperfire",CHAN_WEAPON);
        A_StartSound("FARM14",CHAN_6);

        if(!ads)
        {
            A_ZoomFactor(0.96);
            A_FlashOverlay(state:"BiggestMuzzleFlash");
            PB_GunSmoke_Sniper(0,0,0); PB_MuzzleFlashEffects(0,0,0, "FF9D2E", true);
            A_GunFlash();
            PB_FireOffset();
            A_FireCustomMissile("YellowFlareSpawn",0,0,0,0);
        }

        invoker.mBurstCount++;
    }

    action state handleWheel()
    {
        A_TakeInventory("GoWeaponSpecialAbility", 1) ;  
        SniperWheel tokens = getTokens();

        switch(tokens)
        {
            case CLOSE_WHEEL: 
                cleanTokens();
                return ResolveState("Ready3");

            case TOGGLE_FIREMODE:
                invoker.mSemiAuto = !invoker.mSemiAuto;
			    A_Print(invoker.mSemiAuto ? "$PB_FIREMODE_SEMI" : "$PB_FIREMODE_BURST");
                break;

            case TOGGLE_LASER:
                PBX_ToggleLaserSight(skipPlaySound:true);
                if(PB_GetZoom()) A_StartSound("MS/Button",CHAN_AUTO);
                break;

            case TOGGLE_CLOAK:
                cleanTokens();
                // If cloak is not active and no energy
                if(!invoker.mCloakEngaged && CountInv(CLOAK_ENERGY) < CLOAK_MIN)
                {
                    A_StartSound("Sniper/CloakLow",CLOAK_CHAN,CHANF_OVERLAP);
                    A_Print("$PBX_XM21_CloakNoEnergy");
                    return ResolveState("Ready3");
                }

                invoker.mCloakEngaged = !invoker.mCloakEngaged;
                bool isEngaged = invoker.mCloakEngaged; // Save the var
                if(isEngaged) 
                {
                    A_SetRenderStyle(.5, STYLE_Subtract);
                    A_StartSound("Sniper/CloakActive",CLOAK_CHAN,CHANF_OVERLAP,volume:5.0);
                    A_StartSound("Sniper/CloakLoop",CLOAK_CHAN_LOOP,CHANF_LOOP|CHANF_OVERLAP);
                    bShadow = true;
                    bCantSeek = true;
                    self.player.cheats |= CF_NOTARGET;
                    let holo = PBX_SniperTarget(Spawn("PBX_SniperTarget", pos));
                    if(holo)
                    {
                        holo.angle = angle;
                        holo.targetPos = pos;
                        holo.tracer = self;
                        holo.angle = angle;
                    }
                }
                else if(!isEngaged)
                {
                    A_StopSound(CLOAK_CHAN_LOOP);
                    A_SetRenderstyle(1.0, STYLE_Normal);
                    A_StartSound("Sniper/CloakDisabled",CLOAK_CHAN,CHANF_OVERLAP);
                    bShadow = false;
                    bCantSeek = false;
                    self.player.cheats &= ~CF_NOTARGET;
                }
                return ResolveState("Ready3");

            case TOGGLE_SCOPE:
                cleanTokens();
                PBX_ToggleSmartScope();
                return ResolveState("Ready3");

            case TOGGLE_NVG:
                cleanTokens();
                PBX_ToggleNightVision();
                return ResolveState("Ready3");
        }
        cleanTokens();
        return PBX_ReturnReady(normal:"SwitchAnimation");
    }
    
    action int getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("XM21_Toggle_Firemode"))
			return TOGGLE_FIREMODE;
		else if (FindInventory("PBX_Toggle_Laser"))
			return TOGGLE_LASER;
        else if(FindInventory("PBX_Toggle_Scope"))
            return TOGGLE_SCOPE;
        else if(FindInventory("PBX_Toggle_NVG"))
            return TOGGLE_NVG;
        else if (FindInventory("XM21_Toggle_Cloak"))
			return TOGGLE_CLOAK;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}

    action void cleanTokens()
    {
        A_SetInventory("XM21_Toggle_Cloak",0);
        A_SetInventory("XM21_Toggle_Firemode",0);
        A_SetInventory("PBX_Toggle_Laser",0);
        A_SetInventory("PBX_Toggle_Scope",0);
        A_SetInventory("PBX_Toggle_NVG",0);
        A_SetInventory("PBX_CloseWheel",0);
    }

    action int getSemiAuto()
	{
		return invoker.mSemiAuto;
	}

	action void setSemiAuto(int mode)
	{
		invoker.mSemiAuto = mode;
	}

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            WM14 B -1;
            Stop;

        WeaponRespect:
            X23R GHIJKLM 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            TNT1 A 0 A_StartSound("weapons/rifle/magchange",CHAN_AUTO);
            X21R MNOPPQQQQQQQQRSTU 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            TNT1 A 0 A_StartSound("weapons/rifle/magin",CHAN_AUTO);
            X21R UUVVW 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            X21R "XXYZ[[[[[]" 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            X22R ABC 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            X21R B 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            X22R DEFGHIJ 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            X22R K 3 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            X22R LMMM 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);
            X22R NNOPQRS 1 A_DoPBWeaponAction(WRF_ALLOWZOOM);
            Goto Ready3;

        WeaponInspect:
            X21G A 1 A_DoPBWeaponAction();
            X22R SRE 1 A_DoPBWeaponAction();
            X22R FGHIJ 1 A_DoPBWeaponAction();
            X22R K 5 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            X22R LLMM 1 A_DoPBWeaponAction();
        HoldInspect:
            X22R M 2 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);
            X22R NNOP 1 A_DoPBWeaponAction();
            X22R Q 4 A_DoPBWeaponAction();
            X22R QRS 1 A_DoPBWeaponAction();
            Goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
		    X21S EFGH 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("Sniper/Draw");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            X21S ABCD 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
			TNT1 A 0 { invoker.mBurstCount = 0; }
			TNT1 A 0 A_jumpif(PB_GetZoom(),"Ready2");
		ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
			X21G A 1 {
                PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
				return PB_ReadyFire();
            }
            loop;

        Ready2:
            TNT1 A 0 {
				PB_SetRoll(0);
				A_SetCrosshair(-1);
            }
		ReadyToFire2:
		    SN1P D 1 {
                PB_CoolDownBarrel();
				A_ZoomFactor(PBX_GetZoomLevel());
				PBX_ReadySmartScope();
				return PB_ReadyFire(ads:true);
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        BurstFireRecoil:
            X21F C 1;
            X21G A 2;
        Fire:
            TNT1 A 0 {
				A_WeaponOffset(0, 32);
				PB_SetRoll(0);
				PB_HandleCrosshair(39);
				A_ZoomFactor(1.0);
			}
			TNT1 A 0 A_JumpIf(PB_GetZoom(), "FireADS");
            TNT1 A 0 PB_JumpIfNoAmmo();
            X21F A 1 BRIGHT fireWeapon();
            X21F B 1 {
                A_ZoomFactor(1.0);
                PB_RotateCamera(addAngle:0.1);
            }
			TNT1 A 0 A_JumpIf(getSemiAuto(), "BurstDone");
			TNT1 A 0 A_JumpIf(invoker.mBurstCount < 3, "BurstFireRecoil");
		BurstDone:
			TNT1 A 0 { invoker.mBurstCount = 0; }
            X21F C 1;
            X21G A 2;
            X21G AAAAAAA 1 {
				// Track button release
				if (!(player.cmd.buttons & BT_ATTACK))
					invoker.mSemiClear = true;
				// Refire only if button was released and pressed again
				if (invoker.mSemiClear && PlayerPressedOnce(BT_ATTACK))
					return resolvestate("Fire");
				return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOFIRE | WRF_NOPRIMARY);
			}
			TNT1 A 0 { invoker.mSemiClear = false; }
            Goto Ready3;

        BurstFireRecoilADS:
            SN1P D 3;
        Fire2:
			TNT1 A 0 A_ZoomFactor(PBX_GetZoomLevel());
            TNT1 A 0 PB_JumpIfNoAmmo();
            SN1P D 1;
            SN1P A 1 fireWeapon();
            SN1P B 1;
            SN1P C 1;
			TNT1 A 0 A_JumpIf(getSemiAuto(), "BurstDoneADS");
			TNT1 A 0 A_JumpIf(invoker.mBurstCount < 3, "BurstFireRecoilADS");
		BurstDoneADS:
			TNT1 A 0 { invoker.mBurstCount = 0; }
            SN1P D 5;
            SN1P DDDDDDD 1 {
				// Track button release
				if (!(player.cmd.buttons & BT_ATTACK))
					invoker.mSemiClear = true;
				// Refire only if button was released and pressed again
				if (invoker.mSemiClear && PlayerPressedOnce(BT_ATTACK))
					return resolvestate("Fire2");
				return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOFIRE | WRF_NOPRIMARY);
			}
			TNT1 A 0 { invoker.mSemiClear = false; }
            Goto Ready2;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
			TNT1 A 0 A_Jumpif(PB_GetZoom(),"ZoomOut");
		ZoomIn:
            TNT1 A 0 {
				A_ZoomFactor(1.25);
				A_startsound("IronSights",CHAN_AUTO);
				A_SetCrosshair(-1);
			}
            X21A AB 1;
            TNT1 A 0 A_ZoomFactor(PBX_GetZoomLevel());
			X21A C 1;
			TNT1 A 0 PB_SetZoom(true);
            goto Ready2;

        ZoomOut:
			TNT1 A 0 {
				A_startsound("IronSights",CHAN_AUTO);
				A_ZoomFactor(1.0);
				PB_SetZoom(false);
			}
		    X21A CB 1;
			X21A A 1;
			goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
        ReloadFromADS:
			TNT1 A 0 PB_HandleCrosshair(39);
			TNT1 A 0 A_startsound("IronSights",29);
            TNT1 A 0 A_ZoomFactor(1.25);
			X21A CB 1;
			TNT1 A 0 PB_SetZoom(false);
			X21A A 1;
		Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null,"StartRechamber","Ready3","Ready3",MAGAZINE_SIZE,invoker.ReserveToMagAmmoFactor);
            X21R AB 1;
            X21R CDEFGHHII 1;
            TNT1 A 0 A_StartSound("weapons/rifle/magout",CHAN_AUTO);
            X21R IIJK 1;
            TNT1 A 0 {
                if(PB_GetMagEmpty()) PB_SpawnCasing("EmptyDMRMag",38,26,7,frandom(0, 3.5),frandom(-7.2, -3.3),frandom(3,7));
                PB_SetMagUnloaded(true);
            }
            X21R LM 1;
        ContinueReload:	
            TNT1 A 0 A_StartSound("weapons/rifle/magchange",CHAN_AUTO);
            X21R NOPPQQQQQQQQQQ 1;
            X21R RSTU 1;
            X21R UUVVW 1;
            TNT1 A 0 {
                A_StartSound("weapons/rifle/magin",CHAN_AUTO);
                PB_AmmoIntoMag(
                    invoker.ammo2.getClassName(),
                    invoker.ammo1.getClassName(),
                    PB_GetChamberEmpty() ? MAGAZINE_SIZE-1 : MAGAZINE_SIZE,
                    invoker.ReserveToMagAmmoFactor
                );
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
            }
            X21R "XXYZ[[[[[]" 1;
            X22R ABC 1;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(),"Rechamber");
            X21R BA 1;
            Goto Ready3;

        StartRechamber:
            X21R A 1;
        Rechamber:
            X21R B 1;
            X22R DEFGHIJ 1;
            X22R K 5;
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            X22R L 1 PB_SetChamberEmpty(false);
            X22R MMMMM 1;
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);		
            X22R NNOPQRS 1;
            TNT1 A 0 PB_SetReloading(false);
            Goto Ready3;
        
        RaiseFromEmpty:
            X21R AB 1;
            X23R ABCDEF 1;
            Goto ContinueReload;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
        Unload:
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded() && !PB_GetChamberEmpty(), "UnloadChamber");
			TNT1 A 0 A_Jumpif(PB_GetMagUnloaded(),"Ready3");
		    X21R ABCDEFGHHIIJJ 1;
            TNT1 A 0 {
                A_StartSound("weapons/rifle/magout",CHAN_AUTO);
                if(PB_GetMagEmpty()) PB_SpawnCasing("EmptyDMRMag",38,26,7,frandom(0, 3.5),frandom(-7.2, -3.3),frandom(3,7));
				PB_UnloadMag(
                    invoker.ammo2.getclassname(),
                    invoker.ammo1.getclassname(),
                    invoker.ReserveToMagAmmoFactor,
                    goal:PB_GetChamberEmpty() ? 0 : 1
                );
				PB_SetMagUnloaded(true);
                PB_SetMagEmpty(true);
			}
            X21R JJKLMMMMMM 1;
            X23R FEDCBA 1;
			TNT1 A 0 A_Jumpif(!PB_GetChamberEmpty(),"Dechamber");
        FinishUnload:   
            X21R BA 1;
            goto Ready3;

        Dechamber:
            X22R DEFGHIJ 1;
            X22R K 5;
            TNT1 A 0 A_StartSound("Sniper/BoltBack",CHAN_AUTO);
            X22R L 1;
            TNT1 A 0 {
                PB_SetChamberEmpty(true);
                PB_UnloadMag(
                    invoker.ammo2.getclassname(),
                    invoker.ammo1.getclassname(),
                    invoker.ReserveToMagAmmoFactor,
                    goal:0,
                    spawnActor:"PB_HighCalRound"
                );
            }
            X22R MMMMM 1;
            TNT1 A 0 A_StartSound("Sniper/BoltForward",CHAN_AUTO);		
            X22R NNOPQRS 1;
            Goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 handleWheel();
        SwitchAnimation:
            X21G BCDE 1;
            X21G F 1;
            TNT1 A 0 A_StartSound("MS/Button",CHAN_AUTO);		
            X21G EDCB 1;
            Goto Ready3;            

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        BiggestMuzzleFlash:
            TNT1 A 0 A_Jump(256, "BiggestMuzzleFlash1Start", "BiggestMuzzleFlash2Start", "BiggestMuzzleFlash3Start", "BiggestMuzzleFlash4Start", "BiggestMuzzleFlash5Start","BiggestMuzzleFlash6Start");
        BiggestMuzzleFlashStart1:
            MZ00 C 1 BRIGHT A_GunFlash();
            TNT1 A 0 A_Jump(256, "BiggestMuzzleFlashEnd1", "BiggestMuzzleFlashEnd2");
            STOP;
        BiggestMuzzleFlashStart2:
            MZ00 D 1 BRIGHT A_GunFlash();
            TNT1 A 0 A_Jump(256, "BiggestMuzzleFlashEnd1", "BiggestMuzzleFlashEnd2");
            STOP;
        BiggestMuzzleFlashStart3:
            MZ00 E 1 BRIGHT A_GunFlash();
            TNT1 A 0 A_Jump(256, "BiggestMuzzleFlashEnd1", "BiggestMuzzleFlashEnd2");
            STOP;
        BiggestMuzzleFlashStart4:
            MZ00 F 1 BRIGHT A_GunFlash();
            TNT1 A 0 A_Jump(256, "BiggestMuzzleFlashEnd1", "BiggestMuzzleFlashEnd2");
            STOP;
        BiggestMuzzleFlashStart5:
            MZ00 G 1 BRIGHT A_GunFlash();
            TNT1 A 0 A_Jump(256, "BiggestMuzzleFlashEnd1", "BiggestMuzzleFlashEnd2");
            STOP;
        BiggestMuzzleFlashStart6:
            MZ00 H 1 BRIGHT A_GunFlash();
            TNT1 A 0 A_Jump(256, "BiggestMuzzleFlashEnd1", "BiggestMuzzleFlashEnd2");
            STOP;
        BiggestMuzzleFlashEnd1:
            MZ00 JK 1 BRIGHT A_GunFlash();
            STOP;
        BiggestMuzzleFlashEnd2:
            MZ00 IL 1 BRIGHT A_GunFlash();
            STOP;

        FlashPunching:
            // 14 frames
            X21G BCDE 1;
            X21G F 6;
            X21G EDCB 1;
            goto Ready3;

        FlashKicking:
            // 15 frames
            X21G BCDE 1;
            X21G F 7;
            X21G EDCB 1;
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            X21G BCDE 1;
            X21G F 8;
            X21G EDCB 1;  
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            X21G BCDE 1;
            X21G F 19;
            X21G EDCB 1;
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            X21G EEEEDCB 1;
            goto Ready3;
    }
}

class PBX_SniperTarget : PBX_Hologram
{
    Default
    {
        +FRIENDLY
        +THRUSPECIES
        +THRUACTORS
        BloodType '';
        Species 'Marines';
        Health 1000;
    }

    override void PostBeginPlay()
	{
		super.PostBeginPlay();
		mLifetime = 5;
	}

    States
    {
        Spawn:
            TNT1 A 1 A_HologramAlert();
			Loop;

        Death:
			TNT1 A 1 A_XScream();
			Stop;

    }
}