//	PB Neo HMG 
// 	Original by jaih1r0
//	carrot: resprite of the old PB HMG
//	PC1073: firing sounds
//	Tesefy: the weapons pickup sheet used to frankensprite the pickup sprite of this thing
//	jaih1r0: animations and code
//	old PB 3.0 HMG sprite (couldnt found specific credits :p but im almost sure is eriance)
// 	HMG Shield is from BDP made by EmeraldCoast and the BDP Team
// 	Shield Sounds (Ported from BDP Assault Shotgun): Created/edited/mixed by Dissy EX
// 	(Sounds sourced and modified from Halo: Reach, Halo 4, Counter-Strike: Global Offensive, and Doom Eternal)

// Includes
#include "./NeoHMG_Functions.zs"

class PBX_NeoHMG : PBX_WeaponBase
{
	Default
	{
        //$Title NeoHMG
        //$Category Weapons
        //$Sprite HG0WA0
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        Inventory.AltHudIcon "HG0WA0";
		PB_WeaponBase.MaxOverheat MAX_OVERHEAT;
		PB_WeaponBase.OverheatCoolingRate OVERHEATCOOLING_RATE;
		PB_WeaponBase.ReserveToMagAmmoFactor 1;

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
		Weapon.AmmoType1 "PB_HighCalMag";
	    Weapon.AmmoType2 "HMGChamberAmmo";
	    Weapon.AmmoGive1 80;
		
//////////////////////////// SPRITES & OFFSETS ////////////////////////////////////////////////////////////////////////////////////
        PB_WeaponBase.OffsetRecoilX 2.5;
		PB_WeaponBase.OffsetRecoilY 2.0;
		PB_WeaponBase.TailPitch 0.8;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Obituary "$OB_WEAP_NEOHMG";
        Inventory.PickupMessage "$PBX_NeoHMG_Pickup";
        Inventory.PickupSound "LMGPKP";
	    Tag "$PBX_NeoHMG_Tag";
        
//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +FORCEXYBILLBOARD
	}
	
//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
	// Constants
	const MAGAZINE_SIZE 		= 80;
	const SHIELD_MAXCHARGE 		= 120;
	const HMG_SHIELDLAYER 		= -567;
	const HMG_SHIELDSOUNDLAYER 	= 234;
	const HMG_SHIELDSOUNDLAYER2 = 233;

	const MAX_OVERHEAT	 		= 300;
	const OVERHEAT_THRESHOLD	= 80;	// Overheat threshold for firing the special rounds
	const OVERHEATCOOLING_RATE 	= 4;	// How many tics before removing 5 overheat when not selected
	const OVERHEATCOOLING_RATE2 = -5;	// Decrease overheat when the weapon is selected
	const OVERHEATCOOLING_LAYER = 3;
	const OVERHEAT_GIVE_OVR 	= 12;	// How much heat given when over Threshold
	const OVERHEAT_GIVE_NORM	= 10;	// How much heat given when normal fire

	// Shield Variables
	bool mShieldActive;
	bool mShieldIsReady;
	bool mShieldWasActive;
	bool mShieldIsBroken;
	int mShieldCooldown;
	int mShieldRechargeTimer;
	int mShieldFrame;
	int mShieldDrain;

	// Shield Values
	const SHIELD_PROTECTION_MULTIPLIER = 1;   // How many shield charges are consumed per point of damage (Multiplier)
	const SHIELD_RECHARGE_CYCLE = 5; 		  // How many tics before doing the shield charge cycle
	const SHIELD_RECHARGE_AMOUNT = 2; 		  // How many shield charges to give each cycle
	const SHIELD_COOLDOWN = 15; 			  // How many tics before shield is available again

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
	States
	{
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
		Spawn:
            HG0W A -1;
            Stop;

        Deselect:
			TNT1 A 0 {
				invoker.mShieldWasActive = false;
				A_ClearOverlays(OVERHEATCOOLING_LAYER,OVERHEATCOOLING_LAYER);
				A_ClearOverlays(HMG_SHIELDLAYER,HMG_SHIELDLAYER);
			}
            HG0D ABCD 1;
			TNT1 A 0 A_lower(120);	
			wait;

		WeaponRespect:
			HG0U ABCD 1 A_DoPBWeaponAction();
			goto ready3;

		Select:
			TNT1 A 0 {
				invoker.mShieldWasActive = false;
				A_ClearOverlays(OVERHEATCOOLING_LAYER,OVERHEATCOOLING_LAYER);
				A_ClearOverlays(HMG_SHIELDLAYER,HMG_SHIELDLAYER);
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(52);
                PBX_WeaponRaise("HMGUP");
				cooldownOverheat();
			    return PB_RespectIfNeeded();
			}
		SelectAnimation:
			TNT1 A 0 A_JumpIf(PB_GetMagUnloaded(), "UnloadedSelect");
			HG0U ABCD 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
		Ready3:
			TNT1 A 0 {
				if(PB_GetOverheat() > 1) {cooldownOverheat();}
				PB_HandleCrosshair(52);
			}
		ReadyToFire:
			// Load Sprites
			XH01 A 0; XH02 A 0;
			XH03 A 0; XH04 A 0;
			// Actual Code
			HG0F A 1 {
				PB_HandleCrosshair(52);
				HMG_CoolDownBarrel();
				setMagSprite("HG0F","XH04","XH03","XH02","XH01");

				// Unload sprite
				if(PB_GetMagUnloaded())
				{
					A_SetWeaponSpriteEx("HG0R");
					A_SetWeaponFrame(17);
				}

				// So you can still fire even when the shield is up
				if (PressingFire() && PressingAltfire() && CountInv(invoker.ammotype2) > 0)
					return resolvestate("Fire");
				return A_DoPBWeaponAction(); 
			}
			loop;
		
		UnloadedSelect:
			HG0R MNOPQRS 1;
			goto Ready3;

		Overheat:
			TNT1 A 0 A_StartSound("MG42HEAT", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			TNT1 A 0 A_StartSound("weapons/chagan/stop", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			TNT1 A 0 {
				HMG_CoolDownBarrel();
				cooldownOverheat();
			}
			TNT1 A 0 HMG_DetonateShield();
			HG0F A 45 {
				setMagSprite("HG0F","XH04","XH03","XH02","XH01");
				return A_DoPBWeaponAction(WRF_NOFIRE|WRF_NOSWITCH);
			}
			Goto Ready3;
        
//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
		Fire:
			// Load Sprites
			XH01 BCDEF 0;
			XH02 BCDEF 0;
			XH03 BCDEF 0;
			XH04 EF 0;
			// Actual Code
			TNT1 A 0 A_JumpIf(PB_GetOverheat() >= MAX_OVERHEAT-5,"overheat");
			TNT1 A 0 PB_HandleCrosshair(52);
            TNT1 A 0 PB_jumpIfNoAmmo("Reload",1,false);
			TNT1 A 0 A_StartSound("weapons/chagan/start", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			HG0F A 9;
		Hold:
			TNT1 A 0 A_JumpIf(PB_GetOverheat() >= MAX_OVERHEAT-5,"overheat");
            TNT1 A 0 PB_jumpIfNoAmmo("Reload",1,false);
			HG0F B 1 bright {
				setMagSprite("HG0F","HG0F","XH03","XH02","XH01");
				fireHMG(1);
			}
			"####" C 1 bright fireHMG(2);
			"####" D 2 A_ZoomFactor(1.0);
			HG0F E 1 setMagSprite("HG0F","XH04","XH03","XH02","XH01");
			"####" A 0 A_Weaponoffset(0,32);
			"####" F 1 PB_Refire();
			TNT1 A 0 A_StartSound("weapons/HMG/Stop", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			TNT1 A 0 A_StartSound("weapons/chagan/stop", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			HG0F A 7;
			goto Ready3;

		// AltFire:
		// 	TNT1 A 0;
		// 	goto Ready3;

		HMGShieldBash:
			PSHL E 0 {
				if(countinv("HMGShield") <= 0)
				{
					return resolvestate("HMGShieldBreak");
				}
				A_FireProjectile("KickAttack");
				return resolvestate(null);
			}
		HMGShield:
			TNT1 A 0 {
				if(countinv("HMGShield") <= 0)
				{
					return resolvestate("HMGShieldBreak");
				}
				A_OverlayFlags(HMG_SHIELDLAYER,PSPF_FLIP,random[sfx](0,1));
				A_OverlayFlags(HMG_SHIELDLAYER,PSPF_RENDERSTYLE|PSPF_FORCESTYLE|PSPF_ALPHA|PSPF_FORCEALPHA,true);
				A_OverlayRenderStyle(HMG_SHIELDLAYER,STYLE_Add);
				A_OverlayAlpha(HMG_SHIELDLAYER,0.5);
				return resolvestate(null);
			}
			TNT1 A 0 A_JumpIf(invoker.mShieldFrame > 0,"HMGShield2");
			PSHL A 1 BRIGHT {invoker.mShieldFrame++;}
			stop;
		HMGShield2:
			TNT1 A 0 A_JumpIf(invoker.mShieldFrame > 1,"HMGShield3");
			PSHL B 1 BRIGHT {invoker.mShieldFrame++;}
			stop;
		HMGShield3:
			TNT1 A 0 A_JumpIf(invoker.mShieldFrame > 2,"HMGShield4");
			PSHL C 1 BRIGHT {invoker.mShieldFrame++;}
			stop;
		HMGShield4:
			TNT1 A 0 A_JumpIf(invoker.mShieldFrame > 3,"HMGShield5");
			PSHL D 1 BRIGHT {invoker.mShieldFrame++;}
			stop;
		HMGShield5:
			TNT1 A 0 A_JumpIf(invoker.mShieldFrame > 4,"HMGShield6");
			PSHL E 1 BRIGHT {invoker.mShieldFrame++;}
			stop;
		HMGShield6:
			TNT1 A 0 A_JumpIf(invoker.mShieldFrame > 5,"HMGShield7");
			PSHL F 1 BRIGHT {invoker.mShieldFrame++;}
			stop;
		HMGShield7:
			TNT1 A 0 A_JumpIf(invoker.mShieldFrame > 6,"HMGShield8");
			PSHL G 1 BRIGHT {invoker.mShieldFrame++;}
			stop;
		HMGShield8:
			PSHL H 1 BRIGHT {invoker.mShieldFrame = 0;}
			stop;
		HMGShieldBreak:
			PSHL A 0 A_FireShieldParticles();
			stop;
		HMGShieldBroken:
			TNT1 A 0 {
				A_StartSound("PLSULT", CHAN_WEAPON, CHANF_OVERLAP);
				A_SetBlend("Blue", 0.6, 12);	
				HMGSpawnStunBomb();
				A_FireShieldParticles();
				PB_SetOverheat(0);
			}
			stop;
		
//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
		Reload:
			// Load Sprites
			XH1R A 0; XH2R A 0; XH3R A 0;
			XH4R A 0; XHR1 A 0; XHR2 A 0;
			XHR3 A 0; XHR4 A 0;
			// Actual Code
            TNT1 A 0 {
				A_ZoomFactor(1.0);
				A_WeaponOffset(0,32);
			}
			TNT1 A 0 PB_checkReload("RaiseFromEmpty", null, null, "Ready","Ready",MAGAZINE_SIZE,1);
			HG0R ABCDE 1 setMagSprite("HG0R","XHR4","XHR3","XHR2","XHR1");
			HG0R FGH 1 setMagSprite("HG0R","HG0R","XHR3","XHR2","XHR1");
			"####" A 0 A_StartSound("weapons/sgl/detach", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			"####" A 0 A_JumpIf(PB_GetMagUnloaded(),"Reload_Unloaded");
			"####" A 0 {
				if(invoker.ammo2.amount < 1 && !PB_GetMagUnloaded())
					PB_SpawnCasing("EmptyLMGMag", 12, -2.5, 6.25,frandom(2,5),frandom(1,3),frandom(2,4));
			}
			"####" I 1;
			HG0R JK 1;
			HG0R L 1 {
				PB_SetMagUnloaded(true);
				PB_SetChamberEmpty(true);
			}
			HG0R MNOOPP 1;
			HG0R QQQ 1;
			HG0R QRST 1;
		Reload_Unloaded:	
			TNT1 A 0 A_StartSound("weapon/HMG/Reload1", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			HG0R U 1;
			HG0R V 1 setMagSprite("HG0R","XHR4","XHR3","XHR2","XHR1");
			"####" A 0 {
				PB_AmmoIntoMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname(),MAGAZINE_SIZE);
				PB_SetMagEmpty(false);
				PB_SetMagUnloaded(false);
				PB_SetChamberEmpty(false);
			}
			"####" W 1;
			"####" XX 1;
			"####" YYZ 1;
			"####" ABC 1 setMagSprite("HG1R","XHR4","XHR3","XHR2","XHR1");
			goto Ready3;

        RaiseFromEmpty:
            HG0R S 1;
            goto Reload_Unloaded;

//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
		Unload:
			// Load Sprites
			XHR1 A 0; XHR2 A 0; HG1R A 0;
			XHR3 A 0; XHR4 A 0;
			// Actual Code
			TNT1 A 0 A_Jumpif(pb_getmagunloaded(),"Ready3");
			HG0R ABCDE 1 setMagSprite("HG0R","XHR4","XHR3","XHR2","XHR1");
			HG0R FGH 1 setMagSprite("HG0R","HG0R","XHR3","XHR2","XHR1");
			"####" A 0 A_StartSound("weapons/sgl/detach", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			"####" I 1;
			HG0R JK 1;
			HG0R L 1 {
				PB_UnloadMag(invoker.ammo2.getclassname(),invoker.ammo1.getclassname(),1);
				PB_SetMagUnloaded(true);
				PB_SetChamberEmpty(true);
			}
			HG0R MNOOPP 1;
			HG0R QQQ 1;
			HG0R QRS 1; 
			goto Ready3;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
		Weaponspecial:
			TNT1 A 0 HMG_HandleSpecial();
			// HG0U DDDDCC 1;
			// TNT1 A 0 A_StartSound("excavator/switch", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
			// HG0U CCDDDD 1;
			goto Ready3;
		
//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
		FlashPunching:
			TNT1 A 0 cooldownOverheat();
			HG0K ABCDEFGHFEDCBA 1;
			goto Ready3;
		
		FlashKicking:
			TNT1 A 0 cooldownOverheat();
			HG0K ABCDEFGHHFEDCBA 1;
			goto Ready3;
			
		FlashAirKicking:
			TNT1 A 0 cooldownOverheat();
			HG0K ABCDEFGHHHFEDCBA 1;
			goto Ready3;
			
		FlashSlideKicking:
			TNT1 A 0 cooldownOverheat();
			HG0K ABCDEFGHHHHHHHHHHHHHGFEDCBA 1;
			goto Ready3;
			
			TNT1 A 0 cooldownOverheat();
		FlashSlideKickingStop:
			HG0K GFEDCBA 1;
			goto Ready3;
		
//////////////////////////// OVERLAYS ////////////////////////////////////////////////////////////////////////////////////
		Cooling:
			TNT1 A 8;
			TNT1 A 4 {
				PBXCore_Debug.Print("Lowered Overheat");
				PB_ModifyOverheat(OVERHEATCOOLING_RATE2);
			}
			Wait;

		MuzzleFlash:
			TNT1 A 0 A_jump(256,"Muzzle1","Muzzle2","Muzzle3");
		Muzzle1:
			HG0M AB 1 bright;
			stop;
		Muzzle2:
			HG0M CD 1 bright;
			stop;
		Muzzle3:
			HG0M EF 1 bright;
			stop;
	}
}

