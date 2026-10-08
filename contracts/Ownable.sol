// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

contract Ownable {
    error Ownable__UnauthorizedAccount(address account);
    error Ownable__OwnerCannotBeBurnAddress();
    error Ownable__NotPendingOwner();

    // Current owner of the contract
    address private _owner;
    // Pending owner for two-step ownership transfer
    address private _pendingOwner;

    // Emitted when ownership is transferred
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    // Emitted when a new pending owner is set
    event OwnershipTransferStarted(
        address indexed previousOwner,
        address indexed newOwner
    );

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        if (msg.sender != _owner)
            revert Ownable__UnauthorizedAccount(msg.sender);
        _;
    }

    // Constructor sets the deployer as the initial owner
    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    // Returns the current owner
    function owner() public view returns (address) {
        return _owner;
    }

    // Returns the pending owner (if any)
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    // Start the ownership transfer process (only current owner can call)
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner == address(0)) revert Ownable__OwnerCannotBeBurnAddress();
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(_owner, newOwner);
    }

    // Complete the ownership transfer (only pending owner can call)
    function acceptOwnership() public {
        if (msg.sender != _pendingOwner) revert Ownable__NotPendingOwner();
        address oldOwner = _owner;
        _owner = _pendingOwner;
        _pendingOwner = address(0);
        emit OwnershipTransferred(oldOwner, _owner);
    }

    // Renounce ownership (optional, makes contract ownerless)
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
        _pendingOwner = address(0);
    }
}