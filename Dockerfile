#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["MudBlazorWebApp1/MudBlazorWebApp1/MudBlazorWebApp1.csproj", "MudBlazorWebApp1/MudBlazorWebApp1/"]
COPY ["MudBlazorWebApp1/MudBlazorWebApp1.Client/MudBlazorWebApp1.Client.csproj", "MudBlazorWebApp1/MudBlazorWebApp1.Client/"]
RUN dotnet restore "./MudBlazorWebApp1/MudBlazorWebApp1/MudBlazorWebApp1.csproj"
COPY . .
WORKDIR "/src/MudBlazorWebApp1/MudBlazorWebApp1"
RUN dotnet build "./MudBlazorWebApp1/MudBlazorWebApp1/MudBlazorWebApp1.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./MudBlazorWebApp1/MudBlazorWebApp1/MudBlazorWebApp1.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# The value production is used in Program.cs to set the URL for Google Cloud Run
ENV ASPNETCORE_ENVIRONMENT=production
ENV IS_GOOGLE_CLOUD=true

ENTRYPOINT ["dotnet", "MudBlazorWebApp1.dll"]