// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title VaultLink
 * @notice A decentralized digital vault that allows users to securely store,
 *         manage, and share encrypted data references (like IPFS hashes) with
 *         access control mechanisms.
 */
contract Project {
    address public admin;
    uint256 public vaultCount;

    struct Vault {
        uint256 id;
        address owner;
        string dataHash; // IPFS or encrypted data reference
        string label;
        bool shared;
        address sharedWith;
        uint256 timestamp;
    }

    mapping(uint256 => Vault) public vaults;
    mapping(address => uint256[]) public userVaults;

    event VaultCreated(uint256 indexed id, address indexed owner, string label);
    event VaultShared(uint256 indexed id, address indexed sharedWith);
    event VaultRevoked(uint256 indexed id, address indexed revokedFrom);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyOwner(uint256 _id) {
        require(vaults[_id].owner == msg.sender, "Not the vault owner");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Create a new encrypted vault entry
     * @param _dataHash Encrypted or IPFS data hash
     * @param _label A short label or identifier for the vault
     */
    function createVault(string memory _dataHash, string memory _label) external {
        require(bytes(_dataHash).length > 0, "Data hash required");
        require(bytes(_label).length > 0, "Label required");

        vaultCount++;
        vaults[vaultCount] = Vault({
            id: vaultCount,
            owner: msg.sender,
            dataHash: _dataHash,
            label: _label,
            shared: false,
            sharedWith: address(0),
            timestamp: block.timestamp
        });

        userVaults[msg.sender].push(vaultCount);

        emit VaultCreated(vaultCount, msg.sender, _label);
    }

    /**
     * @notice Share a vault with another address
     * @param _id Vault ID
     * @param _sharedWith Address to share with
     */
    function shareVault(uint256 _id, address _sharedWith) external onlyOwner(_id) {
        Vault storage vault = vaults[_id];
        require(!vault.shared, "Vault already shared");
        require(_sharedWith != address(0), "Invalid address");

        vault.shared = true;
        vault.sharedWith = _sharedWith;

        emit VaultShared(_id, _sharedWith);
    }

    /**
     * @notice Revoke shared access to a vault
     * @param _id Vault ID
     */
    function revokeVault(uint256 _id) external onlyOwner(_id) {
        Vault storage vault = vaults[_id];
        require(vault.shared, "Vault not shared");

        address prevSharedWith = vault.sharedWith;
        vault.shared = false;
        vault.sharedWith = address(0);

        emit VaultRevoked(_id, prevSharedWith);
    }

    /**
     * @notice Retrieve vault details (owner or shared user only)
     * @param _id Vault ID
     */
    function getVault(uint256 _id) external view returns (Vault memory) {
        Vault memory v = vaults[_id];
        require(
            msg.sender == v.owner || msg.sender == v.sharedWith,
            "Access denied"
        );
        return v;
    }

    /**
     * @notice Get all vault IDs owned by a specific address
     * @param _owner Address of the vault owner
     */
    function getVaultsByOwner(address _owner) external view returns (uint256[] memory) {
        return userVaults[_owner];
    }
}
