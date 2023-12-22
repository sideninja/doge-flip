pragma solidity ^0.8.0;

contract EtherFlip {
    address public owner;
    uint public balance;

    event FlipResult(bool win);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    function bet(bool _guess) public payable {
        require(msg.value > 0, "You must send some Ether to bet.");

        bool win = pseudoRandomFlip() == _guess;
        if (win) {
            uint payout = msg.value * 2;
            require(address(this).balance >= payout, "Contract does not have enough funds to pay out.");
            (bool sent, ) = msg.sender.call{value: payout}("");
            require(sent, "Failed to send Ether");
        }

        emit FlipResult(win);
    }

    function pseudoRandomFlip() private view returns (bool) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 2 == 0;
    }

    function withdraw() public onlyOwner {
        uint amount = address(this).balance;
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Fallback function to accept incoming Ether
    receive() external payable {
        balance += msg.value;
    }
}
