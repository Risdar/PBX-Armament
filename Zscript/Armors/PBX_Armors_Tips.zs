enum PBX_Armors_TipFlags
{
    PBX_Armors_DemonArmorTip      = 1 < 0
    ,PBX_Armors_DarkRedArmorTip   = 1 < 1
    ,PBX_Armors_GrayArmorTip      = 1 < 2
    ,PBX_Armors_LBlueArmorTip     = 1 < 3
    ,PBX_Armors_LGreenArmorTip    = 1 < 4
    ,PBX_Armors_PinkArmorTip      = 1 < 5
}

const PBX_ARMOR_HELP_FLAG = "PBX_TIP_FLAGS_ARMORS";

class PBX_Armors_TipsManager : Inventory
{
	override bool HandlePickup(Inventory item)
	{
        bool returnValue = super.HandlePickup(item);
        if(!PBX_SEND_TIP) return returnValue;

        switch(item.getClassName())
        {
            default:
                break;

            case 'PBX_DemonArmor':
            {
                Array<String> tips;
                tips.Push("$PBX_Armors_Demon_Tip1");
                PBX_Handler.SendTipArrayIfNeeded(tips, PBX_ARMOR_HELP_FLAG, PBX_Armors_DemonArmorTip);
            }
            break;

            case 'PBX_DarkRedArmor':
            {
                Array<String> tips;
                tips.Push("$PBX_Armors_DarkRed_Tip1");
                PBX_Handler.SendTipArrayIfNeeded(tips, PBX_ARMOR_HELP_FLAG, PBX_Armors_DarkRedArmorTip);
            }
            break;

            case 'PBX_GrayArmor':
            {
                Array<String> tips;
                tips.Push("$PBX_Armors_Gray_Tip1");
                PBX_Handler.SendTipArrayIfNeeded(tips, PBX_ARMOR_HELP_FLAG, PBX_Armors_GrayArmorTip);
            }
            break;

            case 'PBX_LightBlueArmor':
            {
                Array<String> tips;
                tips.Push("$PBX_Armors_LBlue_Tip1");
                PBX_Handler.SendTipArrayIfNeeded(tips, PBX_ARMOR_HELP_FLAG, PBX_Armors_LBlueArmorTip);
            }
            break;

            case 'PBX_LightGreenArmor':
            {
                Array<String> tips;
                tips.Push("$PBX_Armors_LGreen_Tip1");
                tips.Push(String.Format(StringTable.Localize("$PBX_Armors_LGreen_Tip2"),PBX_LGreenArmor_duration, GUARDIAN_HP, GUARDIAN_AMOUNT, GUARDIAN_PERCENT));
                PBX_Handler.SendTipArrayIfNeeded(tips, PBX_ARMOR_HELP_FLAG, PBX_Armors_LGreenArmorTip);
            }
            break;

            case 'PBX_PinkArmor':
            {
                Array<String> tips;
                tips.Push("$PBX_Armors_Pink_Tip1");
                PBX_Handler.SendTipArrayIfNeeded(tips, PBX_ARMOR_HELP_FLAG, PBX_Armors_PinkArmorTip);
            }
            break;

        }

		return returnValue;
	}
}
