using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CommonLib.Messaging.Common
{
    public enum MessageType : ushort
    {
        // MSG TYPE CODES:
        // - NFY => Notify - Means a notifications only, without requiring response.
        // - REQ => Request - Means a request to do, which will provide a corresponding response.
        // - RES => Response - Means a response from a previous request.

        // SERVER CODES:
        // C => CLIENT
        // D => DB
        // M => MAP
        // P => PROCEDURAL

        // Message Pattern: <F><T>_<TYPE>_NAME_IN_CAPITAL. WHERE:
        // F: Who set the message
        // T: Who handles the message
        // TYPE: Either NFY, REQ or RES

        // Example: CM_NFY_WELCOME
        // Client(C) sent message to Map (map) Notifying (NFY) a WELCOME

        // Client <-> MapServer - Should have CM prefix.
        // PS: For some reason, ProtoBuf won't serialize enum with value = 0, so set first value as 1.
        CM_REQ_JOIN_MAP = 1,
        MC_RES_JOIN_MAP,



#if _SERVER  // From here on there are only server messages, so let's remove'em from client.

        // Procedural Server <-> DB Server messages
        PD_NFY_UPSERT_MAP,
        PD_REQ_SURROUNDING_CONNECTIONS,
        DP_RES_SURROUNDING_CONNECTIONS,

        // Map Server <-> DB Server
        MD_REQ_MAP_INFO,
        DM_RES_MAP_INFO,

        MP_REQ_MAP_GEN,
        PM_RES_MAP_GEN,
#endif

        // Meta - Don't use
        MAX = 0xFFFF,
    }

    public enum MessageError
    {
        NONE,
        FAIL,

        SERVER_OFF,

        PLAYER_INVALID,

        INVALID_NAME,
        ALREADY_IN_USE_NAME,

        ROOM_INVALID,
        CREATE_FAIL,
        JOIN_FAIL,
        JOIN_WRONG_PASSWORD,
        NOT_FOUND,
        FULL,
        NOT_ENOUGH,
        NOT_OWNER,
        KICK_YOURSELF,
        TRANSFER_YOURSELF,
        SLOT_CLOSED,
        SLOT_INVALID,

        NOT_READY,
        ALREADY_PLAYING,
        ALREADY_READY,
        ALREADY_CONNECTED,
        AUTH_FAIL,

        INVALID_STATE,

        REGISTER_FAIL,
        REGISTER_LOGIN_IN_USE,
        REGISTER_EMAIL_IN_USE,

        CANT_SELF,
        INVALID_REQUESTER_ID,
        INVALID_REQUESTED_ID,
        ALREADY_EXISTS_REQUESTER,
        ALREADY_EXISTS_REQUESTED,
        ALREADY_FRIENDS,

        MAX = 0xFFFF
    }

    public enum ChatType
    {
        GENERAL = 0,
        SYSTEM,
        NORMAL,
        WHISPER,

        MAX = 0xFFFF
    }

    public enum PlayerGender
    {
        None,
        Male,
        Female
    }

    public enum PlayerStage
    {
        Creating,
        Lobby,
        Room,
        Playing,
    }

    public enum PlayerState
    {
        NotReady,
        Ready,
        Offline,
    }

    public enum RoomStage
    {
        Waiting,
        Full,
        Playing,
    }

    public enum FriendState
    {
        Online,
        Offline,
        WaitingApproval,
        Requested,
    }
}
