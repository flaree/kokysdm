static CSlideTick[MAX_PLAYERS];

forward OnSlidePlayerConnect(playerid);
public OnSlidePlayerConnect(playerid)
{
	CSlideTick[playerid] = 0;
	return false;
}
forward OnPlayerCSlide(playerid);
public OnPlayerCSlide(playerid)
{
	if(ActivityState[playerid] != ACTIVITY_LOBBY && GetPlayerAnimationIndex(playerid) == 1161 && GetWalkingSpeed(playerid) > 8)
	{
		if(CSlideTick[playerid] == 0) CSlideTick[playerid] = gettime() + 1;
		else if(CSlideTick[playerid] < gettime())
		{
			CSlideTick[playerid] = gettime() + 1;
			GameTextForPlayer(playerid, "~R~Do not cslide!", 1000, 6);
			FreezePlayer(playerid, 500);
		}
	}
	else CSlideTick[playerid] = 0;
	return false;
}
GetWalkingSpeed(playerid)
{
	new Float:Px, Float:Py, Float:Pz, Float:Speed;
	GetPlayerVelocity(playerid, Px, Py, Pz);
	Speed = floatsqroot(floatpower(floatabs(Px), 2) + floatpower(floatabs(Py), 2) + floatpower(floatabs(Pz), 2));
	return floatround(Speed * 100);
}