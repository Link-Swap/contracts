// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";

import "../utils/FunctionsParser.sol";
import "./CCIPTokenTransfer.sol";

contract FunctionsConsumer is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;
    using SafeERC20 for IERC20;

    bytes32 public donId; // DON ID for the Functions DON to which the requests are sent

    bytes public s_lastError;
    bytes public s_lastResponse;
    bytes32 public s_lastRequestId;

    struct RequestInfo {
        address payer;
        string ccipData;
    }
    mapping(bytes32 => RequestInfo) public requests;
    mapping(address => uint256) public historyCounter;
    mapping(address => mapping(uint256 => bytes32)) public history;

    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.
    error NothingToWithdraw(); // Used when trying to withdraw Ether but there's nothing to withdraw.
    error FailedToWithdrawEth(address owner, address target, uint256 value); // Used when the withdrawal of Ether fails.
    error UnexpectedRequestID(bytes32 requestId);

    event Response(
        bytes32 indexed requestId,
        uint256 ccipData,
        bytes ccipArgs,
        address payer
    );

    CCIPTokenTransfer public ccipContract;

    constructor(
        address router,
        bytes32 _donId,
        address ccipAddress
    ) FunctionsClient(router) ConfirmedOwner(msg.sender) {
        donId = _donId;
        ccipContract = CCIPTokenTransfer(payable(ccipAddress));
    }

    /**
     * @notice Set the DON ID
     * @param newDonId New DON ID
     */
    function setDonId(bytes32 newDonId) external onlyOwner {
        donId = newDonId;
    }

    /**
     * @notice Set CCIP. Note this should not have setter in mainnet
     * @param ccipAddress New DON ID
     */
    function setCCIPContract(address ccipAddress) external onlyOwner {
        ccipContract = CCIPTokenTransfer(payable(ccipAddress));
    }

    /**
     * @notice Send a simple request
     * @notice any can call this. Only way to activate CCIP token transfer
     * @param source JavaScript source code
     * @param encryptedSecretsUrls Encrypted URLs where to fetch user secrets
     * @param donHostedSecretsSlotID Don hosted secrets slotId
     * @param donHostedSecretsVersion Don hosted secrets version
     * @param args List of arguments accessible from within the source code
     * @param bytesArgs Array of bytes arguments, represented as hex strings
     * @param subscriptionId Billing ID
     */
    function sendRequest(
        string memory source,
        bytes memory encryptedSecretsUrls,
        uint8 donHostedSecretsSlotID,
        uint64 donHostedSecretsVersion,
        string[] memory args,
        bytes[] memory bytesArgs,
        uint64 subscriptionId,
        uint32 gasLimit
    ) external returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        if (encryptedSecretsUrls.length > 0)
            req.addSecretsReference(encryptedSecretsUrls);
        else if (donHostedSecretsVersion > 0) {
            req.addDONHostedSecrets(
                donHostedSecretsSlotID,
                donHostedSecretsVersion
            );
        }
        if (args.length > 0) req.setArgs(args);
        if (bytesArgs.length > 0) req.setBytesArgs(bytesArgs);
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donId
        );

        // We need to store the ccipData for after the request to send to ccip
        requests[s_lastRequestId].payer = msg.sender;
        requests[s_lastRequestId].ccipData = args[0];

        return s_lastRequestId;
    }

    /**
     * @notice Send a pre-encoded CBOR request
     * @param request CBOR-encoded request data
     * @param subscriptionId Billing ID
     * @param gasLimit The maximum amount of gas the request can consume
     * @param donID ID of the job to be invoked
     * @return requestId The ID of the sent request
     */
    function sendRequestCBOR(
        bytes memory request,
        uint64 subscriptionId,
        uint32 gasLimit,
        bytes32 donID
    ) external onlyOwner returns (bytes32 requestId) {
        s_lastRequestId = _sendRequest(
            request,
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }

    /**
     * @notice Store latest result/error
     * @param requestId The request ID, returned by sendRequest()
     * @param response Aggregated response from the user code
     * @param err Aggregated error from the user code or from the execution pipeline
     * Either response or error parameter will be set, but never both
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId);
        }

        RequestInfo memory data = requests[requestId];
        require(bytes(data.ccipData).length > 0, "Invalid request ID");
        require(data.payer != address(0), "Invalid payer");

        s_lastResponse = response;
        s_lastError = err;

        // @notice This will be for future when we either improve to fix gas limit.
        // This will remove the need for Chainlink Automation :)
        // Validation should have passed and got all necessary data to process CCIP
        // FunctionsParser.CCIPArgs memory args = FunctionsParser.parseAsString(
        //     string(abi.encodePacked(response))
        // );
        // ccipContract.sendMessagePayLINK(
        //     args.destinationChainSelector,
        //     args.receiver,
        //     data.ccipData,
        //     data.payer
        // );

        emit Response(
            requestId,
            stringToUint256(data.ccipData),
            response,
            data.payer
        );

        // Reset information and audit
        requests[requestId].payer = address(0);
        requests[requestId].ccipData = "";

        historyCounter[data.payer]++;
        history[data.payer][historyCounter[data.payer]] = requestId;
    }

    /**
     * @dev converts a string memory to uint256 type
     * @notice very expensive and may fail
     */
    function stringToUint256(string memory data)
        internal
        pure
        returns (uint256)
    {
        uint256 val = 0;
        bytes memory b = bytes(data);
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                val = val * 10 + (c - 48);
            }
        }

        return val;
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
