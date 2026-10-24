// The SPAS 12 
// From BD Plus made by yaelvolador
// sprite is made by Wocht11k
// Originally from BD Plus then ported to PB2022 by RENEGADE_ANDROiD
// the PB2022 version is the base for the PBX version
// some sounds are from Half-Life 2

// SPAS 12 Rework:
// The SPAS-12 Decorate code is mostly a copy-paste of Brutal Doom's Shotgun
// Sprites edits (hands, pump animation...) by Edewaa

// // Includes
#include "./Spas12_Wheel.zs"

class SP12_Toggle_Secondary : inventory {default{inventory.maxamount 1;}}
class SP12_Toggle_Stock : inventory {default{inventory.maxamount 1;}}
class SP12_Toggle_Type : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_SPAS12 : PBX_WeaponBase
{
	Default
	{
		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.5;
		Weapon.BobStyle "InverseSmooth";
		Weapon.BobSpeed 2.4;
		Weapon.AmmoType1 "PB_Shell";
		weapon.ammogive1 10;
		Weapon.AmmoType2 "PBX_SPAS12Mag";
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "Spas12Wheel";
		Inventory.PickupMessage "$PBX_SPAS12_PICKUP";
		Inventory.PickupSound "weapons/spas12/raise";
		Inventory.Icon "SPACA0";
		Inventory.AltHUDIcon "SPACA0";
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		Obituary "$OB_WEAP_SPAS12";
		Scale 0.40;
		Tag "$PBX_SPAS12_TAG";
        +FLOORCLIP;
		+DONTGIB;
		+WEAPON.NOAUTOAIM;
		+WEAPON.NOAUTOFIRE;
		+WEAPON.NOALERT;
	}

    bool mStockIsFolded;
    bool mSemiAuto;
    bool mDualBlast;
    bool mFirstTimePickup; // So it prints the current mode once upon pickup
    bool mJustFiredDualBlast;
    const MAGAZINE_SIZE = 9;
    const TIME_DELAY_UNFOLDED = 2; // How many tics should the duration be longer if the stock is unfolded

    enum SPAS12_WheelMode
    {
        ERROR_WHEEL = -1,
        CLOSE_WHEEL,
        TOGGLE_SECONDARY,
        TOGGLE_STOCK,
        TOGGLE_TYPE
    }

    override void PostBeginPlay()
    {
        super.PostBeginPlay();
        mStockIsFolded = true;
        mSemiAuto = true;
        mFirstTimePickup = true;
    }

    action void  SP12_SetSprite(
        name foldedManual = '', 
        name unfoldedManual = '', 
        name foldedSemi = '', 
        name unfoldedSemi = ''
    )
    {
        name s;
        bool isSemi = SP12_IsSemiAuto();

        if(SP12_IsStockFolded())
        {
            s = isSemi ? foldedSemi : foldedManual;
        }
        else
        {
            s = isSemi ? unfoldedSemi : unfoldedManual;
        }

        if(s != '')
        {
            A_SetWeaponSpriteEX(s);
        }
    }

    action state SP12_HandleWheel()
    {
        A_Takeinventory("GoWeaponSpecialAbility",1);
        SPAS12_WheelMode tokens = getTokens();

        switch(tokens)
        {
            Default:
            case CLOSE_WHEEL:
                break;

            case TOGGLE_TYPE:
                // Mode Change is on unload
                // The Print is reversed because technically you havent changed the mode yet
                A_Print(!SP12_IsSemiAuto() ? "$PBX_SPAS12_SEMI" : "$PBX_SPAS12_MANUAL");
                return ResolveState("Unload");

            case TOGGLE_STOCK:
                cleanTokens();
                invoker.mStockIsFolded = !invoker.mStockIsFolded;
                name icon = invoker.mStockIsFolded ? "SPACA0" : "SPBCA0";
                invoker.AltHudIcon = TexMan.CheckForTexture(icon);
                A_Print(SP12_IsStockFolded() ? "$PBX_SPAS12_STOCK_FOLDED" : "$PBX_SPAS12_STOCK_UNFOLDED");
                return ResolveState("FoldSwitchAnimation");

            case TOGGLE_SECONDARY:
                cleanTokens();
                invoker.mDualBlast = !invoker.mDualBlast;
                A_Print(invoker.mDualBlast ? "$PBX_SPAS12_DUALFIRE" : "$PBX_SECONDARY_ZOOM");
                return ResolveState("SecondarySwitchAnimation");
                
        }
        cleanTokens();
        return PBX_ReturnReady();
    }

    action state SP12_ModeChange()
    {
        if(getTokens() == TOGGLE_TYPE)
        {
            cleanTokens();
            return ResolveState("SwitchFireMode"); // Actual mode change here
        }

        return ResolveState(null);
    }

    action void SP12_UnloadShells()
    {
        name casing = SP12_IsSemiAuto() ? "ShotgunCasingRedLive" : "ShotgunCasingGreenLive";
        PB_SpawnCasing(casing,15,-5,26,0,3,3);
        A_Takeinventory(invoker.ammo2.getClassName(),1);
    }

    action SPAS12_WheelMode getTokens()
	{
		// Prioritize checking the tokens
		if(FindInventory("SP12_Toggle_Secondary"))
			return TOGGLE_SECONDARY;
		else if(FindInventory("SP12_Toggle_Stock"))
			return TOGGLE_STOCK;
		else if (FindInventory("SP12_Toggle_Type"))
			return TOGGLE_TYPE;
		else if (FindInventory("PBX_CloseWheel"))
			return CLOSE_WHEEL;
		else
			return ERROR_WHEEL;
	}

    action void cleanTokens()
    {
        A_SetInventory("SP12_Toggle_Secondary",0);
        A_SetInventory("SP12_Toggle_Stock",0);
        A_SetInventory("SP12_Toggle_Type",0);
        A_SetInventory("PBX_CloseWheel",0);

    }

    action void SP12_HandleCrosshair()
    {
        int crs = SP12_IsSemiAuto() ? 69 : 68;
        PB_HandleCrosshair(crs);
    }

    action void SP12_SetDuration()
    {
        // Slower animation if stock is unfolded
        if(!SP12_IsStockFolded())
        {
            A_SetTics(TIME_DELAY_UNFOLDED);
        }
    }

    action void SPAS_Fire(int tic)
    {
        double ofs          = 4.0; //Standard offset for firing
        bool isZoom         = PB_GetZoom();
        bool isSemi         = SP12_IsSemiAuto();
        bool isStockFolded  = SP12_IsStockFolded();
        name casing         = isSemi ? "ShotgunCasing" : "ShotgunCasing2";

        switch(tic)
        {
            case 1:
                A_AlertMonsters();
				A_FireProjectile("ShotgunWad", random(-2,2), 0, random(-2,2), -3, FPF_NOAUTOAIM, random(-2,2));

                // If stock is unfolded, increase accuracy by 1.0, if zoomed increase even further
                if(!isStockFolded)
                {
                    ofs -= 1.0;
                }
                if(isZoom)
                {
                    ofs -= 1.0;
                    SP12_SetSprite('SPA8','SPB8','SPA8','SPB8');
                }
                else
                {
					SP12_HandleCrosshair();
				    PB_FireOffset();
                    SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
                }

                if(isSemi)
                {
                    PB_FireBullets("PB_12GAPellet",9,ofs,0,0,ofs);
                    A_StartSound("weapons/sg", CHAN_WEAPON,CHANF_OVERLAP,pitch:frandom(0.95, 1.05));
                }
                else
                {
				    PB_SetChamberEmpty(true);
                    A_StartSound("SlugShot", CHAN_WEAPON,CHANF_OVERLAP,pitch:frandom(0.95, 1.05));
                    PBX_FireBullets("PB_12GASlug", 1, ofs, 0, 0, ofs);
                }

				PB_LowAmmoSoundWarning("shotgun");
				PB_TakeAmmo(invoker.ammo2.getClassName(),1,0);

                PB_WeaponRecoil(-ofs,frandom[sfx](-1.0,1.0));
				PB_IncrementHeat();
				A_FireCustomMissile("YellowFlareSpawn", 0, 0, 0, 0);
				_SpawnMuzzleSparksSG(0, 0, -4);
				PB_MuzzleFlashEffects(0, 0, -4);
				PB_DynamicTail("shotgun", "shotgun");
				A_SetInventory("CantDoAction", 1);
				A_GunFlash();
                break;

            case 2:
                PB_QuakeCamera(3,3);
                A_ZoomFactor(0.94); 
                break;

            case 3: case 4:
                A_ZoomFactor(tic == 4 ? 1.0 : 0.96);
                break;

            case 5:
                if(isZoom)
                {
                    PB_SpawnCasing(casing,18,3,30,0,3,3);
                }
                else if(SP12_IsSemiAuto())
                {
                    PB_SpawnCasing(casing,25,-5,19,0,3,3);
                }
                else
                {
                    PB_SpawnCasing(casing,15,-5,26,0,3,3);
                }

				if(!PB_GetMagEmpty()) PB_SetChamberEmpty(false);
                A_ZoomFactor(PB_GetZoom() ? 1.25 : 1.0);
                break;

        }
    }

    action void SP12_HLFire()
    {
        double ofs          = 4.0; //Standard offset for firing
        bool isSemi         = SP12_IsSemiAuto();
        bool isStockFolded  = SP12_IsStockFolded();

        SPAS_Fire(1);

        if(isSemi)
        {
            PB_FireBullets("PB_12GAPellet",12,ofs,0,0,ofs);
            A_StartSound("weapons/sg",CHAN_WEAPON,CHANF_OVERLAP,pitch:frandom(0.95, 1.05));
        }
        else
        {
            A_StartSound("SlugShot",CHAN_WEAPON,CHANF_OVERLAP,pitch:frandom(0.95, 1.05));
            PBX_FireBullets("PB_12GASlug", 1, ofs, 0, 0, ofs);
        }

        A_Recoil3D(3);
        PB_WeaponRecoil(-ofs,frandom[sfx](-1.0,1.0));
        PB_QuakeCamera(3,3);
        PB_SetChamberEmpty(true);
        A_FireProjectile("ShotgunWad", random(-2,2), 0, random(-2,2), -3, FPF_NOAUTOAIM, random(-2,2));
        PB_TakeAmmo(invoker.ammo2.getClassName(),1,0);
        PB_FireOffset();
        invoker.mJustFiredDualBlast = true;
        PB_SetReloading(true);
    }

    // Called in PB_CheckReload()
    action StateLabel SPAS_CheckPump()
    {
        StateLabel result = "Pump";
        if(invoker.mJustFiredDualBlast)
        {
            result = "PumpSlow";
        }
        return result;
    }

    action state SPAS_HandleAlt()
    {
        PB_SetRoll(0);
        SP12_HandleCrosshair();

        if(invoker.mDualBlast)
        {
            return ResolveState("HL2Fire");
        }

        A_StartSound("IronSights",CHAN_AUTO);

        if(PB_GetZoom())
        {
            return ResolveState("Zoomout");
        }
            
        return ResolveState(null);
    }

    action bool SP12_IsStockFolded()
    {
        return invoker.mStockIsFolded;
    }

    action void SP12_SetStockState(bool set)
    {
        invoker.mStockIsFolded = set;
    }

    action bool SP12_IsSemiAuto()
    {
        return invoker.mSemiAuto;
    }

    action void SP12_SetSemiAuto(bool set)
    {
        invoker.mSemiAuto = set;
    }

	States
	{
        LoadSprites:
            SPAC A 0; SPBC A 0;
            SPAA A 0; SPBA A 0;
            SPAN A 0; SPBL A 0;
            SPA5 A 0; SPB5 A 0;
            SPA6 A 0; SPB6 A 0;
            SPA7 A 0; SPB7 A 0;
            SPA8 A 0; SPB8 A 0;
            SPA9 A 0; SPB9 A 0;
            Stop;
            
        Spawn:
            SPAC A -1 {
                invoker.mFirstTimePickup = true;
                if(SP12_IsStockFolded())
                {
                    sprite = GetSpriteIndex("SPAC");
                }
                else
                {
                    sprite = GetSpriteIndex("SPBC");
                }
            } 
            Stop;

        // Unfolded
        WeaponRespect:
            TNT1 A 0 {
				A_SetCrosshair(-1);
                A_StartSound("weapons/spas12/pumpback",CHAN_AUTO);
            }
            // Select
            SPAA MLKJ 1 {
                SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
                return A_DoPBWeaponAction();
            }
		    // Raise
		    SPAN AAAAA 1 {
                SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
                return A_DoPBWeaponAction();
            }
            "####" BCDEFG 1 A_DoPBWeaponAction();
		    "####" STUUU 1  A_DoPBWeaponAction();
            // Press Button
            SPA9 ABCD 1 {
                SP12_SetSprite('SPA9','SPB9','SPA9','SPB9');
                return A_DoPBWeaponAction();
            }
		    "####" A 0 A_StartSound("MS/Button",CHAN_AUTO,CHANF_OVERLAP);
		    "####" DCBA 1 A_DoPBWeaponAction();
            // Insert Shell
            SPAN UUUUUU 1 {
                SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
                return A_DoPBWeaponAction();
            }
            "####" VW 1 A_DoPBWeaponAction();
            "####" A 0 A_StartSound("weapons/spas12/insert", CHAN_AUTO);
            "####" X 1 A_DoPBWeaponAction();
            SPAN YZ 1 {
                SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
                return A_DoPBWeaponAction();
            }
            "####" "[]" 1 A_DoPBWeaponAction();
            // Rechamber
            SPAN UTS 1 {
                SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
                return A_DoPBWeaponAction();
            }
            "####" H 1 A_DoPBWeaponAction();
            "####" A 0 A_StartSound("weapons/spas12/pumpback",CHAN_AUTO,CHANF_OVERLAP);
            "####" IJJKKLLLLLMMN 1 A_DoPBWeaponAction();
            "####" A 0 A_StartSound("weapons/spas12/pumpforward",CHAN_AUTO,CHANF_OVERLAP);
            // Lower
            "####" PQRGGGFFEDCBA 1 A_DoPBWeaponAction();
            Goto Ready3;

        WeaponInspect:
            // Raise
		    SPAN ABCDE 1 {
                SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
                return A_DoPBWeaponAction();
            }
		    "####" FG 1 A_DoPBWeaponAction();
            "####" A 0 A_StartSound("weapons/spas12/pumpback",CHAN_AUTO,CHANF_OVERLAP);
            // Pump
		    SPA6 ABCDEFFF 1 {
                SP12_SetSprite('SPA6','SPB6','SPA7','SPB7');
                return A_DoPBWeaponAction();
            }
            "####" FF 1 A_DoPBWeaponAction();
        HoldInspect:
            SPA6 G 1 {
                SP12_SetSprite('SPA6','SPB6','SPA7','SPB7');
                return A_DoPBWeaponAction();
            }
            "####" A 0 A_JumpIf(PressingReload(),"HoldInspect");
            "####" A 0 A_StartSound("weapons/spas12/pumpforward",CHAN_AUTO,CHANF_OVERLAP);
            "####" HI 1 A_DoPBWeaponAction();
            // Lower
            SPAN FED 1 {
                SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
                return A_DoPBWeaponAction(); // Goto Inspect2+12
            }
            "####" CBA 1 A_DoPBWeaponAction();
            Goto ReadyToFireAnimation;
            

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            SPAA NOPQ 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    SP12_HandleCrosshair();
                PBX_WeaponRaise("weapons/spas12/raise");
                SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
                if(invoker.mFirstTimePickup)
                {
                    A_Print(SP12_IsSemiAuto() ? "$PBX_SPAS12_SEMI_PICKUP" : "$PBX_SPAS12_MANUAL_PICKUP");
                    invoker. mFirstTimePickup = false;
                }
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            SPAA MLKJ 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
        Ready3:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Ready2");
            TNT1 A 0 {
                PB_SetRoll(0);
                A_ZoomFactor(1.0);
                SP12_HandleCrosshair();
				A_SetInventory("CantWeaponSpecial",0);
				A_SetInventory("CantDoAction",0);
                PB_SetReloading(false);
            }
        ReadyToFire:
			TNT1 A 0 PBX_CheckInspect();
            SPAN A 1 {
				PB_CoolDownBarrel();
                SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
                return PB_ReadyFire();
            }
            Loop;

        ReadyToFireAnimation:
            SPAA FGHI 1 {
                SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
                return PB_ReadyFire();
            }
            Goto Ready3;

        Ready2:
            TNT1 A 0 {
				PB_SetRoll(0);
                A_ZoomFactor(1.25);
                A_SetCrosshair(-1);
				A_SetInventory("CantDoAction",0);
                PB_SetReloading(false);
            }
        ReadytoFire2:
            SPA8 C 1 {
				PB_CoolDownBarrel();
                SP12_SetSprite('SPA8','SPB8','SPA8','SPB8');
                return PB_ReadyFire(ads:true);
            }
            Loop;

        WeaponSpecial:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Zoomout");
            TNT1 A 0 SP12_HandleWheel();
            Goto Ready3;

        SwitchFireModeStart:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				A_StartSound("Ironsights",CHAN_AUTO);
			}
			// Raise Weapon
            SPAN BCDEFG 1 SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
        SwitchFireMode:
		    SPAN STUUU 1 SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
		    SPA9 ABCD 1 SP12_SetSprite('SPA9','SPB9','SPA9','SPB9');
		    "####" A 0 {
                invoker.mSemiAuto = !invoker.mSemiAuto; // Actual mode change
                A_StartSound("MS/Button",CHAN_AUTO,CHANF_OVERLAP);
            }
		    "####" DCBA 1;
		    "####" UUU 1 SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
            Goto ShellChecker;

        FoldSwitchAnimation:
		    TNT1 A 0 A_StartSound("Ironsights",CHAN_AUTO,CHANF_OVERLAP);
		    SPAA NOPQ 1 SP12_SetSprite('SPBA','SPAA','SPBA','SPAA'); // Its reversed so the correct animation plays
		    TNT1 A 10;
		    SPAA MLKJ 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
            Goto Ready3;

        // Dual Blast / Zoom Switch Animation
        SecondarySwitchAnimation:
		    TNT1 A 0 A_StartSound("Ironsights",CHAN_AUTO);
            SPAA RSTU 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
            "####" V 5;
		    "####" A 0 A_StartSound("MS/Button",CHAN_AUTO);
            "####" UTSR 1;
            Goto Ready3;

        AltFire:
			TNT1 A 0 SPAS_HandleAlt();
        ZoomIn:
            TNT1 A 0 {
                A_ZoomFactor(1.25);
                A_SetCrosshair(-1);
				PB_SetZoom(true);
			}
            SPA8 ABC 1 SP12_SetSprite('SPA8','SPB8','SPA8','SPB8');
            Goto Ready2;

        Zoomout:
            TNT1 A 0 {	
				A_ZoomFactor(1.0);
                PB_SetZoom(false);
            }
            SPA8 CBA 1 SP12_SetSprite('SPA8','SPB8','SPA8','SPB8');
            TNT1 A 0 A_JumpIfInventory("GoWeaponSpecialAbility",1,"WeaponSpecial"); // If you weapon special then zoom out first
            Goto Ready3;

        HL2Fire:
			TNT1 A 0 PB_jumpIfNoAmmo(min:2);
            SPAA A 1 Bright     SP12_HLFire();
            "####" B 1 Bright   SPAS_Fire(2);
            "####" C 1          SPAS_Fire(3);
            "####" D 1          SPAS_Fire(4);
            "####" EW 1;
			// "####" A 0 A_JumpIf(invoker.ammo2.amount <= 0, "Reload");
        PumpSlow:
            // Raise
            SPAN BCDEFG 1 SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
            // Pump
            "####" H 1;
            "####" A 0 A_StartSound("weapons/spas12/pumpback", CHAN_AUTO); 
            "####" IJ 1;
            "####" K 1;
            "####" A 0 {
                SPAS_Fire(5);
                PB_SpawnCasing(SP12_IsSemiAuto() ? "ShotgunCasing" : "ShotgunCasing2",15,-5,26,0,3,3);
            }
            "####" L 10;
            "####" MN 1;
            "####" A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_AUTO); 
            "####" OPQR 1;
            "####" A 0 {invoker.mJustFiredDualBlast = false;}
            Goto PumpEnd;

        FireSemi:
            "####" A 0 SPAS_Fire(5); // So it unsets the chamber empty
            SPAA W 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
            SPAN A 4 SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
            "####" AAA 1 PB_ReadyFire(ads:false);
            Goto Ready3;

        Fire:
            TNT1 A 0 {
                A_WeaponOffset(0, 32);
                A_SetRoll(0);
            }
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Fire2");
		Fire1Actual:
			TNT1 A 0 		    PB_jumpIfNoAmmo();
            SPAA A 1 Bright     SPAS_Fire(1);
            "####" B 1 Bright   SPAS_Fire(2);
            "####" C 1          SPAS_Fire(3);
            "####" D 1          SPAS_Fire(4);
            "####" EW 1;
            "####" A 0 {
                if(SP12_IsSemiAuto())
                {
				    A_SetInventory("CantDoAction",0);
                    return ResolveState("FireSemi");
                }
                return ResolveState(null);
            }
			TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"Ready3");
        Pump:
            SPAN BCDEFG 1 SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
		PumpBegin:
            SPAN H 1 {
                SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
                PB_SetReloading(true); 
            }
            "####" A 0 A_StartSound("weapons/spas12/pumpback", CHAN_AUTO); 
            "####" IJ 1;
            "####" A 0 SPAS_Fire(5);
            "####" KLMN 1;
            "####" A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_AUTO); 
            "####" OPQR 1;
		PumpEnd:
            SPAN GF 1 SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
            "####" EDCB 1 {
				A_SetInventory("CantDoAction",0);
				PB_SetReloading(false);
				PB_Refire();
			}
            Goto ReadyToFireAnimation;

        Fire2Semi:
            "####" A 0 SPAS_Fire(5); // So it unsets the chamber empty
            SPA8 KFF 1 SP12_SetSprite('SPA8','SPB8','SPA8','SPB8');
		    "####" FGCCCC 1;
		    "####" CCC 1 PB_ReadyFire(ads:true);
            Goto Ready2;

        Fire2:
            TNT1 A 0 {
				PB_SetRoll(0);
				A_SetCrosshair(-1);
			}
		Fire2Actual:
			TNT1 A 0        PB_jumpIfNoAmmo();
            SPA8 D 1 Bright SPAS_Fire(1);
            "####" E 1;
			"####" A 0      A_ZoomFactor(1.25);
		    "####" A 0      A_JumpIf(SP12_IsSemiAuto(),"Fire2Semi");
            "####" FGC 1;
			"####" A 0      A_JumpIf(invoker.ammo2.amount <= 0,"Ready3");
		Pump2:
            "####" A 0 A_StartSound("weapons/spas12/pumpback", CHAN_AUTO); 
            SPA8 GHII 1 SP12_SetSprite('SPA8','SPB8','SPA8','SPB8');
            "####" JJJJJ 1;
            "####" A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_AUTO); 
            "####" A 0 SPAS_Fire(5);
		    "####" IH 1;
            "####" HGG 1 {
				if(JustPressed(BT_ATTACK) && invoker.ammo2.amount > 0) return ResolveState("Fire2");
                return ResolveState(null);
			}
            "####" A 0 {
				A_SetInventory("CantDoAction",0);
				return PB_ReadyFire(ads:true);
			}
            Goto Ready2;

        ReloadFromADS:
            TNT1 A 0 {	
				SP12_HandleCrosshair();
                A_startsound("IronSights",29);
                A_ZoomFactor(1.25);
            }
            SPA8 CB 1 SP12_SetSprite('SPA8','SPB8','SPA8','SPB8');
			"####" A 0 PB_SetZoom(false);
			"####" A 1;
        Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 PB_CheckReload(null,null,SPAS_CheckPump(),"Ready3","Ready3",MAGAZINE_SIZE);
			TNT1 A 0 A_StartSound("Ironsights",CHAN_AUTO);
            // Raise Weapon
            SPAN BCDEFG 1 SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
		    "####" ST 1 ;
        ShellChecker:
            // Main reload loop
			"####" A 0 A_JumpIf(invoker.ammo1.amount < 1 || invoker.ammo2.amount >= MAGAZINE_SIZE,"FinishReload");
			"####" A 0 PB_SetReloading(true);
            SPAN UUU 1 {
                SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
                return A_DoPBWeaponAction(WRF_NOBOB);
            }
            "####" VW 1 {
                SP12_SetDuration();
                return A_DoPBWeaponAction(WRF_NOBOB);
            }
            "####" A 0 A_StartSound("weapons/spas12/insert", CHAN_AUTO);
            "####" X 1 {
                SP12_SetDuration();
                return A_DoPBWeaponAction(WRF_NOBOB);
            }
            SPAN Y 1 {
                SP12_SetDuration();
                SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
                return A_DoPBWeaponAction(WRF_NOBOB);
            }
            "####" Z 1 A_DoPBWeaponAction(WRF_NOBOB);
            "####" A 0 {
				A_Giveinventory(invoker.ammo2.getClassName(),1);
				A_Takeinventory(invoker.ammo1.getClassName(),1,TIF_NOTAKEINFINITE);
                // PB_RotateCamera(0.2,-0.2,-0.4);
            }
            "####" "[]" 1 A_DoPBWeaponAction(WRF_NOBOB);
            "####" A 0 A_JumpIf(PB_GetChamberEmpty(), "PumpReload");
			Loop;

        PumpReload:
            // Flip the weapon
            SPAN UTS 1 SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
            // Pump
            "####" H 1; 
            "####" A 0 A_StartSound("weapons/spas12/pumpback", CHAN_AUTO); 
            "####" IJ 1;
            "####" A 0 {
                A_StartSound("weapons/spas12/pump", CHAN_AUTO);
                A_ZoomFactor(1.0);
                PB_SetChamberEmpty(false);
				PB_SetMagEmpty(false);
            }
            "####" KLMN 1;
            "####" A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_AUTO); 
            "####" OPQR 1;
            // Flip the weapon
		    "####" ST 1 ;
            goto ShellChecker;

        FinishReload:
            TNT1 A 0 A_StartSound("Ironsights",CHAN_AUTO,CHANF_OVERLAP);
            SPAN TS 1 SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
		    "####" GFEDCB 1;
			TNT1 A 0 PB_SetReloading(false);
            Goto ReadyToFireAnimation;

        Unload:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				A_StartSound("Ironsights",CHAN_AUTO);
			}
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty() && getTokens() == TOGGLE_TYPE, "SwitchFireModeStart");
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(),"Ready3");
			// Raise Weapon
            SPAN BCDEFG 1 SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
		RemoveBullets:
            TNT1 A 0 A_JumpIf(invoker.ammo2.amount <= 0,"FinishUnload");
            SPAN G 1 SP12_SetSprite('SPAN','SPBL','SPA5','SPB5');
            "####" A 0 A_StartSound("weapons/spas12/pumpback", CHAN_AUTO); 
            "####" H 1 A_DoPBWeaponAction();
            "####" IJ 1 A_DoPBWeaponAction();
            "####" KLKJ 1 A_DoPBWeaponAction();
            "####" A 0 SP12_UnloadShells();
            "####" A 0 A_StartSound("weapons/spas12/pumpforward", CHAN_AUTO); 
            "####" IH 1 A_DoPBWeaponAction();
            "####" GF 1 A_DoPBWeaponAction();
			loop;

		FinishUnload:
            TNT1 A 0 {
                PB_SetMagEmpty(true);
                PB_SetChamberEmpty(true);
				PB_SetReloading(false);
                return SP12_ModeChange();
            }
            SPAN EDCBA 1 SP12_SetSprite('SPAN','SPBL','SPAN','SPBL');
			Goto ReadyToFireAnimation;

        FlashKicking:
            SPAA RSTU 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
            "####" V 6;
            "####" UTSR 1;
            Goto Ready3;

        FlashAirKicking:
            SPAA RSTU 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
            "####" V 7;
            "####" UTSR 1;
            Goto Ready3;

        FlashPunching:
            SPAA RSTU 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
            "####" V 8;
            "####" UTSR 1;
            Goto Ready3;

        FlashSlideKicking:
            SPAA RSTU 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
            "####" V 19;
            "####" UTSR 1;
            Goto Ready3;

        FlashSlideKickingStop:
            SPAA VVVUTSR 1 SP12_SetSprite('SPAA','SPBA','SPAA','SPBA');
            Goto Ready3;

	}
}