#include <sourcemod>
#include <sdktools>
#include <files>

public Plugin myplugin = 
{
    name = "Net Channel Limit Checker",
    author = "Alley",
    description = "Kicks players exceeding net_chan_limit_msec.",
    version = "1.0",
    url = "https://hlmod.net/members/alley.164202/"
};

const int MAX_PLAYERS = 64;
const float NET_CHAN_LIMIT = 50.0;

public void OnPluginStart()
{
    CreateTimer(10.0, CheckNetChanLimit);
}

public Action CheckNetChanLimit(Handle timer)
{
    char value[32];
    GetConVarString(FindConVar("net_chan_limit_msec"), value, sizeof(value));

    if (StringToFloat(value) != NET_CHAN_LIMIT)
    {
        PrintToServer("net_chan_limit_msec is not set to 50. Setting it now.");
        ServerCommand("net_chan_limit_msec 50");
    }

    for (int i = 1; i <= MAX_PLAYERS; i++)
    {
        if (IsClientInGame(i) && IsClientConnected(i))
        {
            float playerNetChanLimit = GetClientNetChanLimit(i);

            if (playerNetChanLimit > NET_CHAN_LIMIT)
            {
                LogToFile("kick_log.txt", "Player %N kicked for exceeding net_chan_limit_msec: %f", i, playerNetChanLimit);
                PrintToServer("Player %N has been kicked for exceeding net_chan_limit_msec (%f)", i, playerNetChanLimit);
                KickClient(i, "You have been kicked for exceeding net_chan_limit_msec (limit: 50)");
            }
        }
    }

    return Plugin_Continue;
}

float GetClientNetChanLimit(int client)
{
    if (client <= 0 || client > MAX_PLAYERS) return 0.0;
    return GetConVarFloat(FindConVar("net_chan_limit_msec"));
}
