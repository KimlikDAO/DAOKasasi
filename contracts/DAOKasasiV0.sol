//SPDX-License-Identifier: MIT
//🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿

pragma solidity 0.8.15;

import "interfaces/Addresses.sol";
import "interfaces/IDAOKasasi.sol";

contract DAOKasasiV0 is IDAOKasasi {
    function redeem(
        address payable,
        uint256,
        uint256
    ) external {}

    function distroStageUpdated(DistroStage) external {}

    function migrateToCode(address codeAddress) external {
        require(msg.sender == DEV_KASASI);
        require(
            // ethers.utils.keccak256(ethers.utils.toUtf8Bytes("DAOKasasiV1"))
            bytes32(
                0x3f5e44c15812e7a9bd6973fd9e7c7da4afea4649390f7a1652d5b56caa8afeff
            ) == IDAOKasasi(codeAddress).versionHash()
        );
        assembly {
            sstore(ERC1967_CODE_SLOT, codeAddress)
        }
    }

    function versionHash() external pure returns (bytes32) {
        return 0;
    }
}
