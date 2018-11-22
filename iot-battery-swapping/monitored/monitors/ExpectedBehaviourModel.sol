import "./MonitoredBatterySwappingStation.sol";

contract ExpectedBehaviourMonitor is MonitoredBatterySwappingStationStorage{
    enum state{INIT, AFTERENTRY, BAD, AFTERSETID, AFTEREXIT}
    
    state current;
    
    function recordEntry() returns (bool){
        if(current == state.INIT){
            current = state.AFTERENTRY;
        }
    }
    
    function recordExit(){
        if(current == state.AFTERENTRY){
            current = state.BAD;
        } else if(current == state.AFTERSETID){
            current = state.AFTEREXIT;
        }
    }
    
    function recordSetID(uint battID) returns (bool){
        if(current == state.AFTERENTRY){
            current = state.AFTERSETID;
        }
    }
}