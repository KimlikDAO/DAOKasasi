//SPDX-License-Identifier: MIT
//🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿

pragma solidity 0.8.15;

import "interfaces/IDAOKasasi.sol";
import "interfaces/Tokens.sol";
import {DEV_KASASI, TCKO_ADDR} from "interfaces/Addresses.sol";

contract DAOKasasiV0 is IDAOKasasi {
    function redeem(
        address payable redeemer,
        uint256 amount,
        uint256 totalSupply
    ) external {
        require(msg.sender == TCKO_ADDR);

        IERC20[7] memory tokens = [FRAX, MIM, TRYB, USDC, USDD, USDT, YUSD];
        for (uint256 i = 0; i < tokens.length; ++i) {
            uint256 toSend = (tokens[i].balanceOf(address(this)) * amount) /
                totalSupply;
            if (toSend > 0) tokens[i].transfer(redeemer, toSend);
        }

        uint256 toSendNative = (address(this).balance * amount) / totalSupply;
        if (toSendNative > 0) redeemer.transfer(toSendNative);
    }

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
