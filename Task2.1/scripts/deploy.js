async function main() {

  const Donation = await ethers.getContractFactory("Donation");
  // Start deployment, returning a promise that resolves to a contract object
  const donation = await Donation.deploy();   
  console.log("Contract Donation deployed to address:", donation.address);

  const NFT = await ethers.getContractFactory("NFT");
  // Start deployment, returning a promise that resolves to a contract object
  const nft = await NFT.deploy();   
  console.log("Contract NFT deployed to address:", nft.address);

}
main()
 .then(() => process.exit(0))
 .catch(error => {
   console.error(error);
   process.exit(1);
 });