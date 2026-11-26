// Wheel Tokens
Class SelectCSG_No : 			Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_SwitchSingle : 	Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_SwitchHook : 	Inventory {default{inventory.maxamount 1;}}

Class SelectCSG_SwitchMenu : 	Inventory {default{inventory.maxamount 1;}}

Class SelectCSG_Buckshot : 		Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_Danmaku : 		Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_Slugshot :		Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_Dragonsbreath : Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_Flak : 			Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_Flechette : 	Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_Explosive : 	Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_WPhosphorus : 	Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_Doom : 			Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_SubZero : 		Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_HellFire : 		Inventory {default{inventory.maxamount 1;}}
Class SelectCSG_Acid : 			Inventory {default{inventory.maxamount 1;}}

// Upgrade Tokens
Class ExplosiveUpgrade 			: CSSGUpgradetokens{}
Class WhitePhosphorusUpgrade 	: CSSGUpgradetokens{}
Class TripleDoomUpgrade 		: CSSGUpgradetokens{}
Class DanmakuUpgrade 			: CSSGUpgradetokens{}
Class SubZeroUpgrade 			: CSSGUpgradetokens{}
Class HellFireUpgrade 			: CSSGUpgradetokens{}
Class AcidShellsUpgrade 		: CSSGUpgradetokens{}

// Others
class MeatHookExtended : Inventory {Default {Inventory.MaxAmount 1;}}

//a base class for tokens, wasnt really needed, but at first i thought they were a lot more
Class CSSGUpgradetokens : inventory
{
	default
	{
		inventory.maxamount 1;
		+INVENTORY.UNCLEARABLE;
		+INVENTORY.UNDROPPABLE;
	}
}

// Casings
Class ShellCasingBase : ShotgunCasing  
{	
	states
	{
		cachetextures:
			WCS1 A 0; CAS8 A 0; CAS9 A 0; XCS1 A 0;
			TDS1 A 0; DC0S A 0; CAF8 A 0; XFC1 A 0;
			CAHF K 0; CAAS K 0;
			stop;

	}
}

Class BuckShellCasing :			ShellCasingBase {default{PB_CasingBase.CasingSprite 'CASX';}}
Class SlugShellCasing :			ShellCasingBase {default{PB_CasingBase.CasingSprite 'CAS5';}}
Class DragonShellCasing :		ShellCasingBase {default{PB_CasingBase.CasingSprite 'CAS6';}}
Class ExplosiveShellCasing :	ShellCasingBase {default{PB_CasingBase.CasingSprite 'XCS1';}}
Class FlakShellCasing :			ShellCasingBase {default{PB_CasingBase.CasingSprite 'CAS9';}}
Class FlechetShellCasing :		ShellCasingBase {default{PB_CasingBase.CasingSprite 'CAF8';}}
Class WhitePShellCasing :		ShellCasingBase {default{PB_CasingBase.CasingSprite 'WCS1';}}
Class TDoomCasing :				ShellCasingBase {default{PB_CasingBase.CasingSprite 'TDS1';}}
Class DanmakuCasing :			ShellCasingBase {default{PB_CasingBase.CasingSprite 'DC0S';}}
Class SubZeroCasing :			ShellCasingBase {default{PB_CasingBase.CasingSprite 'XFC1';}}
Class HellFireCasing :			ShellCasingBase {default{PB_CasingBase.CasingSprite 'CAHF';}}
Class AcidShellsCasing :		ShellCasingBase {default{PB_CasingBase.CasingSprite 'CAAS';}}