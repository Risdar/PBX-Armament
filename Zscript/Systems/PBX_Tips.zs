extend class PBX_Handler
{
    static clearscope void SendTipArrayIfNeeded(Array<String> tipStrings, string cvarName, int tipFlag)
	{
        CVAR shouldSend = CVar.GetCVar("PBX_SEND_TIP");
        if(!shouldSend) return;
        bool send = shouldSend.GetBool();
        if(!send) return;

        CVar name = CVar.GetCvar(cvarName);
        if(!name) return;

		if(!PB_HelpNotificationsHandler.CheckTipEvent(tipFlag, name))
		{
			PB_HelpNotificationsHandler.PB_SendTipArray(tipStrings, cvarName, tipFlag);
		}
	}
}