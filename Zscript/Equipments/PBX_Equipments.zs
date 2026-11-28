#include "./IncendiaryGrenade.zs"
#include "./ChaosGrenade.zs"
#include "./SmokeGrenade.zs"
#include "./MedPack.zs"
#include "./Charges/ChargesBase.zs"
#include "./Tripmine.zs"

class PBX_Equipment : PB_Equipment
{
    action void EQ_FinishAnimation()
    {
        player.SetPSprite(1, player.readyweapon.ResolveState("GoingToReady2"));
    }

    action void EQ_SetWeaponState(StateLabel st = "GoingToReady2")
    {
        let weap = PB_WeaponBase(player.readyweapon); if(!weap) return;
        A_TakeInventory("ToggleEquipment",1);
        weap.PB_SetUsingMelee(false);
        weap.PB_SetUsingEquipment(false);
        weap.A_LegOverlay(-1000, "FirstPersonLegsStand");
        weap.A_ClearReFire();
        player.SetPSprite(PSP_WEAPON, player.readyweapon.ResolveState(st));
    }

    action state EQ_JumpIfHold(StateLabel st = "HoldEquipment")
    {
        if(PressingUser1())
        {
            return resolvestate(st);
        }
        return resolvestate(null);
    }

    action int EQ_GetAmount()
    {
        return CountInv(invoker.AmmoType);
    }

    action void EQ_TakeAmmo(int amt = 1)
    {
        A_TakeInventory(invoker.AmmoType,amt,TIF_NOTAKEINFINITE);
    }
}