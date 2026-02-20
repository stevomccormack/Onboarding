# .shared/variables/azure-cli.ps1

# -------------------------------------------------------------------------------------------------
# Azure CLI Extensions Configuration & Management
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# Azure CLI Extension Commands
# -------------------------------------------------------------------------------------------------
# List installed extensions:
#   az extension list
# Install an extension:
#   az extension add --name <extension-name>
# Update an extension:
#   az extension update --name <extension-name>
# Remove an extension:
#   az extension remove --name <extension-name>
# List available extensions:
#   az extension list-available
# -------------------------------------------------------------------------------------------------

$azInstallUrl = 'https://learn.microsoft.com/en-us/cli/azure/install-azure-cli'
$azDocsUrl = 'https://learn.microsoft.com/en-us/cli/azure/'
$azExtensionsUrl = 'https://learn.microsoft.com/en-us/cli/azure/azure-cli-extensions-list'

$Az = [pscustomobject]@{
    Id             = 'azure-cli'
    Enabled        = $true                        # Enable Azure CLI installation
    Name           = 'Azure CLI'
    CommandName    = 'az'
    TestCommand    = 'az --version'
    Description    = 'Azure command-line interface'
    WingetId       = 'Microsoft.AzureCLI'         # winget install --exact --id Microsoft.AzureCLI --source winget
    ChocoId        = 'azure-cli'                  # choco install azure-cli
    InstallUrl     = $azInstallUrl                # Azure CLI installation
    DocsUrl        = $azDocsUrl                   # Documentation
    ExtensionsUrl  = $azExtensionsUrl             # Available extensions list
    
    # Azure CLI Configuration Settings
    Yes            = $true                        # Assume yes to all prompts
    OnlyShowErrors = $false                       # Only show errors
    Verbose        = $false                       # Verbose output
    Debug          = $false                       # Debug output
    NoWait         = $false                       # Don't wait for long-running operations
    
    Extensions     = @(
        # AI & Machine Learning
        @{ Id = 'ai-examples'; Enabled = $false; Name = 'Azure AI Examples'; CommandName = 'az'; TestCommand = 'az ai --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/ai' }
        @{ Id = 'ml'; Enabled = $true; Name = 'Azure Machine Learning'; CommandName = 'az'; TestCommand = 'az ml --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/ml' }

        # Application Services
        @{ Id = 'containerapp'; Enabled = $true; Name = 'Container Apps'; CommandName = 'az'; TestCommand = 'az containerapp --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/containerapp' }
        @{ Id = 'webapp'; Enabled = $true; Name = 'Web Apps'; CommandName = 'az'; TestCommand = 'az webapp --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/webapp' }
        @{ Id = 'spring'; Enabled = $false; Name = 'Azure Spring Apps'; CommandName = 'az'; TestCommand = 'az spring --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/spring' }
        @{ Id = 'functionapp'; Enabled = $true; Name = 'Azure Functions'; CommandName = 'az'; TestCommand = 'az functionapp --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/functionapp' }

        # DevOps & CI/CD
        @{ Id = 'azure-devops'; Enabled = $true; Name = 'Azure DevOps'; CommandName = 'az'; TestCommand = 'az devops --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/devops' }
        @{ Id = 'aks-preview'; Enabled = $true; Name = 'AKS Preview'; CommandName = 'az'; TestCommand = 'az aks --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/aks' }

        # Monitoring & Observability
        @{ Id = 'application-insights'; Enabled = $true; Name = 'Application Insights'; CommandName = 'az'; TestCommand = 'az monitor app-insights --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/monitor/app-insights' }
        @{ Id = 'log-analytics'; Enabled = $true; Name = 'Log Analytics'; CommandName = 'az'; TestCommand = 'az monitor log-analytics --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/monitor/log-analytics' }

        # Databases
        @{ Id = 'cosmosdb-preview'; Enabled = $true; Name = 'Cosmos DB Preview'; CommandName = 'az'; TestCommand = 'az cosmosdb --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/cosmosdb' }
        @{ Id = 'sql-server-lr'; Enabled = $true; Name = 'SQL Server LR'; CommandName = 'az'; TestCommand = 'az sql --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/sql' }
        @{ Id = 'rdbms-connect'; Enabled = $false; Name = 'Database Connect'; CommandName = 'az'; TestCommand = 'az mysql --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/mysql' }

        # Networking
        @{ Id = 'front-door'; Enabled = $true; Name = 'Azure Front Door'; CommandName = 'az'; TestCommand = 'az afd --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/afd' }
        @{ Id = 'dns-resolver'; Enabled = $false; Name = 'DNS Resolver'; CommandName = 'az'; TestCommand = 'az dns-resolver --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/dns-resolver' }
        @{ Id = 'virtual-wan'; Enabled = $false; Name = 'Virtual WAN'; CommandName = 'az'; TestCommand = 'az network vwan --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/network/vwan' }

        # Security & Identity
        @{ Id = 'keyvault-preview'; Enabled = $true; Name = 'Key Vault Preview'; CommandName = 'az'; TestCommand = 'az keyvault --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/keyvault' }
        @{ Id = 'azure-firewall'; Enabled = $false; Name = 'Azure Firewall'; CommandName = 'az'; TestCommand = 'az network firewall --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/network/firewall' }

        # Storage & Data
        @{ Id = 'storage-preview'; Enabled = $true; Name = 'Storage Preview'; CommandName = 'az'; TestCommand = 'az storage --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/storage' }
        @{ Id = 'synapse'; Enabled = $false; Name = 'Azure Synapse'; CommandName = 'az'; TestCommand = 'az synapse --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/synapse' }
        @{ Id = 'databricks'; Enabled = $false; Name = 'Azure Databricks'; CommandName = 'az'; TestCommand = 'az databricks --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/databricks' }

        # IoT & Edge
        @{ Id = 'azure-iot'; Enabled = $false; Name = 'Azure IoT'; CommandName = 'az'; TestCommand = 'az iot --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/iot' }

        # Management & Governance
        @{ Id = 'resource-graph'; Enabled = $true; Name = 'Resource Graph'; CommandName = 'az'; TestCommand = 'az graph --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/graph' }
        @{ Id = 'blueprint'; Enabled = $false; Name = 'Azure Blueprints'; CommandName = 'az'; TestCommand = 'az blueprint --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/blueprint' }
        @{ Id = 'maintenance'; Enabled = $false; Name = 'Maintenance'; CommandName = 'az'; TestCommand = 'az maintenance --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/maintenance' }

        # Communication
        @{ Id = 'communication'; Enabled = $false; Name = 'Communication Services'; CommandName = 'az'; TestCommand = 'az communication --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/communication' }

        # Specialized Services
        @{ Id = 'attestation'; Enabled = $false; Name = 'Azure Attestation'; CommandName = 'az'; TestCommand = 'az attestation --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/attestation' }
        @{ Id = 'quantum'; Enabled = $false; Name = 'Azure Quantum'; CommandName = 'az'; TestCommand = 'az quantum --help'; Url = 'https://learn.microsoft.com/en-us/cli/azure/quantum' }
    )
}

# -------------------------------------------------------------------------------------------------

if ($Global.Log.Enabled) {
    Write-Header "`$Az` Variable:"
    $Az | Format-List
}
