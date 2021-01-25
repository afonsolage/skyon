using MapServer.Server;

class MainApp
{
    static int Main(string[] args)
    {
        var instanceId = uint.Parse(args[0]);

        AppServer server = new AppServer(instanceId);

        server.Init();
        server.Start();

        return 0;
    }
}
