//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MillionaireMaker is Ownable 
{

    AggregatorV3Interface internal priceFeed;
    uint256 private funds;
    address payable[] private _inLottery;

    constructor(address ethUsdAddress) {
        priceFeed = AggregatorV3Interface(ethUsdAddress);
    }

    function getPrice() public view returns(uint256){
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return(uint256(answer));
    }

    function enterLottery() public payable
	{
        uint256 ethPrice = getPrice();
        uint256 valueInUsd = msg.value * ethPrice / 1 ether;
        require(valueInUsd >  90000000, "The value needs the be higher than 0.9 usd");
        require(valueInUsd < 110000000, "The value needs the be lower than 1.1 usd");
        require(!exist(msg.sender), "The address already exist");
        _inLottery.push(payable(msg.sender));
		funds += msg.value;
        uint256 fundsInUsd = funds * ethPrice / 1 ether;
        if(fundsInUsd >= 100000000000000)
        {
            uint winner = random() % _inLottery.length;
            _inLottery[winner].transfer(address(this).balance);
            funds = 0;
            delete _inLottery;
        }
	}

    function exist (address addressToTest) internal view returns (bool) 
    {        
        address payable addr1 = payable(addressToTest);
        for (uint i; i < _inLottery.length; i++){
            if (addr1 == _inLottery[i])
            {
                return true;
            }
        }
        return false;
    }

    function random() private view returns (uint) 
    {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, _inLottery)));
    }
}
