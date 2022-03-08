import { ethers, upgrades } from "hardhat";

// var Oracle // TODO
// var TombTaxOracle // TODO

async function main() {
  // const EctoFactory = await ethers.getContractFactory("Ecto");
  // const Ecto = await EctoFactory.deploy("0", "0x44A33a4a822194d3C8402629932dd88B0FF49b09");
  // await Ecto.deployed();
  // console.log("Ecto deployed to:", Ecto.address);

  // const EShareFactory = await ethers.getContractFactory("EShare");
  // const EShare = await EShareFactory.deploy("1646678000", "0x44A33a4a822194d3C8402629932dd88B0FF49b09");
  // await EShare.deployed();
  // console.log("EShare deployed to:", EShare.address);

  // const EBondFactory = await ethers.getContractFactory("EBond");
  // const EBond = await EBondFactory.deploy();
  // await EBond.deployed();
  // console.log("EBond deployed to:", EBond.address);

  // const EctoGenesisRewardPoolFactory = await ethers.getContractFactory("EctoGenesisRewardPool");
  // const EctoGenesisRewardPool = await EctoGenesisRewardPoolFactory.deploy(Ecto.address, "1646678000");
  // await EctoGenesisRewardPool.deployed();
  // console.log("EctoGenesisRewardPool deployed to:", EctoGenesisRewardPool.address);

  // const EctoRewardPoolFactory = await ethers.getContractFactory("EctoRewardPool");
  // const EctoRewardPool = await EctoRewardPoolFactory.deploy(Ecto.address, "1646678000");
  // await EctoRewardPool.deployed();
  // console.log("EctoRewardPool deployed to:", EctoRewardPool.address);
  
  // const EShareRewardPoolFactory = await ethers.getContractFactory("EShareRewardPool");
  // const EShareRewardPool = await EShareRewardPoolFactory.deploy(EShare.address, "1646678000");
  // await EShareRewardPool.deployed();
  // console.log("EShareRewardPool deployed to:", EShareRewardPool.address);

  // const ZapFactory = await ethers.getContractFactory("Zap");
  // const Zap = await ZapFactory.deploy("0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83");
  // await Zap.deployed();
  // console.log("Zap deployed to:", Zap.address);


  //Oracle, EShareSwapper

  // const TaxOfficeFactory = await ethers.getContractFactory("TaxOfficeV2");
  // const TaxOffice = await TaxOfficeFactory.deploy();
  // await TaxOffice.deployed();
  // console.log("TaxOffice deployed to:", TaxOffice.address);

  const TreasuryFactory = await ethers.getContractFactory("Treasury");
  const Treasury = await TreasuryFactory.deploy();
  await Treasury.deployed();
  console.log("Treasury deployed to:", Treasury.address);

  const MasonryFactory = await ethers.getContractFactory("Masonry");
  const Masonry = await MasonryFactory.deploy();
  await Masonry.deployed();
  console.log("Masonry deployed to:", Masonry.address);
  Masonry.initialize("0x3Ccf8274A57dEa42E6538Dc0B53FAC5cf49e64cF", "0x617db1197eC80eB3E081125b6Fb424C3D9D09A6F", Treasury.address)

  // const OracleFactory = await ethers.getContractFactory("Oracle");
  // const Oracle = await OracleFactory.deploy("0x051D74152d772E7D24C58F536Ae2DF5163d8c751", "21600", "1646678000");
  // await Oracle.deployed();
  // console.log("Oracle deployed to:", Oracle.address);

  // const EShareSwapperFactory = await ethers.getContractFactory("EShareSwapper");
  // const EShareSwapper = await EShareSwapperFactory.deploy("0x3Ccf8274A57dEa42E6538Dc0B53FAC5cf49e64cF", "0xa911fe5126b2771142C1b2C3D8E13a33FB43FE27", "0x617db1197eC80eB3E081125b6Fb424C3D9D09A6F", "0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83", "0x051D74152d772E7D24C58F536Ae2DF5163d8c751", "0x6D658C69EA9814C7043b9208692c89472A534Dde", "0x44A33a4a822194d3C8402629932dd88B0FF49b09");
  // await EShareSwapper.deployed();
  // console.log("EShareSwapper deployed to:", EShareSwapper.address);


  // const EctoFactory = await ethers.getContractAt("EShare", "0x617db1197eC80eB3E081125b6Fb424C3D9D09A6F");
  // const resp = await EctoFactory.mint("0x44A33a4a822194d3C8402629932dd88B0FF49b09", "100000000000000000000");
  // console.log(resp);
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
