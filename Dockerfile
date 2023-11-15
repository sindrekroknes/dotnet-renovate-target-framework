#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0@sha256:80154b737b6dcbc533aa22d028578641764ad8c23efe94b0a1a4f9fa044b7b91 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0@sha256:f972ec3d257e82c73b0d1c70df854521957bfc214823700ee9dc6ae27dc6a10b AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["dotnet-renovate-target-framework.csproj", "."]
RUN dotnet restore "./././dotnet-renovate-target-framework.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "./dotnet-renovate-target-framework.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./dotnet-renovate-target-framework.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dotnet-renovate-target-framework.dll"]