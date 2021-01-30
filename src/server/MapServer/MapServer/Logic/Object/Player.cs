using MapServer.Server;
using System;
using System.Collections.Generic;
using System.Text;

namespace MapServer.Logic.Object
{
    class Player
    {

        public ClientSession Session { get; private set; }

        public Player(ClientSession session)
        {
            Session = session;
        }


    }
}
