// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// interface Buyer {
//   function price() external view returns (uint);
// }

contract Shop {
  uint public price = 100;
  bool public isSold;

  function buy() public {
    Buyer _buyer = Buyer(msg.sender);

    if (_buyer.price() >= price && !isSold) {
      isSold = true;
      price = _buyer.price();
    }
  }
}

contract Buyer {
    Shop shop;
    constructor(address a) {
        shop = Shop(a);
    }

    function buy() external {
        shop.buy();
    }

    function price() external view returns (uint) {
        if(shop.isSold() == false) {
            return shop.price() + 10;
        } else {
            return shop.price() - 10;
        }
    }
}
