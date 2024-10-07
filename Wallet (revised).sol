//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./SharedWallet.sol";

contract Wallet is SharedWallet { // inheritance
    // Events: 
    event MoneyWithdrawn(address indexed _to, uint _amount); // funds were withdrawn from the wallet
    event MoneyReceived(address indexed _from, uint _amount); // funds arrived in the wallet

    // Withdrawal, modifier from SharedWallet
    function withdrawMoney(uint _amount) public ownerOrWithinLimits(_amount) {
        // Check: there are sufficient funds in the account
        require(_amount <= address(this).balance, "Not enough funds to withdraw!");

        if(!isOwner()) { 
            deduceFromLimit(_msgSender(), _amount); // Reducing user limit
        }

        address payable _to = payable(_msgSender());
        _to.transfer(_amount);

        emit MoneyWithdrawn(_to, _amount);
    }

    function sendToContract(address _to) public payable {
        address payable to = payable(_to);
        to.transfer(msg.value);

        emit MoneyReceived(_msgSender(), msg.value);
    }
    
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    fallback() external payable {}
    
    // Will be called if funds were received into the contract without specifying the function
    receive() external payable { emit MoneyReceived(_msgSender(), msg.value); }
}