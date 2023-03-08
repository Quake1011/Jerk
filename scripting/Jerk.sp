Handle hClientCooldown[MAXPLAYERS+1], hAnnouncer[MAXPLAYERS+1];
bool bCooldown[MAXPLAYERS+1];
int iClientCounter[MAXPLAYERS+1], COOLDOWN; 
float SPEED, TIME;
ConVar cvars[3];

public Plugin myinfo = 
{ 
	name = "Jerk", 
	author = "Palonez", 
	description = "Jerk", 
	version = "1.0.1.0", 
	url = "https://github.com/Quake1011" 
};

public void OnPluginStart()
{
	HookConVarChange((cvars[0] = CreateConVar("Jerk_time", "0.2", "Activity time of Jerk")), OnCVChange);
	TIME = cvars[0].FloatValue;
	
	HookConVarChange((cvars[1] = CreateConVar("Jerk_speed", "5.0", "Power of Jerk")), OnCVChange);
	SPEED = cvars[1].FloatValue;
	
	HookConVarChange((cvars[2] = CreateConVar("Jerk_cooldown", "5", "Cooldown before next using")), OnCVChange);
	COOLDOWN = cvars[2].IntValue;
	
	LoadTranslations("Jerk.phrases");
	AutoExecConfig(true, "Jerk");
}

public void OnCVChange(ConVar convar, const char[] sOldValue, const char[] sNewValue)
{
	if(convar != INVALID_HANDLE)
	{
		if(convar == cvars[0]) TIME = convar.FloatValue;
		else if(convar == cvars[1]) SPEED = convar.FloatValue;
		else if(convar == cvars[2]) COOLDOWN = convar.IntValue;
	}
}

public Action OnPlayerRunCmd(int iClient, int& iButtons, int& iImpulse, float fVel[3], float fAngles[3], int& iWeapon, int& iSubtype, int& iCmdnum, int& iTickcount, int& iSeed, int iMouse[2])
{
	if(iButtons & IN_USE && (iButtons & IN_FORWARD || iButtons & IN_BACK || iButtons & IN_MOVELEFT || iButtons & IN_MOVERIGHT))
	{
		if(bCooldown[iClient]) return Plugin_Continue;
		else
		{
			SetEntPropFloat(iClient, Prop_Send, "m_flLaggedMovementValue", SPEED);
			bCooldown[iClient] = true;
			iClientCounter[iClient] = COOLDOWN;
			hClientCooldown[iClient] = CreateTimer(1.0, ResetCooldown, iClient, TIMER_REPEAT);
			CreateTimer(TIME, Jerk, iClient);				
		}
	}

	return Plugin_Continue;
}

public Action Jerk(Handle hTimer, int iClient)
{
	SetEntPropFloat(iClient, Prop_Send, "m_flLaggedMovementValue", 1.0);
	PrintToChat(iClient, "%t", "CoolDownAnnounce", iClientCounter[iClient]);
	return Plugin_Continue;
}

public Action ResetCooldown(Handle hTimer, int iClient)
{
	iClientCounter[iClient]--;
	if(iClientCounter[iClient] == 0)
	{
		bCooldown[iClient] = false;
		if(hClientCooldown[iClient])
		{
			KillTimer(hClientCooldown[iClient]);
			hClientCooldown[iClient] = null;
		}
		PrintToChat(iClient, "%t", "JerkAvailable");
	}
	
	return Plugin_Continue;
}

public void OnMapEnd()
{
	for(int i = 0; i < sizeof(hAnnouncer[]); i++)
	{
		if(hAnnouncer[i])
		{
			KillTimer(hAnnouncer[i]);
			hAnnouncer[i] = null;
		}

		if(hClientCooldown[i])
		{
			KillTimer(hClientCooldown[i]);
			hClientCooldown[i] = null;
		}	
	}
}