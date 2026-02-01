# Azure Environment Architecture

> Generated: 2026-02-01
> Subscription: Azure subscription 1 (Fintel Sandbox)

## Overview Diagram

```mermaid
flowchart TB
    subgraph Azure["Azure Subscription: Fintel Sandbox"]

        subgraph UKS["UK South Region"]
            subgraph RG1["rg-portfolio-prod-uks"]
                SWA1[("swapubportfolio-prod<br/>Static Web App")]
            end

            subgraph RG2["rg-serviceflow-mvp"]
                SWA2[("swa-serviceflow-dev<br/>Static Web App")]
            end

            subgraph RG3["rg-supplier-portal"]
                SWA3[("swa-supplier-portal<br/>Static Web App")]
            end

            subgraph RG4["rg-azwaf-portal-demo"]
                SWA4[("azure-waf-dashboard<br/>Static Web App")]
            end

            subgraph RG5["rg-onboarding-portal"]
                SWA5[("onboarding-portal<br/>Static Web App")]
                SWA6[("budget-portal<br/>Static Web App")]
            end

            subgraph RG6["rg-isms-portal"]
                SWA7[("isms-portal<br/>Static Web App")]
            end

            subgraph RG7["rg-pensham-daughters"]
                SWA8[("pensham-daughters<br/>Static Web App")]
                SWA9[("swa-it-ops-diagnostic<br/>Static Web App")]
            end

            subgraph RG8["rg-unified-platform"]
                SWA10[("swa-unified-platform<br/>Static Web App")]
            end

            subgraph RG9["rg-iacportal-dev"]
                SWA11[("iacportal-dev-web<br/>Static Web App")]
                COSMOS1[("iacportal-dev-cosmos<br/>Cosmos DB")]
                ST1[("stiacportal...<br/>Storage Account")]
                KV1[("kvp34...<br/>Key Vault")]
            end

            subgraph RG10["rg-m365migrate-dev"]
                SWA12[("m365migrate-dev-web<br/>Static Web App")]
                COSMOS2[("m365migrate-dev-cosmos<br/>Cosmos DB")]
                ST2[("stm365migrate...<br/>Storage Account")]
                KV2[("kv-m365migrate<br/>Key Vault")]
                LOG1[("Log Analytics<br/>Workspace")]
                AI1[("App Insights")]
                FUNC1[("m365migrate-dev-api<br/>Function App")]
                VNET1[("VNet + Private<br/>Endpoints")]
            end
        end

        subgraph WEU["West Europe Region"]
            subgraph RG11["rg-m365hub-dev"]
                SWA13[("m365hub-dev-web<br/>Static Web App")]
            end
        end

        subgraph NEU["North Europe Region"]
            subgraph RG12["rg-m365-maturity-portal"]
                ACR1[("m365portal...<br/>Container Registry")]
                KV3[("m365kv...<br/>Key Vault")]
                LOG2[("Log Analytics<br/>Workspace")]
                AI2[("App Insights")]
                WEB1[("m365-maturity-portal-web<br/>Web App")]
                API1[("m365-maturity-portal-api<br/>Web App")]
                AUTO1[("Automation Account<br/>+ Runbook")]
                VNET2[("VNet + Private<br/>Endpoints")]
            end
        end
    end

    style Azure fill:#0078D4,color:#fff
    style UKS fill:#E6F3FF,stroke:#0078D4
    style WEU fill:#E6F3FF,stroke:#0078D4
    style NEU fill:#E6F3FF,stroke:#0078D4
```

## Detailed Resource Diagram

```mermaid
flowchart LR
    subgraph Projects["Local Projects → Azure Mapping"]
        direction TB

        subgraph SimpleApps["Simple Static Web Apps"]
            P1["personal-brochure"] --> SWA1["swapubportfolio-prod"]
            P2["ops-serviceflow-mvp"] --> SWA2["swa-serviceflow-dev"]
            P3["ops-supplier-portal"] --> SWA3["swa-supplier-portal"]
            P4["azure-waf-monitor"] --> SWA4["azure-waf-dashboard"]
            P5["hr-onboarding-portal"] --> SWA5["onboarding-portal"]
            P6["fin-budget-portal"] --> SWA6["budget-portal"]
            P7["grc-isms-portal"] --> SWA7["isms-portal"]
            P8["personal-pensham-daughters"] --> SWA8["pensham-daughters"]
            P9["ops-diagnostic-portal"] --> SWA9["swa-it-ops-diagnostic"]
            P10["m365-admin-hub"] --> SWA13["m365hub-dev-web"]
        end

        subgraph FullStack["Full-Stack Applications"]
            subgraph IaC["azure-iac-portal"]
                IAC_FE["Frontend"] --> IAC_SWA["iacportal-dev-web"]
                IAC_API["API"] --> IAC_COSMOS["Cosmos DB"]
                IAC_API --> IAC_KV["Key Vault"]
                IAC_API --> IAC_ST["Storage"]
            end

            subgraph M365Migrate["m365-migration-portal"]
                M365M_FE["Frontend"] --> M365M_SWA["m365migrate-dev-web"]
                M365M_API["Azure Functions"] --> M365M_COSMOS["Cosmos DB"]
                M365M_API --> M365M_KV["Key Vault"]
                M365M_API --> M365M_ST["Storage"]
                M365M_API --> M365M_VNET["Private VNet"]
            end

            subgraph M365Maturity["m365-azure-maturity-toolbox"]
                M365T_WEB["Web App"] --> M365T_API["API App"]
                M365T_API --> M365T_ACR["Container Registry"]
                M365T_API --> M365T_KV["Key Vault"]
                M365T_AUTO["Automation"] --> M365T_RB["Runbook"]
            end
        end
    end
```

## Resource Summary

| Resource Type | Count | Locations |
|---------------|-------|-----------|
| **Static Web Apps** | 13 | West Europe |
| **Web Apps** | 3 | North Europe, West Europe |
| **Function Apps** | 1 | West Europe |
| **Cosmos DB** | 2 | UK South |
| **Storage Accounts** | 2 | UK South |
| **Key Vaults** | 3 | UK South, North Europe |
| **Container Registry** | 1 | North Europe |
| **Virtual Networks** | 2 | West Europe, North Europe |
| **Log Analytics** | 2 | UK South, North Europe |
| **App Insights** | 2 | West Europe, North Europe |
| **Automation Accounts** | 1 | North Europe |

## Project to Azure Mapping

| Local Project | Azure Resource | Resource Group | Type |
|---------------|---------------|----------------|------|
| personal-brochure | swapubportfolio-prod | rg-portfolio-prod-uks | Static Web App |
| ops-serviceflow-mvp | swa-serviceflow-dev | rg-serviceflow-mvp | Static Web App |
| ops-supplier-portal | swa-supplier-portal | rg-supplier-portal | Static Web App |
| azure-waf-monitor | azure-waf-dashboard | rg-azwaf-portal-demo | Static Web App |
| hr-onboarding-portal | onboarding-portal | rg-onboarding-portal | Static Web App |
| fin-budget-portal | budget-portal | rg-onboarding-portal | Static Web App |
| grc-isms-portal | isms-portal | rg-isms-portal | Static Web App |
| personal-pensham-daughters | pensham-daughters | rg-pensham-daughters | Static Web App |
| ops-diagnostic-portal | swa-it-ops-diagnostic | rg-pensham-daughters | Static Web App |
| m365-admin-hub | m365hub-dev-web | rg-m365hub-dev | Static Web App |
| azure-iac-portal | iacportal-dev-* | rg-iacportal-dev | Full Stack |
| m365-migration-portal | m365migrate-dev-* | rg-m365migrate-dev | Full Stack |
| m365-azure-maturity-toolbox | m365-maturity-portal-* | rg-m365-maturity-portal | Full Stack |

## Network Architecture

```mermaid
flowchart TB
    subgraph Internet
        Users[("Users")]
    end

    subgraph Azure
        subgraph PublicEndpoints["Public Endpoints"]
            SWA["Static Web Apps<br/>(13 apps)"]
        end

        subgraph m365migrate["rg-m365migrate-dev VNet"]
            PE1["Private Endpoint<br/>Cosmos DB"]
            PE2["Private Endpoint<br/>Blob Storage"]
            PE3["Private Endpoint<br/>Queue Storage"]
            FUNC["Azure Functions"]
        end

        subgraph m365maturity["rg-m365-maturity-portal VNet"]
            PE4["Private Endpoint<br/>Key Vault"]
            PE5["Private Endpoint<br/>Container Registry"]
            WEBAPP["Web Apps"]
        end

        subgraph PrivateDNS["Private DNS Zones"]
            DNS1["privatelink.documents.azure.com"]
            DNS2["privatelink.blob.core.windows.net"]
            DNS3["privatelink.queue.core.windows.net"]
            DNS4["privatelink.vaultcore.azure.net"]
            DNS5["privatelink.azurecr.io"]
        end
    end

    Users --> SWA
    Users --> FUNC
    Users --> WEBAPP
    FUNC --> PE1
    FUNC --> PE2
    FUNC --> PE3
    WEBAPP --> PE4
    WEBAPP --> PE5
    PE1 -.-> DNS1
    PE2 -.-> DNS2
    PE3 -.-> DNS3
    PE4 -.-> DNS4
    PE5 -.-> DNS5
```

## Cost Optimization Notes

- **Static Web Apps**: Most apps use the Free tier - consider Standard for production
- **Cosmos DB**: Using serverless/provisioned - monitor RU consumption
- **Private Endpoints**: Each incurs hourly cost - consolidate where possible
- **Container Registry**: Basic tier - upgrade for geo-replication if needed

## Security Features

- ✅ Private Endpoints for Cosmos DB, Storage, Key Vault, ACR
- ✅ Virtual Networks with proper subnet segmentation
- ✅ Key Vault for secrets management
- ✅ App Insights for monitoring
- ⚠️ Consider: Azure Front Door for WAF protection on Static Web Apps
- ⚠️ Consider: Managed Identities for all app-to-resource connections
