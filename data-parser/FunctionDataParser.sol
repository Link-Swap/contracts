// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

library FunctionDataParser {
    struct CCIPArgs {
        uint64 destinationChainSelector;
        address receiver;
        // 32 bytes remaining for payload
    }

    function _packCCIPArgsAsBytes(
        uint64 _destinationChainSelector,
        address _receiver
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                _packCCIPArgsAsBytes32(_destinationChainSelector, _receiver)
            );
    }

    function _packCCIPArgsAsBytes32(
        uint64 _destinationChainSelector,
        address _receiver
    ) internal pure returns (bytes32) {
        return bytes32(_packCCIPArgs(_destinationChainSelector, _receiver));
    }

    function _packCCIPArgs(uint64 _destinationChainSelector, address _receiver)
        internal
        pure
        returns (uint256)
    {
        return uint160(_receiver) | (uint256(_destinationChainSelector) << 160);
    }

    function _parseCCIPData(uint256 ccipArgs)
        internal
        pure
        returns (CCIPArgs memory)
    {
        address reciever = address(uint160(ccipArgs));
        uint64 destinationChainSelector = uint64(ccipArgs >> 160);
        // uint32 forFuture = uint32(ccipData >> (160 + 32));
        return CCIPArgs(destinationChainSelector, reciever);
    }

    function _parseCCIPDataAsBytes32(bytes32 ccipArgs)
        internal
        pure
        returns (CCIPArgs memory)
    {
        uint256 data = uint256(ccipArgs);
        return _parseCCIPData(data);
    }

    function _parseCCIPDataAsBytes(bytes memory ccipArgs)
        internal
        pure
        returns (CCIPArgs memory)
    {
        bytes32 data = abi.decode(ccipArgs, (bytes32));
        return _parseCCIPDataAsBytes32(data);
    }
}
