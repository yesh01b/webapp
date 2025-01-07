## Stage 1: Base - This stage is used when running from VS in fast mode (Default for Debug configuration)

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

## Stage 2: Build - This stage is used to build the service project

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["webapp/webapp.csproj", "webapp/"]
RUN dotnet restore "./webapp/webapp.csproj"
COPY . .
WORKDIR "/src/webapp"
RUN dotnet build "./webapp.csproj" -c Release -o /app/build

## Stage 3: Publish - This stage is used to publish the service project to be copied to the final stage

FROM build AS publish
RUN dotnet publish "./webapp.csproj" -c Release -o /app/publish /p:UseAppHost=false

## Stage 4 : Production - This stage is used in production or when running from VS in regular mode (Default when not using the Debug configuration)

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
CMD [ "dotnet", "webapp.dll" ]