pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  YourToken public yourToken;

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
function buyTokens() public payable {
  /*
  The buyTokens() function in Vendor.sol should use msg.value and tokensPerEth to calculate an amount of tokens to yourToken.transfer() to msg.sender.
   */
   require(msg.value >0, "send eth to buy tokens");
   uint256 amountOfTokens = msg.value * tokensPerEth;
   require(yourToken.balanceOf(address(this))>=amountOfTokens, "vendor has insufficient tokens");
(bool sent) = yourToken.transfer(msg.sender, amountOfTokens);
require(sent, "failed to transfer tokens to users");
  emit BuyTokens(msg.sender, msg.value, amountOfTokens);
}

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
function withdraw() public onlyOwner {
  uint256 ownerBalance = address(this).balance;
  require(ownerBalance > 0, "owner has no balance to withdraw");

  (bool sent,) = msg.sender.call{value: ownerBalance}("");
  require(sent, "Failed to send user balance back to the owner");

  //payable(owner()).transfer(address(this).balance);
}

  // ToDo: create a sellTokens(uint256 _amount) function:
  function sellTokens(uint256 _amount) public {
    require(_amount > 0, "Specify an amount of tokens greater than zero");

    uint256 allowance = yourToken.allowance(msg.sender, address(this));
    require(allowance >= _amount, "Check the token allowance");

    uint256 userBalance = yourToken.balanceOf(msg.sender);
    require(userBalance >= _amount, "Your balance is lower than the amount of tokens you want to sell");

    uint256 amountOfETH = _amount / tokensPerEth;
    require(address(this).balance >= amountOfETH, "Vendor has insufficient funds to buy");

    bool sent = yourToken.transferFrom(msg.sender, address(this), _amount);
    require(sent, "Failed to transfer tokens from user to vendor");

    (sent,)=msg.sender.call{value: amountOfETH}("");
    require(sent, "Failed to send ETH to the user");


  emit SellTokens(msg.sender, _amount, amountOfETH);
  }
}

