//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SharedWallet is Ownable(msg.sender) {
    // События:
    event LimitChanged(address indexed _user, uint _oldLim, uint _newLim); // лимит изменен
    event MemberCreated(address indexed _member); // создан пользователь

    struct Member {
        string name;
        uint limit;
        bool isAdmin;
    }

    mapping(address => Member) public members;

    // Проверка: является ли инициатор транзакции владельцем
    function isOwner() internal view returns(bool) {
        return owner() == _msgSender();
    }

    // Проверка: инициатор является владельцем или пользователем, транзакция не превыщает лимит
    modifier ownerOrWithinLimits(uint _amount) {
        require(isOwner() || members[_msgSender()].limit >= _amount, "You are not allowed to perform this operation!");
        _;
    }

    // Проверка: есть ли пользователь в списке участников
    modifier isMember(address _member) {
        require(bytes(members[_member].name).length != 0, "No such user. Create a user first!");
        _;
    }

    // Создание нового пользователя (только владелец)
    function createMember(address _member, string memory _name) public onlyOwner {
        require(bytes(members[_member].name).length == 0, "This user already exists!");
        members[_member].name = _name;
        members[_member].isAdmin = _member == owner();

        emit MemberCreated(_member);
    }

    // дать права администратора
    function makeAdmin(address _member) public onlyOwner isMember(_member) {
        members[_member].isAdmin = true;
    }

    // забрать права администратора
    function revokeAdmin(address _member) public onlyOwner isMember(_member) {
        members[_member].isAdmin = false;
    }

    // Добавление или изменение лимита пользователям (только владелец)
    function addLimit(address _member, uint _limit) public onlyOwner isMember(_member) {
        uint oldLim = members[_member].limit;
        members[_member].limit = _limit;

        emit LimitChanged(_member, oldLim, _limit);
    }

    // Удаление пользователя (только владелец)
    function deleteMember(address _member) public onlyOwner isMember(_member) {
        delete members[_member];
    }

    // Уменьшение допустимого лимита пользователя
    function deduceFromLimit(address _member, uint _amount) internal isMember(_member) {
        members[_member].limit -= _amount;
    }

    // Чтобы не получилось так, что кошелек без владельца
    function renounceOwnership() override public view onlyOwner {
        revert("Can't renounce!");
    }
}