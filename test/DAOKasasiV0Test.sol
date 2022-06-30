//SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "contracts/DAOKasasiV0.sol";
import "contracts/Versions.sol";
import "forge-std/Test.sol";
import "interfaces/Addresses.sol";

contract DAOKasasiV0Test is Test {
    IDAOKasasi private daoKasasi;

    function setUp() public {
        vm.setNonce(DAO_KASASI_DEPLOYER, 1);
        vm.prank(DAO_KASASI_DEPLOYER);
        daoKasasi = new DAOKasasiV0();

        assertEq(address(daoKasasi), DAO_KASASI_VO);
    }

    function testAuthentication() public {
        vm.expectRevert();
        daoKasasi.redeem(payable(address(this)), 1, 100);

        vm.expectRevert();
        daoKasasi.migrateToCode(vm.addr(1337));
    }
}
