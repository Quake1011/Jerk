Handle hClientCooldown[MAXPLAYERS+1], hAnnouncer[MAXPLAYERS+1];
bool bCooldown[MAXPLAYERS+1];
int iClientCounter[MAXPLAYERS+1], COOLDOWN; 
float SPEED, TIME;
ConVar cvars[3];

public Plugin myinfo = 
{ 
	name = "Pull", 
	author = "Palonez", 
	description = "Pull", 
	version = "1.0.0.0", 
	url = "https://github.com/Quake1011" 
};

public void OnPluginStart()
{
	HookConVarChange((cvars[0] = CreateConVar("pull_time", "0.2", "Activity time of pull")), OnCVChange);
	TIME = cvars[0].FloatValue;
	
	HookConVarChange((cvars[1] = CreateConVar("pull_speed", "5.0", "Power of pull")), OnCVChange);
	SPEED = cvars[1].FloatValue;
	
	HookConVarChange((cvars[2] = CreateConVar("pull_cooldown", "5", "Cooldown before next using")), OnCVChange);
	COOLDOWN = cvars[2].IntValue;
	
	AutoExecConfig(true, "pull");
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
			CreateTimer(TIME, pull, iClient);				
		}
	}

	return Plugin_Continue;
}

public Action pull(Handle hTimer, int iClient)
{
	SetEntPropFloat(iClient, Prop_Send, "m_flLaggedMovementValue", 1.0);
	PrintToChat(iClient, "Рывок будет доступен через %i секунд", iClientCounter[iClient]);
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
		PrintToChat(iClient, "Рывок снова доступен");
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