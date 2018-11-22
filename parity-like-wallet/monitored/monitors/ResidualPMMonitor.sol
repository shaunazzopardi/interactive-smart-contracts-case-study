pragma solidity ^0.4.21;

import "./MonitoredWalletLibrary.sol";

contract ResidualPMMonitor is MonitoredWalletLibraryStorage{
    enum state {INIT, AFTERINIT, AFTEREXECUTE}
    state current;
    //monitoring variable
    mapping(address => bool) owners;
    uint limit;

    function exitInitWallet(uint _limit){
        if(current == state.INIT){
            for(uint i = 0; i < uint(m_owners.length); i++){
                owners[address(m_owners[i])] = true;
            }
            limit = _limit;
            current = state.AFTERINIT;
        }
    }

    function setTransactionLimit(uint _limit){
        if(current == state.AFTERINIT){
            limit = _limit;
            current = state.AFTERINIT;
        }
    }
    
    function exitExecute(){
      if(current == state.AFTEREXECUTE){
          current = state.AFTERINIT;
      }
    }
    
    //don't need to use ids to match exit and entry of same function, since by analysis of code there is no recursion
    function entryExecute(uint _value){
        if(current == state.AFTERINIT){
            if(_value > limit 
            || !owners[msg.sender]){
                current = state.AFTEREXECUTE;
            }
        }
    }
    
    function exitSendEther(){
        if(current == state.AFTEREXECUTE){
            revert();
        }
    }
}
