// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../CountersImpl.sol";
import "../../proxy/UUPS/Proxiable.sol";

contract ProxiableMock is CountersImpl, Proxiable {
    function _beforeUpgrade() internal virtual override {}
}

contract ProxiableUnsafeMock is CountersImpl, Proxiable {
    function upgradeTo(address newImplementation) external virtual override {
        ERC1967Upgrade._upgradeToAndCall(newImplementation, bytes(""));
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual override {
        ERC1967Upgrade._upgradeToAndCall(newImplementation, data);
    }

    function _beforeUpgrade() internal virtual override {}
}

contract ProxiableBrokenMock is CountersImpl, Proxiable {
    function upgradeTo(address) external virtual override {
        // pass
    }

    function upgradeToAndCall(address, bytes memory) external payable virtual override {
        // pass
    }

    function _beforeUpgrade() internal virtual override {}
}
