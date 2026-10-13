//////////////////////////// SLOT 2 ////////////////////////////////////////////////////////////////////////////////////
// Plasma Blaster
Class HellPistolerAmmo : PB_Ammo
{
	Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_PlasmaBlaster.CELL_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_PlasmaBlaster.CELL_SIZE;
	    Inventory.Icon "ARMZA0";
        +INVENTORY.IGNORESKILL;
	}
}

// Prosurv Blaster
Class BlasterPistolCharge : PB_Ammo
{
	Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_ProsurvBlaster.CELL_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_ProsurvBlaster.CELL_SIZE;
	    Inventory.Icon "ARMZA0";
        +INVENTORY.IGNORESKILL;
	}
}

// Lever Action
Class LeverActionAmmo : PB_Ammo
{
	Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_Prosurv_LeverAction.MAGAZINE_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_Prosurv_LeverAction.MAGAZINE_SIZE;
	    Inventory.Icon "ARMZA0";
        +INVENTORY.IGNORESKILL;
	}
}

class PBX_MarlinRound : PB_LowCalMag // What the PB_Unload uses
{
    Default
    {
        Inventory.Amount PBX_Prosurv_LeverAction.AMMO_TAKE_MARLIN;
        Inventory.PickupSound "weapons/casing";
        Inventory.Icon "4LVMA0";
    }

    override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("4LVM");
    }

	States
    {
        CacheSprites:
            4LVM A 0;
    }
}

class PBX_MagnumRound : PB_LowCalMag
{
    Default
    {
        Inventory.Amount PBX_Prosurv_LeverAction.AMMO_TAKE_MAGNUM;
        Inventory.PickupSound "weapons/casing";
        Inventory.Icon "4M35A0";
    }

    override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("4M35");
    }

	States
    {
        CacheSprites:
            4M35 A 0;
    }
}

//////////////////////////// SLOT 3 ////////////////////////////////////////////////////////////////////////////////////
// CSSG
Class CSSGShellsIn : Ammo
{
	default
	{
        Inventory.Amount 0;
		inventory.maxamount PBX_CSSG.BARREL_CAPACITY;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_CSSG.BARREL_CAPACITY;
		Inventory.Icon "AUSCA0";
        +INVENTORY.IGNORESKILL;
	}
}

class PBX_CSSG_ShellBase : PB_Shell
{
	Default
    {
        Inventory.Amount PBX_CSSG.BARREL_CAPACITY;
		Ammo.BackpackAmount PBX_CSSG.BARREL_CAPACITY;
        Inventory.PickupSound "weapons/casing";
        Scale 0.25;
    }

	States
	{
		CacheSprites:
			ZCG1 A 0; ZCG2 A 0; ZCG3 A 0; ZCG4 A 0; ZCG5 A 0;
			ZCG6 A 0; ZCG7 A 0; ZCG8 A 0; ZCG9 A 0; ZC10 A 0;
			ZC11 A 0; ZC12 A 0;
	}
}

class PBX_CSSG_BuckShell          : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG8A0");}}
class PBX_CSSG_DragonsBreathShell : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZC10A0");}}
class PBX_CSSG_SlugShell          : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG9A0");}}
class PBX_CSSG_FlechetteShell     : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG1A0");}}
class PBX_CSSG_FlakShell          : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG2A0");}}
class PBX_CSSG_ExplosiveShell     : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG7A0");}}
class PBX_CSSG_WPShell            : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG6A0");}}
class PBX_CSSG_TDoomShell         : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG5A0");}}
class PBX_CSSG_DanmakuShell       : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG4A0");}}
class PBX_CSSG_SubZeroShell       : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZCG3A0");}}
class PBX_CSSG_HellFireShell      : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZC11A0");}}
class PBX_CSSG_AcidShell          : PBX_CSSG_ShellBase {override void PB_SetAmmoSprite() {sprite = GetSpriteIndex("ZC12A0");}}

// PSG
class PumpShotgunAmmo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount PBX_ProSurvPSG.MAGAZINE_SIZE;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount PBX_ProSurvPSG.MAGAZINE_SIZE;
        Inventory.Icon "AUSCA0";
        +INVENTORY.IGNORESKILL;
    }
}

class PBX_LaserCharge : PB_RocketAmmo
{
    Default
    {
        Inventory.Amount PBX_ProSurvPSG.LASERCHARGE_TAKE;
        Inventory.PickupSound "Ammocase/Open";
        Inventory.Icon "LSRCS0";
        Scale .45;
    }

    override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("LSRCS0");
        frame = 18;
    }

	States
    {
        CacheSprites:
            LSRC S 0;
    }
}

class PBX_AcidCharge : PB_RocketAmmo
{
    Default
    {
        Inventory.Amount PBX_ProSurvPSG.ACIDCHARGE_TAKE;
        Inventory.PickupSound "Ammocase/Open";
        Inventory.Icon "REMTS0";
        Scale .45;
    }

    override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("REMTS0");
        frame = 18;
    }

	States
    {
        CacheSprites:
            REMT S 0;
    }
}

class PBX_SwarmCharge : PB_RocketAmmo
{
    Default
    {
        Inventory.Amount PBX_ProSurvPSG.SWARMCHARGE_TAKE;
        Inventory.PickupSound "Ammocase/Open";
        Inventory.Icon "SWRMS0";
        Scale .45;
    }

    override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("SWRMS0");
        frame = 18;
    }

	States
    {
        CacheSprites:
            SWRM S 0;
    }
}

class PBX_Tripmine : PB_RocketAmmo
{
    Default
    {
        Inventory.Amount PBX_ProSurvPSG.TRIPMINE_TAKE;
        Inventory.PickupSound "Ammocase/Open";
        Inventory.Icon "TRPMA0";
		Scale 0.08;
    }

    override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("TRPMA0");
    }

	States
    {
        CacheSprites:
            TRPM A 0;
    }
}

// SPAS 12
class PBX_SPAS12Mag : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount PBX_SPAS12.MAGAZINE_SIZE;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount PBX_SPAS12.MAGAZINE_SIZE;
        Inventory.Icon "AUSCA0";
        +INVENTORY.IGNORESKILL;
    }
}

// Cryo SG
class CryoSGAmmo : PB_Ammo
{
	default
	{
		Inventory.Amount 0;
		inventory.maxamount PBX_CryoSG.MAGAZINE_SIZE;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount PBX_CryoSG.MAGAZINE_SIZE;
        Inventory.Icon "FZSGA0";
        +INVENTORY.IGNORESKILL;
	}
}

class CryoASGAmmo : PB_Ammo
{
    default
	{
		Inventory.Amount 0;
		inventory.maxamount PBX_CryoASG.DRUM_SIZE;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount PBX_CryoASG.DRUM_SIZE;
        Inventory.Icon "412PA0";
        +INVENTORY.IGNORESKILL;
	}
}

//////////////////////////// SLOT 4 ////////////////////////////////////////////////////////////////////////////////////
// Battle Rifle
class BR_Ammo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount PBX_BDPBattleRifle.MAGAZINE_SIZE;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount PBX_BDPBattleRifle.MAGAZINE_SIZE;
        Inventory.Icon "AUSCA0";
        +INVENTORY.IGNORESKILL;
    }
}

// Metal Sniper
class MetalSniperAmmo : PB_Ammo
{
	default
	{
		Inventory.Amount 0;
		inventory.maxamount PBX_MetalSniper.MAGAZINE_SIZE;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount PBX_MetalSniper.MAGAZINE_SIZE;
        Inventory.Icon "AUSCA0";
        +INVENTORY.IGNORESKILL;
	}
}

class PBX_ResoRound : PB_HighCalMag
{
    Default
    {
        Inventory.Amount PBX_MetalSniper.AMMO_TAKE_RESONANCE;
        Inventory.PickupSound "weapons/casing";
    }

    override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("MSXEA0");
    }

	States
    {
        CacheSprites:
            MSXE A 0;
    }
}

// Normal Rifle
class NormalRifleAmmo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount PBX_NormalRifle.MAGAZINE_SIZE;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount PBX_NormalRifle.MAGAZINE_SIZE;
        Inventory.Icon "RIFLA0";
    }
}

class NormalRifleLeftAmmo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount PBX_NormalRifle.MAGAZINE_SIZE;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount PBX_NormalRifle.MAGAZINE_SIZE;
        Inventory.Icon "RIFLA0";
    }
}

// Crossbow Ballista
class CrossbowBallistaAmmo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount PBX_Prosurv_Ballista.ARROW_AMOUNT;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount PBX_Prosurv_Ballista.ARROW_AMOUNT;
        Inventory.Icon "RIFLA0";
    }
}

mixin class PBX_BallistaPickupBase
{
    Default
    {
        Inventory.Amount PBX_Prosurv_Ballista.ARROW_AMOUNT;
        Inventory.PickupSound "Ammocase/Open";
    }

    override void PB_SetAmmoSprite()
    {
        switch(self.getClassName())
        {
            case 'PBX_BallistaBoltPickup':
                sprite = GetSpriteIndex("CRBA");
                break;

            case 'PBX_ExplosiveBoltPickup':
                sprite = GetSpriteIndex("CRBZ");
                frame = 3;
                break;

            case 'PBX_DemonicBoltPickup':
                sprite = GetSpriteIndex("CRBA");
                frame = 1;
                break;

            case 'PBX_ShockBoltPickup':
                sprite = GetSpriteIndex("CRBS");
                frame = 3;
                break;
        }
    }

    States
    {
        CacheSprites:
            CRBA A 0; CRBZ D 0; CRBA B 0; CRBS D 0;
    }
}

class PBX_BallistaBoltPickup : PB_HighCalMag    {mixin PBX_BallistaPickupBase;}
class PBX_ExplosiveBoltPickup : PB_RocketAmmo   {mixin PBX_BallistaPickupBase;}
class PBX_DemonicBoltPickup : PB_RocketAmmo     {mixin PBX_BallistaPickupBase;}
class PBX_ShockBoltPickup : PB_Cell             {mixin PBX_BallistaPickupBase;}

// XM21
class XM21Ammo : Ammo
{
    Default
    {
        Inventory.Amount 0;
        Inventory.MaxAmount PBX_XM21.MAGAZINE_SIZE;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount PBX_XM21.MAGAZINE_SIZE;
        Inventory.Icon "WM14B0";
    }
}

class CloakEnergy : PB_Ammo 
{
    Default 
	{
        Inventory.MaxAmount PBX_XM21.CLOAK_DURATION;
		ammo.backpackmaxamount PBX_XM21.CLOAK_DURATION;
        +INVENTORY.IGNORESKILL;
    }
}

//////////////////////////// SLOT 5 ////////////////////////////////////////////////////////////////////////////////////
// Neo HMG
Class HMGChamberAmmo : PB_Ammo
{
	Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_NeoHMG.MAGAZINE_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_NeoHMG.MAGAZINE_SIZE;
        +INVENTORY.IGNORESKILL;
	}
}

class HMGShield : PB_Ammo 
{
    Default 
	{
        Inventory.MaxAmount PBX_NeoHMG.SHIELD_MAXCHARGE;
		ammo.backpackmaxamount PBX_NeoHMG.SHIELD_MAXCHARGE;
        +INVENTORY.IGNORESKILL;
    }
}

// Super Nailgun
class SuperNailgunAmmo : PB_Ammo
{
    Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_SuperNailgun.MAGAZINE_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_SuperNailgun.MAGAZINE_SIZE;
        +INVENTORY.IGNORESKILL;
	}
}

class PBX_SuperNail_DroppedMag : PB_HighCalMag
{
    Default
    {
        Inventory.Amount PBX_SuperNailgun.MAGAZINE_SIZE;
        Inventory.PickupSound "Ammocase/Open";
        Height 12;
        Radius 9;
        Speed 4;
        Scale 0.57;
        Mass 1;
        SeeSound "weapons/largemagdrop";
    }

    override void PB_SetAmmoSprite()
    {
        sprite = GetSpriteIndex("DRM8");
    }

	States
    {
        CacheSprites:
            DRM8 A 0;
    }
}

//////////////////////////// SLOT 6 ////////////////////////////////////////////////////////////////////////////////////
// Cyberdemon Rocket Launcher
class CyberRLDurability : PB_Ammo
{
	default
	{
		Inventory.Amount 0;
		inventory.maxamount PBX_CyberdemonRL.DURABILITY;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount PBX_CyberdemonRL.DURABILITY;
	}
}

// Excavator
Class ExcavatorRounds : PB_Ammo
{
	Default{
		inventory.maxamount PBX_Excavator.MAGAZINE_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_Excavator.MAGAZINE_SIZE;
		+INVENTORY.IGNORESKILL
		Inventory.Icon "5DUNA0";
	}
}

// Mastermind Chaingun
class MastermindCGDurability : PB_Ammo
{
	default
	{
		Inventory.Amount 0;
		inventory.maxamount PBX_MastermindChaingun.DURABILITY;
		Ammo.BackpackAmount 0;
		Ammo.BackpackMaxAmount PBX_MastermindChaingun.DURABILITY;
	}
}

//////////////////////////// SLOT 7 ////////////////////////////////////////////////////////////////////////////////////
// BDP Railgun
Class BDPRailgunAmmo : PB_Ammo
{
	Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_BDPRailgun.MAGAZINE_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_BDPRailgun.MAGAZINE_SIZE;
	    Inventory.Icon "ARMZA0";
        +INVENTORY.IGNORESKILL;
	}
}

//////////////////////////// SLOT 8 ////////////////////////////////////////////////////////////////////////////////////
// Tesla Gun
Class TeslaAmmo : PB_Ammo
{
	Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_TeslaGun.CELL_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_TeslaGun.CELL_SIZE;
	    Inventory.Icon "ETROA0";
        +INVENTORY.IGNORESKILL;
	}
}

class Tesla_LightningCharge : PB_Ammo 
{
    Default 
	{
        Inventory.MaxAmount PBX_TeslaGun.LIGHTNING_SPECIAL_MAXCHARGE;
    }
}

// Freeze Rifle 
Class FreezeRifleAmmo : PB_Ammo
{
	Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_FreezeRifle.CELL_SIZE;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_FreezeRifle.CELL_SIZE;
	    Inventory.Icon "F12RA0";
        +INVENTORY.IGNORESKILL;
	}
}

//////////////////////////// SLOT 9 ////////////////////////////////////////////////////////////////////////////////////
// Hexa Shotgun
Class HexaShotgunAmmo : PB_Ammo
{
	Default
	{
		inventory.amount 0;
		inventory.maxamount PBX_HexaShotgun.BARREL_CAPACITY;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_HexaShotgun.BARREL_CAPACITY;
	    Inventory.Icon "HSGPA0";
        +INVENTORY.IGNORESKILL;
	}
}

//////////////////////////// OTHERS ////////////////////////////////////////////////////////////////////////////////////
// Soul Charge
Class SoulCharge: PB_Ammo
{
    Default
    {
        inventory.amount 0;
		inventory.maxamount PBX_DemonExt.SOUL_CAPACITY / 2;
		ammo.backpackamount 0;
		ammo.backpackmaxamount PBX_DemonExt.SOUL_CAPACITY;
	    Inventory.Icon "ARMZA0";
        +INVENTORY.IGNORESKILL;
    }
}

// Nuke Ammo
class PBX_NukeAmmo : PB_Ammo
{
	Default
	{
		//$Title Nuclear Warhead
		//$Category Project Brutality/Ammunition
		//$Sprite MBLKA0
		//Scale 0.13;
		Tag "$PB_LOWCALMAG_TAG";
		Inventory.Amount 1;
		Inventory.MaxAmount 1;
		Inventory.PickupSound "misc/rockboxa";
		Ammo.BackpackAmount 1;
		Ammo.BackpackMaxAmount 1;
		// PB_Ammo.ammotype "lowcal";
        PB_Ammo.HUDGraphics "BARBACY1", "BARBACY2", "BARBACY3", "BARBACY4", "ABAR1", "AMMOIC12", "Yellow";
	}
}
