// Plasma Blaster 
// From Project Survival made by ThePopeOfDope

// Includes
// #include "./prosurvblaster_Functions.zs"
// #include "./PlasmaBlaster_Wheel.zs"

// Actual Weapon
class PBX_ProsurvBlaster : PBX_WeaponBase
{
    Default
    {
        Weapon.BobRangeX 0.3;
        Weapon.BobRangeY 0.5;
        Weapon.BobStyle "InverseSmooth";
        Weapon.BobSpeed 2.4;
        Weapon.AmmoType1 "BlasterPistolCharge";
        Inventory.MaxAmount 3;
        Inventory.Amount 1;
        +FLOORCLIP;
        +DONTGIB;
        Obituary "$OB_WEAP_PROSURVBLASTER";
        AttackSound "None";
        Tag "$PBX_ProsurvBlaster_Tag";
        Inventory.Icon "BRPIA0";
        DamageType "Plasma";
        Inventory.PickupSound "weapons/pistolup";
        Inventory.Pickupmessage "$PBX_ProsurvBlaster_Pickup";
        PBX_WeaponBase.SelectWeaponUpgrade "PBX_PlasmaBlaster";
        +WEAPON.WIMPY_WEAPON;
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NOALERT;
        Scale 0.44;
        Inventory.AltHUDIcon "BRPIA0";
        FloatBobStrength 0.5;
    }

    bool laserActive;
    enum blasterChargeSet{
        SET,
        TAKE,
        GIVE
    }
    enum blasterChargeAmount{
        GIVECHARGERATE  = 3, // Give the charge every this amount of tic
        GIVECHARGE      = 1, // How many charge is given each rate
        TAKECHARGE      = 5, // Take this many charge each shot
        CHARGERELOAD    = 3  // How fast should the reload charge the battery
    }
    const CELL_SIZE = 100;
    const MUZZLELAYER = -5;

    mixin PBX_LaserSight;

    static const StateLabel blockedLaserStates[] = {
        "Reload", "Recharge","WeaponRespect", "Deselect", "SelectAnimation", "ReloadFromADS", "WeaponInspect",
        "FlashPunching", "FlashKicking", "FlashAirKicking", "FlashSlideKicking", "FlashSlideKickingStop",
        "SwitchAnimation"
    };

    override void DoEffect() 
	{
		super.DoEffect();
        if (level.isFrozen()) return;
        if(!owner || !owner.player || !owner.player.readyweapon) return;

        // This way the blaster will always recharge even if not selected
        if(self.ammo1.amount < CELL_SIZE)
            giveBlasterCharge();

    }

    override void PBX_DoEffectWeaponReady()
    {
		PBX_SpawnLaserSight(BLUE_DOT);
    }

    void giveBlasterCharge()
    {
        // Dont give the charge if they're in one of the exceptions
        static const StateLabel blockedStates[] = {
            "Fire", "Fire2", "Reload", "Recharge"
        };

        let psp = owner.player.FindPSprite(PSP_WEAPON);
        if(!psp) return;

        for (int i = 0; i < blockedStates.Size(); i++)
        {
            if (InStateSequence(psp.curstate, ResolveState(blockedStates[i]))) return;
        }

        // Give the charge every this amount of tic
        if(level.time % GIVECHARGE != 0) return;
        owner.A_GiveInventory(self.ammo1.getClassName(),1);
    }

    action void fireweapon(int tic)
    {
        bool ads     = PB_GetZoom();
        double zoomA = ads ? 1.24 : 0.985;
        double zoomB = ads ? 1.245 : 0.99;
        double zoomC = ads ? 1.25 : 1.0;

        switch(tic)
        {
            case 1: case 2: case 3:
                // Only called in First Tic
                if(tic == 1)
                {
                    PB_IncrementHeat();
                    A_GunFlash();
                    A_Overlay(MUZZLELAYER, "GunFlash", true);
                    A_AlertMonsters();
                    PB_TakeAmmo(invoker.ammo1.getClassName(),TAKECHARGE,0);
                    // modifyBlasterCharge(TAKE,5);
                    A_StartSound("weapons/blasterpistol/fire",CHAN_WEAPON,CHANF_OVERLAP);
                    if(!ads) PB_WeaponRecoil(-0.18,frandom[sfx](-0.08,0.08));
                    A_FireCustomMissile("BlueFlareSpawn", 0, 0, 0, 0, 0, 0);
		            PB_FireBullets("ProsurvBlasterProjectile", 1, 0, 0, 0, frandom(-0.1, 0.1));
                }

                // Depends on which Tic
                A_ZoomFactor(tic == 1 ? zoomA : tic == 2 ? zoomB : zoomC);
                
                break;
        }
    }

    // All in one function to modify the battery charge
    action void modifyBlasterCharge(int mode, int amount)
    {
        string ammo = invoker.ammo1.getClassName();
        switch(mode)
        {
            case SET:
                A_SetInventory(ammo,amount);
                break;
            case TAKE:
                A_TakeInventory(ammo,amount);
                break;
            case GIVE:
                A_Giveinventory(ammo,amount);
                break;
        }
    }

    States
    {
        Spawn:
            BRPI A -1;
            Stop;

        WeaponRespect:
            TNT1 A 0 {
                A_SetCrosshair(-1);
            }
            TNT1 A 10 A_DoPBWeaponAction();
            // TNT1 A 0 A_StartSound("weapons/blasterpistol/ready",CHAN_WEAPON);
            BRGT EDCBAAAAA 1 A_DoPBWeaponAction();
            BRGC CDEF 1 {
                PB_SetRoll(roll+.2);
                return A_DoPBWeaponAction();
            }
            TNT1 A 0 A_StartSound("weapons/blasterpistol/recharge",CHAN_WEAPON,CHANF_OVERLAP);
            BRGC GHIJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJK 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            BRGC LM 1 A_DoPBWeaponAction();
            BRGC NOPQ 1 {
                PB_SetRoll(roll-.2);
                return A_DoPBWeaponAction();
            }
            Goto Ready3;

		WeaponInspect:
            TNT1 A 0 A_StartSound("weapons/blasterpistol/ready",CHAN_WEAPON,CHANF_OVERLAP);
            BRGC CDEF 1 {
                PB_SetRoll(roll+.2);
                return A_DoPBWeaponAction();
            }
            BRGC GLL 1 A_DoPBWeaponAction();
            BRGC LLLLLLLLLLLLLL 1 A_DoPBWeaponAction(); 
        InspectHold:
            BRGC L 1 A_DoPBWeaponAction(); 
			TNT1 A 0 A_PressingReload("InspectHold");
            TNT1 A 0 A_StartSound("BEPBEP",CHAN_WEAPON,CHANF_OVERLAP);
            BRGC LM 1 A_DoPBWeaponAction();
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            BRGC NOPQ 1 {
                PB_SetRoll(roll-.2);
                return A_DoPBWeaponAction();
            }
            Goto Ready3;

        Deselect:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(65);
                A_ZoomFactor(1.0);
                PB_SetZoom(false);
			}
			BRGT BCDE 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(65);
                modifyBlasterCharge(SET,CELL_SIZE);
                PBX_WeaponRaise("weapons/blasterpistol/ready");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            BRGT EDCB 1;
        Ready3:
			TNT1 A 0 PBX_CheckInspect();
            BRGT A 1 {
			    PB_HandleCrosshair(65);
                PB_CoolDownBarrel();
                if(invoker.ammo1.amount < CELL_SIZE && (PressingReload() || (player.oldbuttons & BT_RELOAD)))
                    return resolvestate("Reload");
                return PB_ReadyFire(useMag:false);
            }
            Loop;

        Ready2:
            BRGG F 1 {
                A_SetCrosshair(-1);
                PB_CoolDownBarrel();
                if(invoker.ammo1.amount < CELL_SIZE && (PressingReload() || (player.oldbuttons & BT_RELOAD)))
                    return resolvestate("Reload");
                return PB_ReadyFire(ads:true,useMag:false);
            }
            Loop;

        Fire:
            TNT1 A 0 {
			    PB_HandleCrosshair(65);
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
            }
			TNT1 A 0 A_JumpIf(PB_GetZoom(), "Fire2");
			TNT1 A 0 PB_JumpIfNoAmmo(secondary:false);
            BRGF A 1 BRIGHT fireweapon(1);
            BRGF B 1 fireweapon(2);
            BRGF C 1 fireweapon(3);
            BRGF DC 1 {
                if (JustPressed(BT_ATTACK) && invoker.ammo1.amount > 0) 
                    return ResolveState("Fire");
                return ResolveState(null);
            }
            BRGT AAAAAAA 1 {
                if (JustPressed(BT_ATTACK) && invoker.ammo1.amount > 0) 
                    return ResolveState("Fire");
                return ResolveState(null);
            }
            Goto Ready3;

        Fire2:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                A_SetCrosshair(-1);
            }
			TNT1 A 0 PB_JumpIfNoAmmo(secondary:false);
            BRGG G 1 BRIGHT fireweapon(1);
            BRGG H 1 fireweapon(2);
            BRGG I 1 fireweapon(3);
            BRGG JKLFFFFFF 1 {
                if (JustPressed(BT_ATTACK) && invoker.ammo1.amount > 0) 
                    return ResolveState("Fire2");
                return ResolveState(null);
            }
            Goto Ready2;

        AltFire:
            TNT1 A 0 {
                A_GunFlash("LightDone",GFF_NOEXTCHANGE);
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(65);
            }
            TNT1 A 0 A_StartSound("IronSights");
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Zoomout");
        ZoomIn:
            TNT1 A 0 A_ZoomFactor(1.25);
            BRGG BC 1 ;
            BRGG DEF 1;
            TNT1 A 0 {
                PB_SetZoom(true);
                A_SetCrosshair(-1);
            }
            Goto Ready2;

        Zoomout:
            TNT1 A 0 {	
                A_GunFlash("LightDone",GFF_NOEXTCHANGE);
                PB_SetZoom(false);
                PB_HandleCrosshair(65);
                A_ZoomFactor(1.0);
            }
            BRGG FED 1 ;
            BRGG CB 1 ;
            Goto Ready3;

        ReloadFromADS:
            TNT1 A 0 {	
                A_GunFlash("LightDone",GFF_NOEXTCHANGE);
                PB_SetZoom(false);
                PB_HandleCrosshair(65);
            }
            BRGG FED 1 ;
            BRGG CB 1 ;
        Reload:
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"ReloadFromADS");
            TNT1 A 0 {
                A_ZoomFactor(1.0);
                A_SetCrosshair(-1);
			}
            TNT1 A 0 PB_CheckReload(null, null, null, "Ready3", "Ready3", CELL_SIZE);
        Recharge:
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            BRGC CDEF 1 PB_SetRoll(roll+.2);
            TNT1 A 0 A_StartSound("weapons/blasterpistol/recharge",CHAN_WEAPON,CHANF_OVERLAP);
            BRGC GH 1;
            BRGC I 1;
            // BRGC JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ 1 {
            //     modifyBlasterCharge(GIVE, CHARGERELOAD);
            //     PB_SetMagEmpty(false);
            //     PB_SetMagUnloaded(false);
            //     PB_SetChamberEmpty(false);
            // }
        AddCharge:
            BRGC J 1 {
                modifyBlasterCharge(GIVE, CHARGERELOAD);
                PB_SetMagEmpty(false);
                PB_SetMagUnloaded(false);
                PB_SetChamberEmpty(false);
            }
            TNT1 A 0 A_JumpIf(invoker.ammo1.amount < CELL_SIZE,"AddCharge");
            BRGC JJJ 1;
            BRGC K 1;
            TNT1 A 0 A_StartSound("Ironsights",CHAN_WEAPON,CHANF_OVERLAP);
            BRGC LM 1;
            BRGC NOPQ 1 PB_SetRoll(roll-.2);
            TNT1 A 0 PB_SetReloading(false);
            Goto Ready3;

        Unload:
            TNT1 A 0 ;
            Goto Ready3;

        WeaponSpecial:
            TNT1 A 0 {
				A_Takeinventory("GoWeaponSpecialAbility",1);
				PB_HandleCrosshair(65);
			}
            TNT1 A 0 PBX_ToggleLaserSight();
            TNT1 A 0 A_JumpIf(PB_GetZoom(),"Ready2");
        SwitchAnimation:
            BRGY ABCDEFGFEDCBA 1;
			Goto Ready3;

        FlashKicking:
            BRGY ABCDEFGFEDCBAA 1;
            Goto Ready3;	
            
        FlashAirKicking:
            BRGY ABCDEFGGFEDCBAAA 1;
            Goto Ready3;
            
        FlashSlideKicking:
            BRGY ABCDEFGGGGGGGGGGGGGGGGGG 1;
            Goto Ready3;
        
        FlashSlideKickingStop:
            BRGY FEDCBAA 1;
            Goto Ready3;
            
        FlashPunching:
            BRGS ABCCCCCCCCCCMN 1;
			Goto Ready3;

        GunFlash:
            TNT1 A 0 A_Jump(256, "Flash1", "Flash2", "Flash3", "Flash4", "Flash5", "Flash6", "Flash7", "Flash8");
            TNT1 A 1;
            Stop;
        Flash1:
            BRGM A 1 Bright;
            STOP;
        Flash2:
            BRGM B 1 Bright;
            STOP;
        Flash3:
            BRGM C 1 Bright;
            STOP;
        Flash4:
            BRGM D 1 Bright;
            STOP;
        Flash5:
            BRGM E 1 Bright;
            STOP;
        Flash6:
            BRGM F 1 Bright;
            STOP;
        Flash7:
            BRGM G 1 Bright;
            STOP;
        Flash8:
            BRGM H 1 Bright;
            STOP;
    }
}
