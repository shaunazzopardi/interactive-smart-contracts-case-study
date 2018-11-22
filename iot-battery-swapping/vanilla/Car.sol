
contract Owned{
  address owner;
  
  function Owner(){
    owner = msg.sender;
  }
  
  modifier isOwner(){
    require(msg.sender == owner);
    _;
  }
 
}

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
    
}

//https://www.researchgate.net/publication/325899686_Using_Ethereum_Blockchain_in_Internet_of_Things_A_Solution_for_Electric_Vehicle_Battery_Refueling
contract Car is BatteryUser, Owned{

    BatteryInfo currentBattery;
    
    BatteryInfo[] previousBatteries;
    
    address station;
    
    modifier ownerOrStation(){
        require(msg.sender == owner || msg.sender == station);
        _;
    }
    
    modifier ifNotCompleteFillIn(){
        if(currentBattery.complete){
            previousBatteries.push(currentBattery);
            currentBattery.complete = false;
            _;
        }
    }

    //supplier can check battery information using getters
    function requestBatterySwap(uint location) isOwner returns(bool){
        require(currentBattery.stationOriginator != 0);//i.e. we have a battery
        return station.call(bytes4(keccak256("requestBatterySwap(uint, uint)")), currentBattery.id, location);
    }
    
    function effectBatterySwap(uint location) returns(bool){
        require(currentBattery.stationOriginator != 0);
        if(station.call(bytes4(keccak256("effectBatterySwap(uint, uint)")), currentBattery.id, location)){
            currentBattery.complete = true;
        }
    }
    
    //GETTERS
    
    function getCurrentBatteryIDl() ownerOrStation returns(uint){
        return currentBattery.id;
    }
    
    function getCurrentBatteryEnergyLevel() ownerOrStation returns(uint){
        return currentBattery.energyLevel;
    }
    
    function getCurrentBatteryChargeLeft() ownerOrStation returns(uint){
        return currentBattery.chargeLeftTime;
    }
    
    function getCurrentBatteryQuality() ownerOrStation returns(Quality){
        return currentBattery.qualityOfBattery;
    }
    
    function getCurrentBatteryStationOriginator() ownerOrStation returns(address){
        return currentBattery.stationOriginator;
    }
    
    //SETTERS
    
    function setCurrentBatteryID(uint id) ownerOrStation ifNotCompleteFillIn returns(bool){
        currentBattery.id = id;
    }
    
    function setCurrentBatteryEnergyLevel(uint energyLevel) ownerOrStation ifNotCompleteFillIn returns(bool){
        currentBattery.energyLevel = energyLevel;
    }
    
    function getCurrentBatteryChargeLeft(uint chargeLeftTime) ownerOrStation ifNotCompleteFillIn returns(bool){
        currentBattery.chargeLeftTime = chargeLeftTime;
    }
    
    function getCurrentBatteryQuality(Quality quality) ownerOrStation ifNotCompleteFillIn returns(bool){
        currentBattery.qualityOfBattery = quality;
    }
    
    function getCurrentBatteryStationOriginator(address originator) ownerOrStation ifNotCompleteFillIn returns(bool){
        currentBattery.stationOriginator = originator;
    }
}