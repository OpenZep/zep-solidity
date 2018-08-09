const { increaseTime } = require('./helpers/increaseTime');
const { expectThrow } = require('./helpers/expectThrow');
const { assertRevert } = require('./helpers/assertRevert');

const NULL_ADDRESS = '0x0000000000000000000000000000000000000000';

const Heritable = artifacts.require('Heritable');

require('chai')
  .should();

contract('Heritable', function (accounts) {
  let heritable;
  let owner;

  beforeEach(async function () {
    heritable = await Heritable.new(4141);
    owner = await heritable.owner();
  });

  it('should start off with an owner, but without heir', async function () {
    const heir = await heritable.heir();

    owner.should.be.a('string').that.is.not.equal(NULL_ADDRESS);
    heir.should.be.a('string').that.is.equal(NULL_ADDRESS);
  });

  it('only owner should set heir', async function () {
    const newHeir = accounts[1];
    const someRandomAddress = accounts[2];
    owner.should.equal(someRandomAddress);

    await heritable.setHeir(newHeir, { from: owner });
    await expectThrow(heritable.setHeir(newHeir, { from: someRandomAddress }));
  });

  it('owner can\'t be heir', async function () {
    await assertRevert(heritable.setHeir(owner, { from: owner }));
  });

  it('owner can remove heir', async function () {
    const newHeir = accounts[1];
    await heritable.setHeir(newHeir, { from: owner });
    let heir = await heritable.heir();

    heir.should.eq(newHeir);
    await heritable.removeHeir();
    heir = await heritable.heir();
    heir.should.eq(NULL_ADDRESS);
  });

  it('heir can claim ownership only if owner is dead and timeout was reached', async function () {
    const heir = accounts[1];
    await heritable.setHeir(heir, { from: owner });
    await expectThrow(heritable.claimHeirOwnership({ from: heir }));

    await heritable.proclaimDeath({ from: heir });
    await increaseTime(1);
    await expectThrow(heritable.claimHeirOwnership({ from: heir }));

    await increaseTime(4141);
    await heritable.claimHeirOwnership({ from: heir });
    (await heritable.heir()).should.eq(heir);
  });

  it('only heir can proclaim death', async function () {
    const someRandomAddress = accounts[2];
    await assertRevert(heritable.proclaimDeath({ from: owner }));
    await assertRevert(heritable.proclaimDeath({ from: someRandomAddress }));
  });

  it('heir can\'t proclaim death if owner is death', async function () {
    const heir = accounts[1];
    await heritable.setHeir(heir, { from: owner });
    await heritable.proclaimDeath({ from: heir });
    await assertRevert(heritable.proclaimDeath({ from: heir }));
  });

  it('heir can\'t claim ownership if owner heartbeats', async function () {
    const heir = accounts[1];
    await heritable.setHeir(heir, { from: owner });

    await heritable.proclaimDeath({ from: heir });
    await heritable.heartbeat({ from: owner });
    await expectThrow(heritable.claimHeirOwnership({ from: heir }));

    await heritable.proclaimDeath({ from: heir });
    await increaseTime(4141);
    await heritable.heartbeat({ from: owner });
    await expectThrow(heritable.claimHeirOwnership({ from: heir }));
  });

  it('should log events appropriately', async function () {
    const heir = accounts[1];

    const setHeirLogs = (await heritable.setHeir(heir, { from: owner })).logs;
    const setHeirEvent = setHeirLogs.find(e => e.event === 'HeirChanged');

    assert.isTrue(setHeirEvent.args.owner === owner);
    assert.isTrue(setHeirEvent.args.newHeir === heir);

    const heartbeatLogs = (await heritable.heartbeat({ from: owner })).logs;
    const heartbeatEvent = heartbeatLogs.find(e => e.event === 'OwnerHeartbeated');

    assert.isTrue(heartbeatEvent.args.owner === owner);

    const proclaimDeathLogs = (await heritable.proclaimDeath({ from: heir })).logs;
    const ownerDeadEvent = proclaimDeathLogs.find(e => e.event === 'OwnerProclaimedDead');

    assert.isTrue(ownerDeadEvent.args.owner === owner);
    assert.isTrue(ownerDeadEvent.args.heir === heir);

    await increaseTime(4141);
    const claimHeirOwnershipLogs = (await heritable.claimHeirOwnership({ from: heir })).logs;
    const ownershipTransferredEvent = claimHeirOwnershipLogs.find(e => e.event === 'OwnershipTransferred');
    const heirOwnershipClaimedEvent = claimHeirOwnershipLogs.find(e => e.event === 'HeirOwnershipClaimed');

    assert.isTrue(ownershipTransferredEvent.args.previousOwner === owner);
    assert.isTrue(ownershipTransferredEvent.args.newOwner === heir);
    assert.isTrue(heirOwnershipClaimedEvent.args.previousOwner === owner);
    assert.isTrue(heirOwnershipClaimedEvent.args.newOwner === heir);
  });

  it('timeOfDeath can be queried', async function () {
    assert.eq(await heritable.timeOfDeath(), 0);
  });

  it('heartbeatTimeout can be queried', async function () {
    assert.eq(await heritable.heartbeatTimeout(), 4141);
  });
});
