import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Deploy LPToken
  const LPToken = await ethers.getContractFactory("LPToken");
  const lpToken = await LPToken.deploy(deployer.address);
  console.log("LPToken deployed to:", lpToken.target); // <- aquí usamos .target en v6

  // Deploy DAppToken
  const DAppToken = await ethers.getContractFactory("DAppToken");
  const dappToken = await DAppToken.deploy(deployer.address);
  console.log("DAppToken deployed to:", dappToken.target);

  // Deploy TokenFarm
  const TokenFarm = await ethers.getContractFactory("TokenFarm");
  const tokenFarm = await TokenFarm.deploy(dappToken.target, lpToken.target);
  console.log("TokenFarm deployed to:", tokenFarm.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
