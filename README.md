# Simple Token Farm - Proyecto DeFi Yield Farming

Este proyecto implementa un **Token Farm simple** al estilo DeFi usando Hardhat y Solidity, donde los usuarios pueden:

- Depositar tokens LP (`LPToken`)
- Reclamar recompensas en `DAppToken`
- Retirar sus tokens LP del staking

## Contratos incluidos

- `DAppToken.sol` → Token de recompensa de la plataforma (DAPP)
- `LPToken.sol` → Token mock LP que se stakea
- `TokenFarm.sol` → Contrato principal de staking y distribución de recompensas

## Requisitos

- Node.js ≥ 18
- npm ≥ 10
- Hardhat

---

## Instalación

1. Clonar el repositorio:

git clone https://github.com/DevCodeOK/simple-token-farm.git
cd simple-token-farm

2. Instalar dependencias:
npm install

3. Compilar los contratos:
npx hardhat compile

4. Despliegue en nodo local
4.1. Ejecutar un nodo local de Hardhat:
npx hardhat node

4.2. En otra terminal, desplegar los contratos:
npx hardhat run scripts/deploy.ts --network localhost

## Estructura del proyecto
├─ contracts/

│   ├─ DAppToken.sol

│   ├─ LPToken.sol

│   └─ TokenFarm.sol

├─ scripts/

│   └─ deploy.ts

├─ hardhat.config.ts

├─ package.json

└─ README.md

