import "./MonitoredCourierService.sol";

contract ExpectedBehaviour is Owned, CourierServiceStorage{
    enum state{INIT, BAD}

    state current;
    mapping(uint => bool) orderedAndNotDelivered;

    function onAddOrder(uint _orderNo, address _sender){
        require(_sender == owner);

        if(current == state.INIT){
            orderedAndNotDelivered[_orderNo] = true;
        }
    }

    function onDelivery(uint _orderNo, address _sender){
        require(_sender == owner);

        if(current == state.INIT
            && !orderedAndNotDelivered[_orderNo]){
            current = state.BAD;
        } else{
            orderedAndNotDelivered[_orderNo] = false;
        }
    }
}
