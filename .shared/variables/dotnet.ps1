# .shared/variables/dotnet.ps1

# -------------------------------------------------------------------------------------------------
# .NET Variables
# -------------------------------------------------------------------------------------------------

$dotNetInstallDir = [System.IO.Path]::Combine($HOME, '.dotnet')
$dotNetInstallScriptPath = [System.IO.Path]::Combine($PWD, '.shared\files\dotnet-install.ps1')
$dotNetInstallDownloadUrl = 'https://dot.net/v1/dotnet-install.ps1'
$dotNetInstallLearnUrl = 'https://learn.microsoft.com/en-us/dotnet/core/install/windows#install-with-powershell'

# -------------------------------------------------------------------------------------------------

$DotNet = [pscustomobject]@{
    InstallDir          = $dotNetInstallDir            # Directory where .NET SDKs and Runtimes are installed
    InstallScriptPath   = $dotNetInstallScriptPath     # Path to the dotnet-install.ps1 script
    InstallDownloadUrl  = $dotNetInstallDownloadUrl    # URL to download the dotnet-install.ps1 script
    InstallLearnUrl     = $dotNetInstallLearnUrl       # URL to learn more about .NET installation
    
    # SDK versions to install
    InstallVersions = @(
        @{ Channel = '8.0';  Type = 'sdk' }            # .NET 8 LTS (current, supported until Nov 2026)
        @{ Channel = '10.0'; Type = 'sdk' }            # .NET 10 LTS (preview/latest)
    )
    
    # Workloads to install (requires SDK)
    Workloads = @(
        'aspire'                                       # .NET Aspire - Cloud-native orchestration
        'maui'                                         # .NET MAUI - Cross-platform native apps (iOS, Android, macOS, Windows)
        'wasm-tools'                                   # WebAssembly - Blazor WebAssembly tools
        # 'android'                                    # Android - Native Android development
        # 'ios'                                        # iOS - Native iOS development
        # 'maccatalyst'                                # macOS Catalyst - iOS apps on macOS
        # 'wasi-experimental'                          # WASI - WebAssembly System Interface (experimental)
    )
    
    # Global tools to install (dotnet tool install --global <tool>)
    Tools = @(
        'dotnet-ef'                                  # Entity Framework Core CLI - Database migrations and scaffolding
        'dotnet-aspnet-codegenerator'                # ASP.NET Core scaffolding - Generate controllers, views, pages
        'dotnet-outdated-tool'                       # Outdated - Check for outdated NuGet packages
        'dotnet-trace'                               # Trace - Performance profiling and diagnostics
        'dotnet-counters'                            # Counters - Real-time performance metrics
        'dotnet-dump'                                # Dump - Memory dump analysis
        'dotnet-gcdump'                              # GC Dump - Garbage collection heap analysis
        'dotnet-monitor'                             # Monitor - Production diagnostics and metrics
        'dotnet-reportgenerator-globaltool'          # Report Generator - Code coverage reports
        'dotnet-dev-certs'                           # Dev Certs - HTTPS development certificates
        'dotnet-serve'                               # Serve - Simple HTTP file server
        'httprepl'                                   # HTTP REPL - Interactive HTTP client for testing APIs
        # 'microsoft.tye'                            # Tye - Microservices development orchestration
        # 'dotnet-stryker'                           # Stryker - Mutation testing
        # 'upgrade-assistant'                        # Upgrade Assistant - Migrate projects to latest .NET
        # 'volo.abp.cli'                             # ABP CLI - ABP Framework project management
        # 'dotnet-svcutil'                           # Service Util - WCF service reference generation
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$DotNet` Variable:"
    $DotNet | Format-List
}
