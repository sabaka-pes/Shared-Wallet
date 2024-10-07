//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SharedWallet is Ownable(msg.sender) {
    // Events:
    event LimitChanged(address indexed _user, uint _oldLim, uint _newLim); // limit changed
    event MemberCreated(address indexed _member); // member created

    struct Member {
        string name;
        uint limit;
        bool isAdmin;
    }

    mapping(address => Member) public members;

    // Check: if the transaction initiator the owner
    function isOwner() internal view returns(bool) {
        return owner() == _msgSender();
    }

    // Verification: Initiator is owner or user, transaction does not exceed limit
    modifier ownerOrWithinLimits(uint _amount) {
        require(isOwner() || members[_msgSender()].limit >= _amount, "You are not allowed to perform this operation!");
        _;
    }

    // Check: if the member in the list of participants
    modifier isMember(address _member) {
        require(bytes(members[_member].name).length != 0, "No such user. Create a user first!");
        _;
    }

    // Create new member (owner only)
    function createMember(address _member, string memory _name) public onlyOwner {
        require(bytes(members[_member].name).length == 0, "This user already exists!");
        members[_member].name = _name;
        members[_member].isAdmin = _member == owner();

        emit MemberCreated(_member);
    }

    // Give admin rights (owner only)
    function makeAdmin(address _member) public onlyOwner isMember(_member) {
        members[_member].isAdmin = true;
    }

    // Revoke admin rights (owner only)
    function revokeAdmin(address _member) public onlyOwner isMember(_member) {
        members[_member].isAdmin = false;
    }

    // Add or change member limit (owner only)
    function addLimit(address _member, uint _limit) public onlyOwner isMember(_member) {
        uint oldLim = members[_member].limit;
        members[_member].limit = _limit;

        emit LimitChanged(_member, oldLim, _limit);
    }

    // Delete member (owner only)
    function deleteMember(address _member) internal onlyOwner isMember(_member) {
        delete members[_member];
    }

    // Reducing the member's allowed limit
    function deduceFromLimit(address _member, uint _amount) internal isMember(_member) {
        uint oldLim = members[_member].limit;
        members[_member].limit -= _amount;

        emit LimitChanged(_member, oldLim, members[_member].limit);
    }

    // To prevent a situation where the wallet has no owner
    function renounceOwnership() override public view onlyOwner {
        revert("Can't renounce!");
    }
}