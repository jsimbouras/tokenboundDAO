pragma solidity ^0.8.0;

import "IERC6551Registry.sol";
import "IERC6551Account.sol";

contract SimpleDAO {
    IERC6551Registry private registry;
    address private daoTokenContract;
    
    mapping(address => uint256) private voteCount;
    
    event VoteCast(address indexed voter, uint256 proposalId);
    
    constructor(address _registryAddress, address _daoTokenContract) {
        registry = IERC6551Registry(_registryAddress);
        daoTokenContract = _daoTokenContract;
    }
    
    function vote(uint256 proposalId) external {
        address voter = msg.sender;
        require(voteCount[voter] == 0, "Already voted");
        voteCount[voter] = 1;
        emit VoteCast(voter, proposalId);
    }
    
    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external {
        address accountAddress = registry.createAccount(implementation, chainId, tokenContract, tokenId);
        // Transfer the ERC6551 token ownership to the accountAddress
        IERC6551Account(accountAddress).transferOwnership(tokenContract, tokenId);
    }
    
    function getVoteCount(address voter) external view returns (uint256) {
        return voteCount[voter];
    }



}
