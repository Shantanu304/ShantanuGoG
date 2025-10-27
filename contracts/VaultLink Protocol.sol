// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VaultLink
 * @dev A decentralized vault system for secure asset deposits and controlled withdrawals.
 */
contract Project {
    address public admin;
    uint256 public vaultCount;

    struct Vault {
        uint256 id;
        address depositor;
        uint256 balance;
        bool locked;
    }

    mapping(uint256 => Vault) public vaults;

    event VaultCreated(uint256 indexed id, address indexed depositor, uint256 balance);
    event VaultLocked(uint256 indexed id);
    event VaultUnlocked(uint256 indexed id);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // ✅ Function 1: Create a new vault with initial deposit
    function createVault() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");

        vaultCount++;
        vaults[vaultCount] = Vault(vaultCount, msg.sender, msg.value, false);

        emit VaultCreated(vaultCount, msg.sender, msg.value);
    }

    // ✅ Function 2: Lock a vault (admin only)
    function lockVault(uint256 _id) public onlyAdmin {
        Vault storage v = vaults[_id];
        require(!v.locked, "Vault already locked");
        v.locked = true;

        emit VaultLocked(_id);
    }

    // ✅ Function 3: Unlock a vault and withdraw funds (admin only)
    function unlockVault(uint256 _id) public onlyAdmin {
        Vault storage v = vaults[_id];
        require(v.locked, "Vault not locked");
        v.locked = false;

        uint256 amount = v.balance;
        v.balance = 0;

        payable(v.depositor).transfer(amount);
        emit VaultUnlocked(_id);
    }

    // ✅ Function 4: View vault details
    function getVault(uint256 _id) public view returns (Vault memory) {
        require(_id > 0 && _id <= vaultCount, "Invalid vault ID");
        return vaults[_id];
    }
}
