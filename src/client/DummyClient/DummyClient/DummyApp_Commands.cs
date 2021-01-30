using CommonLib.Messaging.Client;
using CommonLib.Util;
using System;
using System.Collections.Generic;
using System.Text;

namespace DummyClient
{
    partial class DummyApp
    {
        protected virtual void ProcessCommand(string[] command)
        {
            switch (command[0])
            {
                case "map":
                    ProcessMapCommand(command);
                    break;
                default:
                    CLog.W("Unkown command: {0}", command[0]);
                    break;
            }
        }

        private void ProcessMapCommand(string[] command)
        {
            if (command.Length < 2)
            {
                CLog.W("Invalid map command usage: map <join>");
                return;
            }

            var cmd = command[1];
            switch (cmd)
            {
                case "join":
                    ProcessMapJoinCommand(command);
                    break;
                default:
                    CLog.W("Invalid map command usage: map <join>");
                    break;
            }
        }

        private void ProcessMapJoinCommand(string[] command)
        {
            if (command.Length < 5)
            {
                CLog.W("Invalid map command usage: map join x y channel");
                return;
            }

            var x = int.Parse(command[2]);
            var y = int.Parse(command[3]);
            var c = int.Parse(command[4]);

            _mapServerConnection.Send(new CM_REQ_JOIN_MAP()
            {
                x = x,
                y = y,
                channel = c,
            });

            CLog.I("Map join request sent!");
        }
    }
}
