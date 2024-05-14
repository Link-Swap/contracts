// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./FunctionDataParser.sol";

contract FunctionDataParserContract {
    function packCCIPArgsAsBytes(
        uint64 _destinationChainSelector,
        address _receiver
    ) public pure returns (bytes memory) {
        return
            FunctionDataParser._packCCIPArgsAsBytes(
                _destinationChainSelector,
                _receiver
            );
    }

    function packCCIPArgsAsBytes32(
        uint64 _destinationChainSelector,
        address _receiver
    ) public pure returns (bytes32) {
        return
            FunctionDataParser._packCCIPArgsAsBytes32(
                _destinationChainSelector,
                _receiver
            );
    }

    function packCCIPArgs(uint64 _destinationChainSelector, address _receiver)
        public
        pure
        returns (uint256)
    {
        return
            FunctionDataParser._packCCIPArgs(
                _destinationChainSelector,
                _receiver
            );
    }

    function parseCCIPData(uint256 ccipArgs)
        public
        pure
        returns (FunctionDataParser.CCIPArgs memory)
    {
        return FunctionDataParser._parseCCIPData(ccipArgs);
    }

    function parseCCIPDataAsBytes(bytes32 ccipArgs)
        public
        pure
        returns (FunctionDataParser.CCIPArgs memory)
    {
        return FunctionDataParser._parseCCIPDataAsBytes32(ccipArgs);
    }

    function parseCCIPDataAsBytesMemory(bytes memory ccipArgs)
        public
        pure
        returns (FunctionDataParser.CCIPArgs memory)
    {
        return FunctionDataParser._parseCCIPDataAsBytes(ccipArgs);
    }
}
