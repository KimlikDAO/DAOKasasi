// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "contracts/DAOKasasi.sol";
import "contracts/DAOKasasiV0.sol";
import "contracts/Versions.sol";
import "forge-std/Test.sol";
import "interfaces/Addresses.sol";
import "interfaces/testing/MockTokens.sol";

contract Poked {
    function poke() external view {
        console.log(msg.sender);
        assert(msg.sender == DAO_KASASI);
    }
}

contract DAOKasasiV1 is IDAOKasasi {
    function redeem(
        address payable redeemer,
        uint256 burnedTokens,
        uint256 totalTokens
    ) external {}

    function distroStageUpdated(DistroStage) external {}

    function versionHash() external pure returns (bytes32) {
        return
            0x3f5e44c15812e7a9bd6973fd9e7c7da4afea4649390f7a1652d5b56caa8afeff;
    }

    function migrateToCode(IDAOKasasi codeAddress) external {}

    function poke() external view {
        Poked(TCKT_ADDR).poke();
    }
}

contract DAOKasasiV0Test is Test {
    IDAOKasasi private daoKasasiV0;
    IDAOKasasi private daoKasasi;

    function setUp() public {
        vm.prank(TCKT_DEPLOYER);
        new Poked();
        DeployMockTokens();
        vm.startPrank(DAO_KASASI_DEPLOYER);
        daoKasasi = IDAOKasasi(address(new DAOKasasi()));
        daoKasasiV0 = new DAOKasasiV0();
        vm.stopPrank();
    }

    function testAddressConsistency() public {
        assertEq(address(daoKasasi), DAO_KASASI);
        assertEq(address(daoKasasiV0), DAO_KASASI_VO);
    }

    function testRedeem() public {
        vm.prank(USDT_DEPLOYER);
        USDT.transfer(DAO_KASASI, 100e6);
        vm.prank(USDC_DEPLOYER);
        USDC.transfer(DAO_KASASI, 100e6);
        vm.prank(TRYB_DEPLOYER);
        TRYB.transfer(DAO_KASASI, 100e6);
        vm.prank(TCKO_ADDR);
        daoKasasi.redeem(payable(address(this)), 1, 100);

        assertEq(USDT.balanceOf(address(this)), 1e6);
        assertEq(USDC.balanceOf(address(this)), 1e6);
        assertEq(TRYB.balanceOf(address(this)), 1e6);
    }

    function testMigrateToCode() public {
        DAOKasasiV1 daoKasasiV1 = new DAOKasasiV1();
        vm.prank(DEV_KASASI);
        daoKasasi.migrateToCode(daoKasasiV1);
        DAOKasasiV1(address(daoKasasi)).poke();
    }

    function testAuthentication() public {
        vm.expectRevert();
        daoKasasi.redeem(payable(address(this)), 1, 100);

        vm.prank(TCKO_ADDR);
        daoKasasi.redeem(payable(address(this)), 1, 100);

        vm.expectRevert();
        daoKasasi.migrateToCode(IDAOKasasi(vm.addr(1337)));
    }
}
