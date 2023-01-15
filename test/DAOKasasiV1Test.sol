// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "contracts/DAOKasasi.sol";
import "contracts/DAOKasasiV1.sol";
import "forge-std/Test.sol";
import "interfaces/Addresses.sol";
import "interfaces/testing/MockTokens.sol";

contract Poked {
    function poke() external view {
        console.log(msg.sender);
        assert(msg.sender == DAO_KASASI);
    }
}

contract MockDAOKasasiV2 is IDAOKasasi {
    function redeem(uint256 amountSupplyRedeemer) external {}

    function distroStageUpdated(DistroStage) external {}

    function versionHash() external pure returns (bytes32) {
        return keccak256("DAOKasasiV2");
    }

    function migrateToCode(IDAOKasasi codeAddress) external {}

    function poke() external view {
        Poked(TCKT_ADDR).poke();
    }
}

contract MockBadDAOKasasiV2 is IDAOKasasi {
    function redeem(uint256 amountSupplyRedeemer) external {}

    function distroStageUpdated(DistroStage) external {}

    function versionHash() external pure returns (bytes32) {
        return keccak256("DAOKasasiV2-bad");
    }

    function migrateToCode(IDAOKasasi codeAddress) external {}
}

contract MockTCKT {
    function sweepNativeToken() external {
        DAO_KASASI.transfer(address(this).balance);
    }
}

contract DAOKasasiV1Test is Test {
    IDAOKasasi private daoKasasiV1;
    IDAOKasasi private daoKasasi;

    function setUp() public {
        vm.prank(TCKT_DEPLOYER);
        new Poked();
        DeployMockTokens();
        vm.startPrank(DAO_KASASI_DEPLOYER);
        daoKasasi = IDAOKasasi(address(new DAOKasasi()));
        daoKasasiV1 = new DAOKasasiV1();
        vm.stopPrank();
    }

    function testAddressConsistency() public {
        assertEq(address(daoKasasi), DAO_KASASI);
        assertEq(address(daoKasasiV1), DAO_KASASI_V1);
    }

    receive() external payable {}

    function testRedeemAllPresent() public {
        // Set initial balance of this contract to 1e18.
        vm.deal(address(this), 1e18);
        vm.deal(DAO_KASASI, 100e18);
        vm.prank(USDT_DEPLOYER);
        USDT.transfer(DAO_KASASI, 100e6);
        vm.prank(USDC_DEPLOYER);
        USDC.transfer(DAO_KASASI, 100e6);
        vm.prank(TRYB_DEPLOYER);
        TRYB.transfer(DAO_KASASI, 100e6);
        vm.prank(BUSD_DEPLOYER);
        BUSD.transfer(DAO_KASASI, 100e6);
        vm.prank(TCKO_ADDR);
        daoKasasi.redeem(
            (uint256(1) << AMOUNT_OFFSET) |
                (uint256(100) << SUPPLY_OFFSET) |
                uint160(address(this))
        );

        assertEq(USDT.balanceOf(address(this)), 1e6);
        assertEq(USDC.balanceOf(address(this)), 1e6);
        assertEq(TRYB.balanceOf(address(this)), 1e6);
        assertEq(BUSD.balanceOf(address(this)), 1e6);
        assertEq(address(this).balance, 2e18);
    }

    function testRedeemNativeTokenPresent() public {
        uint256 balance = address(this).balance;
        vm.deal(DAO_KASASI, 5);

        vm.prank(TCKO_ADDR);
        daoKasasi.redeem(
            (uint256(1) << AMOUNT_OFFSET) |
                (uint256(5) << SUPPLY_OFFSET) |
                uint160(address(this))
        );

        assertEq(address(this).balance, balance + 1);
    }

    function testRedeemNativeTokenNotPresent() public {
        uint256 balance = address(this).balance;
        vm.deal(DAO_KASASI, 0);

        vm.prank(TCKO_ADDR);
        daoKasasi.redeem(
            (uint256(1) << AMOUNT_OFFSET) |
                (uint256(5) << SUPPLY_OFFSET) |
                uint160(address(this))
        );

        assertEq(address(this).balance, balance);

        vm.prank(TCKO_ADDR);
        daoKasasi.redeem(
            (uint256(1) << AMOUNT_OFFSET) |
                (uint256(5) << SUPPLY_OFFSET) |
                uint160(address(this))
        );

        assertEq(address(this).balance, balance);
    }

    function testMigrateToCode() public {
        assertEq(daoKasasi.versionHash(), keccak256("DAOKasasiV1"));

        IDAOKasasi badDaoKasasiV2 = new MockBadDAOKasasiV2();
        vm.expectRevert();
        daoKasasi.migrateToCode(badDaoKasasiV2);
        vm.prank(OYLAMA);
        vm.expectRevert();
        daoKasasi.migrateToCode(badDaoKasasiV2);

        MockDAOKasasiV2 daoKasasiV2 = new MockDAOKasasiV2();
        vm.expectRevert();
        daoKasasi.migrateToCode(daoKasasiV2);
        vm.prank(OYLAMA);
        daoKasasi.migrateToCode(daoKasasiV2);
        MockDAOKasasiV2(address(daoKasasi)).poke();
    }

    function testAuthentication() public {
        vm.expectRevert();
        daoKasasi.redeem(
            (uint256(1) << AMOUNT_OFFSET) |
                (uint256(100) << SUPPLY_OFFSET) |
                uint160(address(this))
        );

        vm.prank(TCKO_ADDR);
        daoKasasi.redeem(
            (uint256(1) << AMOUNT_OFFSET) |
                (uint256(100) << SUPPLY_OFFSET) |
                uint160(address(this))
        );

        vm.expectRevert();
        daoKasasi.migrateToCode(IDAOKasasi(vm.addr(1337)));

        daoKasasi.distroStageUpdated(DistroStage.Presale2);
    }

    function testCollectPaymentSweep() public {
        vm.prank(TCKT_DEPLOYER);
        MockTCKT tckt = new MockTCKT();

        vm.deal(address(tckt), 88e18);
        tckt.sweepNativeToken();

        assertEq(address(tckt).balance, 0);
        assertEq(address(daoKasasi).balance, 88e18);
    }
}
