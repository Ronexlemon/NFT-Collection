const {ethers} = require("hardhat");
require("dotenv").config({path: ".env"});
const whitelistcontract = process.env.WhitelistContractAddress;
const metadataurl = process.env.METADATA_URL;

async function main(){
    //get the contract
    const cryptoDevsContract = await ethers.getContractFactory("CryptoDevs");
    //deploy th contract
    const cryptoDevsContractDeploy = await cryptoDevsContract.deploy(
        metadataurl,
        whitelistcontract
    );
    //await for deployment
    await cryptoDevsContractDeploy.deployed();
    console.log("Crypto Devs Contract Address",cryptoDevsContractDeploy.address);
}
main()
.then(()=>process.exit(0))
.catch((error)=>{
    console.log(error);
    process.exit(1);
});