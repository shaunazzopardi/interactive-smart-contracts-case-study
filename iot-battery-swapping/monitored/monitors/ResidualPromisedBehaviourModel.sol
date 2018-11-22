import "./MonitoredBatterySwappingStation.sol";

contract PromisedBehaviourMonitor is MonitoredBatterySwappingStationStorage{
    enum state{INIT, AFTERENTRY, BAD, AFTERSETID, AFTERSETCHARGE, AFTEREXIT}
    
    state current;
    
    uint newBatt;
    
    function recordEntry(){
        if(current == state.INIT){
            current = state.AFTERENTRY;
        }
    }
    
    function recordExit(){
        if(current == state.AFTERENTRY
            || current == state.AFTERSETID
            || current == state.AFTERSETCHARGE){
            current = state.BAD;
            revert();
        } else if(current == state.AFTERSETCHARGE){
            if(batteryIDInfo[newBatt].energyLevel > 95){
                current = state.AFTEREXIT;
            } else if(batteryIDInfo[newBatt].energyLevel <= 95){
                current = state.BAD;
            }
        }
    }
    
    function recordSetID(uint battID){
        if(current == state.AFTERENTRY){
            current = state.AFTERSETID;            
            newBatt = battID;
        }
    }
    
    function recordSetCharge(){
        if(current == state.AFTERSETID){
            current = state.AFTERSETCHARGE;
        }
    }
}