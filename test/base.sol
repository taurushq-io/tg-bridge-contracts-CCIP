

contract baseTest {

     // Arrange
    function setUp() public {
        // Deploy CCIP Sender
        CCIPSENDER_CONTRACT = new CCIPSender(
            SENDER_ADMIN,
            0x1
        );
    }

    
}