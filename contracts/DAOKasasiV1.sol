// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "interfaces/AvalancheTokens.sol";
import {CODE_SLOT} from "interfaces/ERC1967.sol";
import {DistroStage, IDAOKasasi} from "interfaces/IDAOKasasi.sol";
import {OYLAMA, TCKO_ADDR} from "interfaces/Addresses.sol";

address constant DAO_KASASI_V1 = 0x4DB9cbE44bF9B747Cd3F3fEfEFbfDb2f2DaA8Cf5;

contract DAOKasasiV1 is IDAOKasasi {
    function redeem(
        address payable redeemer,
        uint256 amount,
        uint256 totalSupply
    ) external {
        require(msg.sender == TCKO_ADDR);

        IERC20[4] memory tokens = [IERC20(USDT), USDC, TRYB, BUSD];
        for (uint256 i = 0; i < tokens.length; ++i) {
            uint256 toSend = (tokens[i].balanceOf(address(this)) * amount) /
                totalSupply;
            if (toSend > 0) tokens[i].transfer(redeemer, toSend);
        }

        uint256 toSendNative = (address(this).balance * amount) / totalSupply;
        if (toSendNative > 0) redeemer.transfer(toSendNative);
    }

    function distroStageUpdated(DistroStage) external {}

    function migrateToCode(IDAOKasasi newCode) external {
        require(msg.sender == OYLAMA);
        require(
            // keccak256("DAOKasasiV2")
            newCode.versionHash() ==
                0x2d7821c610b81500eb7161a82514071bd27c2ea4bcd376b4e2641a3478f8227c
        );
        assembly {
            sstore(CODE_SLOT, newCode)
        }
    }

    function versionHash() external pure returns (bytes32) {
        // keccak256("DAOKasasiV1")
        return
            0x3f5e44c15812e7a9bd6973fd9e7c7da4afea4649390f7a1652d5b56caa8afeff;
    }
}
