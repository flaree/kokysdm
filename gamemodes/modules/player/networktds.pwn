new PlayerText:PlayerFPSTD[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};
new PlayerText:PlayerPingTD[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

ShowNetworkTDs(playerid)
{
	PlayerTextDrawShow(playerid, PlayerFPSTD[playerid]);
	PlayerTextDrawShow(playerid, PlayerPingTD[playerid]);
	return true;
}
CreateNetworkTDs(playerid)
{
	PlayerFPSTD[playerid] = CreatePlayerTextDraw(playerid, 547.000000, 25.000000, "FPS:~W~ 0");
	PlayerTextDrawBackgroundColor(playerid, PlayerFPSTD[playerid], 255);
	PlayerTextDrawFont(playerid, PlayerFPSTD[playerid], 2);
	PlayerTextDrawLetterSize(playerid, PlayerFPSTD[playerid], 0.200000, 1.000000);
	PlayerTextDrawColor(playerid, PlayerFPSTD[playerid], -1397969665);
	PlayerTextDrawSetOutline(playerid, PlayerFPSTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerFPSTD[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerFPSTD[playerid], 0);

	PlayerPingTD[playerid] = CreatePlayerTextDraw(playerid, 547.000000, 34.000000, "PING:~W~ 0");
	PlayerTextDrawBackgroundColor(playerid, PlayerPingTD[playerid], 255);
	PlayerTextDrawFont(playerid, PlayerPingTD[playerid], 2);
	PlayerTextDrawLetterSize(playerid, PlayerPingTD[playerid], 0.200000, 1.000000);
	PlayerTextDrawColor(playerid, PlayerPingTD[playerid], -1397969665);
	PlayerTextDrawSetOutline(playerid, PlayerPingTD[playerid], 1);
	PlayerTextDrawSetProportional(playerid, PlayerPingTD[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, PlayerPingTD[playerid], 0);
	return true;
}
UpdateNetworkdTDs(playerid)
{
    PlayerTextDrawSetString(playerid, PlayerFPSTD[playerid], sprintf("FPS:~W~ %i", pFPS[playerid]));
    PlayerTextDrawSetString(playerid, PlayerPingTD[playerid], sprintf("PING:~W~ %i", GetPlayerPing(playerid)));
    return true;
}