// Demonic Exterminator 
// Original by Jaih1r0
// Inspect and Mode Switch animation from God Complex by ULtraViolence

// Includes
#include "./DemonicExtFunctions.zs"
#include "./DemonicExtStuff.zs"
#include "./DemonicExt_Wheel.zs"

// Tokens
class UMDE_Select_LaserMode : inventory{default{inventory.maxamount 1;}}
class UMDE_Select_IncinerationMode : inventory{default{inventory.maxamount 1;}}
class UMDE_Select_LightningMode : inventory{default{inventory.maxamount 1;}}

class UMDE_Select_NoIncinerationMode : inventory{default{inventory.maxamount 1;}}
class UMDE_Select_NoLightningMode : inventory{default{inventory.maxamount 1;}}

// The Actual Weapon
Class PBX_DemonExt : PBX_WeaponBase
{
	default
	{
		//Demonic_Exterminator
		Tag "$PBX_DemonExt_Tag";
		inventory.pickupsound "UNMPCK";
		inventory.pickupmessage "$PBX_DemonExt_Pickup";
		Obituary "$OB_WEAP_DEMONEXT";
		Weapon.AmmoType1 "PB_DTech";
		Weapon.AmmoType2 "SoulCharge";
		Weapon.AmmoUse1 2;
		Weapon.AmmoGive1 200;
		Scale 0.8;
		Inventory.althudicon "UNMXA0";
		+weapon.noautofire;
		PB_WeaponBase.UsesWheel true;
		PB_WeaponBase.WheelInfo "DemonicExtWheel";
		PB_WeaponBase.ReserveToMagAmmoFactor 1;
	}

	const chan_unmkidle = 66;	//the channel of the idle sound
	int U_level;				//the offset of the beams (its actually in an array, this is the index of that value, check UN_LevelOfs[] below)
	const primammouse2 = 6;		//how many ammo uses its primary
	const secammouse2 = 20;		//how many ammo uses its secondary
	const primammouse = 4;		
	const secammouse = 12;		
	
	const primammo2use3 = 12;
	const secammo2use3 = 30;

	const LASER_DAMAGE = 80;
	int ExterminatorMode;
	bool ExterminatorWeaponSpecial;

	const SOUL_CAPACITY = 666;

	const specialOverlay = 11;
	const muzzleLayer = -64;

	const SOUL_GAIN = 6;

	states{
		Spawn:
			UNMX A -1 bright;
			Loop;
			
		Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				A_zoomfactor(1.0);
			    DemonExtCrosshair();
                PBX_WeaponRaise("UNMAKSEL");
			    return PB_RespectIfNeeded();
			}
		SelectAnimation:
			TNT1 A 0 A_JumpIf(invoker.ExterminatorMode == LightningMode,"SelectSoul");
			UNMS ABCDE 1; 
			goto Ready3;
		SelectSoul:
			UNMS FGHIJ 1; 
			goto Ready3;
		
		Deselect:
			TNT1 A 0 A_stopsound(chan_unmkidle);
			TNT1 A 0 A_JumpIf(invoker.ExterminatorMode == LightningMode,"DeselectSoul");
			UNMD ABCDE 1; 
			TNT1 A 0 A_Lower;
			wait;
		DeselectSoul:
			UNMD FGHIJ 1;
			TNT1 A 0 A_Lower;
			wait;
		
		WeaponRespect:
			UNMD EDCBA 1 UNM_WeaponReady();
			UNMI AAAAAAAAAAAAAAA 1 UNM_WeaponReady();
			TNT1 A 0 A_startsound("UNOCFIR", 1);
			UNMI AAAA 1 UNM_WeaponReady();
			TNT1 A 0 A_overlay(66,"LightningFlash");
			UNMI AAAA 1 UNM_WeaponReady();
			TNT1 A 0 A_overlay(67,"LightningFlash");
			UNMI AAAA 1 UNM_WeaponReady();
			TNT1 A 0 A_overlay(68,"LightningFlash");
			UNMI AAAA 1 UNM_WeaponReady();
			TNT1 A 0 A_overlay(65,"LightningFlash");
			UNMI AAAA 1 UNM_WeaponReady();
			TNT1 A 0 A_overlay(66,"LightningFlash");
			UNMI AAAA 1 UNM_WeaponReady();
			TNT1 A 0 A_overlay(67,"LightningFlash");
			UNMI AAAA 1 UNM_WeaponReady();
			TNT1 A 0 A_overlay(68,"LightningFlash");
			UNMI AAAA 1 UNM_WeaponReady();
			goto Ready3;

		WeaponInspect:
            UNM2 A 1 {
				A_Playsound("QSGCHRG",8);
				return A_DoPBWeaponAction();
			}
			UNM2 BCDEFGH 1 A_DoPBWeaponAction();
			TNT1 AAAAAAAAAAAAAAA 1 A_DoPBWeaponAction();
		HoldInspect:
			TNT1 A 1 A_DoPBWeaponAction();
            TNT1 A 0 A_JumpIf(PressingReload(),"HoldInspect");
			UNM2 H 1 {
				A_Playsound("QSGCHRG",8);
				return A_DoPBWeaponAction();
			}
			UNM2 GFEDCBA 1 A_DoPBWeaponAction();
            Goto Ready3;

		Ready3:
			TNT1 A 0 A_Startsound("unmaker/hum",chan_unmkidle,CHANF_LOOPING);
			UNMI AAAAAAAAAAAAAAABBBCCCDDDEEEFFFFFFFFFFFFFFFFFFEEEDDDCCCBBBAAA 1 {
				if(invoker.ExterminatorMode == LightningMode){return ResolveState("Ready.Soul");}
				if (PressingReload() || (player.oldbuttons & BT_RELOAD)) 
					return resolvestate("WeaponInspect");
				return UNM_WeaponReady();
			}
			loop;
		Ready.Soul:
			UNMI IIIIIIJJJJKKKKJJJJIIIIIIIIIIIIJJJJKKKKJJJJIIIIII 1 {
				if(invoker.ExterminatorMode != LightningMode){return ResolveState("Ready3");}
				if (PressingReload())
				{
					return resolvestate("WeaponInspect");
				} 
				return UNM_WeaponReady();
			}
			goto Ready3;
			
		ReadyNoAmmo:
			UNMI H 1 UNM_WeaponReady();
			loop;
			
		WeaponSpecialLayer:
			TNT1 A 1 {
				A_WeaponOffset(0,32);
				A_Playsound("UNMSWTC",8);
				invoker.ExterminatorWeaponSpecial = true;
			}
			TNT1 AAAAAAAAA 1 A_WeaponOffset(-2,2,WOF_ADD);
			TNT1 A 3 ;
			TNT1 AA 1 A_WeaponOffset(-6,6,WOF_ADD);
			TNT1 A 2 ;
			TNT1 AAAAAAAAAAAAAAA 1 A_WeaponOffset(2,-2,WOF_ADD);
			TNT1 A 1 A_WeaponOffset(0,32);
			TNT1 AAAAA 0 {
				invoker.ExterminatorWeaponSpecial = false;
			}
			stop;
			
		SwitchToSoul:
			UNMI A 7;
			Goto Ready.Soul;

		SwitchToSoulLayer:
			UNM2 H 1 {
				A_Playsound("QSGCHRG",8);
				invoker.ExterminatorWeaponSpecial = true;
			}
			UNM2 GFEDCBA 1;
			UNM2 AAAAA 0 {
				invoker.ExterminatorWeaponSpecial = false;
			}
			Stop;

		SwitchFromSoulLayer:
			UNM2 A 1 {
				A_Playsound("QSGCHRG",8);
				invoker.ExterminatorWeaponSpecial = true;
			}
			UNM2 BCDEFGH 1;
			UNM2 AAAAA 0 {
				invoker.ExterminatorWeaponSpecial = false;
			}
			Stop;

		WeaponSpecial:
			TNT1 A 0 WeaponSpecialCheck();
			goto ready3;
		Fire.BigOrb:
			TNT1 A 0 A_overlay(muzzleLayer,"MuzzleFlash1");
			TNT1 A 0 A_Stopsounds(1,3);
			TNT1 A 0 A_startsound("unmaker/fire",21);
			TNT1 A 0 A_startsound("unmaker/pick",23);
			UNMF A 1 bright A_FireProjectile("UNMK_AltPj",0,0);
			TNT1 A 0 A_TakeInventory(invoker.ammotype1,invoker.secammouse,TIF_NOTAKEINFINITE);
			TNT1 A 0 PB_FireOffset();
			TNT1 A 0 PB_WeaponRecoil(-4.25,frandom[sfx](-1.7,1.7));
			UNMF BC 1 bright;
			TNT1 A 0 A_weaponoffset(0,36);
			UNMF LMNO 1 bright A_WeaponOffset(0,-1,WOF_ADD);
			UNMI ABCDEFEDCBAABCDEFEDC 1 PB_GunSmoke(random(-1,1),random(-1,1),random(1,5));
			TNT1 A 0 A_refire("AltFire");
			goto ready3;
		Fire:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				DemonExtCrosshair();
			}
			TNT1 A 0 A_JumpIf(invoker.ExterminatorMode == IncinerationMode,"Fire.Incineration");
			TNT1 A 0 A_JumpIf(invoker.ExterminatorMode == LightningMode,"Fire.Soul");
		Fire.Laser:
			TNT1 A 0 A_jumpif(countinv(invoker.ammotype1) < invoker.primammouse, "FireNoAmmo");
			TNT1 A 0 A_overlay(muzzleLayer,"MuzzleFlash2");
			TNT1 A 0 A_startsound("unmaker/laser",21);
			TNT1 A 0 A_TakeInventory(invoker.ammotype1,invoker.primammouse,TIF_NOTAKEINFINITE);
			UNMF A 1 bright UNM_FireLasers();
			TNT1 A 0 PB_FireOffset();
			TNT1 A 0 PB_WeaponRecoil(-0.32,frandom[sfx](-0.25,0.25));
			UNMF DE 1 bright A_weaponoffset(0,32);
			TNT1 A 0 A_JumpIf(Player.ReFire%2 == 1, 4);
			UNMF MO 1 bright;
			TNT1 A 0 A_Jump(256,3);
			UNMF LN 1 bright;
			TNT1 A 0 A_refire("Fire");
			UNMI AAAAAA 1 bright {
				PB_GunSmoke(random(-1,1),random(-1,1),random(1,5));

				if(invoker.ExterminatorWeaponSpecial)
					return A_DoPBWeaponAction(WRF_NOFIRE|WRF_NOSWITCH);
				else
					return A_DoPBWeaponAction();
				
			}
			goto ready3;
		FireRecoilScale:
			TNT1 A 1 {A_OverlayPivotAlign(PSP_WEAPON,PSPA_CENTER,PSPA_TOP);A_OverlayScale(PSP_WEAPON,1.2);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.175);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.15);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.125);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.1);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.075);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.05);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.025);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.0);}
			stop;
		FireRecoilScaleLightning:
			TNT1 A 1 {A_OverlayPivotAlign(PSP_WEAPON,PSPA_CENTER,PSPA_TOP);A_OverlayScale(PSP_WEAPON,1.3);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.275);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.25);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.225);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.2);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.175);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.15);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.125);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.1);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.075);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.05);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.025);}
			TNT1 A 1 {A_OverlayScale(PSP_WEAPON,1.0);}
			stop;
		Fire.Soul:
			TNT1 A 0 A_jumpif(countinv(invoker.ammotype2) < invoker.primammo2use3, "FireNoAmmo");
			UNMI K 3 Bright {A_WeaponOffset(0,32);A_overlay(65,"OverchargeFlash");}
			TNT1 AAAA 0 A_PlaySound("DSREAFI1",CHAN_AUTO);
			UNMI K 21 BRIGHT A_WeaponOffset(0,32);
			UNMI K 1 bright {
				A_Overlay(-5,"FireRecoilScale");
				A_FireProjectile("ReaperBall",0,0);//UNMK_StormShot1
			}
			TNT1 A 0 A_TakeInventory(invoker.ammotype2,invoker.primammo2use3,TIF_NOTAKEINFINITE);
			TNT1 A 0 PB_FireOffset();
			TNT1 A 0 PB_WeaponRecoil(-4.25,frandom[sfx](-1.7,1.7));
			UNMI JI 1 bright A_weaponoffset(0,36);
			//bright
			UNMI IIII 1 bright A_WeaponOffset(0,-1,WOF_ADD);
			UNMI IJKJIJKJIJKJIJKJIJKJ 1 PB_GunSmoke(random(-1,1),random(-1,1),random(1,5));
			TNT1 A 0 A_refire("Fire");
			goto ready3;
		Fire.Incineration:
			TNT1 A 0 A_jumpif(countinv(invoker.ammotype1) < invoker.primammouse2, "FireNoAmmo");
			UNMF A 1 bright {
				A_overlay(muzzleLayer,"MuzzleFlash0");
				A_startsound("unmaker/fire",21);
				UNM_FireBeams(invoker.U_Level)
				;A_TakeInventory(invoker.ammotype1,invoker.primammouse2,TIF_NOTAKEINFINITE);
				UNM_Add_level();
			}
			TNT1 A 0 {
				PB_FireOffset();
				PB_WeaponRecoil(-0.32,frandom[sfx](-0.25,0.25));
			}
			UNMF BC 1 bright A_weaponoffset(0,35);
			UNMF MNO 1 bright A_WeaponOffset(0,-1,WOF_ADD);
			TNT1 A 0 A_refire("Fire");
			UNMI AAAAAA 1 bright {
				PB_GunSmoke(random(-1,1),random(-1,1),random(1,5));

				if(invoker.ExterminatorWeaponSpecial)
					return A_DoPBWeaponAction(WRF_NOFIRE|WRF_NOSWITCH);
				else
					return A_DoPBWeaponAction();
				
			}
			goto ready3;

		AltFire:
			TNT1 A 0 A_JumpIf(invoker.ExterminatorMode == IncinerationMode,"AltFire.Incineration");
			TNT1 A 0 A_JumpIf(invoker.ExterminatorMode == LightningMode,"Altfire.Soul");
		Altfire.Laser:
			TNT1 A 0 A_jumpif(countinv(invoker.ammotype1) < invoker.secammouse, "FireNoAmmo");
			UNMI F 0 Bright Offset(0,32) A_PlaySound("RCHARGE",CHAN_ITEM);
			UNMI H 1 Bright Offset(0,33);
			UNMI H 1 Bright Offset(1,34);
			UNMI H 1 Bright Offset(0,35);
			UNMF G 1 Bright Offset(-1,34);
			UNMF A 1 Bright Offset(0,33);
			UNMF A 1 Bright Offset(1,34);
			UNMF G 1 Bright Offset(0,35);
			UNMF G 1 Bright Offset(-1,34);
			UNMF G 1 Bright Offset(0,33);
			UNMF H 1 Bright Offset(1,34);
			UNMF H 1 Bright Offset(0,35);
			UNMF H 1 Bright Offset(-1,34);
			UNMF I 1 Bright Offset(0,33);
			UNMF I 1 Bright Offset(1,34);
			UNMF I 1 Bright Offset(0,35);
			UNMF J 1 Bright Offset(-1,34);
			UNMF J 1 Bright Offset(0,33);
			UNMF J 1 Bright Offset(1,34);
			UNMF K 1 Bright Offset(0,35);
			UNMF K 1 Bright Offset(-1,34);
			UNMF K 1 Bright Offset(0,33);
			UNMF K 1 Bright Offset(1,34);
			UNMF K 1 Bright Offset(0,35);
			UNMF K 1 Bright Offset(-1,34);
			UNMF K 1 Bright Offset(0,33);
			UNMF K 1 Bright Offset(1,34);
			UNMF K 1 Bright Offset(0,35);
			UNMF K 1 Bright Offset(-1,34);
		AltHold.Laser:
			TNT1 A 0 A_jumpif(countinv(invoker.ammotype1) < invoker.secammouse, "FireNoAmmo");
			UNMF A 2 Bright {
				A_overlay(muzzleLayer,"MuzzleFlash3");
				A_WeaponOffset(0,32);
				A_TakeInventory("PB_DTech",invoker.secammouse,TIF_NOTAKEINFINITE);
				A_FireCustomMissile("DemonExterminatorEnergyBlast",0,FALSE,0,-3);
				A_AlertMonsters();
				A_FireCustomMissile("DemonExterminatorLaserTrail",0,FALSE);
				A_StopSound(CHAN_ITEM);
				A_PlaySound("RBLAST",CHAN_WEAPON);
			}
			TNT1 A 0 PB_WeaponRecoil(-1.0,frandom[sfx](-1,1));
			UNMF BCLMNO 1 Bright;
			//UNMF LMNO 1 bright A_ZoomFactor(1.0);
			//UNMI A 1 ;
			"####" F 0 A_ReFire("AltHold.Laser");
			UNMI AA 2 PB_GunSmoke(random(-1,1),random(-1,1),random(1,5));
			Goto Ready3;
		AltFire.Incineration:
			TNT1 A 0 A_jumpif(countinv(invoker.ammotype1) < invoker.secammouse2, "FireNoAmmo");
			TNT1 A 0 A_overlay(65,"LightningFlash");
			TNT1 A 0 A_startsound("UNOCFIR", 1);
			TNT1 A 0 A_startsound("UNMSTA", 3);
			UNMI HHHH 1 A_weaponoffset(0 + random(-1,1),32 + random(1,3));
			TNT1 A 0 A_overlay(66,"LightningFlash");
			UNMI HHHH 1 A_weaponoffset(0 + random(-3,3),32 + random(1,4));
			TNT1 A 0 A_overlay(67,"LightningFlash");
			UNMI HHHH 1 A_weaponoffset(0 + random(-1,1),32 + random(1,3));
			TNT1 A 0 A_overlay(68,"LightningFlash");
			UNMI HHHH 1 A_weaponoffset(0 + random(-3,3),32 + random(1,4));
			TNT1 A 0 A_overlay(65,"LightningFlash");
			UNMI HHHH 1 A_weaponoffset(0 + random(-1,1),32 + random(1,3));
			TNT1 A 0 A_overlay(66,"LightningFlash");
			UNMI HHHH 1 A_weaponoffset(0 + random(-3,3),32 + random(1,4));
			TNT1 A 0 A_overlay(67,"LightningFlash");
			UNMI HHHH 1 A_weaponoffset(0 + random(-1,1),32 + random(1,3));
			TNT1 A 0 A_overlay(68,"LightningFlash");
			UNMI HHHH 1 A_weaponoffset(0 + random(-3,3),32 + random(1,4));
			TNT1 A 0 A_weaponoffset(0,32);
			TNT1 A 0 A_overlay(muzzleLayer,"MuzzleFlash1");
			TNT1 A 0 A_Stopsounds(1,3);
			TNT1 A 0 A_startsound("unmaker/fire",21);
			TNT1 A 0 A_startsound("unmaker/pick",23);
			UNMF A 1 bright A_FireProjectile("UNMK_Grounder",0,0);	//A_Fireprojectile("UNMK_AltPj",0,0);
			TNT1 A 0 A_TakeInventory(invoker.ammotype1,invoker.secammouse2,TIF_NOTAKEINFINITE);
			TNT1 A 0 PB_FireOffset();
			TNT1 A 0 PB_WeaponRecoil(-4.25,frandom[sfx](-1.7,1.7));
			UNMF BC 1 bright;
			TNT1 A 0 A_weaponoffset(0,36);
			UNMF LMNO 1 bright A_WeaponOffset(0,-1,WOF_ADD);
			//UNMI A 2 bright A_weaponoffset(0,32);
			UNMI ABCDEFEDCBAABCDEFEDC 1 PB_GunSmoke(random(-1,1),random(-1,1),random(1,5));
			TNT1 A 0 A_refire("AltFire");
			goto ready3;
		Altfire.Soul:
			UNMI F 0 Bright Offset(0,32) A_jumpif(countinv(invoker.ammotype2) < invoker.secammo2use3, "FireNoAmmo");
			UNMI K 1 Bright Offset(0,33) A_overlay(65,"OverchargeFlash");
			UNMI K 1 Bright Offset(1,34);
			UNMI K 1 Bright Offset(0,35);
			TNT1 AAAA 0 A_PlaySound("DSREAFI3",CHAN_AUTO);
			UNMI K 1 Bright Offset(-1,34);
			UNMI K 1 Bright Offset(0,33);
			UNMI K 1 Bright Offset(1,34);
			UNMI K 1 Bright Offset(0,35);
			UNMI K 1 Bright Offset(-1,34);
			UNMI K 1 Bright Offset(0,33);
			UNMI K 1 Bright Offset(1,34);
			UNMI K 1 Bright Offset(0,35);
			UNMI K 1 Bright Offset(-1,34);
			UNMI K 1 Bright Offset(0,33);
			UNMI K 1 Bright Offset(1,34);
			UNMI K 1 Bright Offset(0,35);
			UNMI K 1 Bright Offset(-1,34);
			UNMI K 1 Bright Offset(0,33);
			UNMI K 1 Bright Offset(1,34);
			UNMI K 1 Bright Offset(0,35);
			UNMI K 1 Bright Offset(-1,34);
			UNMI K 1 Bright Offset(0,33);
			UNMI K 1 Bright Offset(1,34);
			UNMI K 1 Bright Offset(0,35);
			UNMI K 1 Bright Offset(-1,34);
			TNT1 A 0 A_overlay(muzzleLayer,"MuzzleFlash3");
			TNT1 A 0 A_Stopsounds(1,3);
			TNT1 A 0 A_PlaySound("DSREAFI4",CHAN_AUTO);
			TNT1 AAAA 0 A_startsound("unmaker/thunder",CHAN_AUTO);
			TNT1 A 0 A_SetBlend("FFFFFF",0.9,12,"FF0000");
			UNMI K 1 bright {
				A_Overlay(-5,"FireRecoilScaleLightning");
				UNM_FireStorm();
			}
			TNT1 A 0 A_TakeInventory(invoker.ammotype2,invoker.secammo2use3,TIF_NOTAKEINFINITE);
			TNT1 A 0 PB_FireOffset();
			TNT1 A 0 PB_WeaponRecoil(-4.25,frandom[sfx](-1.7,1.7));
			UNMI KK 1 bright;
			TNT1 A 0 A_weaponoffset(0,36);
			UNMI JJII 1 bright A_WeaponOffset(0,-1,WOF_ADD);
			UNMI IJKJIJKJIJKJIJKJIJKJ 1 PB_GunSmoke(random(-1,1),random(-1,1),random(1,5));
			goto ready3;
		FireNoAmmo:
			UNMI ABCDEFEDCBA 1;
			goto ready3;
		
		//for quick melee
		FlashPunching:
			TNT1 A 0 A_stopsound(chan_unmkidle);
			UNMD ABCDEEEEEEDCBA 1;
			goto ready3;
		
		//for kicking
		FlashKicking:
			UNMD ABCDEEEEEEEDCBA 1;
			goto ready3;
			
		FlashAirKicking:
			UNMD ABCDEEEEEEEEDCBA 1;
			goto ready3;
			
		FlashSlideKicking:
			UNMD ABCDEEEEEEEEEEEEEEEEEEEDCBA 1;
			goto ready3;
			
		FlashSlideKickingStop:
			UNMD EEEDCBA 1;
			goto ready3;
		
		//reused from the dtech rifle, just resized in code
		MuzzleFlash0:
			TNT1 A 0 {
				A_overlayFlags(overlayid(),PSPF_FLIP|PSPF_MIRROR,random(0,1));
				A_OverlayPivotAlign(overlayId(),PSPA_CENTER,PSPA_CENTER);
				A_OverlayScale(overlayid(),frandom(1.0,1.4));
			}
			goto MuzzleFlash.Incineration;
		MuzzleFlash1:
			TNT1 A 0 {
				A_overlayFlags(overlayid(),PSPF_FLIP|PSPF_MIRROR,random(0,1));
				A_OverlayPivotAlign(overlayId(),PSPA_CENTER,PSPA_CENTER);
				A_OverlayScale(overlayid(),frandom(1.4,2.25));
			}
			goto MuzzleFlash.Incineration;
		MuzzleFlash.Incineration:
			D3T2 A 1 bright {
				int f = randompick(0,3,6);
				UNM_ChangePSFrame(f,overlayID());
			}
			D3T2 B 1 bright {
				int fm = randompick(1,4,7);
				UNM_ChangePSFrame(fm,overlayID());
			}
			D3T2 C 1 bright	{
				int fme = randompick(2,5,8);
				UNM_ChangePSFrame(fme,overlayID());
			}
			stop;
		MuzzleFlash2:
			TNT1 A 0 {
				A_overlayFlags(overlayid(),PSPF_FLIP|PSPF_MIRROR,random(0,1));
				A_OverlayPivotAlign(overlayId(),PSPA_CENTER,PSPA_CENTER);
				A_OverlayScale(overlayid(),frandom(1.0,1.4));
			}
			TNT1 A 0 A_Jump(256, "CMuzzle1", "CMuzzle2", "CMuzzle3", "CMuzzle4", "CMuzzle5", "CMuzzle6");
		MuzzleFlash3:
			TNT1 A 0 {
				A_overlayFlags(overlayid(),PSPF_FLIP|PSPF_MIRROR,random(0,1));
				A_OverlayPivotAlign(overlayId(),PSPA_CENTER,PSPA_CENTER);
				A_OverlayScale(overlayid(),frandom(1.4,2.25));
			}
			TNT1 A 0 A_Jump(256, "CMuzzle1", "CMuzzle2", "CMuzzle3", "CMuzzle4", "CMuzzle5", "CMuzzle6");
		CMuzzle1:
			UMFL AB 1 BRIGHT;
			TNT1 A 0 A_Jump(100, "ThirdCMuzzle1");
			Stop;
		CMuzzle2:
			UMFL DE 1 BRIGHT;
			TNT1 A 0 A_Jump(100, "ThirdCMuzzle2");
			Stop;
		CMuzzle3:
			UMFL GH 1 BRIGHT;
			TNT1 A 0 A_Jump(100, "ThirdCMuzzle3");
			STOP;
		CMuzzle4:
			UMFL JK 1 BRIGHT;
			TNT1 A 0 A_Jump(100, "ThirdCMuzzle4");
			STOP;
		CMuzzle5:
			UMFL MN 1 BRIGHT;
			TNT1 A 0 A_Jump(100, "ThirdCMuzzle5");
			STOP;
		CMuzzle6:
			UMFL PQ 1 BRIGHT;
			TNT1 A 0 A_Jump(100, "ThirdCMuzzle6");
			STOP;
			
		ThirdCMuzzle1:
			UMFL C 1 BRIGHT;
			STOP;
		ThirdCMuzzle2:
			UMFL F 1 BRIGHT;
			STOP;
		ThirdCMuzzle3:
			UMFL I 1 BRIGHT;
			Stop;
		ThirdCMuzzle4:
			UMFL L 1 BRIGHT;
			Stop;
		ThirdCMuzzle5:
			UMFL O 1 BRIGHT;
			Stop;
		ThirdCMuzzle6:
			UMFL R 1 BRIGHT;
			Stop;
		LightningFlash:
			TNT1 A 0 {
				A_OverlayFlags(overlayId(),PSPF_FLIP|PSPF_MIRROR,random(false,true));
				A_OverlayOffset(overlayId(),frandom(-5,5),frandom(-7,7));
				A_OverlayPivotAlign(overlayId(),PSPA_CENTER,PSPA_CENTER);
				A_OverlayRotate(overlayId(),frandom(-20,20));
			}
			TNT1 A 0 A_jump(256,"FiringLightning1","FiringLightning2","FiringLightning3");
		FiringLightning1:
			UNHL ABCCDDDD 1 BRIGHT;
			Stop;
		FiringLightning2:
			UNHL EFGHH 1 BRIGHT;
			Stop;
		FiringLightning3:
			UNHL IJKKLLL 1 BRIGHT;
			Stop;
		OverchargeFlash:
			TNT1 A 0 {
				A_OverlayFlags(overlayId(),PSPF_FLIP|PSPF_MIRROR,random(false,true));
				//A_OverlayOffset(overlayId(),frandom(-5,5),frandom(-7,7));
				A_OverlayPivotAlign(overlayId(),PSPA_CENTER,PSPA_CENTER);
				A_OverlayOffset(overlayId(),0,-40);
				//A_OverlayRotate(overlayId(),frandom(-20,20));
				//A_OverlayTranslation(overlayId(),"FFFFFF:000000 = [FF,00,00]:[00,00,00]");
			}
		OverchargeCharge:
			UMTB ABCDEFGHIJKLMNOPQRSTUVW 1 BRIGHT;
			Stop;
		StormMuzzleFlash:
			TNT1 A 0 {
				A_OverlayFlags(overlayId(),PSPF_FLIP|PSPF_MIRROR,random(false,true));
				//A_OverlayOffset(overlayId(),frandom(-5,5),frandom(-7,7));
				A_OverlayPivotAlign(overlayId(),PSPA_CENTER,PSPA_CENTER);
				A_OverlayOffset(overlayId(),0,-40);
				//A_OverlayRotate(overlayId(),frandom(-20,20));
				//A_OverlayTranslation(overlayId(),"FFFFFF:000000 = [FF,00,00]:[00,00,00]");
			}
			UMTB ACEGIKMOQSUW 1 BRIGHT;
			Stop;
			UMTB BDFHJLNPRTV 1 BRIGHT;
			Stop;
			UMTB ABCDEFGHIJKLMNOPQRSTUVW 1 BRIGHT;
			Stop;
		//unused, looks silly
			/*
		ChargingFLash:
			DB26 IJKLMNOPQRSTUV 1 bright;
			stop;
			*/
}}
class FighterFalling : Inventory
{
	Default
	{
		Inventory.MaxAmount 4;
	}
}

// Hammer Puff (also used by fist) ------------------------------------------

class FHammerPuff : Actor
{
	Default
	{
		+NOBLOCKMAP +NOGRAVITY
		+PUFFONACTORS
		RenderStyle "Translucent";
		Alpha 0.6;
		VSpeed 0.8;
		SeeSound "FighterHammerHitThing";
		AttackSound "FighterHammerHitWall";
		ActiveSound "FighterHammerMiss";
	}
	States
	{
	Spawn:
		FXFX ABCDEFGHIJ 2 A_FadeOut();
		Stop;
	}
}