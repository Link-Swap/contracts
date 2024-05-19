// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LinkSwapToken is
    ERC20,
    ERC20Burnable,
    AccessControl,
    ERC20Permit,
    ReentrancyGuard
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant FAUCET_AMOUNT = 100 * 10**18; // Amount to distribute per request
    uint256 public constant FAUCET_TIMEOUT = 24 hours; // Timeout period for faucet (24 hours)

    mapping(address => uint256) private _lastFaucetTime;

    constructor(address defaultAdmin, address minter)
        ERC20("LinkSwap", "LSWAP")
        ERC20Permit("LinkSwap")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function faucet() external nonReentrant {
        // require(
        //     hasRole(MINTER_ROLE, msg.sender),
        //     "LinkSwap: must have MINTER_ROLE to faucet"
        // );
        require(
            _lastFaucetTime[msg.sender] + FAUCET_TIMEOUT <= block.timestamp,
            "LinkSwap: faucet timeout not reached"
        );

        _lastFaucetTime[msg.sender] = block.timestamp;
        _mint(msg.sender, FAUCET_AMOUNT);
    }

    // Function to check the time remaining until the next faucet request is available
    function timeUntilNextFaucet(address account)
        external
        view
        returns (uint256)
    {
        if (block.timestamp >= _lastFaucetTime[account] + FAUCET_TIMEOUT) {
            return 0;
        } else {
            return _lastFaucetTime[account] + FAUCET_TIMEOUT - block.timestamp;
        }
    }
}
