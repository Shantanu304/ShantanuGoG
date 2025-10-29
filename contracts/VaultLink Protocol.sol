? Function 1: Create a new vault with initial deposit
    function createVault() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");

        vaultCount++;
        vaults[vaultCount] = Vault(vaultCount, msg.sender, msg.value, false);

        emit VaultCreated(vaultCount, msg.sender, msg.value);
    }

    ? Function 3: Unlock a vault and withdraw funds (admin only)
    function unlockVault(uint256 _id) public onlyAdmin {
        Vault storage v = vaults[_id];
        require(v.locked, "Vault not locked");
        v.locked = false;

        uint256 amount = v.balance;
        v.balance = 0;

        payable(v.depositor).transfer(amount);
        emit VaultUnlocked(_id);
    }

    // ? Function 4: View vault details
    function getVault(uint256 _id) public view returns (Vault memory) {
        require(_id > 0 && _id <= vaultCount, "Invalid vault ID");
        return vaults[_id];
    }
}
// 
update
// 
