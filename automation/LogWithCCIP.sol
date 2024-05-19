// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ILogAutomation.sol";
import "../utils/FunctionsParser.sol";
import "../chainlink/CCIPTokenTransfer.sol";

import "@openzeppelin/contracts/utils/Strings.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";

contract LogWithCCIP is ILogAutomation, ConfirmedOwner {
    using SafeERC20 for IERC20;

    event CountedBy(address indexed msgSender, bytes32 messageId);

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
    error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.

    CCIPTokenTransfer public ccipContract;

    constructor(address ccipAddress) ConfirmedOwner(msg.sender) {
        ccipContract = CCIPTokenTransfer(payable(ccipAddress));
    }
    
    /**
     * @notice Set CCIP. Note this should not have setter in mainnet
     * @param ccipAddress New DON ID
     */
    function setCCIPContract(address ccipAddress) external onlyOwner {
        ccipContract = CCIPTokenTransfer(payable(ccipAddress));
    }

    function checkLog(Log calldata log, bytes memory)
        external
        pure
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = true;
        performData = log.data;
    }

    function performUpkeep(bytes calldata performData) external override {
        (uint256 ccipData, bytes memory ccipArgs, address payer) = abi.decode(
            performData,
            (uint256, bytes, address)
        );

        FunctionsParser.CCIPArgs memory args = FunctionsParser.parseAsString(
            string(abi.encodePacked(ccipArgs))
        );

        // Validation should have passed and got all necessary data to process CCIP
        bytes32 messageId = ccipContract.sendMessagePayLINK(
            args.destinationChainSelector,
            args.receiver,
            Strings.toString(ccipData),
            payer
        );

        emit CountedBy(payer, messageId);
    }

    /// @notice Fallback function to allow the contract to receive Ether.
    /// @dev This function has no function body, making it a default function for receiving Ether.
    /// It is automatically called when Ether is sent to the contract without any data.
    receive() external payable {}

    /// @notice Allows the contract owner to withdraw the entire balance of Ether from the contract.
    /// @dev This function reverts if there are no funds to withdraw or if the transfer fails.
    /// It should only be callable by the owner of the contract.
    /// @param _beneficiary The address to which the Ether should be sent.
    function withdraw(address _beneficiary) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = address(this).balance;

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        // Attempt to send the funds, capturing the success status and discarding any return data
        (bool sent, ) = _beneficiary.call{value: amount}("");

        // Revert if the send failed, with information about the attempted transfer
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    /// @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token.
    /// @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    /// @param _beneficiary The address to which the tokens will be sent.
    /// @param _token The contract address of the ERC20 token to be withdrawn.
    function withdrawToken(address _beneficiary, address _token)
        public
        onlyOwner
    {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).safeTransfer(_beneficiary, amount);
    }
}
