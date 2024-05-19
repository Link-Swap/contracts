// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../utils/FunctionsParser.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract EmitLog {
    event Response(
        bytes32 indexed requestId,
        uint256 ccipData,
        bytes ccipArgs,
        address payer
    );

    constructor() {}

    function emitCountLog(
        bytes32 requestId,
        uint256 ccipData,
        bytes memory response,
        address payer
    ) public {
        emit Response(requestId, ccipData, response, payer);
    }
}
