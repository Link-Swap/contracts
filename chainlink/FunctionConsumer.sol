// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";

import "../utils/FunctionsParser.sol";
import "./CCIPTokenTransfer.sol";

contract FunctionsConsumer is FunctionsClient, ConfirmedOwner {
    using FunctionsRequest for FunctionsRequest.Request;

    bytes32 public donId; // DON ID for the Functions DON to which the requests are sent

    bytes public s_lastError;
    bytes public s_lastResponse;
    bytes32 public s_lastRequestId;

    struct RequestInfo {
        address payer;
        string ccipData;
    }
    mapping(bytes32 => RequestInfo) private requests;

    error UnexpectedRequestID(bytes32 requestId);

    event Response(bytes32 indexed requestId, bytes response, bytes err);

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
    ) external onlyOwner returns (bytes32 requestId) {
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

        FunctionsParser.CCIPArgs memory args = FunctionsParser.parseAsString(
            string(abi.encodePacked(response))
        );

        // Validation should have passed and got all necessary data to process CCIP
        ccipContract.sendMessagePayLINK(
            args.destinationChainSelector,
            args.receiver,
            data.ccipData,
            data.payer
        );

        emit Response(requestId, s_lastResponse, s_lastError);
    }
}
