import { ethers } from "hardhat";
import { pn } from "./utils";

async function main() {
  const TestToken = await ethers.getContractFactory("Currency");
  const testToken = await TestToken.deploy();
  const ownerTokenAddress = testToken.address;
  const masterTokenAddress = testToken.address;

  const CollectibleV1 = await ethers.getContractFactory("CollectibleV1");
  const contract = await CollectibleV1.deploy(
    "Test",
    "TEST",
    100,
    true,
    true,
    "http://local.dev",
    ownerTokenAddress,
    masterTokenAddress
  );

  const instance = await contract.deployed();
  const tx = instance.deployTransaction;
  const rec = await tx.wait();
  console.log(
    `CollectibleV1 deployed at ${instance.address}. Gas used: ${pn(
      rec.gasUsed
    )}`
  );
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
