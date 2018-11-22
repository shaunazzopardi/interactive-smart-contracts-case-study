contract CourierService{

    address owner;

    mapping(address => uint) fees;

    mapping(uint => address) orderToSender;
    mapping(uint => address) orderToCustomer;
    mapping(uint => uint) orderETA;
    mapping(uint => uint) orderDeliveryTime;
    mapping(uint => address) confirmedBy;
    mapping(uint => bool) delivered;

    uint cost;

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
        orderToCustomer[orderNo] = customer;
        orderETA[orderNo] = eta;
    }

    function customerSignature(uint orderNo){
        require(!delivered[orderNo]);

        confirmedBy[orderNo] = msg.sender;
        delivered[orderNo] = true;

        orderDeliveryTime[orderNo] = now;

        //we notify the sender of delivery
        //and request payment
        orderToSender[orderNo].call(bytes4(keccak256("deliveryMade(uint)")), orderNo);
    }
}
