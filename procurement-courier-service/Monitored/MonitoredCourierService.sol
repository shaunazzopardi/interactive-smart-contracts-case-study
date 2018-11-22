contract Monitored{
    mapping(address => address[]) userToMonitor;

    function addMonitor(address _addr) returns(bool){
        delete userToMonitor[msg.sender];
        userToMonitor[msg.sender].push(_addr);
    }
}

contract CourierServiceStorage{
    address owner;

    mapping(address => uint) fees;

    mapping(uint => address) orderToSender;
    mapping(uint => address) orderToCustomer;
    mapping(uint => uint) orderETA;
    mapping(uint => uint) orderDeliveryTime;
    mapping(uint => address) confirmedBy;
    mapping(uint => bool) delivered;

    uint cost;

}

contract CourierService is Monitored, CourierServiceStorage{

    function CourierService(){
        owner = msg.sender;
    }

    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }

    function addOrder(address customer, uint orderNo, uint eta) payable{
        require(msg.value >= cost);
        require(orderToCustomer[orderNo] == 0);

        for(uint i = 0; i < userToMonitor[msg.sender].length; i++){
            if(!userToMonitor[msg.sender][i].delegatecall(bytes4(keccak256("onAddOrder()")))){
                revert();
            }
        }

        orderToCustomer[orderNo] = customer;
        orderETA[orderNo] = eta;
    }

    function customerSignature(uint orderNo){
        require(!delivered[orderNo]);

        for(uint i = 0; i < userToMonitor[msg.sender].length; i++){
            if(!userToMonitor[msg.sender][i].delegatecall(bytes4(keccak256("onDelivery()")))){
                revert();
            }
        }

        confirmedBy[orderNo] = msg.sender;
        delivered[orderNo] = true;

        orderDeliveryTime[orderNo] = now;

        //we notify the sender of delivery
        //and request payment
        orderToSender[orderNo].call(bytes4(keccak256("deliveryMade(uint)")), orderNo);
    }

}
