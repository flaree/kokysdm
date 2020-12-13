LatestDonatorText()
{
	new str[128];
	format(str, sizeof(str), "{EE5133}Latest Donator: {33C4EE}N/A {EE5133}purchased {33C4EE}N/A {EE5133}!");
	latestdonatorlabel = Create3DTextLabel(str, -1, DONATOR_NPC_POS, 30.0, 0, 0);
}
UpdateLatestDonator(playerid)
{
	new str[128];
	format(str, sizeof(str), "{EE5133}Latest Donator: {33C4EE}%s!\n{EE5133}Donated: {33C4EE}%.2f Euro!", GetName(playerid), Account[playerid][DonationAmount]);
	Update3DTextLabelText(latestdonatorlabel, -1, str);
	DestroyActor(latestdonator_actor);
	latestdonator_actor = CreateActor(Account[playerid][Skin], DONATOR_NPC_POS, 180.0);
 	ApplyActorAnimation(latestdonator_actor, "GHANDS", "gsign3", 4.1, 1, 1, 1, 0, 0);
	SetActorVirtualWorld(latestdonator_actor, 0);
	SetActorInvulnerable(latestdonator_actor, false);
	SetActorHealth(latestdonator_actor, 1000);
	ApplyActorAnimation(latestdonator_actor, "GHANDS", "gsign3", 4.1, 1, 1, 1, 0, 0);
	return 1;	
}