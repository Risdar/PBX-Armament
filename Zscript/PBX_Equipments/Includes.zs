#include "./Incendiary_Grenade/Incendiary_Grenade.zs"
#include "./Smoke_Grenade/Smoke_Grenade.zs"
#include "./MedPack/MedPack.zs"

class PBX_Equipment : PB_Equipment
{
    action void EQ_SetWeaponState(StateLabel st = "GoingToReady2")
    {
        player.SetPSprite(PSP_WEAPON, player.readyweapon.ResolveState(st));
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