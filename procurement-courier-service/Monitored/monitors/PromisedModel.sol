import "./MonitoredCourierService.sol";

contract PromisedBehaviour is Owned, CourierServiceStorage{
    enum state{INIT, BAD, ACCEPT, ONORDER, ONREFUNDREQUEST, ONREFUNDHANDLED, ONTRANSFER}

    mapping(uint => state) orderState;

    function onAddOrder(uint _orderNo, address _sender){
        require(_sender == owner);

        if(orderState[_orderNo] == state.INIT){
            orderState[_orderNo] = state.ONORDER;
        }
    }

    function onDelivery(uint _orderNo, address _sender){
        require(_sender == owner);

        if(orderState[_orderNo] == state.ONORDER){
            orderState[_orderNo] = state.ACCEPT;
        }
    }

    function onRefundCall(uint _orderNo, address _sender){
        require(_sender == owner);

        if(orderState[_orderNo] == state.ONORDER
            && now > orderETA[_orderNo]){
            orderState[_orderNo] = state.ONREFUNDREQUEST;
        }
    }

    function onTransfer(uint _orderNo, address _sender){
        require(_sender == owner);

        if(orderState[_orderNo] == state.ONREFUNDREQUEST){
            orderState[_orderNo] = state.ONTRANSFER;
        }
    }

    function onRefundExit(uint _orderNo, address _sender){
        require(_sender == owner);

        if(orderState[_orderNo] == state.ONREFUNDREQUEST){
            orderState[_orderNo] = state.BAD;
        }
    }
}
