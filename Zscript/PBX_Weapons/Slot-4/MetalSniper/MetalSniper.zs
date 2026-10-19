// Metalsniper 
// Original by Metalman (Sprites)
// Jaih1r0 (Code/Animations)
// PC1073 and Ravik (Sounds)
// Updated by AresFallen/ItAres

// Includes
#include "./MetalSniper_Functions.zs"
#include "./MetalSniper_Wheel.zs"

// Normal Wheel Tokens
class MS_Select_AimMode : inventory {default{inventory.maxamount 1;}}
class MS_Select_GrenMode : inventory {default{inventory.maxamount 1;}}
class MS_Select_Resonance : inventory {default{inventory.maxamount 1;}}
class MS_Select_NO : inventory {default{inventory.maxamount 1;}}
// Other Tokens
class MetalSniperUpgraded : inventory {default{inventory.maxamount 1;}}

Class PBX_MetalSniper : PBX_WeaponBase
{
    default
    {
        inventory.pickupsound "CLIPIN";
        inventory.pickupmessage "$PBX_MetalSniper_Pickup";
        Inventory.AltHudIcon "MSNWA0";
        weapon.ammotype1 "PB_HighCalMag";
        weapon.ammogive1 32;
        weapon.ammotype2 "MetalSniperAmmo";
        PB_WeaponBase.UsesWheel true;
        PB_WeaponBase.WheelInfo "MetalSniperWheel";
		PB_WeaponBase.ReserveToMagAmmoFactor AMMO_TAKE_NORMAL;
        PBX_WeaponBase.ScopeConfiguration true, MINZOOM, MAXZOOM; 
        Tag "$PBX_MetalSniper_Tag";
		Obituary "$OB_WEAP_METALSNIPER";
        scale 0.62;
        +weapon.noalert;
        +weapon.noautofire;
    }

    // ── Constants ────────────────────────────────────────────────────────────
    const MAGAZINE_SIZE = 12; // mag size for resonance is 4
    const AMMO_TAKE_NORMAL = 2;
    const AMMO_TAKE_RESONANCE = 6;
    const muzzlelayer = -52;
    const MINZOOM = 1.25;
    const MAXZOOM = 12.0;

    // ── State ─────────────────────────────────────────────────────────────────
    bool resonanceAmmoLoaded;
    bool grenadeloaded;
    bool AltMode;
    bool enableScopeHUD; // This is for the overlay that you see when the scope mode is active
    int currentMaxAmmo;

    enum MS_WheelMode
    {
        ERROR_WHEEL = -3,
        CLOSE_WHEEL,
        NO_UPGRADE,
        ZOOM_ALTFIRE,
        GRENADE_ALTFIRE,
        TOGGLE_RESONANCE,
        TOGGLE_LASER,
        TOGGLE_SCOPE,
        TOGGLE_NVG
    }

    // ═════════════════════════════════════════════════════════════════════════
    // STATES
    // ═════════════════════════════════════════════════════════════════════════
    states
    {
        // ── Spawn ─────────────────────────────────────────────────────────
        Spawn:
            MSNW A -1;
            stop;

        // ── Weapon Respect ──────────────────────
        WeaponRespect:
            TNT1 A 0 A_SetCrosshair(-1);
            MSNI ABCDEFGHIJKLMNOPQRSSSS 1 A_DoPBWeaponAction();
            MSU0 ABCDEFGHIJKL 1 A_DoPBWeaponAction();
            M3NC ABCDEFGHI 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MS/BoltDown",CHAN_AUTO);
            M3NC J 15 A_DoPBWeaponAction();
            M3NC K 10 A_DoPBWeaponAction();
            M3NC LL 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MS/BoltUp",CHAN_AUTO);
            M3NC M 1 A_DoPBWeaponAction();
            MSNR ABCDEFG 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MS/InsertMag",CHAN_AUTO);
            MSNR HIJKLMNOPQR 1 A_DoPBWeaponAction();
            MSU1 LKJIHGFEDCBA 1 A_DoPBWeaponAction();
            MSNI T 1 A_DoPBWeaponAction();
            MSNI UVWXYZ 1 A_DoPBWeaponAction();
            MSNJ AAB 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MS/BoltDown",CHAN_AUTO);
            MSNJ BCDEEF 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MS/BoltUp",CHAN_AUTO);
            MSNJ GHIJKL 1 A_DoPBWeaponAction();
            goto Ready3;

        WeaponInspect:
            MSNI T 1 A_DoPBWeaponAction();
            MSNI UVWXYZ 1 A_DoPBWeaponAction();
            MSNJ AAB 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MS/BoltDown",CHAN_AUTO);
            MSNJ BCDE 1 A_DoPBWeaponAction();
        HoldInspect:
            MSNJ E 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
            MSNJ EF 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("MS/BoltUp",CHAN_AUTO);
            MSNJ GHIJKL 1 A_DoPBWeaponAction();
            Goto Ready3;

        // ── 1t / Deselect ─────────────────────────────────────────────
        Select:
            TNT1 A 0 {
                PBX_WeaponRaise("MS/Up");
                return PB_RespectIfNeeded();
            }
        SelectAnimation:
            MSNU ABCD 1;
            goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            MSND ABCD 1;
            TNT1 A 0 A_Lower(120);
            wait;

        // ── Ready (hip-fire) ──────────────────────────────────────────────
        //    Sprite-only states consumed by animation tools — never looped into.
        Ready:
            MST0 ABCDEFGHIJKL 0;        // take mag empty
            MST3 ABCDEFGHIJKL 0;        // take mag resonance
            MST1 ABCDEFGHIJKL 0;        // take mag standard
            MSNC ABCDEFGHIJKLM 0;       // standard chamber
            M3NC ABCDEFGHIJKLM 0;       // empty chamber
            MSN4 ABCDEFGHIJKLM 0;       // resonance chamber
            MSU0 ABCDEFGHIJKL 0;        // raise no mag
            MSU1 ABCDEFGHIJKL 0;        // raise normal
            MSNR ABCDEFGHIJKLMNOPQR 0;  // insert standard mag
            MSR6 ABCDEFGHIJKLMNOPQR 0;  // insert resonance mag 
        Ready3:
            TNT1 A 0 {
                PB_HandleCrosshair(42);
                A_ZoomFactor(1.0);
            }
            TNT1 A 0 A_JumpIf(PB_GetZoom(), "Ready2");
        ReadyToFire:
            TNT1 A 0 PBX_CheckInspect();
            MSNF A 1 {
                PB_HandleCrosshair(42);
                PB_CoolDownBarrel(-4, 0, 6, 0,  1);
                PB_CoolDownBarrel( 4, 0, 6, 0, -1);
                return A_DoPBWeaponAction(WRF_ALLOWRELOAD);
            }
            loop;

        // ── No Ammo States ─────────────────────────────────────────────
        NoAmmo:
            MSNF A 1 A_StartSound("weapons/empty",CHAN_AUTO);
            goto Ready3;

        NoAmmo_Grenade:
            MSNG A 1 A_StartSound("weapons/empty",CHAN_AUTO);
            goto AltFire_Grenade;

        // ── Fire ────────────────────────────────────────────────────
        Fire:
            TNT1 A 0 {
                A_WeaponOffset(0, 32);
                PB_SetRoll(0);
                PB_HandleCrosshair(42);
            }
            TNT1 A 0 A_JumpIf(PB_GetZoom(), "Fire_ADS");
            TNT1 A 0 PB_JumpIfNoAmmo("Reload");
            TNT1 A 0 A_AlertMonsters();
            MSNF B 1 bright MetalSniperFire();
            MSNF C 1 bright;
            MSNF DDDEF 1;
            MSNF GHAAAAAA 1;
            MSNF AAAA 1 {
                if (PlayerPressedOnce(BT_ATTACK)) return resolvestate("Fire");
                return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOFIRE);
            }
            TNT1 A 0 A_Refire("Fire");
            goto Ready3;

        // ── AltFire: zoom or grenade mode ────────────────────────────────
        AltFire:
            TNT1 A 0 A_JumpIf(invoker.AltMode == GRENADE_ALTFIRE, "AltFire_Grenade");
        AltFire_Zoom:
            TNT1 A 0 A_JumpIf(PB_GetZoom(), "ZoomOut");
        ZoomIn:
            TNT1 A 0 {
                invoker.wheelinfo = "MS_Zoomed_Wheel";
                PB_SetZoom(true);
                A_StartSound("IronSights",CHAN_AUTO);
				A_SetCrosshair(-1);
				A_ZoomFactor(1.25);
            }
            MSNA ABC 1;
            TNT1 A 0 A_ZoomFactor(PBX_GetZoomLevel());
            MSNA DEF 1;
            goto Ready2;

        ZoomOut:
            TNT1 A 0 {
				A_StartSound("IronSights",CHAN_AUTO);
				A_ZoomFactor(1.0);
				PB_SetZoom(false);
			}
            MSNA FED 1;
            MSNA CBA 1;
            goto Ready3;

        // ── Ready (ADS) ───────────────────────────────────────────────────
        Ready2:  
        Ready_ADS:
            MSNS A 1 MS_ReadyZoom();
            loop;

        // ── Fire (ADS) ────────────────────────────────────────────────────
		Fire2:
        Fire_ADS:
            TNT1 A 0 PB_JumpIfNoAmmo();
        ActualFireADS:
            MSNS B 1 bright MetalSniperFireADS();
        FireADSContinue:
            MSNS C 1 bright;
            MSNS DDD 1;
            MSNS EFG 1;
            MSNS HIAAAAAA 1;
            MSNS AAAA 1 {
                // A_SetInventory("CantDoAction", 0);
                if (PB_GetAimMode())
                {
                    if (JustReleased(BT_ALTATTACK)) return resolvestate("ZoomOut");
                    if (JustPressed(BT_ATTACK) && PressingAltfire()) return resolvestate("Fire_ADS");
                }
                else
                {
                    if (PressingAltfire())  return resolvestate("ZoomOut");
                    if (JustPressed(BT_ATTACK)) return resolvestate("Fire_ADS");
                    A_Refire("Fire_ADS");
                }
                return A_DoPBWeaponAction(WRF_ALLOWRELOAD | WRF_NOFIRE);
            }
            goto Ready2;

        // ── Grenade mode ──────────────────────────────────────────────────
        AltFire_Grenade:
            MSNG A 1 {
                PB_CoolDownBarrel(-4, 0, 6,  0,  1);
                PB_CoolDownBarrel( 4, 0, 6,  0, -1); 
                if (PlayerPressedOnce(BT_ATTACK))
                    return (getgrenqtty() > 0) ? resolvestate("FireGrenade") : resolvestate("Reload_Grenade");
                return resolvestate(null);
            }
            TNT1 A 0 A_Refire("AltFire_Grenade");
            goto Ready3;

        FireGrenade:
            TNT1 A 0 A_Overlay(muzzlelayer, "MuzzleFlash_Gren");
            TNT1 A 0 A_AlertMonsters();
            TNT1 A 0 A_StartSound("MS/Grenade",CHAN_AUTO);
            MSNG B 1 bright A_FireProjectile("PB_FragGrenade", 0, 0);
            TNT1 A 0 MS_SetGrenadeQ(0);
            TNT1 A 0 PB_FireOffset();
            TNT1 A 0 PB_GunSmoke(0, 0, -2);
            TNT1 A 0 PB_WeaponRecoil(-3, frandom[sfx](-1.5, 1.5));
            MSNG C 1 bright;
            MSNG DEFGA 1;
            TNT1 A 0 A_JumpIf(CountInv("PB_RocketAmmo") > 0, "Reload_Grenade");
            goto Ready3;

        Reload_Grenade:
            TNT1 A 0 A_JumpIf(CountInv("PB_RocketAmmo") < 1, "NoAmmo_Grenade");
            MSNL ABCDEFGGG 1;
            TNT1 A 0 A_StartSound("MS/GrenOpen",CHAN_AUTO);
            MSNL G 1;
            TNT1 A 0 PB_SpawnCasing("EmptyGrenadeBrass", 30, -2, 34, frandom(1.0, 2.0), frandom(-4.0, -2.0), 1.0);
            MSNL HIJKLMN 1;
            TNT1 A 0 {
                if (CountInv("PB_RocketAmmo") > 0)
                {
                    MS_SetGrenadeQ(1);
                    A_TakeInventory("PB_RocketAmmo", 1);
                }
                A_StartSound("MS/GrenClose",CHAN_AUTO);
            }
            MSNL OPQRSTUGGGTTT 1;
            MSNL FEDCBA 1;
            TNT1 A 0 A_Refire("AltFire_Grenade");
            goto Ready3;

        // ── Reload ────────────────────────────────────────────────────────
        ReloadFromADS:
            TNT1 A 0 A_StartSound("IronSights",CHAN_AUTO);
            TNT1 A 0 A_ZoomFactor(1.5);
            MSNA FED 1;
            TNT1 A 0 PB_SetZoom(false);
            MSNA CBA 1;
        Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 A_ZoomFactor(1.0);
            TNT1 A 0 PB_CheckReload("RaiseFromEmpty", null, "Start_Rechamber", "Ready3", "NoAmmo", invoker.currentMaxAmmo, invoker.ReserveToMagAmmoFactor);
        // ── Raise weapon  ──────────────────
        StandardReload:
            TNT1 A 0 A_StartSound("IronSights",CHAN_AUTO);
            MSU1 ABCDEFGHIJKL 1;    // raise
            TNT1 A 0 A_JumpIf(invoker.resonanceAmmoLoaded, "TakeMagResonance");
        // Take standard mag out
        TakeMagStandard:
            MST1 ABCD 1 { if (PB_GetMagEmpty()) A_SetWeaponSprite("MST0"); }
            "####" A 0 A_StartSound("MS/Button",CHAN_AUTO);
            "####" E 1;
            "####" A 0 {
                A_StartSound("MS/TakeMag",CHAN_AUTO);
                PB_SetMagUnloaded(true);
            }
            "####" FGHIJKL 1;
            goto InsertMag;

        // Take resonance mag out
        TakeMagResonance:
            MST3 ABCD 1 { if (PB_GetMagEmpty()) A_SetWeaponSprite("MST0"); }
            "####" A 0 A_StartSound("MS/Button",CHAN_AUTO);
            "####" E 1;
            "####" A 0 {
                A_StartSound("MS/TakeMag",CHAN_AUTO);
                PB_SetMagUnloaded(true);
            }
            "####" FGHIJKL 1;
        // Insert new mag
        InsertMag:
            MSNR ABCDEFG 1 { if (invoker.resonanceAmmoLoaded) A_SetWeaponSprite("MSR6"); }
            TNT1 A 0 A_StartSound("MS/InsertMag",CHAN_AUTO);
            MSNR HIJKL 1 ;
            TNT1 A 0 {
                MS_ReloadMag();
                PB_SetMagUnloaded(false);
                PB_SetMagEmpty(false);
            }
            MSNR MNOPQR 1 ;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "Rechamber");
        FinishReload:
            MSU1 LKJIHGFEDCBA 1;    // lower
            TNT1 A 0 PB_SetReloading(false);
            goto Ready3;

        // ── Raise from fully empty mag ────────────────────────────────────
        RaiseFromEmpty:
            TNT1 A 0 A_StartSound("IronSights",CHAN_AUTO);
            MSU0 ABCDEFGHIJKL 1;    // empty-mag raise
            goto InsertMag;

        // ── Rechamber ──────────────────────────
        Start_Rechamber:
            TNT1 A 0 A_StartSound("IronSights",CHAN_AUTO);
            MSU1 ABCDEFGHIJKL 1;    // raise
        Rechamber:
            MSNC ABCDEFG 1 ;
            TNT1 A 0 A_StartSound("MS/BoltDown",CHAN_AUTO);
            TNT1 A 0 PB_SetChamberEmpty(false);
            MSNC HIJ 1 ;
			MSNC K 1 { if (invoker.resonanceAmmoLoaded) A_SetWeaponSprite("MSN4"); }
			MSNC L 1 ;
            TNT1 A 0 A_StartSound("MS/BoltUp",CHAN_AUTO);
            MSNC M 1 ;
			goto FinishReload;

        // ── Reload from special ─────────────
        ReloadFromSpecial:
            TNT1 A 0 MS_HandleAmmoChange();
            MSR6 ABCDEFG 1 { if (!invoker.resonanceAmmoLoaded) A_SetWeaponSprite("MSNR"); }
            TNT1 A 0 A_StartSound("MS/InsertMag",CHAN_AUTO);
            MSNR HIJKL 1;
            TNT1 A 0 {
                MS_ReloadMag();
                PB_SetMagUnloaded(false);
                PB_SetMagEmpty(false);
            }
            MSNR MNOPQR 1;
            goto Rechamber;

        // ── Unload ────────────────────────────────────────────────────────
        UnloadFromSpecial:
            TNT1 A 0 A_StartSound("IronSights",CHAN_AUTO);
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded() && !PB_GetChamberEmpty(), "StartUnloadChamber");
            MSU1 ABCDEFGHIJKL 1;
            TNT1 A 0 A_JumpIf(invoker.resonanceAmmoLoaded, "UnloadMagResonance");
			goto UnloadMagStandard;

		Unload:
            TNT1 A 0 A_StartSound("IronSights",CHAN_AUTO);
            // If mag already unloaded, skip straight to chamber
            TNT1 A 0 A_JumpIf(PB_GetMagUnloaded() && !PB_GetChamberEmpty(), "StartUnloadChamber");
        UnloadRaise:
            MSU1 ABCDEFGHIJKL 1;
            TNT1 A 0 A_JumpIf(PB_GetMagEmpty(), "UnloadMagEmpty");
            TNT1 A 0 A_JumpIf(invoker.resonanceAmmoLoaded, "UnloadMagResonance");
        // Standard mag unload
        UnloadMagStandard:
            MST1 ABCD 1;
            TNT1 A 0 A_StartSound("MS/Button",CHAN_AUTO);
            MST1 E 1;
            TNT1 A 0 A_StartSound("MS/TakeMag",CHAN_AUTO);
            MST1 FGH 1;
            TNT1 A 0 {
                MS_UnloadMag();
                PB_SetMagUnloaded(true);
                PB_SetMagEmpty(true);
            }
            MST1 IJKL 1;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "FinishUnload");
            goto UnloadChamber;

        // Empty mag unload
        UnloadMagEmpty:
            MST0 ABCD 1;
            TNT1 A 0 A_StartSound("MS/Button",CHAN_AUTO);
            MST0 E 1;
            TNT1 A 0 {
                MS_UnloadMag();
                PB_SetMagUnloaded(true);
                PB_SetMagEmpty(true);
            }
            TNT1 A 0 A_StartSound("MS/TakeMag",CHAN_AUTO);
            MST0 FGHIJKL 1;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "FinishUnload");
            goto UnloadChamber;

        // Resonance mag unload
        UnloadMagResonance:
            MST3 ABCD 1;
            TNT1 A 0 A_StartSound("MS/Button",CHAN_AUTO);
            MST3 E 1;
            TNT1 A 0 {
                MS_UnloadMag();
                PB_SetMagUnloaded(true);
                PB_SetMagEmpty(true);
            }
            TNT1 A 0 A_StartSound("MS/TakeMag",CHAN_AUTO);
            MST3 FGHIJKL 1;
            TNT1 A 0 A_JumpIf(PB_GetChamberEmpty(), "FinishUnload");
            goto UnloadChamber;

        // Unchamber
        UnloadChamber:
            M3NC ABCDEFGHI 1;
            TNT1 A 0 A_StartSound("MS/BoltDown",CHAN_AUTO);
            M3NC JKL 1;
            TNT1 A 0 {
                MS_UnloadMag(true);     // UnloadChamber = true
                PB_SetChamberEmpty(true);
            }
            TNT1 A 0 A_StartSound("MS/BoltUp",CHAN_AUTO);
            M3NC M 1;
        FinishUnload:
            TNT1 A 0 A_JumpIfInventory("MS_Select_Resonance", 1, "ReloadFromSpecial");
            MSU0 LKJIHGFEDCBA 1;    // lower
            goto Ready3;

        // Skip raise — already raised when mag was manually removed
        StartUnloadChamber:
            MSU0 ABCDEFGHIJKL 1;
            goto UnloadChamber;

        // ── Weapon Special ────────────────────
        WeaponSpecial:
            TNT1 A 0 A_SetCrosshair(-1);
            TNT1 A 0 A_TakeInventory("GoWeaponSpecialAbility", 1);
            TNT1 A 0 MS_HandleSpecial();
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Ready2");
        ChangeAnim:
            TNT1 A 0 A_StartSound("IronSights",CHAN_AUTO);
            MSSW ABCDEFF 1;
            TNT1 A 0 A_StartSound("MS/Button",CHAN_AUTO);
            MSSW GHIJKLM 1;
            goto Ready3;

        // ── Muzzle flashes ────────────────────────────────────────────────
        MuzzleFlash:
            TNT1 A 0 A_OverlayFlags(overlayID(), PSPF_MIRROR | PSPF_FLIP, random(0, 1));
            MSNM A 1 bright;
            MSNM B 1 bright A_SetWeaponFrame(random[sfx](1,2));
            stop;

        MuzzleFlash_ADS:
            TNT1 A 0 A_OverlayFlags(overlayID(), PSPF_MIRROR | PSPF_FLIP, random(0, 1));
            MSNM D 1 bright;
            MSNM E 1 bright A_SetWeaponFrame(random[sfx](4,5));
            stop;

        MuzzleFlash_Gren:
            TNT1 A 0 A_OverlayFlags(overlayID(), PSPF_MIRROR | PSPF_FLIP, random(0, 1));
            MSNM G 1 bright;
            stop;

        // ── Melee flash overlays ──────────────────────────────────────────
        FlashPunching:
            MSNQ ABCDEFGHFEDCBA 1;      // 14 frames
            goto Ready3;

        FlashKicking:
            MSNK ABCDEFGHGFEDCBA 1;     // 15 frames
            goto Ready3;

        FlashAirKicking:
            MSNQ ABCDEFGHHGFEDCBA 1;    // 16 frames
            goto Ready3;

        FlashSlideKicking:
            MSNK ABCDEFGHHHHHHHHHHHHHGFEDCBA 1; // 27 frames
            goto Ready3;

        FlashSlideKickingStop:
            MSNK GFEDCBA 1;             // 7 frames
            goto Ready3;
    }
}
