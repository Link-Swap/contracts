# LinkSwap Contracts

### `/chainlink`

Cross-Chain Token Transfer and Oracles Communication with Off-Chain and Cross-Chain Validation. LinkSwap uses the `CCIPTokenTransfer.sol` contract to ensure that tokens can be securely and efficiently transferred between different blockchain networks. By utilizing CCIP, LinkSwap provides a reliable way to move any compatible tokens and cryptocurrencies. Additionally, the `FunctionsConsumer.sol` contract plays a crucial role in facilitating communication between on-chain and off-chain environments. It is used to validate cross-chain token transfers by querying oracles for necessary information such as token approvals, liquidity, and fund availability on both the source and destination chains. This validation ensures that all conditions are met before a cross-chain transaction is executed, enhancing security and reliability.


### `/automation`
The main contract, `LogWithCCIP.sol`, is utilized for the execution of CCIP and Chainlink Functions. It listens for events from successful Chainlink Functions (`FunctionsConsumer.sol`) to initiate a token transfer request, which is validated by Chainlink Functions. Chainlink Automation then triggers the CCIP contract to complete the transfer. This automation reduces the need for manual intervention and ensures timely and accurate processing of cross-chain transactions.

### `/parsers`
The contracts include libraries and helper functions for the LinkSwap contracts. These are used to perform off-chain parsing and deserialize data, providing essential tools for developers.

### `/util`
These contracts manage the LSWAP tokens for faucet and minting, as well as the token list for the LinkSwap platform. They ensure decentralized and accurate mappings of cross-chain tokens.

### `/utils`
Libraries and helper functions for the LinkSwap contracts.

## Installation

*npm coming soon!*

## Deployed Contracts

### CCIP 
```json
{
	"Fuji": "0x140Fc5EE41087B22EB03d009Ba76b74B22a298E3",
	"Amoy": "0x87Bca54F5e4D8DfC7C66d28441F815926BA21192",
	"Sepolia": "0xE42362e2C2226A881070C48e57f6Cd10748E1dF6",
	"Base": "0x53B10f104a0739667504964F9b4BBaF286161307",
	"Optimism": "0x1d967071A97597EeD3c10647EEcd86DE69feab61",
	"Arbitrum": "0x26EF677d60e6715bD052eB5BdB080A8E033e1C17",
	"BNB": "0xb1a8ED6906bD10895Ae7D96569A0310e47c85Be5",
	"Gnosis": "0xeDd5e3333fe570cc54a3d6e26DD009de571126AD",
	"Wemix": "",
	"Celo": "0x0c2549DB92613ED09AC65aE467bFc60Da7e6910C",
}
```

### Function Consumer
```json
{
	"Fuji": "0x49c98D6f68d172AC33E68Fb9EE1cFc572424E1AF",
	"Amoy": "0x954F6444716f08Bc8E8De546AAb787adaBCD8BBE",
	"Sepolia": "0xfA7ffa38B6E89d7e57B4ecf1a4545508f858224C",
	"Optimism": "0x48BC8F854e0eaA573e47679975994eC070e58BFD",
}
```

### UpKeepers
```json
{
	"Fuji": "0xeFeE8e974e292359CF1ec2256c1e3cC9F6ff1497",
	"Amoy": "0xf15808035798381b86f66e0ba544daC11b5FDccb",
	"Sepolia": "0x9c5c014A81d79f86D946141bdFda5DEEE25Fc3F1",
	"Optimism": "0x322600C0F4DF1702AA8108766D3d21c9FcD53459",
}
```

---

## Mocked Tokens

### TokenList
```json
{
	"Fuji": "0xa1f384C7C4870cB9Ce83bf506029a6258F223B9b",
	"Amoy": "0xA96Ebd09F44f1ca1B4d5897FF98eDD1EA9D90590",
	"Sepolia": "0x755261cd44Bc905CaB714d349f41b10f6Fb5a40e",
	"Base": "0xc22dDc2EFeD83D99410b9296058401B2f9A4a177",
	"Optimism": "0xA96Ebd09F44f1ca1B4d5897FF98eDD1EA9D90590",
	"Arbitrum": "0xD9F812433Dd5ce28f7b7aD7b8FF189B65127C847",
	"BNB": "0xD9F812433Dd5ce28f7b7aD7b8FF189B65127C847",
	"Gnosis": "0xfeB362F2148F1303ea6Bf026d32071EA295e25ac",
	"Celo": "0xfeB362F2148F1303ea6Bf026d32071EA295e25ac"
}
```

### LSWAP
```json
{
	"Fuji": "0x6E91F576DEda25aD0CfE19C23aEf953c2eA59413",
	"Amoy": "0xfeB362F2148F1303ea6Bf026d32071EA295e25ac",
	"Sepolia": "0xa662f46804ab3ab3c764c81fe9c063ef811fae70",
	"Base": "0x608D532b14A1070577f01288e5FF3acC5E7F4798",
	"Optimism": "0xfeB362F2148F1303ea6Bf026d32071EA295e25ac",
	"Arbitrum": "0xfeB362F2148F1303ea6Bf026d32071EA295e25ac",
	"BNB": "0xfeB362F2148F1303ea6Bf026d32071EA295e25ac",
	"Gnosis": "0xD9F812433Dd5ce28f7b7aD7b8FF189B65127C847",
	"Celo": "0xD9F812433Dd5ce28f7b7aD7b8FF189B65127C847",
}
```

### Link Swap BAT
```json
{
	"Fuji": "",
	"Amoy": "0xF22114E0945319755E5b876C1cc4f8A8cFbB1639",
	"Sepolia": "0x980c4089bd4dd3e74af9ff18e8bdb1a0344608a1",
	"Base": "0xaff3b785227Cc8236806F584b68d1228ac99186c",
	"Optimism": "0xeDd5e3333fe570cc54a3d6e26DD009de571126AD",
	"Arbitrum": "",
	"BNB": "",
	"Gnosis": "",
}
```

### Link Swap UNI
```json
{
	"Fuji": "0x1F3B2aB5a9Be6FDB765E3d1064383F1E411B5010",
	"Amoy": "0x5d3aab4ff526FCD787A1e2d283E707a4c7a0E68C",
	"Sepolia": "0xb9dC04fB2E58d9ea635484427732369FBEbdb412",
	"Base": "",
	"Optimism": "",
	"Arbitrum": "0x54716e4dfE230cA2A11337Cc307D4FEa82142A56",
	"BNB": "",
	"Gnosis": "",
}
```
