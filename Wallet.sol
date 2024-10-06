//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./SharedWallet.sol";

contract Wallet is SharedWallet { // наследование
    // События: 
    event MoneyWithdrawn(address indexed _to, uint _amount); // деньги выведены из кошелька
    event MoneyReceived(address indexed _from, uint _amount); // деньги пришли в кошелёк

    // Снятие средств, модификатор из SharedWallet
    function withdrawMoney(uint _amount) public ownerOrWithinLimits(_amount) {
        // Проверка: на аккаунте достаточно средств
        require(_amount <= address(this).balance, "Not enough funds to withdraw!");

        if(!isOwner()) { 
            deduceFromLimit(_msgSender(), _amount); // Уменьщение лимита пользователя
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
    
    // вызовется, если в контракт пришли деньги без указания функции
    receive() external payable { emit MoneyReceived(_msgSender(), msg.value); }
}