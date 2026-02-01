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

### High-Level Network Overview

```mermaid
flowchart TB
    subgraph Internet["Internet"]
        Users[("Users")]
    end

    subgraph Azure["Azure Cloud"]
        subgraph PublicLayer["Public Access Layer"]
            SWA["Static Web Apps<br/>13 applications"]
            FUNC_PUB["Azure Functions<br/>(Public Endpoint)"]
            WEB_PUB["Web Apps<br/>(Public Endpoint)"]
        end

        subgraph WEU_VNET["West Europe VNet<br/>m365migrate-dev-vnet<br/>10.0.0.0/16"]
            subgraph FuncSubnet["functions-subnet<br/>10.0.1.0/24"]
                FUNC["Azure Functions<br/>m365migrate-dev-api"]
            end
            subgraph PLSubnet1["privatelink-subnet<br/>10.0.2.0/24"]
                PE_COSMOS["PE: Cosmos DB"]
                PE_BLOB["PE: Blob Storage"]
                PE_QUEUE["PE: Queue Storage"]
            end
        end

        subgraph NEU_VNET["North Europe VNet<br/>m365-maturity-portal-vnet<br/>10.0.0.0/16"]
            subgraph PESubnet["private-endpoints<br/>10.0.1.0/24"]
                PE_KV["PE: Key Vault"]
                PE_ACR["PE: Container Registry"]
            end
            subgraph AppSubnet["app-services<br/>10.0.2.0/24"]
                WEB["Web App"]
                API["API App"]
            end
        end

        subgraph PaaS["PaaS Resources (Private)"]
            COSMOS[("Cosmos DB")]
            STORAGE[("Storage Account")]
            KV[("Key Vault")]
            ACR[("Container Registry")]
        end

        subgraph DNS["Private DNS Zones"]
            DNS_COSMOS["privatelink.documents.azure.com"]
            DNS_BLOB["privatelink.blob.core.windows.net"]
            DNS_QUEUE["privatelink.queue.core.windows.net"]
            DNS_KV["privatelink.vaultcore.azure.net"]
            DNS_ACR["privatelink.azurecr.io"]
        end
    end

    Users --> SWA
    Users --> FUNC_PUB
    Users --> WEB_PUB

    FUNC --> PE_COSMOS
    FUNC --> PE_BLOB
    FUNC --> PE_QUEUE

    WEB --> PE_KV
    API --> PE_KV
    API --> PE_ACR

    PE_COSMOS --> COSMOS
    PE_BLOB --> STORAGE
    PE_QUEUE --> STORAGE
    PE_KV --> KV
    PE_ACR --> ACR

    PE_COSMOS -.-> DNS_COSMOS
    PE_BLOB -.-> DNS_BLOB
    PE_QUEUE -.-> DNS_QUEUE
    PE_KV -.-> DNS_KV
    PE_ACR -.-> DNS_ACR

    style Internet fill:#f5f5f5
    style PublicLayer fill:#e8f4e8
    style WEU_VNET fill:#e3f2fd
    style NEU_VNET fill:#fff3e0
    style PaaS fill:#fce4ec
    style DNS fill:#f3e5f5
```

### Detailed VNet Architecture

```mermaid
flowchart LR
    subgraph WestEurope["West Europe Region"]
        subgraph VNET1["m365migrate-dev-vnet-y7xmaa"]
            direction TB
            CIDR1["Address Space: 10.0.0.0/16"]

            subgraph Subnet1A["functions-subnet"]
                S1A_CIDR["10.0.1.0/24"]
                S1A_RES["Azure Functions<br/>VNet Integration"]
            end

            subgraph Subnet1B["privatelink-subnet"]
                S1B_CIDR["10.0.2.0/24"]
                PE1["m365migrate-dev-cosmos-pe<br/>→ Cosmos DB"]
                PE2["m365migrate-dev-storage-pe-blob<br/>→ Blob Storage"]
                PE3["m365migrate-dev-storage-pe-queue<br/>→ Queue Storage"]
            end
        end

        subgraph DNS1["Private DNS Zones"]
            DNS1A["privatelink.documents.azure.com"]
            DNS1B["privatelink.blob.core.windows.net"]
            DNS1C["privatelink.queue.core.windows.net"]
        end
    end

    subgraph NorthEurope["North Europe Region"]
        subgraph VNET2["m365-maturity-portal-vnet-cxvs3kbky7xcw"]
            direction TB
            CIDR2["Address Space: 10.0.0.0/16"]

            subgraph Subnet2A["private-endpoints"]
                S2A_CIDR["10.0.1.0/24"]
                PE4["m365kv-pe<br/>→ Key Vault"]
                PE5["m365portal-pe<br/>→ Container Registry"]
            end

            subgraph Subnet2B["app-services"]
                S2B_CIDR["10.0.2.0/24"]
                APP1["m365-maturity-portal-web<br/>VNet Integration"]
                APP2["m365-maturity-portal-api<br/>VNet Integration"]
            end
        end

        subgraph DNS2["Private DNS Zones"]
            DNS2A["privatelink.vaultcore.azure.net"]
            DNS2B["privatelink.azurecr.io"]
        end
    end

    VNET1 -.->|"DNS Link"| DNS1
    VNET2 -.->|"DNS Link"| DNS2

    style VNET1 fill:#e3f2fd,stroke:#1976d2
    style VNET2 fill:#fff3e0,stroke:#f57c00
```

### Private Endpoint Connectivity

```mermaid
flowchart TB
    subgraph Apps["Application Layer"]
        FUNC["Azure Functions<br/>m365migrate-dev-api"]
        WEB["Web App<br/>m365-maturity-portal-web"]
        API["API App<br/>m365-maturity-portal-api"]
    end

    subgraph PrivateEndpoints["Private Endpoints"]
        subgraph WEU_PE["West Europe VNet"]
            PE_COSMOS["Cosmos DB PE<br/>10.0.2.x"]
            PE_BLOB["Blob Storage PE<br/>10.0.2.x"]
            PE_QUEUE["Queue Storage PE<br/>10.0.2.x"]
        end

        subgraph NEU_PE["North Europe VNet"]
            PE_KV["Key Vault PE<br/>10.0.1.x"]
            PE_ACR["ACR PE<br/>10.0.1.x"]
        end
    end

    subgraph Resources["Azure PaaS Resources"]
        COSMOS[("m365migrate-dev-cosmos<br/>Cosmos DB<br/>UK South")]
        STORAGE[("stm365migrate<br/>Storage Account<br/>UK South")]
        KV[("m365kv<br/>Key Vault<br/>North Europe")]
        ACR[("m365portal<br/>Container Registry<br/>North Europe")]
    end

    subgraph DNS["Private DNS Resolution"]
        DNS_DOC["*.documents.azure.com<br/>→ Private IP"]
        DNS_BLOB["*.blob.core.windows.net<br/>→ Private IP"]
        DNS_QUEUE["*.queue.core.windows.net<br/>→ Private IP"]
        DNS_VAULT["*.vaultcore.azure.net<br/>→ Private IP"]
        DNS_ACR["*.azurecr.io<br/>→ Private IP"]
    end

    FUNC -->|"Private"| PE_COSMOS
    FUNC -->|"Private"| PE_BLOB
    FUNC -->|"Private"| PE_QUEUE

    WEB -->|"Private"| PE_KV
    API -->|"Private"| PE_KV
    API -->|"Private"| PE_ACR

    PE_COSMOS --> COSMOS
    PE_BLOB --> STORAGE
    PE_QUEUE --> STORAGE
    PE_KV --> KV
    PE_ACR --> ACR

    PE_COSMOS -.-> DNS_DOC
    PE_BLOB -.-> DNS_BLOB
    PE_QUEUE -.-> DNS_QUEUE
    PE_KV -.-> DNS_VAULT
    PE_ACR -.-> DNS_ACR

    style Apps fill:#c8e6c9
    style PrivateEndpoints fill:#bbdefb
    style Resources fill:#ffcdd2
    style DNS fill:#e1bee7
```

### Network Resource Inventory

| Resource | Type | Location | Address Space | Connected To |
|----------|------|----------|---------------|--------------|
| **m365migrate-dev-vnet-y7xmaa** | VNet | West Europe | 10.0.0.0/16 | - |
| ├─ functions-subnet | Subnet | West Europe | 10.0.1.0/24 | Azure Functions |
| └─ privatelink-subnet | Subnet | West Europe | 10.0.2.0/24 | Private Endpoints |
| **m365-maturity-portal-vnet** | VNet | North Europe | 10.0.0.0/16 | - |
| ├─ private-endpoints | Subnet | North Europe | 10.0.1.0/24 | Private Endpoints |
| └─ app-services | Subnet | North Europe | 10.0.2.0/24 | Web Apps |

### Private Endpoint Details

| Private Endpoint | Resource Group | Target Resource | Target Type | Subnet |
|------------------|----------------|-----------------|-------------|--------|
| m365migrate-dev-cosmos-pe | rg-m365migrate-dev | m365migrate-dev-cosmos | Cosmos DB | privatelink-subnet |
| m365migrate-dev-storage-pe-blob | rg-m365migrate-dev | stm365migrate | Storage (Blob) | privatelink-subnet |
| m365migrate-dev-storage-pe-queue | rg-m365migrate-dev | stm365migrate | Storage (Queue) | privatelink-subnet |
| m365kv-pe | rg-m365-maturity-portal | m365kv | Key Vault | private-endpoints |
| m365portal-pe | rg-m365-maturity-portal | m365portal | Container Registry | private-endpoints |

### Private DNS Zones

| DNS Zone | Resource Group | Linked VNets | Purpose |
|----------|----------------|--------------|---------|
| privatelink.documents.azure.com | rg-m365migrate-dev | m365migrate-dev-vnet | Cosmos DB |
| privatelink.blob.core.windows.net | rg-m365migrate-dev | m365migrate-dev-vnet | Blob Storage |
| privatelink.queue.core.windows.net | rg-m365migrate-dev | m365migrate-dev-vnet | Queue Storage |
| privatelink.vaultcore.azure.net | rg-m365-maturity-portal | m365-maturity-portal-vnet | Key Vault |
| privatelink.azurecr.io | rg-m365-maturity-portal | m365-maturity-portal-vnet | Container Registry |

### Network Security Posture

```mermaid
flowchart LR
    subgraph Public["Public Internet"]
        USER[("Users")]
    end

    subgraph Edge["Edge Security"]
        SWA_SEC["Static Web Apps<br/>Built-in DDoS<br/>TLS 1.2+"]
    end

    subgraph AppLayer["Application Layer"]
        FUNC_SEC["Azure Functions<br/>Auth/AuthZ<br/>Managed Identity"]
        WEB_SEC["Web Apps<br/>Auth/AuthZ<br/>Managed Identity"]
    end

    subgraph DataLayer["Data Layer (Private Only)"]
        COSMOS_SEC["Cosmos DB<br/>🔒 Private Endpoint Only<br/>RBAC Enabled"]
        KV_SEC["Key Vault<br/>🔒 Private Endpoint Only<br/>RBAC Enabled"]
        STORAGE_SEC["Storage<br/>🔒 Private Endpoint Only<br/>Encryption at Rest"]
        ACR_SEC["Container Registry<br/>🔒 Private Endpoint Only<br/>Content Trust"]
    end

    USER --> SWA_SEC
    USER --> FUNC_SEC
    USER --> WEB_SEC

    FUNC_SEC -->|"Private Link"| COSMOS_SEC
    FUNC_SEC -->|"Private Link"| STORAGE_SEC
    WEB_SEC -->|"Private Link"| KV_SEC
    WEB_SEC -->|"Private Link"| ACR_SEC

    style Public fill:#ffebee
    style Edge fill:#e8f5e9
    style AppLayer fill:#e3f2fd
    style DataLayer fill:#f3e5f5
```

### Network Recommendations

| Area | Current State | Recommendation | Priority |
|------|---------------|----------------|----------|
| **VNet Peering** | No peering between VNets | Consider peering if cross-region communication needed | Low |
| **NSGs** | Not detected | Add NSGs to subnets for granular traffic control | Medium |
| **Azure Firewall** | Not deployed | Consider for centralized egress control | Low |
| **DDoS Protection** | Standard (platform) | Consider DDoS Protection Standard for production | Medium |
| **Private DNS** | Configured per VNet | Consider centralized Private DNS Hub | Low |
| **Service Endpoints** | Not used | Already using Private Endpoints (better) | N/A |

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
