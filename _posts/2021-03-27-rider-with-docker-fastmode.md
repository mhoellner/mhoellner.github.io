---
title: Building Container Fastmode in Jetbrains Rider
date: 2021-03-27 23:30:00 +0100
layout: post
tags: [ visual studio, jetbrains rider, docker ]
---

When switching from Visual Studio 2019 to Jetbrains Rider, I was missing some of the comfort while working with Docker.
The most notable being the container fastmode used by Visual Studio.

This post shows how to build something similar to the container fastmode using Jetbrains Rider's "Run/Debug Configurations".
<!--more-->

When adding docker support to a ASP.NET application in Visual Studio, a Dockerfile is added.
This file contains a multi-stage build using multiple base images.
Visual Studio's container fastmode uses only the `base` stage.
Additionally, the complete folder containing the compiled libraries is mounted into the container.

## Create a Dockerfile

The first step to add container fastmode in Jetbrains Rider is to add a new Dockerfile.
This file only needs to contain the `base` stage of the original Dockerfile.
To prevent the container from exiting directly, you'll need an entrypoint.
You can use the same entrypoint as in your original Dockerfile.

Your `Rider.Dockerfile` could look like this:
```docker
FROM mcr.microsoft.com/dotnet/aspnet:5.0.3-buster-slim AS base
WORKDIR /app

ENTRYPOINT ["dotnet", "API.dll"]
```

## Create a docker-compose file

To run all containers at once, we can use docker-compose.
Visual Studio adds docker-compose support with their `*.dcproj` file.
This is currently not supported in Jetbrains Rider.

If you added docker-compose support in Visual Studio, you can just create a new docker-compose file.
I'll call it `docker-compose.rider.yml`.
In this file we'll need to update the dockerfile to build from our newly created `Rider.Dockerfile` and mount the compiled libraries into the container as a volume.

The file could look like this:
```yaml
services:
  api:
    build:
      dockerfile: src/API/Rider.Dockerfile
    volumes:
      - ./src/API/bin/Debug/net5.0:/app
```

The volume is used to mount the compiled DLL into the container.
In the original Dockerfile, compilation is part of the image build.
For our container fastmode, compilation is done locally by Jetbrains Rider.

## Create a docker-compose Debug/Run Configuration

The last step is to create a new "Debug/Run Configuration" in Jetbrains Rider for "docker-compose".
We need to add multiple compose files: `docker-compose.yml`, `docker-compose.override.yml` and `docker-compose.rider.yml`.
The order of the files is important, as each compose file extends the configuration and overwrites existing keys.

By default, Jetbrains Rider tries to debug / run all containers from the compose files, even the services that are not built locally.
To prevent this, we'll need to select the correct services for the "Debug/Run Configuration".

To ensure always debugging / running the latest version, we can add a "Before Launch" step to build the solution.

## Conclusion

With a few small changes to the existing solution, we can add something similar to Visual Studio's container fastmode in Jetbrains Rider.
This makes using Jetbrains Rider even more viable as a replacement for Visual Studio.
