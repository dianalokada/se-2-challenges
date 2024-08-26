// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

    event Stake(address indexed staker, uint256 amount);


  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
  mapping (address => uint256) public balances;

  uint256 public constant threshold = 1 ether;

  function stake() public payable {
    require(block.timestamp < deadline, "deadline has passed");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
  uint256 public deadline = block.timestamp + 72 hours;

  bool public openForWithdraw;

  modifier notCompleted () {
    require(!exampleExternalContract.completed(), "already executed");  
    _;
  }

  function execute() public notCompleted {
    require(block.timestamp >= deadline, "deadline not yet reached");
  
    if(address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
        openForWithdraw = true;
      }
    }

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
function withdraw() public notCompleted {
    require(openForWithdraw, "withdrawals are not open yet");
    uint256 userBalance = balances[msg.sender];
    require(userBalance>0, "no balance available to withdraw");
    balances[msg.sender]=0;
    // Call returns a boolean value indicating success or failure.
      // This is the current recommended method to use.
      (bool sent, ) = msg.sender.call{value: userBalance}("");
      require(sent, "Failed to send Ether");
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
function timeLeft() public view returns (uint256) {
    if(block.timestamp >= deadline) {
      return 0;
      } else {
        return deadline - block.timestamp;
      }
  }

  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }
}
