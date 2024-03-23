# data for call/delegatecall
### js
const contractAddress = '0x7a65FdAb89cE1e8E5b939dB01f3fB6B9594E3849'; // Address of the contract to call
const functionSignature = 'transfer(address,uint256)'; // Function signature
const functionSelector = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(functionSignature)).substr(0, 10); // Take the first 8 characters (4 bytes)

//Encode the function arguments
const arguments = ethers.utils.defaultAbiCoder.encode(
  ['address', 'uint256'],
  ["0x123456789abcdef123456789abcdef123456789a", 1]
);

const encodedData = functionSelector + arguments;
//encodedData == 0xa9059cbb000000000000000000000000123456789abcdef123456789abcdef123456789a0000000000000000000000000000000000000000000000000000000000000001

### browser console 
let encodedData = _ethers.utils.keccak256(_ethers.utils.toUtf8Bytes("execute(address,uint256,bytes)")).substr(0,10) + _ethers.utils.defaultAbiCoder.encode([ "address", "uint256", "bytes" ], ['0xE60767C6ddFe11d3E84aFC1B7F773BD7901d3853', 1000000000001000, 0x00]).substr(2)
//encodedData == 0xb61d27f6000000000000000000000000e60767c6ddfe11d3e84afc1b7f773bd7901d385300000000000000000000000000000000000000000000000000038d7ea4c683e8000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000

### solidity
abi.encodeWithSignature("setMaxBalance(uint256)", uint256(uint160(_address)))


# read slots from contract

### foundry utilit
   >cast storage 0x04211b24785a79381A8565AD8ca65E56Afa8606B 5 --rpc-url "https://ethereum-sepolia.publicnode.com"
contract address \----------------------------------------/ |           |                                       |
slot number                                                 /           |                                       |
RPC                                                                     \---------------------------------------/