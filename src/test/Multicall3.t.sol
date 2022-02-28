// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {Multicall3} from "../Multicall3.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockCallee} from "./mocks/MockCallee.sol";

contract Multicall3Test is DSTestPlus {
  Multicall3 multicall;
  MockCallee callee;

  /// @notice Setups up the testing suite
  function setUp() public {
    multicall = new Multicall3();
    callee = new MockCallee();
  }

  /// >>>>>>>>>>>>>>>>>>>>>  AGGREGATE TESTS  <<<<<<<<<<<<<<<<<<<<< ///

  function testAggregation() public {
    // Test successful call
    Multicall3.Call[] memory calls = new Multicall3.Call[](1);
    calls[0] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number)
    );
    (
        uint256 blockNumber,
        bytes[] memory returnData
    ) = multicall.aggregate(calls);
    assert(blockNumber == block.number);
    assert(keccak256(returnData[0]) == keccak256(abi.encodePacked(blockhash(block.number))));
  }

  function testUnsuccessulAggregation() public {
    // Test unexpected revert
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number)
    );
    calls[1] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("thisMethodReverts()")
    );
    vm.expectRevert(bytes("Multicall aggregate: call failed"));
    (
        uint256 blockNumber,
        bytes[] memory returnData
    ) = multicall.aggregate(calls);
  }

  /// >>>>>>>>>>>>>>>>>>>  TRY AGGREGATE TESTS  <<<<<<<<<<<<<<<<<<< ///

  function testTryAggregate() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number)
    );
    calls[1] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("thisMethodReverts()")
    );
    (
        Multicall3.Result[] memory returnData
    ) = multicall.tryAggregate(false, calls);
    assert(returnData[0].success == true);
    assert(keccak256(returnData[0].returnData) == keccak256(abi.encodePacked(blockhash(block.number))));
    assert(returnData[1].success == false);
  }

  function testTryAggregateUnsuccessful() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number)
    );
    calls[1] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("thisMethodReverts()")
    );
    vm.expectRevert(bytes("Multicall2 aggregate: call failed"));
    (
        Multicall3.Result[] memory returnData
    ) = multicall.tryAggregate(true, calls);
  }

  /// >>>>>>>>>>>>>>  TRY BLOCK AND AGGREGATE TESTS  <<<<<<<<<<<<<< ///

  function testTryBlockAndAggregate() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number)
    );
    calls[1] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("thisMethodReverts()")
    );
    (
        uint256 blockNumber,
        bytes32 blockHash,
        Multicall3.Result[] memory returnData
    ) = multicall.tryBlockAndAggregate(false, calls);
    assert(blockNumber == block.number);
    assert(blockHash == blockhash(block.number));
    assert(returnData[0].success == true);
    assert(keccak256(returnData[0].returnData) == keccak256(abi.encodePacked(blockhash(block.number))));
    assert(returnData[1].success == false);
  }

  function testTryBlockAndAggregateUnsuccessful() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number)
    );
    calls[1] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("thisMethodReverts()")
    );
    vm.expectRevert(bytes("Multicall2 aggregate: call failed"));
    (
        uint256 blockNumber,
        bytes32 blockHash,
        Multicall3.Result[] memory returnData
    ) = multicall.tryBlockAndAggregate(true, calls);
  }

  function testBlockAndAggregateUnsuccessful() public {
    Multicall3.Call[] memory calls = new Multicall3.Call[](2);
    calls[0] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number)
    );
    calls[1] = Multicall3.Call(
        address(callee),
        abi.encodeWithSignature("thisMethodReverts()")
    );
    vm.expectRevert(bytes("Multicall2 aggregate: call failed"));
    (
        uint256 blockNumber,
        bytes32 blockHash,
        Multicall3.Result[] memory returnData
    ) = multicall.blockAndAggregate(calls);
  }

  /// >>>>>>>>>>>>>>>>>>>  AGGREGATE3 TESTS  <<<<<<<<<<<<<<<<<<<<<< ///

  function testAggregate3() public {
    Multicall3.Call3[] memory calls = new Multicall3.Call3[](2);
    calls[0] = Multicall3.Call3(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number),
        false
    );
    calls[1] = Multicall3.Call3(
        address(callee),
        abi.encodeWithSignature("thisMethodReverts()"),
        false
    );
    (
        uint256 blockNumber,
        bytes32 blockHash,
        Multicall3.Result[] memory returnData
    ) = multicall.aggregate3(calls);
    assert(blockNumber == block.number);
    assert(blockHash == blockhash(block.number));
    assert(returnData[0].success == true);
    assert(keccak256(returnData[0].returnData) == keccak256(abi.encodePacked(blockhash(block.number))));
    assert(returnData[1].success == false);
  }

  function testAggregate3Unsuccessful() public {
    Multicall3.Call3[] memory calls = new Multicall3.Call3[](2);
    calls[0] = Multicall3.Call3(
        address(callee),
        abi.encodeWithSignature("getBlockHash(uint256)", block.number),
        false
    );
    calls[1] = Multicall3.Call3(
        address(callee),
        abi.encodeWithSignature("thisMethodReverts()"),
        true
    );
    vm.expectRevert(bytes("Multicall3 aggregate3: call failed"));
    (
        uint256 blockNumber,
        bytes32 blockHash,
        Multicall3.Result[] memory returnData
    ) = multicall.aggregate3(calls);
  }

  /// >>>>>>>>>>>>>>>>>>>>>>  HELPER TESTS  <<<<<<<<<<<<<<<<<<<<<<< ///

  function testGetBlockHash(uint256 blockNumber) public {
    assert(blockhash(blockNumber) == multicall.getBlockHash(blockNumber));
  }

  function testGetBlockNumber() public {
    assert(block.number == multicall.getBlockNumber());
  }

  function testGetCurrentBlockCoinbase() public {
    assert(block.coinbase == multicall.getCurrentBlockCoinbase());
  }

  function testGetCurrentBlockDifficulty() public {
    assert(block.difficulty == multicall.getCurrentBlockDifficulty());
  }

  function testGetCurrentBlockGasLimit() public {
    assert(block.gaslimit == multicall.getCurrentBlockGasLimit());
  }

  function testGetCurrentBlockTimestamp() public {
    assert(block.timestamp == multicall.getCurrentBlockTimestamp());
  }

  function testGetEthBalance(address addr) public {
    assert(addr.balance == multicall.getEthBalance(addr));
  }

  function testGetLastBlockHash() public {
    // Prevent arithmetic underflow on the genesis block
    if(block.number == 0) return;
    assert(blockhash(block.number - 1) == multicall.getLastBlockHash());
  }
}