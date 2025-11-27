// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title VaultLinkProtocol
 * @notice A protocol to link multiple vaults together, enabling shared access and relational mapping.
 */
contract VaultLinkProtocol {

    address public admin;
    uint256 public vaultCount;

    struct Vault {
        uint256 id;
        address owner;
        string dataHash;
        string metadataURI;
        uint256 timestamp;
        uint256[] linkedVaults;
    }

    mapping(uint256 => Vault) public vaults;
    mapping(address => uint256[]) public userVaults;

    event VaultCreated(uint256 indexed id, address indexed owner, string dataHash, string metadataURI);
    event VaultLinked(uint256 indexed fromId, uint256 indexed toId);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "VaultLinkProtocol: NOT_ADMIN");
        _;
    }

    modifier vaultExists(uint256 id) {
        require(id > 0 && id <= vaultCount, "VaultLinkProtocol: VAULT_NOT_FOUND");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function createVault(string calldata dataHash, string calldata metadataURI) external returns (uint256) {
        require(bytes(dataHash).length > 0, "VaultLinkProtocol: EMPTY_HASH");

        vaultCount++;
        vaults[vaultCount] = Vault({
            id: vaultCount,
            owner: msg.sender,
            dataHash: dataHash,
            metadataURI: metadataURI,
            timestamp: block.timestamp,
            linkedVaults: new uint256 
        });

        userVaults[msg.sender].push(vaultCount);

        emit VaultCreated(vaultCount, msg.sender, dataHash, metadataURI);
        return vaultCount;
    }

    function linkVaults(uint256 fromId, uint256 toId) external vaultExists(fromId) vaultExists(toId) {
        require(fromId != toId, "VaultLinkProtocol: SELF_LINK");
        require(vaults[fromId].owner == msg.sender || msg.sender == admin, "VaultLinkProtocol: UNAUTHORIZED");

        vaults[fromId].linkedVaults.push(toId);
        vaults[toId].linkedVaults.push(fromId);

        emit VaultLinked(fromId, toId);
        emit VaultLinked(toId, fromId);
    }

    function getVault(uint256 id) external view vaultExists(id) returns (Vault memory) {
        return vaults[id];
    }

    function getUserVaults(address user) external view returns (uint256[] memory) {
        return userVaults[user];
    }

    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "VaultLinkProtocol: ZERO_ADMIN");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
}
