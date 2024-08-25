// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

/**
 * @title DEX Template
 * @author stevepham.eth and m00npapi.eth
 * @notice Empty DEX.sol that just outlines what features could be part of the challenge (up to you!)
 * @dev We want to create an automatic market where our contract will hold reserves of both ETH and 🎈 Balloons. These reserves will provide liquidity that allows anyone to swap between the assets.
 * NOTE: functions outlined here are what work with the front end of this challenge. Also return variable names need to be specified exactly may be referenced (It may be helpful to cross reference with front-end code function calls).
 */
contract DEX {
	/* ========== GLOBAL VARIABLES ========== */

	IERC20 token; //instantiates the imported contract

	/* ========== EVENTS ========== */

	/**
	 * @notice Emitted when ethToToken() swap transacted
	 */
	event EthToTokenSwap(
		address swapper,
		uint256 tokenOutput,
		uint256 ethInput
	);

	/**
	 * @notice Emitted when tokenToEth() swap transacted
	 */
	event TokenToEthSwap(
		address swapper,
		uint256 tokensInput,
		uint256 ethOutput
	);

	/**
	 * @notice Emitted when liquidity provided to DEX and mints LPTs.
	 */
	event LiquidityProvided(
		address liquidityProvider,
		uint256 liquidityMinted,
		uint256 ethInput,
		uint256 tokensInput
	);

	/**
	 * @notice Emitted when liquidity removed from DEX and decreases LPT count within DEX.
	 */
	event LiquidityRemoved(
		address liquidityRemover,
		uint256 liquidityWithdrawn,
		uint256 tokensOutput,
		uint256 ethOutput
	);

	/* ========== CONSTRUCTOR ========== */

	constructor(address token_addr) {
		token = IERC20(token_addr); //specifies the token address that will hook into the interface and be used through the variable 'token'
	}

	uint256 public totalLiquidity;
	mapping (address => uint256) public liquidity;

	/* ========== MUTATIVE FUNCTIONS ========== */

	/**
	 * @notice initializes amount of tokens that will be transferred to the DEX itself from the erc20 contract mintee (and only them based on how Balloons.sol is written). Loads contract up with both ETH and Balloons.
	 * @param tokens amount to be transferred to DEX
	 * @return totalLiquidity is the number of LPTs minting as a result of deposits made to DEX contract
	 * NOTE: since ratio is 1:1, this is fine to initialize the totalLiquidity (wrt to balloons) as equal to eth balance of contract.
	 */

	/**
	We want this function written in a way that when we send ETH and/or $BAL tokens through our front end or deployer script, the function will get those values from the contract and assign them onto the global variables we just defined.
	 */
	 //Calling init() will load our contract up with both ETH and Balloons.
	function init(uint256 tokens) public payable returns (uint256) {
		//check and prevent liquidity being added if the contract already has liquidity
		require(totalLiquidity == 0, "contract already has liquidity");
		//What should the value of totalLiquidity be, how do we access the balance that our contract has and assign the variable a value
		totalLiquidity == address(this).balance;
		//How would we assign our address the liquidity we just provided? How much liquidity have we provided? The totalLiquidity? Just half? Three quarters?
		liquidity[msg.sender] = totalLiquidity;
		//take care of the tokens init() is receiving. How do we transfer the tokens from the sender (us) to this contract address? 
		//How do we make sure the transaction reverts if the sender did not have as many tokens as they wanted to send?
		require(token.transferFrom(msg.sender, address(this), tokens), "hey you don't have that many tokens to send");
		//?? why do i have to return smth here?
		return totalLiquidity;
	}

	/**
	 * @notice returns yOutput, or yDelta for xInput (or xDelta)
	 * @dev Follow along with the [original tutorial](https://medium.com/@austin_48503/%EF%B8%8F-minimum-viable-exchange-d84f30bd0c90) Price section for an understanding of the DEX's pricing model and for a price function to add to your contract. You may need to update the Solidity syntax (e.g. use + instead of .add, * instead of .mul, etc). Deploy when you are done.
	 */
	function price(
		uint256 xInput,
		uint256 xReserves,
		uint256 yReserves
	) public pure returns (uint256 yOutput) {
		//We are multiplying xInput by 997 to "simulate" a multiplication by 0.997 since we can't use decimals in solidity. We'll divide by 1000 later to get the fee back to normal.
		uint256 xInputWithFee = xInput * 997;
		//Next, we'll make our numerator by multiplying xInputWithFee by yReserves.
		uint256 numerator = xInputWithFee * yReserves;
		//Then our denominator will be xReserves multiplied by 1000 (to account for the 997 in the numerator) plus xInputWithFee.
		uint256 denominator = (xReserves * 1000) + xInputWithFee;
		//Last, we will return the numerator / denominator which is our yOutput, or the amount of swapped
		return (numerator / denominator);
	}

	/**
	 * @notice returns liquidity for a user.
	 * NOTE: this is not needed typically due to the `liquidity()` mapping variable being public and having a getter as a result. This is left though as it is used within the front end code (App.jsx).
	 * NOTE: if you are using a mapping liquidity, then you can use `return liquidity[lp]` to get the liquidity for a user.
	 * NOTE: if you will be submitting the challenge make sure to implement this function as it is used in the tests.
	 */
	function getLiquidity(address lp) public view returns (uint256) {
		return liquidity[lp];
	}

	/**
	 * @notice sends Ether to DEX in exchange for $BAL
	 */


	/**
	We can call tokenToEth and it will take our tokens and send us ETH or we can call ethToToken with some ETH in the transaction and it will send us $BAL tokens. */
	 //The basic overview for ethToToken() is we're going to define our variables to pass into price() so we can calculate what the user's tokenOutput is.
	function ethToToken() public payable returns (uint256 tokenOutput) {
		//How would we make sure the value being swapped for balloons is greater than 0?
	require(msg.value > 0, "the value should be more than 0");
		//?? Is xReserves ETH or $BAL tokens? Use a variable name that best describes which one it is. When we call this function, it will already have the value we sent it in it's liquidity. How can we make sure we are using the balance of the contract before any ETH was sent to it?
	uint256 ethReserve = address(this).balance - msg.value;
		//?? For yReserves we will also want to create a new more descriptive variable name. How do we find the other asset balance this address has?
	uint256 token_reserve = token.balanceOf(address(this)); 
		//Now that we have all our arguments, how do we call price() and store the returned value in a new variable? What kind of name would best describe this variable?
		tokenOutput = price(msg.value, ethReserve, token_reserve);
		//After getting how many tokens the sender should receive, how do we transfer those tokens to the sender?
		require(token.transfer(msg.sender, tokenOutput), "you dont have enough tokens to transfer");
		//Which event should we emit for this function?
		//EthToTokenSwap:
		//address swapper,
		//uint256 tokenOutput,
		//uint256 ethInput
		emit EthToTokenSwap(msg.sender, tokenOutput, msg.value );
		//Last, what do we return?
		return tokenOutput;
	}

	/**
	 * @notice sends $BAL tokens to DEX in exchange for Ether
	 */
	function tokenToEth(
		uint256 tokenInput
	) public returns (uint256 ethOutput) {
		//How would we make sure the value being swapped for ETH is greater than 0?
		require(tokenInput > 0, "the value swapped should be more than 0 you cannot swap less");
		// Is xReserves ETH or $BAL tokens this time? Use a variable name the describes which one it is.
		uint token_reserve = token.balanceOf(address(this));
		//For yReserves we will also want to create a new and more descriptive variable name. How do we find the other asset balance this address has?
		//Now that we have all our arguments, how do we call price() and store the returned value in a new variable?
		ethOutput = price(tokenInput, token_reserve, address(this).balance);
		//?? After getting how much ETH the sender should receive, how do we transfer the ETH to the sender?
        require(token.transferFrom(msg.sender, address(this), tokenInput), "tokenToEth(): reverted swap.");
		(bool sent, ) = msg.sender.call{ value: ethOutput }("");
		require(sent, "tokenToEth: revert in transferring eth to you!");
 
		//Which event do we emit for this function?
		/**
		event TokenToEthSwap(
		address swapper,
		uint256 tokensInput,
		uint256 ethOutput
	); */
		emit TokenToEthSwap(msg.sender, tokenInput, ethOutput);
		//Lastly, what are we returning?
		return ethOutput;
		/**
		Each of these functions should calculate the resulting amount of output asset using our price function that looks at the ratio of the reserves vs the input asset. We can call tokenToEth and it will take our tokens and send us ETH or we can call ethToToken with some ETH in the transaction and it will send us $BAL tokens. Deploy it and try it out!
		 */
	}

	/**
	 * @notice allows deposits of $BAL and $ETH to liquidity pool
	 * NOTE: parameter is the msg.value sent with this function call. That amount is used to determine the amount of $BAL needed as well and taken from the depositor.
	 * NOTE: user has to make sure to give DEX approval to spend their tokens on their behalf by calling approve function prior to this function call.
	 * NOTE: Equal parts of both assets will be removed from the user's wallet with respect to the price outlined by the AMM.
	 */
	function deposit() public payable returns (uint256 tokensDeposited) {
		//Part 1: Getting Reserves
		//How do we ensure the sender isn't sending 0 ETH?
		require(msg.value > 0, "you cannot send less than 0 eth");
		//We need to calculate the ratio of ETH and $BAL after the liquidity provider sends ETH, what variables do we need? It's similar to the previous section. 
		//What was that operation we performed on ethReserve in Checkpoint 4 to make sure we were getting the balance before the msg.value went through? We need to do that again for the same reason.
		uint256 ethReserve = address(this).balance - msg.value;
		//What other asset do we need to declare a reserve for, and how do we get its balance in this contract?
		uint256 token_reserve = token.balanceOf(address(this));
		//Part 2: Performing Calculations
		//What are we calculating again? Oh yeah, for the amount of ETH the user is depositing, we want them to also deposit a proportional amount of tokens. Let's make a reusable equation where we can swap out a value and get an output of the ETH and $BAL the user will be depositing, named tokenDeposit and liquidityMinted.

		//How do we calculate how many tokens the user needs to deposit? You multiply the value the user sends through by reserves of the units we want as an output. Then we divide by ethReserve and add 1 to the result.
		//?? why do i have to declare it first whats is the difference. also why didnt i have to do it for liquidityMinted?
		uint256 tokenDeposit;
		tokenDeposit = (msg.value * token_reserve / ethReserve) + 1;
		//Now for liquidityMinted use the same equation but replace tokenReserve with totalLiquidity, so that we are multiplying in the numerator by the units we want.
		uint256 liquidityMinted = msg.value * totalLiquidity / ethReserve;
		//console.log("liq mint: ",liquidityMinted, "total liq",totalLiquidity)
	//Part 3: Updating, Transferring, Emitting, and Returning
	//Now that the DEX has more assets, should we update our two global variables? How do we update liquidity?
	liquidity[msg.sender] += liquidityMinted;
	//How do we update totalLiquidity?
	totalLiquidity += liquidityMinted;
	//The user already deposited their ETH, but they still have to deposit their tokens. How do we require a token transfer from them?
	//?? i dont get the syntax of this require. why there is no "blablabla"
	require(token.transferFrom(msg.sender, address(this), tokenDeposit));
	//We just completed something important, which event should we emit?
	/**
	event LiquidityProvided(
		address liquidityProvider,
		uint256 liquidityMinted,
		uint256 ethInput,
		uint256 tokensInput
	); */
	//?? what is what and why
	emit LiquidityProvided(msg.sender, liquidityMinted, msg.value, tokenDeposit);
	//What do we return?
	return tokensDeposited;

	}

	/**
	 * @notice allows withdrawal of $BAL and $ETH from liquidity pool
	 * NOTE: with this current code, the msg caller could end up getting very little back if the liquidity is super low in the pool. I guess they could see that with the UI.
	 */
	 /**
	 The withdraw() function lets a user take his Liquidity Provider Tokens out, withdrawing both ETH and $BAL tokens out at the correct ratio. The actual amount of ETH and tokens a liquidity provider withdraws could be higher than what they deposited because of the 0.3% fees collected from each trade. It also could be lower depending on the price fluctuations of $BAL to ETH and vice versa (from token swaps taking place using your AMM!). The 0.3% fee incentivizes third parties to provide liquidity, but they must be cautious of Impermanent Loss (IL). */
	function withdraw(
		uint256 amount
	) public returns (uint256 eth_amount, uint256 token_amount) {
		//Part 1: Getting Reserves
		// How can we verify that a user is withdrawing an amount of liquidity that they actually have?
		//?? so who gets these errors from require statement and how and where
	require(liquidity[msg.sender] >= amount, "not enough liqudity to withdraw");
		//Just like the deposit() function we need both assets. How much ETH does our DEX have? Remember, this function is not payable, so we don't have to subtract anything.
		uint256 ethReserve = address(this).balance;
		//What is the value of tokenReserve?
		uint256 token_reserve = token.balanceOf(address(this));
		//Part 2: Performing Calculations
		//We need to calculate how much of each asset our user is going withdraw, call them ethWithdrawn and tokenAmount. The equation is: amount * reserveOfDesiredUnits / totalLiquidity
		//How do we get ethWithdrawn?
		//?? why do i have to declare it first ??
		uint256 ethWithdrawn;
		ethWithdrawn = amount * ethReserve / totalLiquidity;
		//How do we get tokenOutput?
		uint256 tokenAmount = amount * token_reserve / totalLiquidity;
		//Part 3: Updating, Transferring, Emitting, and Returning
		//The user is withdrawing, how do we represent this decrease in this individual's liquidity?
		liquidity[msg.sender] -= amount;
		//The DEX also lost liquidity, how should we update totalLiquidity?
		totalLiquidity -= amount;
		//How do you pay the user the value of ethWithdrawn?
		// ?? ugh
		(bool sent, ) = payable(msg.sender).call{ value: ethWithdrawn }("");
		require(sent, "withdraw wasnt successful");
		//How do we give them their tokens?
		require(token.transfer(msg.sender, tokenAmount));
		//We have an event to emit, which one?
		/**
		event LiquidityRemoved(
		address liquidityRemover,
		uint256 liquidityWithdrawn,
		uint256 tokensOutput,
		uint256 ethOutput
	); */
	//?? i dont understand this again
		emit LiquidityRemoved(msg.sender, amount, tokenAmount, ethWithdrawn);
		//Last, what are we returning?
		return (ethWithdrawn, tokenAmount);
	}
}
