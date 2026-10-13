// THIS IS AN OLD VERSION KEPT FOR ARCHIVING PURPOSES

// Eternal Chaingun 
// From a BD Addon by D_Boi
// TypicalSF (Base Sprite)
// Sergeant_Mark_IV (BD code used as a Base)

// Includes
// #include "./EternalChaingun_Functions.zs"

// Actual Weapon
class PBX_EternalMinigun : PBX_WeaponBase
{
    Default
    {
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        Weapon.SelectionOrder 2545;
        Weapon.SlotNumber 5;
        Weapon.SlotPriority 0.5;
        // PB_WeaponBase.UsesWheel true;
        // PB_WeaponBase.WheelInfo "PlasmaBlasterWheel";
	    Inventory.AltHUDIcon "MGUNA0";

//////////////////////////// AMMO ////////////////////////////////////////////////////////////////////////////////////
        Weapon.AmmoType1 "PB_HighCalMag";
        Weapon.AmmoGive1 50;

//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
        Inventory.Pickupmessage  "$PBX_EternalChaingun_Pickup";
        Inventory.PickupSound "CBOXPKUP";
        Obituary "$OB_WEAP_ETERNALCHAINGUN";
        AttackSound "None";
        Tag "$PBX_EternalChaingun_Tag";
        Scale 0.9;

//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.CHEATNOTWEAPON;
        +WEAPON.NOAUTOAIM;
        +WEAPON.NOAUTOFIRE;
        +WEAPON.NO_AUTO_SWITCH;
    }

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
    int mPowerTime;

//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    // First time pickup
    override void AttachToOwner(Actor other)
    {
        super.AttachToOwner(other);
        if(!other) return;
        if(owner.player.readyweapon != self)
            owner.player.PendingWeapon = self;
    }
    
    // Consequent Pickup
	override bool HandlePickup(Inventory item)
    {
        // If the item being picked up is this gun
        if(item.getClassName() == self.getClassName())
        {
            let plr = owner.player;
            PBXCore_Debug.Print("Weapon Found");

            // Check if the player already has this weapons
            let weap = PBX_EternalMinigun(owner.FindInventory("PBX_EternalMinigun"));
            if(weap)
            {
                // If yes then reset the power time
                weap.mPowerTime = PBXCore_Duration.GetByCVarInSeconds("PBX_Weapons_echaingun_duration");
                // Force switch to this weapon
                if(plr.readyweapon != weap)
                    plr.PendingWeapon = weap;
                // Check if the player is already using this weapon
                if(InStateSequence(plr.FindPSprite(PSP_WEAPON).curstate, weap.ResolveState("Ready3")))
                {
                    // If yes then give powperup
                    owner.A_GiveInventory("PBX_Weapons_InfiniteAmmo",1);
                    owner.A_GiveInventory("PBX_Weapons_Drain",1);
                    owner.A_GiveInventory("PBX_Weapons_Protection",1);
                }
                PBXCore_Debug.PrintInt("Getting Cooldown, %",weap.mPowerTime);
                if(pb_newmugshot) owner.A_SetMugshotState("MegasphereGrin");
            }
            item.bPickupgood = true;
            return true;
        }
        return super.HandlePickup(item);
    }

    // Set Default power time
    override void PostBeginPlay()
    {
        mPowerTime = PBXCore_Duration.GetByCVarInSeconds("PBX_Weapons_echaingun_duration");
        PBXCore_Debug.PrintInt("Power Time is %d",mPowerTime);
        Super.PostBeginPlay();
    }

    override void DoEffect() 
	{
		super.DoEffect();
        if (level.isFrozen()) return;
        If(!owner || !owner.player || !owner.player.readyweapon) return;

        let weap = PBX_EternalMinigun(owner.FindInventory("PBX_EternalMinigun"));
        if(!weap || !(owner.player.readyweapon is "PBX_EternalMinigun") || weap.mPowerTime <= 0) return;

        if(level.time % TICRATE != 0) return;
     
        PBXCore_Debug.PrintInt("Counting seconds %d",weap.mPowerTime-1);
        weap.mPowerTime--;
    }

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
    action void EChaingun_Fire(bool isAlt = false)
    {
        if(isAlt)
        {
            PB_FireBullets("EternalChaingunTracer", 1, 3, 0, 0, 3);
            PB_FireBullets("EternalChaingunTracer", 1, 3, 0, 0, 3);
            PB_IncrementHeat();
            A_TakeInventory(invoker.ammo1.getClassName(), 1, TIF_NOTAKEINFINITE);
            PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
            PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
            A_StartSound("weapon/EternalChaingun/Shoot", CHAN_AUTO, CHANF_OVERLAP);
        }
        
        PB_FireBullets("EternalChaingunTracer", 1, 3, 0, 0, 3);
        A_TakeInventory(invoker.ammo1.getClassName(), 1, TIF_NOTAKEINFINITE);
        PB_IncrementHeat();
        PB_GunSmoke_Basic(0,0,2);//A_FireCustomMissile("GunFireSmoke", 0, 0, 0, 0, 0, 0);
        A_StartSound("weapon/EternalChaingun/Shoot", CHAN_AUTO);
        PB_FireOffset();
        PB_DynamicTail("lmg", "lmg");
        A_AlertMonsters();
        PB_SpawnCasing("PB_EmptyBrass", 19,-13,24,0,-frandom(3,6),frandom(-1,1), false);
        PB_WeaponRecoil(-0.6,frandom[sfx](1.6, -1.6));
        // A_Firecustommissile("50CaseSpawn",0,0,-12,-18)
        A_FlashOverlay();
    }

    action state EChaingun_Ready()
    {
        if(EChaingun_IsInPowerMode())
            return A_DoPBWeaponAction(WRF_NOSWITCH|WRF_DISABLESWITCH);
        else
            return A_DoPBWeaponAction();
    }

    action bool EChaingun_CanNotFire()
    {
        return !EChaingun_IsInPowerMode() && !invoker.OwnerHasBerserk();
    }

    action bool EChaingun_IsInPowerMode()
    {
        return invoker.mPowerTime > 0;
    }

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
    States
    {
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
        Spawn:
            MGUN A -1;
            Stop;

        WeaponRespect:
            CHGS ABCD 1 EChaingun_Ready();
            CHAN AABBCCDDEEFFGG 1;
            TNT1 A 0 A_StartSound("8HAINSW2", CHAN_AUTO);
            CHAN H 10 EChaingun_Ready();
            TNT1 A 0 A_StartSound("8HAINSW3", CHAN_AUTO);
            CHAN GFEDCBA 1 EChaingun_Ready();
            CHAX ABCD 1 EChaingun_Ready();
            TNT1 A 0 A_StartSound("CHAINSTA", CHAN_5);
            CHAX DCBA 1 EChaingun_Ready();
            TNT1 A 0 A_StartSound("weapon/EternalChaingun/Stop", CHAN_5);
            Goto Ready3;

        Deselect:
			TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
				PB_HandleCrosshair(39);
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_WEAPON);
			}
			CHGS DCBA 1;
			TNT1 A 0 A_Lower();
			Wait;

        Select:
            TNT1 A 0 {
                if(invoker.mPowerTime > 0)
                {
                    A_GiveInventory("PBX_Weapons_InfiniteAmmo",1);
                    A_GiveInventory("PBX_Weapons_Drain",1);
                    A_GiveInventory("PBX_Weapons_Protection",1);
                }
            }
            TNT1 A 0 {
				A_WeaponOffset(0,32);
				PB_SetRoll(0);
			    PB_HandleCrosshair(39);
                PBX_WeaponRaise("weapons/minigun/respect1");
			    return PB_RespectIfNeeded();
			}
        SelectAnimation:
            CHGS ABCD 1;
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
        Ready3:
        ReadyToFire:
			CHAX A 1 {
				PB_CoolDownBarrel();
                PB_HandleCrosshair(39);
                return EChaingun_Ready();
            }
            loop;

//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
        Fire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
            }
            TNT1 A 0 {
                if(EChaingun_CanNotFire())
                {
                    A_Print("$PBX_EternalChaingun_NoBerserk");
                    return resolvestate("Ready3");
                }
                return resolvestate(null);
            }
			TNT1 A 0 {
                A_StartSound("CHAINSTA", CHAN_5);
                A_AlertMonsters();
            }
			CHAX BC 1;
			CHAX D 1;
			CHAX AB 1;
			CHAX CDABCD 1;
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
            TNT1 A 0 {
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StartSound("CHAINSPI", CHAN_5, CHANF_LOOPING);
            }
			CHGG ABCDABCD 1;
		Hold:
            TNT1 A 0 A_JumpIf(EChaingun_CanNotFire(),"SpinDown");
			TNT1 A 0 A_PlaySound("weapon/EternalChaingun/Shoot", 1);
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
			CHF_ A 1 BRIGHT EChaingun_Fire();
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
			CHF_ B 1 BRIGHT EChaingun_Fire();
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
			CHF_ C 1 BRIGHT EChaingun_Fire();
            TNT1 A 0 PB_jumpIfNoAmmo("EmptySpin",1,false,false);
			CHF_ D 1 BRIGHT EChaingun_Fire();
		    TNT1 A 0 PB_ReFire("Hold");
        SpinDown:
            TNT1 A 0 {
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_WEAPON);
                A_PlaySound("weapon/EternalChaingun/Stop");
            }
            CHAX A 1 EChaingun_Ready();
            CHAX B 1 EChaingun_Ready();
            CHAX A 0 A_FireCustomMissile("SmokeSpawner11",0,0,0,0);
            CHAX C 2 EChaingun_Ready();
            CHAX D 1 EChaingun_Ready();
            CHAX A 0 A_FireCustomMissile("SmokeSpawner11",0,0,0,0);
            CHAX A 1 EChaingun_Ready();
            CHAX B 1 EChaingun_Ready();
            CHAX A 0 A_FireCustomMissile("SmokeSpawner11",0,0,0,0);
            CHAX C 1 EChaingun_Ready();
            CHAX D 1 EChaingun_Ready();
            CHAX A 0 A_FireCustomMissile("SmokeSpawner11",0,0,0,0);
            CHAX A 1 EChaingun_Ready();
            goto Ready;

        EmptySpin:
            TNT1 A 0 {
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_WEAPON);
                A_PlaySound("weapon/EternalChaingun/Stop");
            }
            CHAX ABCD 1;
            TNT1 A 0 A_StartSound("weapons/empty",0);
            TNT1 A 0 PB_Refire("Hold");
            Goto SpinDown;
  
//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        AltFire:
            TNT1 A 0 {
                A_WeaponOffset(0,32);
                PB_SetRoll(0);
                PB_HandleCrosshair(39);
            }
            TNT1 A 0 {
                if(EChaingun_CanNotFire())
                {
                    A_Print("$PBX_EternalChaingun_NoBerserk");
                    return resolvestate("Ready3");
                }
                return resolvestate(null);
            }
            TNT1 A 0 A_StartSound("DTHDLRST",CHAN_6);
            CHAN AABBCCDDEEFFGG 1;
            TNT1 A 0 A_StartSound("8HAINSW2", CHAN_AUTO);
            CHAN H 2;
            CHNG ABCD 1;
            TNT1 A 0 {
                A_StartSound("DTHDRSN", CHAN_5, CHANF_LOOPING);
                A_StartSound("8HAINFIR", CHAN_WEAPON, CHANF_LOOPING);
            }
        AltHold:
            TNT1 A 0 A_JumpIf(EChaingun_CanNotFire(),"SpinDownAlt");
            TNT1 A 0 PB_jumpIfNoAmmo("SpinDownAlt",2,false,false);
            CHNG A 1 BRIGHT EChaingun_Fire(true);
            TNT1 A 0 PB_jumpIfNoAmmo("SpinDownAlt",2,false,false);
            CHNG B 1 BRIGHT EChaingun_Fire(true);
            TNT1 A 0 PB_jumpIfNoAmmo("SpinDownAlt",2,false,false);
            CHNG C 1 BRIGHT EChaingun_Fire(true);
            TNT1 A 0 PB_jumpIfNoAmmo("SpinDownAlt",2,false,false);
            CHNG D 1 BRIGHT EChaingun_Fire(true);
            MNGG B 0 PB_ReFire("AltHold");
        SpinDownAlt:
            TNT1 A 0 {
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_WEAPON);
                A_StartSound("DTHDLRSP", CHAN_5,CHANF_OVERLAP);
                A_PlaySound("weapon/EternalChaingun/Stop");
            }
            CHNG ABCDABCD 1;
            CHNG D 2;
        SwitchBack:
            CHAN HH 1;
            TNT1 A 0 A_StartSound("8HAINSW3", CHAN_AUTO);
            CHAN GFEDCBA 1;
            CHAX AAA 3;
            GoTo Ready;

//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
        WeaponSpecial:
            TNT1 A 0 {
                A_StopSound(CHAN_6);
                A_StopSound(CHAN_5);
                A_StopSound(CHAN_WEAPON);
                A_PlaySound("weapon/EternalChaingun/Stop");
            }
            TNT1 A 0 {
				A_Takeinventory("GoWeaponSpecialAbility",1);
                A_Print("$PBX_NoSpecial");
			}
            Goto Ready3;
            
//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
        MuzzleFlash:
            PLSE B 1 bright {
                let psp = player.FindPSprite(OverlayID());
                psp.frame += random[sfx](0, 2);
                psp.x = 162;
                psp.y = 110;
                psp.pivot = (0.5, 0.5);
                psp.scale *= frandom[sfx](0.9, 1.2);
                psp.rotation = frandom[sfx](0, 360);
                psp.alpha = frandom[sfx](0.8, 1.2);
            }
            stop;

        FlashPunching:
            CHGS ABCCDDD 1;
            CHGS DDDCCBA 1;      // 14 frames
            goto Ready3;

        FlashKicking:
            CHGS ABCCCDDD 1;
            CHGS DDCCCBA 1;     // 15 frames
            goto Ready3;

        FlashAirKicking:
            CHGS ABBCCDDD 1;
            CHGS DDDCCBBA 1;    // 16 frames
            goto Ready3;

        FlashSlideKicking:
            CHGS ABCD 2;
            CHGS D 11;
            CHGS DCBA 2; // 27 frames
            goto Ready3;

        FlashSlideKickingStop:
            CHGS DDCCBA 1;             // 7 frames
            goto Ready3;
    }
}

class EternalChaingunTracer : PB_556x45mmAP
{

    Default
    {
        Scale .9;
    }

    States
    {
        Spawn:
            PRTL A 1 BRIGHT;
            Loop;

        Death:
            TNT1 A 0;
            TNT1 A 1;
            tnt1 a 2;
        XDeath:
            TNT1 A 0 A_Explode(8, 50);
            Stop;
    }
}

mixin class PBX_Weapons_EternalChaingun_Duration
{
    override void BeginPlay()
    {
        super.BeginPlay();
        EffectTics  = PBX_Weapons_echaingun_duration * TICRATE;
    }
}

class PBX_Weapons_InfiniteAmmo   : PBX_InfiniteAmmoGiver   {mixin PBX_Weapons_EternalChaingun_Duration;}
class PBX_Weapons_Drain          : PBX_DrainGiver          {mixin PBX_Weapons_EternalChaingun_Duration;} 
class PBX_Weapons_Protection     : PBX_ProtectionGiver     {mixin PBX_Weapons_EternalChaingun_Duration; Default {DamageFactor "Normal", 0.75;}} 