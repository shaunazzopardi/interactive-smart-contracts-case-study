pragma solidity ^0.4.21;

import "./MonitoredWalletLibrary.sol";

contract ResidualEMMonitor is MonitoredWalletLibraryStorage{
    enum state {INIT, AFTERINIT, AFTEREXECUTE, BAD}
    state current;
    
    mapping(address => bool) owners;

    function exitInitWallet(){
        if(current == state.INIT){
            for(uint i = 0; i < uint(m_owners.length); i++){
                owners[address(m_owners[i])] = true;
            }
            current = state.AFTERINIT;
        }
    }
    
    function exitExecute(){
        if(current == state.AFTEREXECUTE){
            current = state.AFTERINIT;
        }
    }
    
    //don't need to use ids to match exit and entry of same function, since by analysis of code there is no recursion
    function entryExecute(){
        if(current == state.AFTERINIT){
            if(!owners[msg.sender]){
                current = state.AFTEREXECUTE;
            }
        }
    }
    
    function exitSendEther(){
        if(current == state.INIT
            || current == state.AFTEREXECUTE){
            revert();
        }
    }
}
