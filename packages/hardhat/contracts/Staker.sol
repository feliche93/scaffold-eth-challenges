pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // minimum required staking amount
    uint256 public constant threshold = 1 ether;

    // mapping that keeps track of staked balances
    mapping(address => uint256) public balances;

    // event for staked amounts
    event Stake(address indexed sender, uint256 value);

    // staking payable function mapping each received stake to an address, requiring to stake at least 1 ether
    function stake() public payable {
        require(msg.value >= 0, "Stake amount must be positive");
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // deadline until when the staker can withdraw his stake
    uint256 public deadline = block.timestamp + 72 hours;

    modifier notCompleted() {
        bool completed = exampleExternalContract.completed();
        require(!completed, "Staking process already completed");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    // function checking how much time is left
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    function withdraw() public notCompleted {
        // transfer the staked amount to the staker
        payable(msg.sender).transfer(balances[msg.sender]);

        // remove the staked amount from the mapping
        balances[msg.sender] = 0;
    }

    function execute() public notCompleted {
        if (address(this).balance >= threshold && timeLeft() == 0) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            bool openForWithdraw = true;
            withdraw();
        }
    }

    receive() external payable notCompleted {
        stake();
    }
}
