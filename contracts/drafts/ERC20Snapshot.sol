pragma solidity ^0.5.2;

import "../math/SafeMath.sol";
import "../utils/Arrays.sol";
import "../drafts/Counters.sol";
import "../token/ERC20/ERC20.sol";

/**
 * @title ERC20 token with snapshots.
 * inspired by Jordi Baylina's MiniMeToken to record historical balances
 * @author Validity Labs AG <info@validitylabs.org>
 */
contract ERC20Snapshot is ERC20 {
    using SafeMath for uint256;
    using Arrays for uint256[];
    using Counters for Counters.Counter;

    // Snapshots store a value at the time a snapshot is taken (and a new snapshot id created), and the corresponding
    // snapshot id. Each account has individual snapshots taken on demand, as does the token's total supply.

    // These two fields (value and id) belong together, but are not part of a struct so that functions that work on
    // arrays can be called on them.

    mapping (address => uint256[]) private _accountSnapshotIds;
    mapping (address => uint256[]) private _accountSnapshotValues;

    uint256[] private _totalSupplySnapshotIds;
    uint256[] private _totalSupplySnapshotValues;

    // Snapshot ids increase monotonically, with the first value being 1. An id of 0 is invalid.
    Counters.Counter private _currentSnapshotId;

    event Snapshot(uint256 id);

    // Creates a new snapshot id. Balances are only stored in snapshots on demand: unless a snapshot was taken, a
    // balance change will not be recorded. This means the extra added cost of storing snapshotted balances is only paid
    // when required, but is also flexible enough that it allows for e.g. daily snapshots.
    function snapshot() public returns (uint256) {
        _currentSnapshotId.increment();

        uint256 currentId = _currentSnapshotId.current();
        emit Snapshot(currentId);
        return currentId;
    }

    function balanceOfAt(address account, uint256 snapshotId) public view returns (uint256) {
        (bool snapshotted, uint256 value) =
            _valueAt(snapshotId, _accountSnapshotValues[account], _accountSnapshotIds[account]);

        return snapshotted ? value : balanceOf(account);
    }

    function totalSupplyAt(uint256 snapshotId) public view returns(uint256) {
        (bool snapshotted, uint256 value) = _valueAt(snapshotId, _totalSupplySnapshotValues, _totalSupplySnapshotIds);

        return snapshotted ? value : totalSupply();
    }

    // _transfer, _mint and _burn are the only functions where the balances are modified, so it is there that the
    // snapshots are updated. Note that the update happens _before_ the balance change, with the pre-modified value.
    // The same is true for the total supply and _mint and _burn.
    function _transfer(address from, address to, uint256 value) internal {
        _updateAccountSnapshot(from);
        _updateAccountSnapshot(to);

        super._transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._mint(account, value);
    }

    function _burn(address account, uint256 value) internal {
        _updateAccountSnapshot(account);
        _updateTotalSupplySnapshot();

        super._burn(account, value);
    }

    // When a valid snapshot is queried, there are three possibilities:
    //  a) The queried value was not modified after the snapshot was taken. Therefore, a snapshot entry was never
    //  created for this id, and all stored snapshot ids are smaller than the requested one. The value that corresponds
    //  to this id is the current one.
    //  b) The queried value was modified after the snapshot was taken. Therefore, there will be an entry with the
    //  requested id, and its value is the one to return.
    //  c) More snapshots were created after the requested one, and the queried value was later modified. There will be
    //  no entry for the requested id: the value that corresponds to it is that of the smallest snapshot id that is
    //  larger than the requested one.
    //
    // In summary, we need to find an element in an array, returning the index of the smallest value that is larger if
    // it is not found, unless said value doesn't exist (e.g. when all values are smaller). Arrays.findUpperBound does
    // exactly this.
    function _valueAt(uint256 snapshotId, uint256[] storage values, uint256[] storage ids)
        private view returns (bool, uint256)
    {
        require(snapshotId > 0);
        require(snapshotId <= _currentSnapshotId.current());

        uint256 index = ids.findUpperBound(snapshotId);

        if (index == ids.length) {
            return (false, 0);
        } else {
            return (true, values[index]);
        }
    }

    function _updateAccountSnapshot(address account) private {
        _updateSnapshot(_accountSnapshotValues[account], _accountSnapshotIds[account], balanceOf(account));
    }

    function _updateTotalSupplySnapshot() private {
        _updateSnapshot(_totalSupplySnapshotValues, _totalSupplySnapshotIds, totalSupply());
    }

    function _updateSnapshot(uint256[] storage values, uint256[] storage ids, uint256 currentValue) private {
        uint256 currentId = _currentSnapshotId.current();
        if (_lastSnapshotId(ids) < currentId) {
            ids.push(currentId);
            values.push(currentValue);
        }
    }

    function _lastSnapshotId(uint256[] storage ids) private view returns (uint256) {
        if (ids.length == 0) {
            return 0;
        } else {
            return ids[ids.length - 1];
        }
    }
}
