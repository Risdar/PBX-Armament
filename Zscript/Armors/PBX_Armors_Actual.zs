//////////////////////////// RED ////////////////////////////////////////////////////////////////////////////////////
class PBX_RedArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent RED_PERCENT; 
        Armor.SaveAmount RED_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_Red"; 
        Inventory.AltHudIcon "ARM3A0";
        PBX_ArmorBase.ArmorToken 'PB_Berserk';
        Tag "$PBX_Armors_Red"; 
    }

    States 
    { 
        Spawn:
            ARM3 A 1 Bright;
            ARM3 A 2 Bright A_SpawnItem("RedFlareMedium",0,10);
            Loop;
    }

}

//////////////////////////// PURPLE ////////////////////////////////////////////////////////////////////////////////////
class PBX_PurpleArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent PURPLE_PERCENT; 
        Armor.SaveAmount PURPLE_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_Purple"; 
        Inventory.AltHudIcon "ARM6A0";
        PBX_ArmorBase.ArmorToken 'PB_Doomsphere';
        Tag "$PBX_Armors_Purple_Tag"; 
    }

    States 
    { 
        Spawn:
            ARM6 A 1 Bright;
		    ARM6 A 1 Bright A_SpawnItem("PurpleFlareSmall",0,10);
            Loop; 
    }

}

//////////////////////////// WHITE ////////////////////////////////////////////////////////////////////////////////////
class PBX_WhiteArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent WHITE_PERCENT; 
        Armor.SaveAmount WHITE_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_White"; 
        Inventory.AltHudIcon "ARM4A0";
        PBX_ArmorBase.ArmorToken 'WhiteArmor_Regeneration';
        Tag "$PBX_Armors_White_Tag"; 
    }

    States 
    { 
        Spawn:
            ARM4 A 1 Bright;
		    ARM4 A 1 Bright A_SpawnItem("WhiteFlareSmall",0,10);
            Loop; 
    }

}

class WhiteArmor_Regeneration : PBX_RegenerationGiver 
{
    mixin PBX_Duration_Armors;
    Default
    {
        Powerup.Strength REGEN_STRENGTH;
    }
}

//////////////////////////// ORANGE ////////////////////////////////////////////////////////////////////////////////////
class PBX_OrangeArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent ORANGE_PERCENT; 
        Armor.SaveAmount ORANGE_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_Orange"; 
        Inventory.AltHudIcon "ARM7A0";
        PBX_ArmorBase.ArmorToken 'PB_Infrared';
        Tag "$PBX_Armors_Orange_Tag"; 
    }

    States 
    { 
        Spawn:
            ARM7 A 1 Bright;
		    ARM7 A 2 bright; // A_SpawnItem("OrangeFlareMedium",0,10);
            Loop; 
    }

}

//////////////////////////// YELLOW ////////////////////////////////////////////////////////////////////////////////////
class PBX_YellowArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent YELLOW_PERCENT; 
        Armor.SaveAmount YELLOW_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_Yellow"; 
        Inventory.AltHudIcon "ARM5A0";
        Tag "$PBX_Armors_Yellow_Tag"; 
    }

    override bool TryPickup(in out Actor toucher)
    {
        bool pickup = Super.TryPickup(toucher);
        if (pickup)
        {
            toucher.A_GiveInventory("PB_RadSuit", 1);
            toucher.A_GiveInventory("PB_Haste", 1);
        }
        return pickup;
    }

    States 
    { 
        Spawn:
            ARM5 A 1 Bright;
		    ARM5 A 2 Bright A_SpawnItem("YellowFlareMedium",0,10);
            Loop; 
    }

}

//////////////////////////// BLACK ////////////////////////////////////////////////////////////////////////////////////
class PBX_BlackArmor : PBX_ArmorBase
{
    Default
    {
        Armor.SavePercent BLACK_PERCENT; 
        Armor.SaveAmount BLACK_AMOUNT; 
        Inventory.Pickupmessage "$PBX_Armors_Black";
        Inventory.AltHudIcon "ARM8A0";
        PBX_ArmorBase.ArmorToken 'PB_Backpack';
        Tag "$PBX_Armors_Black_Tag"; 
    }

    States 
    { 
        Spawn:
            ARM8 A 1 Bright;
		    ARM8 A 2 Bright;
            Loop; 
    }

}

//////////////////////////// DEMON ////////////////////////////////////////////////////////////////////////////////////
class PBX_DemonArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent DEMON_PERCENT; 
        Armor.SaveAmount DEMON_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_Demon"; 
        Inventory.AltHudIcon "ARM9A0";
        Tag "$PBX_Armors_Demon_Tag"; 
    }

    States 
    { 
        Spawn:
            ARM9 A 6 bright;
            ARM9 B 6 bright A_SpawnItem("RedFlareSmall",0,10);
            ARM9 C 6 bright;
            ARM9 B 6 bright A_SpawnItem("RedFlareSmall",0,10);
            Loop; 
    }

    override bool TryPickup(in out Actor toucher)
    {
        bool pickup = Super.TryPickup(toucher);
        if (pickup)
        {
            toucher.A_GiveInventory("DemonArmor_Frightener", 1);
            toucher.A_GiveInventory("PB_Berserk", 1);
            toucher.A_GiveInventory("PB_Doomsphere", 1);
        }
        return pickup;
    }
}

class DemonArmor_Frightener : PBX_FrightenerGiver {mixin PBX_Duration_Armors;}


//////////////////////////// CYAN ////////////////////////////////////////////////////////////////////////////////////
class PBX_CyanArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent CYAN_PERCENT; 
        Armor.SaveAmount CYAN_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_Cyan"; 
        Inventory.AltHudIcon "BRM1A0";
        Tag "$PBX_Armors_Cyan_Tag"; 
    }

    States 
    { 
        Spawn:
            BRM1 ABAA 2 BRIGHT; 
            Loop; 
    }

    int mDuration;
    override void BeginPlay()
	{
		super.BeginPlay();
		mDuration = PBX_CyanArmor_duration;
	}

    override string PickupMessage()
    {
		string msg = string.format(StringTable.Localize(Super.PickupMessage()), mDuration);
		return msg;
	}

    override bool TryPickup(in out Actor toucher)
    {
        bool pickup = Super.TryPickup(toucher);
        if (pickup)
        {
            toucher.A_GiveInventory("CyanArmor_TimeFreezer", 1);
            toucher.A_GiveInventory("CyanArmor_Haste", 1);   // Modified haste to have a shorter duration
        }
        return pickup;
    }
}

class CyanArmor_TimeFreezer : PBX_TimeFreezeGiver {mixin PBX_Duration_Armors;}
class CyanArmor_Haste : PB_HasteGiver {mixin PBX_Duration_Armors;}

//////////////////////////// DARK PURPLE ////////////////////////////////////////////////////////////////////////////////////
class PBX_DarkPurpleArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent DPURPLE_PERCENT; 
        Armor.SaveAmount DPURPLE_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_DarkPurple"; 
        Inventory.AltHudIcon "BRM4A0";
        PBX_ArmorBase.ArmorToken 'DPurpleArmor_InfAmmo';
        Tag "$PBX_Armors_DrkPurple_Tag"; 
    }

    States 
    { 
        Spawn:
            BRM4 A 1; 
            BRM4 B 1 BRIGHT; 
            Loop; 
    }
}

class DPurpleArmor_InfAmmo : PBX_InfiniteAmmoGiver {mixin PBX_Duration_Armors;}

// Unused
// class AmmoRefillerToken : Inventory
// {
//     Default 
//     { 
//         Inventory.MaxAmount 1; 
//     }

//     override void DoEffect()
//     {
//         Super.DoEffect();

//         // If there is no armor, destroy
//         if (!Owner || Owner.CountInv("BasicArmor") <= 0 || Owner.CountInv("PBX_DarkPurpleArmor") <= 0) 
//         { 
//             Destroy(); 
//             return; 
//         }

//         // Always refill ammo
//         for (Inventory item = Owner.Inv; item != null; item = item.Inv)
//         {
//             if (item is 'Ammo') item.Amount = item.MaxAmount;
//         }
//     }
// }

//////////////////////////// DARK RED ////////////////////////////////////////////////////////////////////////////////////
class PBX_DarkRedArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent DRED_PERCENT; 
        Armor.SaveAmount DRED_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_DarkRed"; 
        Inventory.AltHudIcon "BRM7A0";
        PBX_ArmorBase.ArmorToken 'ReactiveArmorBehavior';
        Tag "$PBX_Armors_DarkRed_Tag"; 
    }

    States 
    { 
        Spawn:
            BRM7 A 1 BRIGHT; 
            BRM7 B 1 BRIGHT; 
            Loop; 
    }

}

class ReactiveArmorBehavior : PBXArmorBehavior
{
    int cooldown;

    override void ArmorTick()
    {
        if (cooldown > 0) 
        { 
            cooldown--; 
            return; 
        }

        Inventory arm = Owner.FindInventory("BasicArmor"); if (!arm) return;

        BlockThingsIterator it = BlockThingsIterator.Create(Owner, Owner.Radius + 32);
        while (it.Next())
        {
            Actor t = it.thing;
            if (!t || t == Owner || !t.bSHOOTABLE || t.Health <= 0 || !(t is "PB_Monster"))
                continue;

            if (Owner.Distance3D(t) <= (Owner.Radius + t.Radius + 8))
            {
                Owner.A_Explode(200, 128, XF_NOTMISSILE, false, 128);
                Owner.A_StartSound("handgrenade/Explosion", CHAN_BODY, 0, 1.0, ATTN_NORM);
                Owner.A_Quake(4, 15, 0, 400, "");

                for (int i = 0; i < 25; i++)
                {
                    Owner.A_SpawnItemEx("Spark_BD1",
                        0, 0, 35,
                        frandom(-8, 8), frandom(-8, 8), frandom(2, 9),
                        0, SXF_NOCHECKPOSITION);
                }

                Owner.A_SetBlend("Orange", 0.6, 15);

                Vector3 pushDir = t.Vec3To(Owner).Unit() * -1;
                t.Vel += pushDir * 30;
                t.Vel.Z += 8;

                arm.Amount -= 10;
                cooldown = 20;
                break;
            }
        }
    }
}


//////////////////////////// GOLD ////////////////////////////////////////////////////////////////////////////////////
class PBX_GoldArmor : PBX_ArmorBase
{
    Default
    {
        Armor.SavePercent GOLD_PERCENT;
        Armor.SaveAmount GOLD_AMOUNT;
        Inventory.PickupMessage "$PBX_Armors_Gold";
        Inventory.AltHudIcon "BRM2A0";
        PBX_ArmorBase.ArmorToken 'MagneticBehavior';
        Tag "$PBX_Armors_Gold_Tag"; 
    }

    States 
    { 
        Spawn:
            BRM2 A 1 BRIGHT; 
            BRM2 A 1 BRIGHT; 
            Loop; 
    }
    
}

class MagneticBehavior : PBXArmorBehavior
{
    const PICKUP_RADIUS = 256.0;

    override void ArmorTick()
    {
        BlockThingsIterator it = BlockThingsIterator.Create(Owner, PICKUP_RADIUS);
        while (it.Next())
        {
            Actor obj = it.thing;
            if (!obj || obj == Owner || !obj.bSPECIAL) 
            {
                continue;
            }

            bool shouldPickup =
                ((obj is 'PB_HealthBonus') ||
                 (obj is 'PB_ArmorBonus')  ||
                 (obj is 'PB_Backpack')    ||
                 (obj is 'PB_WeaponBase')  ||
                 (obj is 'PB_UpgradeItem') ||
                 (obj is 'Ammo'))          &&
                !(obj is 'PB_ThrownAxe');

            if (shouldPickup && Owner.Distance3D(obj) <= PICKUP_RADIUS)
            {
                obj.Vel = obj.Vec3To(Owner).Unit() * 10;
                obj.bNoFriction = true;
            }
        }
    }
}

//////////////////////////// GRAY ////////////////////////////////////////////////////////////////////////////////////
class PBX_GrayArmor : PBX_ArmorBase
{
    Default
    {
        Inventory.AltHudIcon "DUMYA0";
        Tag "$PBX_Armors_Gray_Tag"; 
    }

    States 
    { 
        Spawn:
            DUMY A 1 BRIGHT; 
            DUMY A 1 BRIGHT; 
            Loop; 
    }

    override bool TryPickup (in out Actor toucher)
    {
        int rPercent        = Random(0,2);
        int rAmount         = Random(1, GRAY_AMOUNT); 

        switch(rPercent)
        {
            case 0: rPercent = 33;
            case 1: rPercent = 50;
            case 2: rPercent = 70;
        }
        
        self.SavePercent    = rPercent;
        self.SaveAmount     = rAmount; 
        if(toucher && toucher.player)
        {
            toucher.A_StartSound("ARMOR",CHAN_AUTO,CHANF_OVERLAP);
        }
        
        bool pickedUp = Super.TryPickup(toucher);

        // Just so it doesnt spam you with the log messages
        if(pickedUp)
        {
            toucher.A_Log(String.Format(StringTable.Localize("$PBX_Armors_Gray"),rAmount, rPercent));
        }
        
        return Super.TryPickup(toucher);
    }
}


//////////////////////////// LIGHT BLUE ////////////////////////////////////////////////////////////////////////////////////
class PBX_LightBlueArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent LBLUE_PERCENT; 
        Armor.SaveAmount LBLUE_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_LightBlue"; 
        Inventory.AltHudIcon "BRM3A0";
        PBX_ArmorBase.ArmorToken 'AquaticBehavior';
        Tag "$PBX_Armors_LightBlue"; 
    }

    States 
    { 
        Spawn:
            BRM3 A 1 BRIGHT; 
            BRM3 A 1 BRIGHT; 
            Loop; 
    }

}

class AquaticBehavior : PBXArmorBehavior
{
    override void ArmorTick()
    {
        let pp = PlayerPawn(Owner);
        if (!pp) 
        { 
            Destroy(); 
            return; 
        }

        if (Owner.WaterLevel == 3)
        {
            pp.ResetAirSupply();
        }

        if (Owner.WaterLevel >= 1 && Owner.Speed != 0)
        {
            Owner.Speed = Owner.Default.Speed * 2.5;
        }
        else
        {
            Owner.Speed = Owner.Default.Speed;
        }
    }

    // Covers armor running out AND the token being cleared on a new armor pickup
    override void OnDestroy()
    {
        if (Owner) Owner.Speed = Owner.Default.Speed;
        Super.OnDestroy();
    }
}

//////////////////////////// LIGHT GREEN ////////////////////////////////////////////////////////////////////////////////////
class PBX_LightGreenArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent LGREEN_PERCENT; 
        Armor.SaveAmount LGREEN_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_LightGreen"; 
        Inventory.AltHudIcon "BRM6A0";
        PBX_ArmorBase.ArmorToken 'SecondChanceToken';
        Tag "$PBX_Armors_LGreen_Tag"; 
    }

    States 
    { 
        Spawn:
            BRM6 A 1 BRIGHT; 
            BRM6 A 1 BRIGHT; 
            Loop; 
    }

}

class SecondChanceToken : Inventory 
{

    Default 
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        +INVENTORY.IGNORESKILL;
        +INVENTORY.UNTOSSABLE;
        +INVENTORY.UNDROPPABLE;
        +INVENTORY.QUIET;
    }

    States 
    {
        RestoreHealth:
            TNT1 A 1;
            // We delay this by a tic after activating the powerup because if we try
            // to zero out the damage, the player doesn't get knocked around by it
            // like they should, and if we try to restore their health before they
            // take damage, big hits like standing in a room of exploding barrels can
            // still drop them down below the intended restore target.
            TNT1 A 0 RestorePlayerHealth();
            // Fallthrough
        Idle:
            TNT1 A 1 A_SetInventory("SecondChanceToken",0);
            STOP;
    }

    override void AbsorbDamage(int damage, Name damageType, out int newdamage, Actor inflictor, Actor source, int flags) 
    {
        Inventory arm = Owner.FindInventory("BasicArmor");
        if (!Owner || !arm || arm.amount <= 0) 
        { 
            if (arm) arm.Destroy(); 
            Destroy(); 
            return; 
        }

        if (IsUndying(owner.player)) 
            return;

        if (damage >= owner.health) 
        {
            newdamage = owner.health - 1;
            ActivateIndestructability();
        }
    }

    void Message(string msg) 
    {
        owner.A_Log(msg, true);
    }

    bool IsUndying(PlayerInfo player) 
    {
        return player.cheats & (CF_BUDDHA | CF_BUDDHA2 | CF_GODMODE | CF_GODMODE2);
    }

    void ActivateIndestructability() 
    {
        Message("$PBX_Armors_LGreenActive");

        owner.GiveInventory("LGreenArmor_Invul",1);

        // Do this after AdjustLives or it will set us to DisplayLivesCount and
        // override the health restoration.
        self.SetStateLabel("RestoreHealth");
    }

    void RestorePlayerHealth() 
    {
        owner.GiveInventory("Health",GUARDIAN_HP);
        owner.GiveInventory("GuardianEffectArmor", 1);
    }
}

class GuardianEffectArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent GUARDIAN_PERCENT; 
        Armor.SaveAmount GUARDIAN_AMOUNT; 
    }
}

class LGreenArmor_Invul : PB_InvulGiver
{
    mixin PBX_Duration_Armors;
    Default
    {
        +INVENTORY.NOSCREENBLINK;
        Powerup.Color "GreenMap", 0.075;
    }
}

//////////////////////////// PINK ////////////////////////////////////////////////////////////////////////////////////
class PBX_PinkArmor : PBX_ArmorBase
{
    Default 
    { 
        Armor.SavePercent PINK_PERCENT; 
        Armor.SaveAmount PINK_AMOUNT; 
        Inventory.PickupMessage "$PBX_Armors_Pink"; 
        Inventory.AltHudIcon "BRM5A0";
        PBX_ArmorBase.ArmorToken 'RepulsorToken';
        Tag "$PBX_Armors_Pink"; 
    }

    States 
    { 
        Spawn:
            BRM5 A 1 BRIGHT; 
            BRM5 A 1 BRIGHT; 
            Loop; 
    }

}

class EnemyStunBehavior : Behavior
{
    int mTimer;

    override void Initialize()
    {
        mTimer = PBX_PinkDebuff_duration * TICRATE;
    }

    override void Tick()
    {
        if (!Owner || Owner.Health <= 0 || mTimer <= 0)
        {
            Destroy();
            return;
        }

        let pain = Owner.FindState("Pain");
        if (pain && mTimer % STUN_FREQ == 0)
        {
            Owner.SetState(pain);
        }

        Owner.Vel.X *= 0.8;
        Owner.Vel.Y *= 0.8;

        mTimer--;
    }
}

class RepulsorToken : Inventory
{
    Default 
    { 
        Inventory.MaxAmount 1; 
    }

    override void DoEffect() 
    { 
        Super.DoEffect(); 
        if (!Owner || Owner.CountInv("BasicArmor") <= 0) 
        {
            Destroy(); 
        }
    }

    override void ModifyDamage(int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags)
    {
        if (passive && source && source != Owner)
        {
            if (damageType == 'Melee' || Owner.Distance3D(source) <= 100)
            {
                Vector3 pDir = Owner.Vec3To(source).Unit();
                source.Vel += pDir * 25; 
                source.Vel.Z += 5;
                if (!source.FindBehavior("EnemyStunBehavior"))
                {
                    source.AddBehavior("EnemyStunBehavior");
                }
                newdamage = 0;
            }
        }
        Super.ModifyDamage(damage, damageType, newdamage, passive, inflictor, source, flags);
    }
}

