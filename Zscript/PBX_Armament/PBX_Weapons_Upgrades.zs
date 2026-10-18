enum PBX_Weapons_eUpgradeTipFlags
{
	// UPGRADES
    PBX_TIP_METALSNIPER_UPGRADE = 1 << 0,
    PBX_TIP_LEVERACTION_UPGRADE = 1 << 1,
    PBX_TIP_CSSG_UPGRADE        = 1 << 2,
    PBX_TIP_EXCAVATOR_UPGRADE   = 1 << 3,
    // OTHERS
    PBX_TIP_DISABLE_UPGRADE     = 1 << 31
}

class PBX_UpgradeBase : PB_UpgradeItem abstract
{
    name upgradetoken, upgradetype, s;
    property UpgradeToken : upgradetoken;
	property Sprite : upgradetype;

	Default
	{
        PBX_UpgradeBase.upgradetoken '';
        PBX_UpgradeBase.Sprite '';
		+inventory.alwayspickup;
	}

	override void PlayPickupSound(actor toucher)
	{
		let hnd  = PB_EventHandler(EventHandler.Find("PB_EventHandler"));
		if(hnd)
		{
			if(hnd.pickuptic[toucher.PlayerNumber()]==gametic) return;
			hnd.pickuptic[toucher.PlayerNumber()] = gametic;
		}
		double atten;
		int flags = CHANF_OVERLAP|CHANF_MAYBE_LOCAL;
		if(bNoAttenPickupSound) atten = ATTN_NONE;
		else atten = ATTN_NORM;
		if(toucher && toucher.CheckLocalView()) flags |= CHANF_NOPAUSE;
		toucher.A_StartSound(PickupSound,1002,flags,1.0,atten);
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		PBX_SetUpgradeSprite();
	}

	virtual void PBX_SetUpgradeSprite()
	{
		switch(upgradetype)
		{
            default: s = "TNT1"; break;
		}

        if(upgradetype != "TNT1")
		    sprite = GetSpriteIndex(s);
	}

	States
	{
		Spawn:
			TNT1 A -1 bright light("WeaponUpgradeSpawner");
			stop;

		LoadSprites:
			TNT1 A 0;
	}
}

//////////////////////////// SLOT 2 ////////////////////////////////////////////////////////////////////////////////////
// Lever Action
class LeverAction_Upgrade : PB_UpgradeItem
{
	Default
	{
		//$Title Lever Action Rifle Upgrade
		//$Category Project Brutality - Weapon Upgrades
		//Game Doom;
		//SpawnID
		Height 32;
		-INVENTORY.ALWAYSPICKUP;
		-COUNTITEM;
		Inventory.Pickupsound "CLIPIN";
		Inventory.PickupMessage "$PBX_LeverAction_UpgradePickup";
		Inventory.althudicon "LVR5A0";
		Tag "$PBX_LeverAction_UpgradeTag";
		Scale 0.4;
		FloatBobStrength 0.5;
	}

	override bool TryPickup(in out Actor toucher) 
	{
		if(toucher.FindInventory("PBX_Prosurv_LeverAction") 
			&& toucher.FindInventory("LA_Upgraded") 
			&& toucher.CountInv("PB_LowCalMag") == toucher.GetAmmoCapacity("PB_LowCalMag")) {
			return false;
		}
        bool pickup = Super.TryPickup(toucher);
		if(pickup && PBX_Weapons_sendTip)
		{
			Array<String> tips;
			tips.Push(string.format(StringTable.Localize("$PBX_LeverActionUpgrade_Tip1"),PBX_Prosurv_LeverAction.AMMO_TAKE_MARLIN));
			PBXCore_TipsManager.SendTipArrayIfNeeded(tips,"PBX_Weapons_upgradeTipFlags", PBX_TIP_LEVERACTION_UPGRADE);
		}
		return pickup;
	}

	States
	{
		Spawn:
			LVR5 A -1;
			Stop;

		Pickup:
			TNT1 A 0 {
				A_SetInventory("LA_Upgraded", 1);
				A_GiveInventory("PBX_Prosurv_LeverAction", 1);
				A_GiveInventory("PB_LowCalMag", 30);
			}
			Stop;
	}
}

//////////////////////////// SLOT 3 ////////////////////////////////////////////////////////////////////////////////////
// CSSG
class CSSGUpgradeBase : PBX_UpgradeBase abstract
{
	Default
	{
		Inventory.Pickupsound "misc/shellbox_PickUp";
        +Inventory.AlwaysPickUp;
	}

	override bool TryPickup(in out Actor toucher) 
	{
		if(toucher.FindInventory("PBX_CSSG") && toucher.FindInventory(upgradetoken) && toucher.CountInv("PB_Shell") == toucher.GetAmmoCapacity("PB_Shell"))
			return false;
		
		return super.TryPickup(toucher);
	}
	

    override void PBX_SetUpgradeSprite()
    {
        name s;

        switch(upgradetype)
		{
			case 'ExplosiveUpgrade': 		s = "XHEL"; break;
			case 'WhitePhosphorusUpgrade': 	s = "PHEL"; break;
			case 'TripleDoomUpgrade':		s = "DHEL"; break;
			case 'DanmakuUpgrade': 			s = "THEL"; break;
			case 'SubZeroUpgrade': 			s = "FHEL"; break;
			case 'HellFireUpgrade': 		s = "HHEL"; break;
			case 'AcidShellsUpgrade': 		s = "AHEL"; break;
            default:                        s = "TNT1"; break;
		}
        sprite = GetSpriteIndex(s);
    }

    States
	{
		Pickup:
			TNT1 A 0 {
				A_GiveInventory("PB_Shell",12);
				
				if (PBX_Weapons_sendTip)
				{
					Array<String> tips;
					tips.Push("$PBX_CSSGUpgrade_Tip1");
					tips.Push("$PBX_CSSGUpgrade_Tip2");
					PBXCore_TipsManager.SendTipArrayIfNeeded(tips, "PBX_Weapons_upgradeTipFlags", PBX_TIP_CSSG_UPGRADE);
				}
				
				if(!FindInventory(invoker.upgradetoken))
					A_SetInventory(invoker.upgradetoken,1);
				
			}
			Stop;

		LoadSprites:
			XHEL A 0; PHEL A 0; DHEL A 0; 
			THEL A 0; FHEL A 0; HHEL A 0;
			AHEL A 0;
	}
}

Class ExplosiveShellsUpgrade : CSSGUpgradeBase
{
	default
	{
		inventory.pickupmessage "$PBX_PICKUP_EXPL";
		PBX_UpgradeBase.upgradetoken 'ExplosiveUpgrade';
		PBX_UpgradeBase.Sprite 'ExplosiveUpgrade';
		Inventory.althudicon "XHELA0";
	}
}

Class WPShellsUpgrade : CSSGUpgradeBase
{
	default
	{
		inventory.pickupmessage "$PBX_PICKUP_WPSP";
		PBX_UpgradeBase.upgradetoken 'WhitePhosphorusUpgrade';
		PBX_UpgradeBase.Sprite 'WhitePhosphorusUpgrade';
		Inventory.althudicon "PHELA0";
	}
}

Class DoomShellsUpgrade : CSSGUpgradeBase
{
	default
	{
		inventory.pickupmessage "$PBX_PICKUP_DOOM";
		PBX_UpgradeBase.upgradetoken 'TripleDoomUpgrade';
		PBX_UpgradeBase.Sprite 'TripleDoomUpgrade';
		Inventory.althudicon "DHELA0";
	}
}

Class DanmakuShellsUpgrade : CSSGUpgradeBase
{
	default
	{
		Inventory.PickupMessage "$PBX_PICKUP_DNMK";
		PBX_UpgradeBase.upgradetoken 'DanmakuUpgrade';
		PBX_UpgradeBase.Sprite 'DanmakuUpgrade';
		Inventory.althudicon "THELA0";
	}
}

Class SubZeroShellsUpgrade : CSSGUpgradeBase
{
	default
	{
		inventory.pickupmessage "$PBX_PICKUP_SUBZ";
		PBX_UpgradeBase.upgradetoken 'SubZeroUpgrade';
		PBX_UpgradeBase.Sprite 'SubZeroUpgrade';
		Inventory.althudicon "FHELA0";
	}
}

Class HellFireShellsUpgrade : CSSGUpgradeBase
{
	default
	{
		inventory.pickupmessage "$PBX_PICKUP_HELF";
		PBX_UpgradeBase.upgradetoken 'HellFireUpgrade';
		PBX_UpgradeBase.Sprite 'HellFireUpgrade';
		Inventory.althudicon "HHELA0";
	}
}

Class AcidShellsUpgradePickup : CSSGUpgradeBase
{
	default
	{
		inventory.pickupmessage "$PBX_PICKUP_ACDS";
		PBX_UpgradeBase.upgradetoken 'AcidShellsUpgrade';
		PBX_UpgradeBase.Sprite 'AcidShellsUpgrade';
		Inventory.althudicon "AHELA0";
	}
}

//////////////////////////// SLOT 4 ////////////////////////////////////////////////////////////////////////////////////
// Metal Sniper
class MetalSniper_Upgrade : PB_UpgradeItem
{
	Default
	{
		//$Title Metal Sniper Upgrade
		//$Category Project Brutality - Weapon Upgrades
		//Game Doom;
		//SpawnID
		Height 32;
		-INVENTORY.ALWAYSPICKUP;
		-COUNTITEM;
		Inventory.Pickupsound "CLIPIN";
		Inventory.PickupMessage "$PBX_MetalSniper_UpgradePickup";
		Inventory.althudicon "MSURA0";
		Tag "$PBX_MetalSniper_UpgradeTag";
		Scale 0.65;
		FloatBobStrength 0.5;
	}

	override bool TryPickup(in out Actor toucher) 
	{
		if(toucher.FindInventory("PBX_MetalSniper") 
			&& toucher.FindInventory("MetalSniperUpgraded") 
			&& toucher.CountInv("PB_HighCalMag") == toucher.GetAmmoCapacity("PB_HighCalMag")) {
			return false;
		}
        bool pickup = Super.TryPickup(toucher);
		if(pickup && PBX_Weapons_sendTip)
		{
			Array<String> tips;
			tips.Push("$PBX_MetalSniperUpgrade_Tip1");
			PBXCore_TipsManager.SendTipArrayIfNeeded(tips,"PBX_Weapons_upgradeTipFlags", PBX_TIP_METALSNIPER_UPGRADE);
		}
		return pickup;
	}

	States
	{
        Spawn:
            MSUR A -1;
            Stop;

        Pickup:
            TNT1 A 0 {
                A_SetInventory("MetalSniperUpgraded", 1);
                A_GiveInventory("PBX_MetalSniper", 1);
                A_SetWeaponTag("PBX_MetalSniper","$PBX_MetalSniper_Tag");
                A_GiveInventory("PB_HighCalMag", 30);
            }
            Stop;
	}
}

// Crossbow Ballista
class PBX_DemonicBallistaUpgrade : PB_UpgradeItem
{
    Default
    {
        Scale 0.7;
	    -INVENTORY.ALWAYSPICKUP
		-COUNTITEM;
        Inventory.PickupMessage "$PBX_DemonicBallistaUpgrade_Pickup";
        Inventory.PickupSound "weapons/ballista/drawstring";
		Inventory.althudicon "CB_ZC0";
		Tag "$PBX_Prosurv_Ballista_UpgradeTag";
    }

	override bool TryPickup(in out Actor toucher) 
	{
		if(toucher.FindInventory("PBX_Prosurv_Ballista") 
			&& toucher.FindInventory("Crossbow_Upgraded") 
			&& toucher.CountInv("PB_DTech") == toucher.GetAmmoCapacity("PB_DTech")) {
			return false;
		}
		return super.TryPickup(toucher);
	}

    States
	{
        Spawn:
            CB_Z Z -1;
            Stop;

        Pickup:
            TNT1 A 0 {
                // A_GiveInventory("CB_Select_DemonicMode", 1);
                A_SetInventory("Crossbow_Upgraded", 1);
                A_GiveInventory("PBX_Prosurv_Ballista", 1);
                A_SetWeaponTag("PBX_Prosurv_Ballista","$PBX_CrossbowBallista_Tag");
                A_GiveInventory("PB_DTech", 30);
                A_GiveInventory("PB_Cell", 30);
            }
            Stop;
	}
}

//////////////////////////// SLOT 6 ////////////////////////////////////////////////////////////////////////////////////
// Excavator
class PBX_ExcavatorUpgrade : PB_UpgradeItem
{
	Default
	{
		//$Title Excavator Upgrade
		//$Category Project Brutality - Weapon Upgrades
		//Game Doom;
		//SpawnID
		Height 32;
		-INVENTORY.ALWAYSPICKUP;
		-COUNTITEM;
		Inventory.Pickupsound "misc/ROCKBOXA";
		Inventory.PickupMessage "$PBX_ExcavatorUpgrade_Pickup";
		Inventory.althudicon "EX_ZA0";
		Tag "$PBX_Excavator_UpgradeTag";
		Scale 0.55;
		FloatBobStrength 0.5;
	}

	override bool TryPickup(in out Actor toucher) 
	{
		if(toucher.FindInventory("PBX_Excavator") 
		&& toucher.FindInventory("Excavator_Upgraded") 
		&& toucher.CountInv("PB_RocketAmmo") == toucher.GetAmmoCapacity("PB_RocketAmmo")
		&& toucher.CountInv("PB_Fuel") == toucher.GetAmmoCapacity("PB_Fuel")) {
			return false;
		}
		bool pickup = Super.TryPickup(toucher);
		if(pickup && PBX_Weapons_sendTip)
		{
			Array<String> tips;
			tips.Push("$PBX_ExcavatorUpgrade_Tip1");
			PBXCore_TipsManager.SendTipArrayIfNeeded(tips,"PBX_Weapons_upgradeTipFlags", PBX_TIP_EXCAVATOR_UPGRADE);
		}
		return pickup;
	}

	States
	{
        Spawn:
            EX_Z A -1;
            Stop;

        Pickup:
            TNT1 A 0 {
				A_GiveInventory("PB_RocketAmmo", 30);
                A_GiveInventory("PB_Fuel", 35);
                A_SetInventory("Excavator_Upgraded", 1);
                A_GiveInventory("PBX_Excavator", 1);
				let weap = PBX_Excavator(FindInventory("PBX_Excavator"));
				if(weap) {
					weap.isUpgraded = true;
					weap.AltHudIcon = TexMan.CheckForTexture("EX_ZA0");
				}
                A_SetWeaponTag("PBX_Excavator","$PBX_Excavator_UpgradeTag");
            }
            Stop;
	}
}

//////////////////////////// WEAPON EDITS / OTHERS ////////////////////////////////////////////////////////////////////////////////////
class SGL_Upgrade : PB_UpgradeItem
{
	Default
	{
		//$Title SGL Upgrade
		//$Category Project Brutality - Weapon Upgrades
		//Game Doom;
		//SpawnID 9410
		Height 24;
		//-COUNTITEM
		-INVENTORY.ALWAYSPICKUP;
		-COUNTITEM;
		Inventory.Pickupsound "misc/rockboxa";
		Inventory.PickupMessage "$PBX_Weapons_SGLUpgrade_Pickup";
		Tag "$PBX_Weapons_SGLUpgrade_Tag";
		Scale 0.52;
		FloatBobStrength 0.5;
	}

	override bool TryPickup(in out Actor toucher) 
	{
		if(toucher.FindInventory("PBX_SGLEdited") 
			&& toucher.FindInventory("SGLUpgraded") 
			&& toucher.CountInv("PB_RocketAmmo") == toucher.GetAmmoCapacity("PB_RocketAmmo")) {
			return false;
		}
		return super.TryPickup(toucher);
	}

	States
	{
		Spawn:
			BSGL A -1;
			Stop;

		Pickup:
			TNT1 A 0 {
				A_GiveInventory("PBX_SGLEdited", 1);
				A_SetInventory("SGLUpgraded", 1);
				A_SetWeaponTag("PBX_SGLEdited","$PBX_Weapons_SGLUpgrade_Tag2");
			}
			Stop;
	}
}

class LMG_Upgrade : PB_UpgradeItem
{
	Default
	{
		//$Title SGL Upgrade
		//$Category Project Brutality - Weapon Upgrades
		//Game Doom;
		//SpawnID 9410
		Height 24;
		//-COUNTITEM
		-INVENTORY.ALWAYSPICKUP;
		-COUNTITEM;
		Inventory.Pickupsound "LLIDOP";
		Inventory.PickupMessage "$PBX_Weapons_LMGUpgrade_Pickup";
		Tag "$PBX_Weapons_LMGUpgrade_Tag";
		Scale 0.52;
		FloatBobStrength 0.5;
	}

	override bool TryPickup(in out Actor toucher) 
	{
		if(toucher.FindInventory("PBX_LMGEdited") 
			&& toucher.FindInventory("LMGUpgraded") 
			&& toucher.CountInv("PB_HighCalMag") == toucher.GetAmmoCapacity("PB_HighCalMag")) {
			return false;
		}
		return super.TryPickup(toucher);
	}
	
	States
	{
		Spawn:
			LMPU A -1;
			Stop;

		Pickup:
			TNT1 A 0 {
				A_GiveInventory("PBX_LMGEdited", 1);
				A_SetInventory("LMGUpgraded", 1);
				A_SetWeaponTag("PBX_LMGEdited","$PBX_Weapons_LMGUpgrade_Tag2");
			}
			Stop;
	}
}