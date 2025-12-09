# Etapa 1: Build con SDK .NET 10
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["MawdyApi.csproj", "./"]
RUN dotnet restore "MawdyApi.csproj"
COPY . .
RUN dotnet publish "MawdyApi.csproj" -c Release -o /app/publish

# Etapa 2: Runtime con ASP.NET Core 10
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
EXPOSE 8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "MawdyApi.dll"]