using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace FileServer
{
    public class Startup
    {
        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit https://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            app.UseRouting();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapGet("/", async context =>
                {
                    if (Program.FileOk)
                    {
                        context.Response.StatusCode = 200;
                        await context.Response.WriteAsync($"Hello world from {Environment.MachineName}");
                    }
                    else
                    {
                        context.Response.StatusCode = 500;
                    }
                });

                endpoints.MapGet("/keys", async context =>
                {

                    if (Program.FileOk)
                    {
                        var path = Environment.GetEnvironmentVariable("DATA_PATH");
                        var fname = Path.Combine(path, "keys.txt");
                        context.Response.StatusCode = 200;
                        await context.Response.WriteAsync(File.ReadAllText(fname));
                    }
                    else
                    {
                        context.Response.StatusCode = 500;
                    }
                });
            });
        }
    }
}
