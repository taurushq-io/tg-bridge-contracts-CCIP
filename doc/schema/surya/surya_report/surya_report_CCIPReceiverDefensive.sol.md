## Sūrya's Description Report

### Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| ./bridge/modules/wrapper/CCIPReceiverDefensive.sol | [object Promise] |


### Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CCIPReceiverDefensive** | Implementation | CCIPReceiverInternal, AuthorizationModule |||
| └ | getLastReceivedMessageDetails | Public ❗️ |   |NO❗️ |
| └ | getFailedMessagesIds | External ❗️ |   |NO❗️ |
| └ | retryFailedMessage | External ❗️ | 🛑  | onlyRole |
| └ | setSimRevert | Public ❗️ | 🛑  | onlyRole |
| └ | supportsInterface | Public ❗️ |   |NO❗️ |


### Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
