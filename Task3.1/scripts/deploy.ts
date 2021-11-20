
import { ethers } from "hardhat";

async function main() {


  // We get the contracts to deploy
  const Donation = await ethers.getContractFactory("Donation");
  const donation = await Donation.deploy();

  await donation.deployed();

  console.log("Donation deployed to:", donation.address);

  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy();

  await nft.deployed();

  console.log("NFT deployed to:", nft.address)

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
