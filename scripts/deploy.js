import hre from "hardhat";

async function main() {
    const Swift = await hre.ethers.getContractFactory("swift");
    // Start deployment, this address is hard-coded because we passed it as a constructor argument in the contract
    const swift = await Swift.deploy("0x7B937E88944f574028f1a02f9BaD5EEF40e73c5b");

    await swift.deployed();

    console.log("Swift deployed to:", swift.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});