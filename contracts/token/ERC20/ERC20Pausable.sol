pragma solidity ^0.6.0;

import "./ERC20.sol";
import "../../lifecycle/Pausable.sol";

/**
 * @title Pausable token
 * @dev ERC20 with pausable transfers and allowances.
 *
 * Useful if you want to stop trades until the end of a crowdsale, or have
 * an emergency switch for freezing all token transfers in the event of a large
 * bug.
 */
contract ERC20Pausable is ERC20, Pausable {
    function _afterTokensMoved(address from, address to, uint256 amount) internal virtual override {
        require(!paused(), "ERC20Pausable: token movement while paused");
        super._afterTokensMoved(from, to, amount);
    }

    function _afterTokensApproved(address from, address to, uint256 amount) internal virtual override {
        require(!paused(), "ERC20Pausable: token approval while paused");
        super._afterTokensApproved(from, to, amount);
    }
}
