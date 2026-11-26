// Mini Shotgun
// From a Brutal Doom Addon by Dox778
// ȽʘɌƉ ȽʘŦḢɅɌ - Sprites

// Includes
// #include "./PlasmaBlaster_Wheel.zs"

// class Plasma_Select_Auto : inventory {default{inventory.maxamount 1;}}

// Actual Weapon
class PBX_MiniShotgun : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
	    Inventory.AltHUDIcon "MTGSE0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_Shell";
        Weapon.AmmoGive1 30;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_MiniShotgun_Pickup";
        Inventory.PickupSound "CBOXPKUP";
        Obituary "$OB_WEAP_MINISHOTGUN";
        AttackSound "None";
        Tag "$PBX_MiniShotgun_Tag";
        Scale 1.0;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    Array<PBX_ShellTypes> mShellArray;
    int mAvailableShellTypes;
    bool mWeaponIsSpinning;

    const AMMO_TAKE = 2;

//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    static const name shellUpgrades[] = {
        "DragonBreathUpgrade", "ExplosiveUpgrade", "WhitePhosphorusUpgrade",
        "TripleDoomUpgrade", "DanmakuUpgrade", "SubZeroUpgrade",
        "HellFireUpgrade", "AcidShellsUpgrade"
    };

    override void AttachToOwner(Actor other)
    {
        Super.AttachToOwner(other);
        buildShellArray();
    }

    override bool HandlePickup(Inventory item)
    {
        bool result = Super.HandlePickup(item);

        for (int i = 0; i < shellUpgrades.Size(); i++)
        {
            if (item.GetClassName() == shellUpgrades[i])
            {
                AddShell(Shell_Drgn + i);
                break;
            }
        }
        return result;
    }
    
//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    // Not private since it'll be called by the cheat handler
    void buildShellArray()
    {
        mShellArray.Clear();

        // Insert default shells
        for (int m = Shell_Buck; m < Shell_Drgn; m++)
        {
            mShellArray.Push(m);
        }

        // Check if the player already has an upgrade
        for (int i = 0; i < shellUpgrades.Size(); i++)
        {
            if (owner && owner.CountInv(shellUpgrades[i]) > 0)
            {
                addShell(Shell_Drgn + i);
            }
        }
    }

    private
    void addShell(PBX_ShellTypes mode)
    {
        if (mShellArray.Find(mode) == mShellArray.Size())
        {
            mShellArray.Push(mode);
        }
    }

    action void fireWeapon()
    {
        A_FireCustomMissile("YellowFlareSpawn", 0, 0, 0, 0);
        fireShells();
        A_TakeInventory(invoker.ammo1.getclassname(),AMMO_TAKE,TIF_NOTAKEINFINITE);
        A_AlertMonsters();
        A_FlashOverlay();
        PB_GunSmoke_Basic(0,0,2);
        A_GunFlash();
        PB_IncrementHeat();
        PB_FireOffset();
        A_StartSound("SSHFIRE",CHAN_WEAPON);
    }

    action void fireShells()
    {
        PBX_ShellTypes mode = invoker.mShellArray[random(0, invoker.mShellArray.Size() - 1)];
		name casingType;
        switch(mode)
		{
			case Shell_Buck: 
				PB_FireBullets("PB_10GAPellet",20,8,0,0,6);
			    casingType = "BuckShellCasing"; 		
				break;
			case Shell_Slug:
				PB_FireBullets("PB_12GASlug",1,0.1,2,0,0); 
				PB_FireBullets("PB_12GASlug",1,0.1,-2,0,0); 
			    casingType = "SlugShellCasing"; 		
				break;
			case Shell_Flech: 
				PB_FireBullets("PB_MGNail",12,3,0,0,3); 
			    casingType = "FlechetShellCasing"; 	
				break;
			case Shell_Flak: 
				PBX_FireBullets("chunk1",3,5,0,0,3); 
				PBX_FireBullets("chunk2",3,3,0,0,4);
				PBX_FireBullets("chunk4",2,4,0,0,3);
			    casingType = "FlakShellCasing"; 		
				break;
			case Shell_Drgn: 
				PB_FireBullets("PB_DragonsBreathTracer",10,6,0,0,6); 
			    casingType = "DragonShellCasing"; 	
				break; 
			case Shell_EXPL:
				PB_FireBullets("ExplosiveProjectile",5,6,0,0,6); 
			    casingType = "ExplosiveShellCasing"; 
				break; 
			case Shell_WPSP: 
				PB_FireBullets("WPhosphorusProjectile",7,6,0,0,6);
			    casingType = "WhitePShellCasing"; 	
				break;
			case Shell_Doom:
				PB_FireBullets("PB_12GASlug",1,0.1,2,0,0); 
				PB_FireBullets("PB_12GASlug",1,0.1,-2,0,0);
				PB_FireBullets("PB_10GAPellet",10,6,0,0,6);
				PB_FireBullets("PB_10GAPellet_LP",1,6,0,0,6);
				PB_FireBullets("PB_8GAPellet",10,16,0,0,12);
			    casingType = "TDoomCasing"; 			
				break;
			case Shell_Damn:
				PBX_FireBullets("DanmakuProjectile",16,4.0,0,0,2.5);
			    casingType = "DanmakuCasing"; 		
				break;
			case Shell_SubZ:
				A_SpawnItemEx("BlueFlareSpawn", 0, 0, -3);
				A_SpawnItemEx("BlueFlareSpawn", 0, 0, 3);
				PB_FireBullets("SubZeroProjectile",6,3,0,0,3);
         		A_FireBullets(8, 6, 10, 18, "SubZ_Puff",FBF_NORANDOM,8192,"CSSG_FrozenTracer",-12);
			    casingType = "SubZeroCasing"; 		
				break;
			case Shell_HellF:
				PB_FireBullets("HellFireProjectile",16,6,0,0,6);
			    casingType = "HellFireCasing"; 		
				break;
			case Shell_Acid:
				PB_FireBullets("AcidShellsProjectile",3,6,0,0,6);
			    casingType = "AcidShellsCasing"; 	
				break;
		}
		// Always shoot the shield breaking projectile
		PB_FireBullets("PB_10GAPellet_LP",1,0,0,0,0);

        for(int i = 0; i < 2; i++)
        {
            PB_SpawnCasing(casingType,random(10,14),random(-1,3),random(26,28),random(1,3),random(-5,-2),random(4,7));
            A_FireProjectile("ShotgunWad",random(-2,2),0,-3,-4,FPF_NOAUTOAIM,random(-2,2));
        }
    }

    action bool getWeaponSpin()
    {
        return invoker.mWeaponIsSpinning;
    }

    action void setWeaponSpin(bool set)
    {
        invoker.mWeaponIsSpinning = set;
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            MTGS E -1;
            Stop;

        WeaponRespect:
            TNT1 A 0 A_StartSound("Ironsights",CHAN_AUTO);
            MSGS DCBA 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("CHGNPKUP",CHAN_AUTO);
            MSGI ABCD 1 A_DoPBWeaponAction();
            MSGI ABCDABCD 1 A_DoPBWeaponAction();
            MSGI ABCDA 1 A_DoPBWeaponAction();
            Goto Ready3;

        Deselect:
            TNT1 A 0 PBX_WeaponLower();
            MSGS ABCD 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("CHGNPKUP");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            MSGS DCBA 1 A_GunFlash();
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
            TNT1 A 0 A_ClearRefire();
            TNT1 A 0 A_JumpIf(getWeaponSpin(),"Ready2");
            TNT1 A 0 setWeaponSpin(false);
        ReadyToFire:
			MSGI A 1 {
                PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
                return A_DoPBWeaponAction();
            }
            loop;

        Ready2:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
            }
        ReadyToFire2:
            MSGI ABCD 1 {
                A_StartSound("weapons/SpinSpin/MINISHOTSPI", CHAN_6, CHANF_LOOPING, 0.3);
                A_AlertMonsters();
                PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
                return A_DoPBWeaponAction();
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 PB_jumpIfNoAmmo("StopFiring",AMMO_TAKE,false,false);
            TNT1 A 0 A_JumpIf(getWeaponSpin(),"Hold");
            MSGI A 0 A_StartSound("weapons/SpinSpin/MINISHOTSTA",CHAN_6);
            MSGI BCDAB 1;
        Hold:
            TNT1 A 0 PB_jumpIfNoAmmo("StopFiring",AMMO_TAKE,false,false);
            MSGI A 0 {
				A_ZoomFactor(0.97);
                A_StartSound("weapons/SpinSpin/MINISHOTSPI", CHAN_6, CHANF_LOOPING, 0.3);
			}
            MSGF A 1 Bright fireWeapon();
            MSGF B 1 A_ZoomFactor(0.98);
            MSGF C 1 A_ZoomFactor(1);
            MSGF D 1;
            TNT1 A 0 PB_ReFire("Hold");
            TNT1 A 0 A_JumpIf(getWeaponSpin(),"Ready2");
        StopFiring:
            TNT1 A 0 {
                setWeaponSpin(false);
				A_StartSound("weapons/SpinSpin/MINISHOTSTO",CHAN_6);
                A_ClearRefire();
            }
            MSGI ABCD 1 A_DoPBWeaponAction();
            MSGI AABBCCDD 1 A_DoPBWeaponAction();
            Goto Ready3;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
            }
            TNT1 A 0 PB_jumpIfNoAmmo("StopFiring",AMMO_TAKE,false,false);
            TNT1 A 0 A_JumpIf(getWeaponSpin(),"StopSpin");
        SpinLoop:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
                A_AlertMonsters();
				A_StartSound("weapons/SpinSpin/MINISHOTSTA",CHAN_6);
                setWeaponSpin(true);
            }
            MSGI BCDABCD 1 A_DoPBWeaponAction();
            TNT1 A 0 PB_ReFire("Ready2");
            Goto Ready3;

        StopSpin:
            MSGI A 0 setWeaponSpin(false);
            MSGI A 0 A_StartSound("weapons/SpinSpin/MINISHOTSTO",CHAN_6);
            MSGI ABCD 1 A_DoPBWeaponAction();
            MSGI AABBCCDD 1 A_DoPBWeaponAction();
            Goto Ready3;

//////////////////////////// RELOAD ////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// UNLOAD ////////////////////////////////////////////////////////////////////////////////////
//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 {
                A_TakeInventory("GoWeaponSpecialAbility", 1);
                A_Print("$PBX_NoSpecial");
            }
        Unload:
		Reload:
            Goto Ready3;
       
//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
            C1MZ A 1 bright;
			C1MZ B 1 bright;
			stop;

        FlashPunching:
            // 14 frames
		    TNT1 A 14;
            goto Ready3;

        FlashKicking:
            // 15 frames
            MSGS AEFG 1;
            MSGS H 7;
            MSGS GFEA 1;    
            goto Ready3;

        FlashAirKicking:
            // 16 frames
            MSGS AEFG 1;
            MSGS H 8;
            MSGS GFEA 1;
            goto Ready3;

        FlashSlideKicking:
            // 27 frames
            MSGS AEFG 1;
            MSGS H 19;
            MSGS GFEA 1;
            goto Ready3;

        FlashSlideKickingStop:
            // 7 frames
            MSGS GFEAAAA 1;
            goto Ready3;
    }
}