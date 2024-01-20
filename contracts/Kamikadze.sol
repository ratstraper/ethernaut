// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Kamikadze {
    constructor(address a) payable {
        selfdestruct(payable(a));
    }
}