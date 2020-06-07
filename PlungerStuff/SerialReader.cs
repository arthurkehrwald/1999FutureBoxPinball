using Godot;
using System;
using System.IO.Ports;
using System.Threading;
using System.Threading.Tasks;

public class SerialReader : Node
{
    public SerialPort _serialPort;
    
    [Export]
    public string portName = "COM5";
    [Export]
    public int baudRate = 9600;


    public string zString;
    public float zFloat = 0.0f;
    public float zNormalized = 0.0f;

    [Signal]
    public delegate void PlungerSignal();

    public override void _Ready()
    {
        //System.Threading.Thread readThread = new System.Threading.Thread(Read);
        //readThread.Start();
        SetPhysicsProcess(false);

        if(!(Array.Exists(SerialPort.GetPortNames(), element => element == portName)))
        {
            GD.Print("port not found");
            return;
        }
        GD.Print("test");
        _serialPort = new SerialPort();
        _serialPort.PortName = portName;
        _serialPort.BaudRate = baudRate;
        _serialPort.DtrEnable = true;
        _serialPort.RtsEnable = false;
        _serialPort.Open();
        SetPhysicsProcess(true);
        GD.Print("port " + portName + " is open");   
        //readThread.Start(); 
        ReadData();
    }

/*
    public void Read()
    {
        GD.Print("ReadThread started");
        while(true)
        {
            //GD.Print("run");
            zString = _serialPort.ReadLine();
            
                if(zString != null)
                {
                    zFloat = float.Parse(zString);
                }

                zNormalized = zFloat/1023;
            //}
            EmitSignal("PlungerSignal", zNormalized);
            GD.Print(zNormalized);
        }
    }
*/
    public void ReadData()
    {   
        GD.Print("in the read data function");
        Task radData = Task.Factory.StartNew(() =>
        {
            GD.Print("Task running");
            while(true)
            {

            //if(_serialPort.IsOpen)
            //{
                zString = _serialPort.ReadLine();
            
                if(zString != null)
                {
                    zFloat = float.Parse(zString);
                }

                zNormalized = (zFloat-120)/(950-120);
            //}
            EmitSignal("PlungerSignal", zNormalized);
            //GD.Print(zNormalized);
            }
        });
    }    
}
