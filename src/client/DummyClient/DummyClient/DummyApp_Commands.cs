using CommonLib.Logic.Map;
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
                CLog.W("Invalid map command usage: map <join|view>");
                return;
            }

            var cmd = command[1];
            switch (cmd)
            {
                case "join":
                    ProcessMapJoinCommand(command);
                    break;
                case "view":
                    ProcessMapViewCommand(command);
                    break;
                default:
                    CLog.W("Invalid map command usage: map <join>");
                    break;
            }
        }

        private void ProcessMapViewCommand(string[] command)
        {
            if (command.Length < 3 || (command[2] != "on" && command[3] != "off"))
            {
                CLog.W("Invalid map command usage: map view <on|off>");
                return;
            }

            ViewMap = command[2] == "on";

            CLog.I("Map viewing {0}", ViewMap ? "enabled" : "disabled");
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
