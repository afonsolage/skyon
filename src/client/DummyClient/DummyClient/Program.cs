using DummyClient;

public class Program
{
    public static void Main(string[] args)
    {
        var dummyApp = new DummyApp();
        dummyApp.Init();
        dummyApp.Start();
    }
}