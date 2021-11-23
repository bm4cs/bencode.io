---
layout: post
title: "dotnet worker kubernetes health probe"
draft: false
slug: "k8s-worker"
date: "2021-11-18 16:48:40"
lastmod: "2021-11-19 19:36:12"
comments: false
categories:
    - kubernetes
tags:
    - kubernetes
    - k8s
---

# The Problem

You have a (headless) background worker process that needs to communicate its readiness to kubernetes.

# The Solution

ASP.NET Core provides a decent [approach](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/health-checks) to performing a series of agnostic health checks. There are [hundreds](https://github.com/Xabaril/AspNetCore.Diagnostics.HealthChecks/tree/master/src) of health probes available such as `Network`, `Elasticsearch`, `Kafka` and `NpgSql`.

However being part of ASP.NET Core, does mean that some of these dependencies, such as [Microsoft.AspNetCore.Diagnostics.HealthChecks](https://www.nuget.org/packages/Microsoft.AspNetCore.Diagnostics.HealthChecks) package, will bleed into the worker as a needed dependency. The plus side is that you can avoid reinventing the wheel.

First we need to create a `IHealthCheckPublisher` that will publish the health of the worker application, in this case by writing a file out to disk:

```c#
using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using api.Models;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace worker.Health
{
    // Touches a file to indicate liveness state of the pod
    // Deletes the file to indicate unhealthy
    public class HealthCheckPublisher : IHealthCheckPublisher
    {
        private readonly string _fileName;
        private HealthStatus _prevStatus = HealthStatus.Unhealthy;

        public HealthCheckPublisher(CoolAppOptions coolAppOptions)
        {
            _fileName = coolAppOptions.HealthCheckFilePath;
        }

        public Task PublishAsync(HealthReport report, CancellationToken cancellationToken)
        {
            var fileExists = _prevStatus == HealthStatus.Healthy;

            if (report.Status == HealthStatus.Healthy)
            {
                using var _ = File.Create(_fileName);
            }
            else if (fileExists)
            {
                File.Delete(_fileName);
            }

            _prevStatus = report.Status;
            return Task.CompletedTask;
        }
    }
}
```

When bootstrapping the worker in `Program.cs` first up register the individual health checks needed (see snippet below which does postgres, rabbitmq and elasticsearch checks), followed by dependency injecting the custom `IHealthCheckPublisher` implementation prior to launching the worker service itself:

```c#
namespace worker
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
            .ConfigureServices((hostContext, services) =>
                {
                    IConfiguration configuration = hostContext.Configuration;
                    CoolAppOptions coolAppOptions = configuration.GetSection("dam").Get<CoolAppOptions>();

                    services.ConnectToRabbitMq(coolAppOptions);
                    var rabbitConnectionFactory = services.BuildServiceProvider().GetService<ConnectionFactory>();
                    services.AddHealthChecks()
                        .AddNpgSql(coolAppOptions.Db.ConnectionString)
                        .AddRabbitMQ(_ => rabbitConnectionFactory)
                        .AddElasticsearch(coolAppOptions.Elastic.Uri);

                    services.AddSingleton<IHealthCheckPublisher, HealthCheckPublisher>(_ => new HealthCheckPublisher(coolAppOptions));
                    services.Configure<HealthCheckPublisherOptions>(options =>
                    {
                        options.Delay = TimeSpan.FromSeconds(5);
                        options.Period = TimeSpan.FromSeconds(20);
                    });

                    services.AddHostedService<Worker>();
                });
    }
}
```

The worker will now emit a file e.g. `/app/health` to indicate its up and running and can connect to everything it needs to.

Finally setup kubernetes readiness and liveness probes to look for this file. Using `find -mmin -1` will only return 0 if a `health` file less than a minute old exists.

```yaml
livenessProbe:
    exec:
        command:
            - find
            - /app/health
            - -mmin
            - "-1"
    initialDelaySeconds: 5
    periodSeconds: 10
```
