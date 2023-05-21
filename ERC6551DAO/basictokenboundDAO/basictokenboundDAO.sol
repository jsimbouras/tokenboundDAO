// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./AccountRegistry.sol";
import "./CrossChainExecutorList.sol";
import "./MinimalReceiver.sol";
import "openzeppelin-contracts/access/AccessControl.sol";

contract SimpleDAO is AccessControl {
    AccountRegistry private accountRegistry;
    CrossChainExecutorList private crossChainExecutorList;
    MinimalReceiver private minimalReceiver;

    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    event FundsDeposited(address sender, uint256 amount);
    event FundsWithdrawn(address receiver, uint256 amount);

    constructor(
        address accountRegistryAddress,
        address crossChainExecutorListAddress,
        address minimalReceiverAddress
    ) {
        accountRegistry = AccountRegistry(accountRegistryAddress);
        crossChainExecutorList = CrossChainExecutorList(
            crossChainExecutorListAddress
        );
        minimalReceiver = MinimalReceiver(minimalReceiverAddress);

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(EXECUTOR_ROLE, msg.sender);
    }

    function depositFunds() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }

    function withdrawFunds(address payable receiver, uint256 amount)
        external
        onlyRole(EXECUTOR_ROLE)
    {
        require(
            address(this).balance >= amount,
            "Insufficient balance in the DAO"
        );

        (bool success, ) = receiver.call{value: amount}("");
        require(success, "Failed to transfer funds");

        emit FundsWithdrawn(receiver, amount);
    }

    function createAccount(
        uint256 chainId,
        address tokenCollection,
        uint256 tokenId
    ) external {
        address accountAddress = accountRegistry.createAccount(
            chainId,
            tokenCollection,
            tokenId
        );

        grantRole(EXECUTOR_ROLE, accountAddress);
    }

    function setCrossChainExecutor(
        uint256 chainId,
        address executor,
        bool enabled
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        crossChainExecutorList.setCrossChainExecutor(chainId, executor, enabled);
    }

    function receiveERC721(address operator, address from, uint256 tokenId)
        external
    {
        // Perform any necessary actions upon receiving an ERC721 token
        // For example, you can interact with the account associated with the token.
    }

    function receiveERC1155(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external {
        // Perform any necessary actions upon receiving an ERC1155 token
        // For example, you can interact with the account associated with the token.
    }

    function () external payable {
        // Fallback function to receive Ether transfers
        minimalReceiver.receive{value: msg.value}();
    }
}
