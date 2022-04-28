using Godot;
using System;
using System.Runtime.InteropServices;
using System.Runtime.ConstrainedExecution;

public class TrackedHeadPoseBam : Spatial
{
    [Export]
    private bool ignoreX = false;
    [Export]
    private bool ignoreY = false;
    [Export]
    private bool ignoreZ = false;
    [Export]
    private bool isTracking = true;

    private bool isReady = false;

    public override void _Ready()
    {
        BAM_Tracker.init();
        GD.Print("Starting BAM client...");
        Translation = new Vector3 (0f, 5f, 0f);

    }

    public override void _Process(float delta)
    {
        
        if (!isReady)
        {
            isReady = BAM_Tracker.isReady();    
            if (isReady)
            {
                GD.Print("BAM client started.");
            }
        }

        if (isReady && isTracking)
        {
            BAM_Tracker.data_struct data = BAM_Tracker.getData();
            Vector3 pose = new Vector3((float)data.EyeVecX, (float)data.EyeVecZ, -(float)data.EyeVecY) * .001f;
            if (ignoreX)
                pose.x = 0f;
            if (ignoreY)
                pose.y = 0f;
            if (ignoreZ)
                pose.z = 0f;
            Translation = pose;
        }
    }

    public override void _ExitTree()
    {
        BAM_Tracker.release();
        GD.Print("BAM Client closed.");
    }
}

public static class BAM_Tracker
{
    /**
     * System functions used:
     * - OpenFileMapping
     * - CloseHandle
     * - MapViewOfFile
     * - UnmapViewOfFile
     */
    // http://msdn.microsoft.com/en-us/library/windows/desktop/aa366791(v=vs.85).aspx
    [DllImport("Kernel32", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern IntPtr OpenFileMapping(int dwDesiredAccess, [MarshalAs(UnmanagedType.Bool)] bool bInheritHandle, string lpName);

    // http://msdn.microsoft.com/en-us/library/windows/desktop/aa366761(v=vs.85).aspx
    [DllImport("Kernel32", CharSet = CharSet.Auto, SetLastError = true)]
    internal static extern IntPtr MapViewOfFile(IntPtr hFileMapping, int dwDesiredAccess, int dwFileOffsetHigh, int dwFileOffsetLow, int dwNumberOfBytesToMap);

    // http://msdn.microsoft.com/en-us/library/windows/desktop/aa366882(v=vs.85).aspx
    [return: MarshalAs(UnmanagedType.Bool)]
    [ReliabilityContract(Consistency.WillNotCorruptState, Cer.Success), DllImport("Kernel32", CharSet = CharSet.Auto, SetLastError = true)]
    internal static extern bool UnmapViewOfFile(IntPtr pvBaseAddress);

    // http://msdn.microsoft.com/en-us/library/windows/desktop/ms724211(v=vs.85).aspx
    [DllImport("kernel32", CharSet = CharSet.Auto, SetLastError = true, ExactSpelling = true)]
    internal static extern int CloseHandle(IntPtr hObject);

    /**
     * Structure of BAM-Tracker data:
     * struct BT_Data_Struct {
     *     int Counter;                      // increased after each update
     *     double PlayerX, PlayerY, PlayerZ; // [mm]
	 *     double EyeVecX, EyeVecY, EyeVecZ; // [normalized vector]
	 *     double ScreenWidth, ScreenHeight; // [mm]
     * }
     */
    [StructLayout(LayoutKind.Explicit, Size = 68, Pack = 1)]
    public struct data_struct
    {
        [MarshalAs(UnmanagedType.I4)]
        [FieldOffset(0)]
        public int Counter;

        [MarshalAs(UnmanagedType.R8)]
        [FieldOffset(8)]
        public double PlayerX;

        [MarshalAs(UnmanagedType.R8)]
        [FieldOffset(16)]
        public double PlayerY;

        [MarshalAs(UnmanagedType.R8)]
        [FieldOffset(24)]
        public double PlayerZ;

        [MarshalAs(UnmanagedType.R8)]
        [FieldOffset(32)]
        public double EyeVecX;

        [MarshalAs(UnmanagedType.R8)]
        [FieldOffset(40)]
        public double EyeVecY;

        [MarshalAs(UnmanagedType.R8)]
        [FieldOffset(48)]
        public double EyeVecZ;

        [MarshalAs(UnmanagedType.R8)]
        [FieldOffset(56)]
        public double ScreenWidth;

        [MarshalAs(UnmanagedType.R8)]
        [FieldOffset(64)]
        public double ScreenHeight;
    }

    static IntPtr hMapFile; // Handle returned by OpenFileMapping
    static IntPtr dataPtr;  // pointer do BAM-Tracker data (c-struct)

    /**
     * Open shared memory.
     * Call it at program init.
     * 
     * It will fill: hMapFile & dataPtr
     */
    internal static void init()
    {
        dataPtr = IntPtr.Zero;
        hMapFile = OpenFileMapping(0x0004 /* FILE_MAP_READ */, false, "BAM-Tracker-Shared-Memory");
        if (hMapFile != IntPtr.Zero)
        {
            int size = Marshal.SizeOf(typeof(data_struct));
            dataPtr = MapViewOfFile(hMapFile, 0x0004 /* FILE_MAP_READ */, 0, 0, size);
            if (dataPtr == IntPtr.Zero)
                CloseHandle(hMapFile);

        }
    }

    /**
     *  Close shared memory.
     *  Call it at program exit.
     */
    internal static void release()
    {
        if (dataPtr != IntPtr.Zero)
            UnmapViewOfFile(dataPtr);
        if (hMapFile != IntPtr.Zero)
            CloseHandle(hMapFile);
    }

    /**
     *  Will return true, if BAM-Tracker is running (and we are client)
     *  Call it before You read BAM-Tracer data.
     */
    internal static bool isReady()
    {
        return dataPtr != IntPtr.Zero;
    }

    /**
     *  Will return BAM-Tracker structure
     */
    internal static data_struct getData()
    {
        return (data_struct)Marshal.PtrToStructure(dataPtr, typeof(data_struct));
    }

    /** 
     * Part of this program, where i read data:
     * if (BAM_Tracker.isReady())
     * {
     *     BAM_Tracker.data_struct data = BAM_Tracker.getData();
     *     lCounter.Text = data.Counter.ToString();
     *     lPlayer.Text = data.PlayerX.ToString("F3") + " / " + data.PlayerY.ToString("F3") + " / " + data.PlayerZ.ToString("F3") + " [mm]";
     *     lEyeVec.Text = data.EyeVecX.ToString("F3") + " / " + data.EyeVecY.ToString("F3") + " / " + data.EyeVecZ.ToString("F3") + " [mm]";
     *     lScreen.Text = data.ScreenWidth.ToString("F3") + " x " + data.ScreenHeight.ToString("F3") + " [mm]";
     * }
     */
};

