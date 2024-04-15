## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./bridge/CCIPBaseReceiver.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CCIPBaseReceiver** | Implementation | CCIPAllowlistedChain, CCIPReceiverDefensive, CCIPRouterManage |||
| └ | ccipReceive | External ❗️ | 🛑  | onlyRouter onlyAllowlisted |
| └ | processMessage | External ❗️ | 🛑  | onlySelf onlyAllowlisted |
| └ | _ccipReceive | Internal 🔒 | 🛑  | |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
