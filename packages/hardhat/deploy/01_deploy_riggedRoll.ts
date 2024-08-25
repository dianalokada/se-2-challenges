import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat/";
import { DiceGame, RiggedRoll } from "../typechain-types";

const deployRiggedRoll: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const diceGame: DiceGame = await ethers.getContract("DiceGame");
  const diceGameAddress = await diceGame.getAddress();

  await deploy("RiggedRoll", {
    from: deployer,
    log: true,
    args: [diceGameAddress],
    autoMine: true,
  });

//   const riggedRoll: RiggedRoll = await ethers.getContract("RiggedRoll", deployer);

//   // Please replace the text "Your Address" with your own address.
//   try {
//     await riggedRoll.transferOwnership("0x6A1a956e2C58298D1d4df38647e790925b0431e1");
//   } catch (err) {
//     console.log(err);
//   }
};

export default deployRiggedRoll;

deployRiggedRoll.tags = ["RiggedRoll"];
