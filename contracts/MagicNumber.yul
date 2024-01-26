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