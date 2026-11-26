// Paingiver 
// Original by Moa-Dixon and R3W
// Ported to PB by Jenny/Jeniffer

// // Includes
// #include "./CyberRL_Projectiles.zs"

class PBX_Paingiver : PBX_WeaponBase
{
	Default
	{
        //$Title Cyberdemon RL
        //$Category Weapons
        //$Sprite CYBFA0
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.Icon "W17PA0";
        Inventory.AltHudIcon "W17PA0";
		// PB_WeaponBase.ReserveToMagAmmoFactor 2;

        Weapon.BobRangeX 0.3;
        Weapon.BobRangeY 0.5;
        Weapon.BobStyle "InverseSmooth";
        Weapon.BobSpeed 2.0;
		
//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
		Weapon.AmmoType1 "PB_RocketAmmo";
	    Weapon.AmmoGive1 30;
		
//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Obituary "$OB_WEAP_PAINGIVER";
		Inventory.Pickupmessage "$PBX_Paingiver_Pickup";
	    Inventory.PickupSound "misc/rockboxa";
		Tag "$PBX_Paingiver_Tag";
	    FloatBobStrength 0.5;
	    Scale 0.9;
        
//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.EXPLOSIVE;
        +WEAPON.NOAUTOFIRE;
        +FORCEXYBILLBOARD;
        +FLOORCLIP;
        +DONTGIB;
	}

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
	bool enragedState;
	int shotCount;
	const ammoTake = 2; // How many rocket ammo does it take per shot
	const soulTake = 3; // How many souls to take per tic
    const minSoul = PBX_DemonExt.SOUL_CAPACITY/2; // The minimum souls needed to activatae enraged mode
      
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
	override void postbeginplay()
	{
		enragedState = false;
        shotCount = 0;
		super.postbeginplay();
	}

    override void PBX_DoEffectWeaponReady()
    {
		if(!enragedState) 
            return;

        if(CountInv("SoulCharge") <= 0)
        {
            A_Playsound("UNMSWT2",3);
            self.A_StopSound(6);
            owner.A_Print("$PB_UNMAKER_RUNOUT");
            owner.A_RemoveLight("FrightenerLight");
            enragedState = false;
            return;
        }

        TakeInventory("SoulCharge",soulTake,TIF_NOTAKEINFINITE);
    }

    override void ModifyDamage(int damage, Name damageType, out int newDamage, bool passive, Actor inflictor, Actor source, int flags)
    {
		if (passive && damage > 0)
		{
			if (owner.player && owner.player.readyweapon is "PBX_Paingiver" && enragedState)
			{
				newDamage = damage/4;
			}
		}
    }

    action state rapidFire()
    {
        if(invoker.enragedState)
            return A_DoPBWeaponAction();
        return resolvestate(null);
    }
      
//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
	States
	{
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
		Spawn:
            W17P A 0 NoDelay;
            W17P A 10 A_PBVPFramework("W17P");
            "####" "#" 0 A_PbvpInterpolate();
            Loop;

        Deselect:
           TNT1 A 0 {
                PBX_WeaponLower();
                A_StopSound(CHAN_6);
                A_PlaySound("KICKSW",CHAN_AUTO,CHANF_OVERLAP);
			}
            W17S ABC 1;
			TNT1 A 0 A_Lower();
			Wait;

		Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(65);
                PBX_WeaponRaise("weapons/sgl/inspect2");
			    return PB_RespectIfNeeded();
			}
		SelectAnimation:
			TNT1 A 0 A_PlaySound("rocket", 2);
            TNT1 A 0 A_PlaySound("KICKSW", CHAN_AUTO);
            W17S CBA 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
		Ready3:
			W17A A 1 {
                if(invoker.enragedState)
                    A_PlaySound("UNOCIDL", 6,1,1);
                else
                    A_PlaySound("BFGHUM", 6,1,1);
                PB_CoolDownBarrel();
                return A_DoPBWeaponAction();
            }
			Loop;

        NoAmmo:
		    W17A A 5 {
                A_ZoomFactor(1.0);
                A_PlaySound("weapons/empty", 4);
            }
            Goto Ready3;
		
//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
		Fire:
            TNT1 A 0 {
			    PB_HandleCrosshair(65);
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
            }
			TNT1 A 0 PB_JumpIfNoAmmo(min:ammoTake,secondary:false);
            TNT1 A 0 A_PlaySound("RLFIRE", CHAN_WEAPON);
            TNT1 A 0 A_PlaySound("RLsweet", CHAN_VOICE);
            W17F A 1 Bright A_DoPBWeaponAction();
            TNT1 A 0 Bright {
                A_AlertMonsters();
                PB_FireOffset();
                PB_IncrementHeat(5);
                A_FireCustomMissile("YellowFlareSpawn",0,0,0,0);
                if(!invoker.enragedState)
                    A_TakeInventory(invoker.ammo1.getClassName(),ammoTake,TIF_NOTAKEINFINITE);
                A_FireCustomMissile("PB_Rocket", 0, 0, 0, 0);
                A_FireCustomMissile("RocketGlassBreaker", 0, 0, 0, 0);
                PB_WeaponRecoil(-0.5,1.0);
                A_ZoomFactor(0.90);
            }
            W17F BCD 1 {
                PB_WeaponRecoilBasic(-1.0); 
                A_ZoomFactor(0.97); 
            }
            W17F EF 2 {
                PB_WeaponRecoilBasic(0.5);  
                A_ZoomFactor(0.99); 
            }
            W17F GH 2 {
                PB_WeaponRecoilBasic(-1.0); 
                A_ZoomFactor(1.0); 
                return rapidFire();
            }
            W17F I 2 rapidFire();
            W17A A 8 rapidFire();
            MISG B 0 PB_ReFire();
            W17A A 1 A_DoPBWeaponAction();
            Goto Ready3;

		Reload:
			TNT1 A 0;
			goto Ready3;

//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
		AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
            }
			TNT1 A 0 { invoker.shotCount = 0; }
        AltFireLoop:
			TNT1 A 0 PB_JumpIfNoAmmo(min:ammoTake,secondary:false);
            TNT1 A 0 A_PlaySound("RLFIRE2", CHAN_WEAPON);
            TNT1 A 0 A_PlaySound("RLsweet", CHAN_VOICE);
            W17F A 1 Bright A_DoPBWeaponAction();
            TNT1 A 0 {
                A_FireCustomMissile("YellowFlareSpawn",0,0,0,0);
                if(!invoker.enragedState)
                    A_TakeInventory(invoker.ammo1.getClassName(),ammoTake,TIF_NOTAKEINFINITE);
                A_FireCustomMissile("SeekerRocket", frandom(20, -20), 1, 0, 0,FPF_NOAUTOAIM, 0);
                A_AlertMonsters();
                PB_IncrementHeat(5);
                PB_FireOffset();
                A_ZoomFactor(0.90);
            }
            W17F BCDE 1;
			TNT1 A 0 { invoker.shotCount++; }
			TNT1 A 0 A_JumpIf(invoker.shotCount < 3, "AltFireLoop");
        FireEnd:
            W17F FG 1 {
                PB_WeaponRecoilBasic(-1.0); 
                A_ZoomFactor(0.97); 
            }
            W17F HI 2 {
                PB_WeaponRecoilBasic(0.5);  
                A_ZoomFactor(0.99); 
            }
            W17A A 2 {
                PB_WeaponRecoilBasic(-1.0); 
                A_ZoomFactor(1.0); 
                return rapidFire();
            }
            W17A A 16 rapidFire();
            MISG B 0 A_ReFire();
            W17A A 1 A_DoPBWeaponAction();
            Goto Ready3;
		
//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
		Weaponspecial:
			TNT1 A 0 A_Takeinventory("GoWeaponSpecialAbility",1);
            TNT1 A 0 {
                if(invoker.enragedState || (CountInv("SoulCharge") < minSoul))
                {
                    A_StartSound("UNMWARN",7);
                    A_Print(invoker.enragedState ? "$PB_UNMAKER_WARN" : "$PB_UNMAKER_TOOLOW");
                    return ResolveState("Ready3");
                }
                return ResolveState(null);
            }
			TNT1 A 0 {
                invoker.enragedState = true;
                A_AttachLightDef("FrightenerLight","FrightenerLight");
                A_FireCustomMissile("MancubusSwitchModeEffect", 0, 0, 0, random(1,3));
            	A_StartSound("unmaker/switch", CHAN_AUTO, CHANF_OVERLAP);
                A_Print("$PBX_Paingiver_Enraged");
			}
			goto Ready3;

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
		FlashKicking:
            W17A A 1 ;
            W17S A 1 ;
            W17S A 1 ;
            W17S B 1 ;
            W17S C 6 ;
            W17S B 1 ;
            W17S A 1 ;
            W17S A 1 ;
			goto Ready3;

        FlashAirKicking:
            W17A A 1 ;
            W17S A 1 ;
            W17S A 1 ;
            W17S B 1 ;
            W17S C 7 ;
            W17S B 1 ;
            W17S A 1 ;
            W17S A 1 ;
			goto Ready3;

        FlashSlideKicking:
            W17A A 1 ;
            W17S A 1 ;
            W17S A 1 ;
            W17S B 1 ;
            W17S C 13 ;
            W17S B 1 ;
            W17S A 1 ;
            W17S A 1 ;
			goto Ready3;

        FlashSlideKickingStop:
            W17A A 1 ;
			goto Ready3;

        FlashPunching:
            W17A A 1 ;
            W17S A 1 ;
            W17S A 1 ;
            W17S B 1 ;
            W17S C 7 ;
            W17S B 1 ;
            W17S A 1 ;
            W17S A 1 ;
			goto Ready3;

        FlashPunchingStop:
            W17A A 1 ;
			goto Ready3;
	}
}