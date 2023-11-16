#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0@sha256:5e99a04b3b0c79235890bf5d29d45266e7e9f0233269d25630460d0215a40449 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0@sha256:239eb99884b49bac13f4ff5935e118654f87b67d6e31bc842c7cd5a6c46fcc4f AS build
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