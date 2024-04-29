## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./bridge/CCIPBaseSender.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CCIPBaseSender** | Implementation | CCIPAllowlistedChain, CCIPSenderBuild, CCIPRouterManage |||
| └ | transferTokens | External ❗️ | 🛑  | onlyRole onlyAllowlistedDestinationChain |
| └ | transferTokensBatch | External ❗️ | 🛑  | onlyRole onlyAllowlistedDestinationChain |
| └ | _buildEndSend | Internal 🔒 | 🛑  | |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
