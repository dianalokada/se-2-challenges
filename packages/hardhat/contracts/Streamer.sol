// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

/**
Main Quests
🛣️ Build a packages/hardhat/contracts/Streamer.sol contract that collects ETH from numerous client addresses using a payable fundChannel() function and keeps track of balances.
💵 Exchange paid services off-chain between the packages/hardhat/contracts/Streamer.sol contract owner (the Guru) and rube clients with funded channels. The Guru provides the service in exchange for signed vouchers which can later be redeemed on-chain.
⏱ Create a Challenge mechanism with a timeout, so that rubes are protected from a Guru who goes offline while funds are locked on-chain (either by accident, or as a theft attempt).
⁉ Consider some security / usability holes in the current design.
 */

contract Streamer is Ownable {
  event Opened(address, uint256);
  event Challenged(address);
  event Withdrawn(address, uint256);
  event Closed(address);

  mapping(address => uint256) balances;
  mapping(address => uint256) canCloseAt;

  /**
  In our case, the service provider is a Guru who provides off-the-cuff wisdom to each client Rube through a one-way chat box. Each character of text that is delivered is expected to be compensated with a payment of 0.01 ETH.

  Rubes seeking wisdom will use a payable fundChannel() function, which will update this mapping with the supplied balance.
  mapping (address => uint256) balances;
   */
  function fundChannel() public payable {
    //reverts if msg.sender already has a running channel 
    require(balances[msg.sender] == 0, "Channel already funded");
    //updates the balances mapping with the eth received in the function call
    balances[msg.sender] += msg.value;
    //emits an Opened event
    emit Opened(msg.sender, msg.value);
  }
    /*
      Checkpoint 2: fund a channel

      Complete this function so that it:
      - reverts if msg.sender already has a running channel (ie, if balances[msg.sender] != 0)
      - updates the balances mapping with the eth received in the function call
      - emits an Opened event
    */

  function timeLeft(address channel) public view returns (uint256) {
    if (canCloseAt[channel] == 0 || canCloseAt[channel] < block.timestamp) {
      return 0;
    }

    return canCloseAt[channel] - block.timestamp;
  }

  function withdrawEarnings(Voucher calldata voucher) public {
    // like the off-chain code, signatures are applied to the hash of the data
    // instead of the raw data itself
    bytes32 hashed = keccak256(abi.encode(voucher.updatedBalance));

    // The prefix string here is part of a convention used in ethereum for signing
    // and verification of off-chain messages. The trailing 32 refers to the 32 byte
    // length of the attached hash message.
    //
    // There are seemingly extra steps here compared to what was done in the off-chain
    // `reimburseService` and `processVoucher`. Note that those ethers signing and verification
    // functions do the same under the hood.
    //
    // see https://blog.ricmoo.com/verifying-messages-in-solidity-50a94f82b2ca
    bytes memory prefixed = abi.encodePacked("\x19Ethereum Signed Message:\n32", hashed);
    bytes32 prefixedHashed = keccak256(prefixed);

    /*
      Checkpoint 4: Recover earnings

      The service provider would like to cash out their hard earned ether.
          - use ecrecover on prefixedHashed and the supplied signature
          - require that the recovered signer has a running channel with balances[signer] > v.updatedBalance
          - calculate the payment when reducing balances[signer] to v.updatedBalance
          - adjust the channel balance, and pay the Guru(Contract owner). Get the owner address with the `owner()` function.
          - emit the Withdrawn event
    */

    // Recover the signer's address using ecrecover
    address signer = ecrecover(prefixedHashed, voucher.v, voucher.r, voucher.s);
    // Check that the signer has a running channel with sufficient balance
    require(balances[signer] > voucher.updatedBalance, "Insufficient balance");
    // Calculate the payout
    uint256 payout = balances[signer] - voucher.updatedBalance;    
    // Update the channel balance
    balances[signer] = voucher.updatedBalance;
    // Send the payout to the Guru (contract owner)
    (bool success, ) = owner().call{value: payout}("");
    require(success, "Transfer to owner failed");
    // Emit the Withdrawn event
    emit Withdrawn(signer, payout);  
    }

  /*
    Checkpoint 5a: Challenge the channel

    Create a public challengeChannel() function that:
    - checks that msg.sender has an open channel
    - updates canCloseAt[msg.sender] to some future time
    - emits a Challenged event
  */
  function challengeChannel() public {
    //checks that msg.sender has an open channel
    require(balances[msg.sender] > 0, "No open channel");
    //updates canCloseAt[msg.sender] to some future time
    canCloseAt[msg.sender] = block.timestamp + 30 seconds;
    //emits a Challenged event
    emit Challenged(msg.sender);  
  }

  /*
    Checkpoint 5b: Close the channel

    Create a public defundChannel() function that:
    - checks that msg.sender has a closing channel
    - checks that the current time is later than the closing time
    - sends the channel's remaining funds to msg.sender, and sets the balance to 0
    - emits the Closed event
  */

  function defundChannel() public {
    //checks that msg.sender has a closing channel
    require(canCloseAt[msg.sender] > 0, "Channel not challenged");
    //checks that the current time is later than the closing time
    require(block.timestamp > canCloseAt[msg.sender], "Challenge period not over");
    //sends the channel's remaining funds to msg.sender, and sets the balance to 0
    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
    //emits the Closed event
    emit Closed(msg.sender);
  }

  struct Voucher {
    uint256 updatedBalance;
    Signature sig;
  }
  struct Signature {
    bytes32 r;
    bytes32 s;
    uint8 v;
  }
}
