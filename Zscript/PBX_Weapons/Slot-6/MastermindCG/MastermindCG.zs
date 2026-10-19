// Mastermind Chaingun
// From a Brutal Doom Addon by Dox778
// Sprite Base - Dr_Cosmobyte, Captain J and Mike12.
// Lighting - Sechtera
// Pickup - Turbo
// Port to PB By Jenny / Jeniffer
// Updated by 17qwerty

// Includes
// #include "./MastermindCG_Functions.zs"

class PBX_MastermindChaingun : PBX_WeaponBase
{
	Default
	{
        //$Title Spider Mastermind Chaingun
        //$Category Weapons
        //$Sprite RMN2A0
//////////////////////////// WEAPON DATA ////////////////////////////////////////////////////////////////////////////////////
        Inventory.AltHudIcon "RMN2A0";
		PB_WeaponBase.ReserveToMagAmmoFactor 1;
		
		Weapon.BobRangeX 0.3;
		Weapon.BobRangeY 0.5;
		Weapon.BobStyle "InverseSmooth";
   		Weapon.BobSpeed 2.0;
    	FloatBobStrength 0.5;
		Scale 0.9;
//////////////////////////// AMMO ///-/////////////////////////////////////////////////////////////////////////////////
		Weapon.AmmoType1 "PB_RocketAmmo";
	    Weapon.AmmoGive1 25;
		
//////////////////////////// MESSAGES & SOUNDS ////////////////////////////////////////////////////////////////////////////////////
		Obituary "$OB_WEAP_MASTERMINDCG";
		Inventory.Pickupmessage "$PBX_MastermindCG_Pickup";
		Inventory.PickupSound "CBOXPKUP";
		Tag "$PBX_MastermindCG_Tag";
        
//////////////////////////// WEAPON FLAGS ////////////////////////////////////////////////////////////////////////////////////
        +WEAPON.NOAUTOAIM
        +WEAPON.EXPLOSIVE
        +WEAPON.NOAUTOFIRE
        +FORCEXYBILLBOARD
        +FLOORCLIP
        +DONTGIB
	}

//////////////////////////// VARIABLES ////////////////////////////////////////////////////////////////////////////////////
	bool SoulSeekerMode;
	const AMMO_PER_DURABILITY = 1; // How many rockets does it take for one point of durability
	const DURABILITY = 200; // Durability Amount
	const DURABILITY_NAME = "MastermindCGDurability"; 
      
//////////////////////////// OVERRIDES ////////////////////////////////////////////////////////////////////////////////////
    override void PostBeginPlay()
    {
        SoulSeekerMode = false;
        Super.PostBeginPlay();
    }

	override bool TryPickup(in out Actor toucher)
    {
        bool pickup = Super.TryPickup(toucher);
        if (pickup)
			toucher.A_giveinventory(DURABILITY_NAME,DURABILITY);
		
        return pickup;
    }

//////////////////////////// FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////
	action void MastermindCG_FireWeapon(int ticCount)
	{
		name tofire = invoker.SoulSeekerMode ? "MastermindCG_SoulSeeker" : "MastermindCGProjectile";

		switch (ticCount)
		{
			default:
			case 1:
				A_AlertMonsters();
				A_StartSound("CHGNSHOT", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
				A_StartSound("FARMGN", CHAN_WEAPON, CHANF_OVERLAP, 1.0);
				A_ZoomFactor(0.98, SPF_INTERPOLATE);
				// PB_FireBullets("CyberBallsPlayer", 1, frandom(-2,2), 0, 0, frandom(-0.5, 0.5));
				PB_LowAmmoSoundWarning("default", invoker.ammotype1.getclassname());
				A_TakeInventory(invoker.AmmoType1, invoker.AMMO_PER_DURABILITY, TIF_NOTAKEINFINITE);
				A_TakeInventory(DURABILITY_NAME,1,TIF_NOTAKEINFINITE);
				A_SpawnItemEx("PlayerMuzzle2",30,5,27);
				A_FireCustomMissile("YellowFlareSpawn", 15, 0, 0, 0);
				A_FireCustomMissile("YellowFlareSpawn", -15, 0, 0, 0);
				PB_FireBullets(tofire, 1, 2, 0, 0, 3);
				PB_FireOffset();
				PB_IncrementHeat(4);
				break;

			case 2: case 3:
				if(ticCount == 2)
				{
					A_ZoomFactor(1.0, SPF_INTERPOLATE);
					A_FireCustomMissile("EmptyGrenadeBrass", random[sfx](-2,2), 0, 0, -12, 0, random[sfx](-2,2));
				}
				PB_WeaponRecoil(-0.75,frandom[sfx](-0.75,0.75));
				break;
		}
	}

//////////////////////////// STATES ////////////////////////////////////////////////////////////////////////////////////
	States
	{
//////////////////////////// SETUP ////////////////////////////////////////////////////////////////////////////////////
		Spawn:
            RMN1 H -1;
            Stop;
        Deselect:
           TNT1 A 0 PBX_WeaponLower();
			RMNG JKLMN 1;
			TNT1 A 0 A_Lower();
			Wait;
		Select:
			TNT1 A 0 PBX_WeaponRaise("CBOXPKUP");
			// TNT1 A 0 PB_RespectIfNeeded();
		SelectAnimation:
			RMNG NMLKJ 1 A_GunFlash();
//////////////////////////// READY ////////////////////////////////////////////////////////////////////////////////////
		Ready:
		Ready3:
			TNT1 A 0 PB_HandleCrosshair(69);
			TNT1 A 0 PB_CoolDownBarrel();
			RMNG F 1 A_DoPBWeaponAction();
			Loop;
		
//////////////////////////// FIRE ////////////////////////////////////////////////////////////////////////////////////
		Fire:
            TNT1 A 0 PBX_HandleDurability(DURABILITY_NAME,AMMO_PER_DURABILITY);
            TNT1 AAAA 0;
			RMNG A 1 BRIGHT MastermindCG_FireWeapon(1);
			RMNG G 1 BRIGHT MastermindCG_FireWeapon(2);
			RMNG HI 1 BRIGHT MastermindCG_FireWeapon(3);
		FireSecondShot:
            TNT1 A 0 PBX_HandleDurability(DURABILITY_NAME,AMMO_PER_DURABILITY);
			RMNG B 1 BRIGHT MastermindCG_FireWeapon(1);
			RMNG G 1 BRIGHT MastermindCG_FireWeapon(2);
			RMNG HI 1 BRIGHT MastermindCG_FireWeapon(3);
			TNT1 A 0 PB_ReFire();
			RMNG FCDEF 1 A_DoPBWeaponAction();
			RMNG CDEF 2 A_DoPBWeaponAction();
			RMNG CDE 3 A_DoPBWeaponAction();
			goto Ready3;

		Reload:
			TNT1 A 0;
			goto Ready3;

//////////////////////////// ALT FIRE ////////////////////////////////////////////////////////////////////////////////////
        NoAmmo:
			RMNG C 2 A_DoPBWeaponAction(WRF_NOFIRE);
			RMNG D 2 A_DoPBWeaponAction(WRF_NOFIRE);
			RMNG E 3 A_DoPBWeaponAction();
			RMNG F 3 A_DoPBWeaponAction();
            TNT1 A 0 A_PlaySound("weapons/empty", 4);
		   	goto Ready3;
		
//////////////////////////// WEAPON SPECIAL ////////////////////////////////////////////////////////////////////////////////////
		Weaponspecial:
			TNT1 A 0 A_Takeinventory("GoWeaponSpecialAbility",1);
			TNT1 A 0 {
				if(invoker.SoulSeekerMode) {
					invoker.SoulSeekerMode = false;
				}
				else {
					invoker.SoulSeekerMode = true;
				}
            	A_StartSound("REVCYC", CHAN_AUTO, CHANF_OVERLAP);
				A_StartSound("weapons/rocket/innercycle", CHAN_AUTO, CHANF_OVERLAP);
				A_Print(invoker.SoulSeekerMode ? "$PBX_MastermindCG_SoulSeeker" : "$PBX_MastermindCG_Normal");
			}
			goto Ready3;

//////////////////////////// FLASH STATES ////////////////////////////////////////////////////////////////////////////////////
		FlashPunching:
        	RMNG F 1;
			RMNG O 1;
			RMNG P 1;
			RMNG Q 1;
			RMNG R 1;
			RMNG S 4;
			RMNG R 1;
			RMNG Q 1;
			RMNG P 1;
			RMNG O 1;
			RMNG F 1;
			goto Ready3;

        FlashKicking:
			RMNG F 1;
			RMNG O 1;
			RMNG P 1;
			RMNG Q 1;
			RMNG R 1;
			RMNG S 6;
			RMNG R 1;
			RMNG Q 1;
			RMNG P 1;
			RMNG O 1;
			RMNG F 1;
			goto Ready3;
			
		FlashAirKicking:
            RMNG F 1;
			RMNG O 1;
			RMNG P 1;
			RMNG Q 1;
			RMNG R 1;
			RMNG S 7;
			RMNG R 1;
			RMNG Q 1;
			RMNG P 1;
			RMNG O 1;
			RMNG F 1;
			goto Ready3;
			
		FlashSlideKicking:
            RMNG F 1;
			RMNG O 1;
			RMNG P 1;
			RMNG Q 1;
			RMNG R 1;
			RMNG S 13;
			RMNG R 1;
			RMNG Q 1;
			RMNG P 1;
			RMNG O 1;
			RMNG F 1;
			goto Ready3;
			
		FlashSlideKickingStop:
			RMNG F 7;
			goto Ready3;
	}
}