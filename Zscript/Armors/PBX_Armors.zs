#include "./PBX_Armors_Actual.zs"
#include "./PBX_Armors_Spawners.zs"
#include "./PBX_Armors_Tips.zs"

enum PBX_Armors_ArmorValues
{
    RED_PERCENT              = 90
    ,RED_AMOUNT              = 160

    ,PURPLE_PERCENT          = 90
    ,PURPLE_AMOUNT           = 140

    ,WHITE_PERCENT           = 100
    ,WHITE_AMOUNT            = 200
    ,REGEN_STRENGTH          = 8

    ,ORANGE_PERCENT          = 70
    ,ORANGE_AMOUNT           = 160

    ,YELLOW_PERCENT          = 50
    ,YELLOW_AMOUNT           = 130

    ,BLACK_PERCENT           = 70
    ,BLACK_AMOUNT            = 160

    ,DEMON_PERCENT           = 100
    ,DEMON_AMOUNT            = 200

    ,CYAN_PERCENT            = 100
    ,CYAN_AMOUNT             = 40

    ,DPURPLE_PERCENT         = 33
    ,DPURPLE_AMOUNT          = 100

    ,DRED_PERCENT            = 100
    ,DRED_AMOUNT             = 200

    ,GOLD_PERCENT            = 100
    ,GOLD_AMOUNT             = 70

    // Gray Armor values are randomized 
    // between 1 and this value below
    ,GRAY_AMOUNT             = 150

    ,LBLUE_PERCENT           = 50
    ,LBLUE_AMOUNT            = 150

    // Light Green will give the player the Guardian Armor
    // If they're below a threshold
    ,LGREEN_PERCENT          = 33
    ,LGREEN_AMOUNT           = 100
    ,GUARDIAN_HP             = 200
    ,GUARDIAN_PERCENT        = 100
    ,GUARDIAN_AMOUNT         = 200

    ,PINK_PERCENT            = 100
    ,PINK_AMOUNT             = 200
    ,STUN_FREQ               = 15    // How frequent should the debuff happens (in tics)  

}

mixin class PBX_Duration_Armors
{
    override void BeginPlay()
	{
		super.BeginPlay();
		EffectTics = getDuration(self);
	}

    private
    int getDuration(actor mActor)
	{
        if(!mActor) return 1; 
        
		name tmp;
		switch(mActor.getClassName())
		{
            // Armors
            case 'WhiteArmor_Regeneration': 	tmp = 'PBX_WhiteArmor_duration';    break;
			case 'DemonArmor_Frightener': 		tmp = 'PBX_DemonArmor_duration';    break;
			case 'CyanArmor_TimeFreezer':
			case 'CyanArmor_Haste': 	        tmp = 'PBX_CyanArmor_duration';     break;
			case 'DPurpleArmor_InfAmmo': 	    tmp = 'PBX_DPurpleArmor_duration';  break;
			case 'LGreenArmor_Invul': 	        tmp = 'PBX_LGreenArmor_duration';   break;
		}

        let c = CVar.FindCVar(tmp);
        int mResult = c ? c.GetInt() * Object.TICRATE : 1;  // So its always in seconds
        return mResult;
	}

}

class PBX_ArmorBase : PB_Armor abstract
{
    Default
    {
        PBX_ArmorBase.ArmorToken '';
        Inventory.PickupSound "ARMOR"; 
        Scale 0.2; 
    }

    name armortoken;
    property ArmorToken : armortoken;

    static const name ArmorInvTokens[] = { 'RepulsorToken', 'SecondChanceToken' };
    static const name ArmorBehaviors[] = { 'ReactiveArmorBehavior', 'MagneticBehavior', 'AquaticBehavior' };

    void giveArmorTokens(Actor toucher)
    {
        // Clear Tokens & Behaviors
        for (int i = 0; i < ArmorInvTokens.Size(); i++)
            toucher.TakeInventory(ArmorInvTokens[i], 1);

        for (int i = 0; i < ArmorBehaviors.Size(); i++)
            toucher.RemoveBehavior(ArmorBehaviors[i]);

        if (armortoken == '') return;

        // armortoken may name either an Inventory token or a Behavior
        class<Behavior> bc = (class<Behavior>)(armortoken);
        if (bc)
            toucher.AddBehavior(bc);
        else
            toucher.GiveInventory(armortoken, 1);
    }

    override bool TryPickup(in out Actor toucher)
    {
        bool pickup = Super.TryPickup(toucher);
        if (pickup)
            giveArmorTokens(toucher);

        return pickup;
    }

    override string PickupMessage()
    {
        return String.Format(StringTable.Localize("$PBX_ArmorPickup"), StringTable.Localize(pickupMsg),int(self.SavePercent),int(self.SaveAmount));
    }

}

// Dies when the owner has no armor left
class PBXArmorBehavior : Behavior abstract
{
    virtual void ArmorTick() {}

    override void Tick()
    {
        if (!Owner || Owner.CountInv("BasicArmor") <= 0)
        {
            Destroy();
            return;
        }
        ArmorTick();
    }
}