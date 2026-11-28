// Repair Kit
// From Project Brutality: Shoo Krew Edition
// Originally from Dusted Pandemonia (Full Credits: https://docs.google.com/document/d/1XGstl84qQO385xiLGv6AX4Tuj6qheQ1BdIz_3Sl4Gyo/edit?usp=sharing)

class PBX_RepairKit : PB_Inventory
{
    Default
    {
		Inventory.AltHudIcon "RPKTA0";
        Inventory.PickupMessage "$REPAIRKIT_PICKUP";
        Inventory.PickupSound "RepairKit/Pickup";
        +FLOORCLIP;
        Tag "$REPAIRKIT_PICKUP";
    }

    override void Touch(Actor toucher)
	{
        if(PBX_SEND_TIP)
        {

            Array<String> tips;
            tips.Push("$PBX_Repairkit_Tip1");
            tips.Push("$PBX_Repairkit_Tip2");
            PBX_Handler.SendTipArrayIfNeeded(tips,ITEMS_HELPTEXT,PBX_Armory_Tip_RepairKit);
        }
        CheckWeapon(toucher);
	}

	private
    void CheckWeapon(Actor toucher)
    {
        let player = toucher.player;
        let playerwep = player.ReadyWeapon;
        if (!playerwep || !playerwep.AmmoType1)
        {
            toucher.A_Print("$REPAIRKIT_NOEFFECT");
            return;
        }

		toucher.A_SetBlend("blue",0.75,16);
        Inventory.PrintPickupMessage(true,pickupMsg);
        toucher.A_StartSound("RepairKit/Pickup", CHAN_ITEM);
        toucher.A_StartSound("RepairKit/Use", CHAN_ITEM);

        // Repair the demonic weapons
        toucher.GiveInventory(PBX_CyberdemonRL.DURABILITY_NAME,PBX_CyberdemonRL.DURABILITY);
        toucher.GiveInventory(PBX_MastermindChaingun.DURABILITY_NAME,PBX_MastermindChaingun.DURABILITY);

	    let wammo = playerwep.AmmoType1.GetClassName();

        FLineTraceData t;
        FTranslatedLineTarget lineTarget;
        bool hit = toucher.LineTrace(toucher.angle,40,toucher.pitch,TRF_NOSKY,32,data:t);
        int offsetpls = 40;
        if(hit) offsetpls = 12;

        switch(wammo)
        {
            case 'PB_DTech':
                RepairKit_SpawnAmmo("PB_DTechLarge","PB_DTech",1,3,offsetpls); break;
            case 'PB_Fuel':
                RepairKit_SpawnAmmo("PB_Fuel","PB_Fuel",1,3,offsetpls); break;
            case 'PB_LowCalMag':
                RepairKit_SpawnAmmo("PB_LowCalMagBox","PB_LowCalMag",1,3,offsetpls); break;	
            case 'PB_HighCalMag':
                RepairKit_SpawnAmmo("PB_HighCalMagBox","PB_HighCalMag",1,3,offsetpls); break;
            case 'PB_Shell':
                RepairKit_SpawnAmmo("PB_ShellBox","PB_Shell",1,2,offsetpls); break;
            case 'PB_RocketAmmo':
                RepairKit_SpawnAmmo("PB_RocketBox","PB_RocketAmmo",1,6,offsetpls); break;
            case 'PB_Cell':
                RepairKit_SpawnAmmo("PB_CellPack","PB_Cell",1,2,offsetpls); break;
            // case 'LesserDemonicEssence':
            //     RepairKit_SpawnAmmo("Nothing","LesserDemonicEssence",0,5,offsetpls); break;
            default: 
                break;
        }
        // goawayanddie();
		bNoInteraction = true;
        SetStateLabel("FinishedGivingAmmo");
	    return;
    }

	private
    void RepairKit_SpawnAmmo(string at1, string at2, int a1, int a2, int xoff)
	{
        // self.A_SpawnItemEx("TeleportationFog",xoff);
        for(int i = a1; i > 0 ; i--)
            self.A_SpawnItemEx(at1,xoff,0,32,frandom(0,2),frandom(-2,2),frandom(3,8),frandom(-30,30));
        for(int i = a2; i > 0 ; i--)
            self.A_SpawnItemEx(at2,xoff,0,32,frandom(-2,2),frandom(-2,2),frandom(3,8),frandom(-30,30));
	}

    States
    {
        Spawn:
            RPKT ABCDEF 4;
            Loop;
        Pickup:
        FinishedGivingAmmo:
            "####" "#" 1 A_FadeOut(0.1); 
            wait;
    }
}