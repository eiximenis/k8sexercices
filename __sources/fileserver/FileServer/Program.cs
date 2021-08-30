using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Threading.Tasks;

namespace FileServer
{
    public class Program
    {
        public static bool FileOk { get; private set; }
        public static async Task Main(string[] args)
        {

            if (args.Length > 0 && args[0] == "create")
            {
                await CreateFile();
            }
            else
            {
                FileOk = CheckFile();
            }

            Console.WriteLine("Starting API Host.");
            CreateHostBuilder(args).Build().Run();
        }

        private static bool CheckFile()
        {
            var path = Environment.GetEnvironmentVariable("DATA_PATH");
            var fname = Path.Combine(path, "keys.txt");
            return File.Exists(fname);
        }

        private static async Task CreateFile()
        {
            var path = Environment.GetEnvironmentVariable("DATA_PATH");
            var fname = Path.Combine(path, "keys.txt");
            if (!File.Exists(fname))
            {
                Console.WriteLine($"Creating keys file {fname}");
                using var fs = new FileStream(fname, FileMode.CreateNew, FileAccess.ReadWrite);
                using var sw = new StreamWriter(fs);
                var rnd = new Random();
                for (var idx = 1; idx <= 5; idx++)
                {
                    await Task.Delay(5000);
                    var key = rnd.Next(1, 15000);
                    sw.WriteLine($"{key}");
                    Console.WriteLine($"Generated key {idx}: value is {key}");
                }
                sw.Flush();
                sw.Close();
            }
            else 
            {
               throw new InvalidOperationException($"Keys file {fname} already exists and create param was passed. Please use only dotnet FileServer.dll without create param if file already exists.");
            } 
            FileOk = true;
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                });
    }
}
