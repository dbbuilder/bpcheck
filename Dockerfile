# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["BloodPressureMonitor.API/BloodPressureMonitor.API.csproj", "BloodPressureMonitor.API/"]
RUN dotnet restore "BloodPressureMonitor.API/BloodPressureMonitor.API.csproj"

# Copy everything else and build
COPY BloodPressureMonitor.API/ BloodPressureMonitor.API/
WORKDIR /src/BloodPressureMonitor.API
RUN dotnet build "BloodPressureMonitor.API.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "BloodPressureMonitor.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Create non-root user
RUN adduser --disabled-password --gecos '' appuser

# Copy published files
COPY --from=publish /app/publish .

# Change ownership
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Start the application
ENTRYPOINT ["dotnet", "BloodPressureMonitor.API.dll"]
