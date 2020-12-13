#define NOTE_ADMIN_LEVEL 1

CMD<AD1>:notes(cmdid, playerid, params[])
{
    new target;
    if(sscanf(params, "u", target)) return SendUsageMessage(playerid, "/notes [playerid or name]");

    if(GetPlayerAdminLevel(playerid) < NOTE_ADMIN_LEVEL) return SendErrorMessage(playerid, "Unauthorised.");

    ShowPlayerAdminNotes(playerid, target);
    return 1;
}

stock ShowPlayerAdminNotes(playerid, target) {
    if(GetPlayerAdminLevel(playerid) < NOTE_ADMIN_LEVEL) return 0;

    yield 1;
    await mysql_aquery_s(SQL_CONNECTION, str_format("SELECT an.id, an.created_at, an.issuer_id, an.description, a.username FROM `admin_notes` an LEFT JOIN accounts a ON a.id = an.issuer_id WHERE an.account_id = %d ORDER BY an.created_at DESC;", Account[target][SQLID]));

    new noteId, noteCreated, noteIssuer, noteDescription[128], noteUsername[MAX_PLAYER_NAME];

    for(new i = 0, r = cache_num_rows(); i < r; i++)
    {
        cache_get_value_name_int(i, "id", noteId);
        cache_get_value_name_int(i, "created_at", noteCreated);
        cache_get_value_name_int(i, "issuer_id", noteIssuer);
        cache_get_value_name(i, "description", noteDescription);
        cache_get_value_name(i, "username", noteUsername);
    }
    return 1;
}