contract BatteryUser{
    enum Quality {Low, Medium, High}

    struct BatteryInfo{
        uint id;
        bool complete;
        uint energyLevel; //as a percentage, so value should be from 0 to 100
        uint chargeLeftTime;
        
        Quality qualityOfBattery;
        
        address stationOriginator;
    }
    
    BatteryInfo empty = BatteryInfo(0, false, 0, 0, Quality.Low, 0);
}

contract BatterySwappingStation is BatteryUser{
    struct Swap{
        BatteryInfo batteryReceived;
        BatteryInfo batteryGiven;
        uint location;
        uint time;
        uint client;
    }
    
    Swap[] swaps;
    
    mapping(uint => BatteryInfo) batteryIDInfo;

    mapping(uint => BatteryType[]) batteryTypesAvailableAtLocations;
    mapping(uint => BatteryInfo[]) availableBatteriesOfType1AtLocations;
    mapping(uint => BatteryInfo[]) availableBatteriesOfType2AtLocations;
    mapping(uint => BatteryInfo[]) availableBatteriesOfType3AtLocations;
    
    uint[] batteriesBeingCharged;
    
    mapping(uint => uint) batteriesOut;
    
    enum BatteryType {TYPE1, TYPE2, TYPE3}
    
    mapping(uint => BatteryType) batteryIDToType;
    
    mapping(address => bool) customers;
    
    modifier fromCustomer(){
        require(customers[msg.sender]);
        _;
    }
    
    function requestBatterySwap(uint idBatteryToSwap, uint location) fromCustomer returns(bool){
        for(uint i = 0; i < batteryTypesAvailableAtLocations[location].length; i++){
            if(batteryTypesAvailableAtLocations[location][i] == batteryIDToType[idBatteryToSwap]){
                return true;
            }
        }
        
        return false;
    }
    
    function effectBatterySwap(uint idBatteryToSwap, uint location) fromCustomer returns(bool){
        BatteryInfo batteryToSwapOut;
        if(batteryIDToType[idBatteryToSwap] == BatteryType.TYPE1){
            uint lastIndex = availableBatteriesOfType1AtLocations[location].length - 1;
            batteryToSwapOut = availableBatteriesOfType1AtLocations[location][lastIndex];
        } else if(batteryIDToType[idBatteryToSwap] == BatteryType.TYPE2){
            lastIndex = availableBatteriesOfType2AtLocations[location].length - 1;
            batteryToSwapOut = availableBatteriesOfType2AtLocations[location][lastIndex];
        } else if(batteryIDToType[idBatteryToSwap] == BatteryType.TYPE3){
            lastIndex = availableBatteriesOfType3AtLocations[location].length - 1;
            batteryToSwapOut = availableBatteriesOfType3AtLocations[location][lastIndex];
        } else return false;
            
        bool success = msg.sender.call(bytes4(keccak256("setCurrentBatteryID(uint)")), batteryToSwapOut.id) &&
                msg.sender.call(bytes4(keccak256("setCurrentBatteryEnergyLevel(uint)")), batteryToSwapOut.energyLevel) &&
                msg.sender.call(bytes4(keccak256("setCurrentBatteryChargeLeft(uint)")), batteryToSwapOut.chargeLeftTime) &&
                msg.sender.call(bytes4(keccak256("setCurrentBatteryQuality(Quality)")), batteryToSwapOut.qualityOfBattery) &&
                msg.sender.call(bytes4(keccak256("setCurrentBatteryStationOriginator(address)")), address(this));
            
        if(success){
            batteriesBeingCharged.push(idBatteryToSwap);
                
            if(batteryIDToType[idBatteryToSwap] == BatteryType.TYPE1){
                availableBatteriesOfType1AtLocations[location][lastIndex] = empty;
            } else if(batteryIDToType[idBatteryToSwap] == BatteryType.TYPE2){
                availableBatteriesOfType2AtLocations[location][lastIndex] = empty;
            } else if(batteryIDToType[idBatteryToSwap] == BatteryType.TYPE3){
                availableBatteriesOfType3AtLocations[location][lastIndex] = empty;                }
        }
            
        return success;
    }
}