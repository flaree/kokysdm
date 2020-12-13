#define DQCMD:%1(%2) forward discord_%1(%2); public discord_%1(%2)

forward DCC_OnChannelMessage(DCC_Channel:channel, DCC_User: author, const message[]);
public DCC_OnChannelMessage(DCC_Channel:channel, DCC_User: author, const message[])
{
	if (message[0] == '!' )
    {
        new functiona[32], posi = 0;
        while(message[++posi] > ' ' ) {
            functiona[posi - 1] = tolower(message[posi]);
        }

        format(functiona, sizeof(functiona), "discord_%s", functiona);

        while(message[posi] == ' ') {
            posi++;
        }

        if(!message[posi]) {
            CallLocalFunction( functiona, "dds", _: channel, _: author, "\1" );
        } else {
            CallLocalFunction( functiona, "dds", _: channel, _: author, message[posi]);
        }
    }

	/*#if defined DCM_DCC_OnChannelMessage
		return DCM_DCC_OnChannelMessage(DCC_Channel:channel, DCC_User: author, message);
	#else
		return 1;
	#endif*/
}
#if defined _ALS_DCC_OnChannelMessage
	#undef DCC_OnChannelMessage
#else
	#define _ALS_DCC_OnChannelMessage
#endif

#define DCC_OnChannelMessage DCM_DCC_OnChannelMessage
#if defined DCM_DCC_OnChannelMessage
	forward DCM_DCC_OnChannelMessage(DCC_Channel:channel, DCC_User: author, const message[]);
#endif