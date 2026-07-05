# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY EcoBazaar.Api.slnx ./
COPY src/EcoBazaar.Api/EcoBazaar.Api.csproj src/EcoBazaar.Api/
RUN dotnet restore src/EcoBazaar.Api/EcoBazaar.Api.csproj

COPY src/ src/
RUN dotnet publish src/EcoBazaar.Api/EcoBazaar.Api.csproj \
  --configuration Release \
  --output /app/publish \
  /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "EcoBazaar.Api.dll"]
