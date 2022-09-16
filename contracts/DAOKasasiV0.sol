// SPDX-License-Identifier: MIT
// 🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿🧿

pragma solidity 0.8.16;

import "interfaces/AvalancheTokens.sol";
import "interfaces/IDAOKasasi.sol";
import {DEV_KASASI, TCKO_ADDR} from "interfaces/Addresses.sol";

contract DAOKasasiV0 is IDAOKasasi {
    function redeem(
        address payable redeemer,
        uint256 amount,
        uint256 totalSupply
    ) external {
        require(msg.sender == TCKO_ADDR);

        IERC20[3] memory tokens = [IERC20(USDT), USDC, TRYB];
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
        require(msg.sender == DEV_KASASI);
        require(
            // keccak256("DAOKasasiV1")
            bytes32(
                0x3f5e44c15812e7a9bd6973fd9e7c7da4afea4649390f7a1652d5b56caa8afeff
            ) == newCode.versionHash()
        );
        assembly {
            sstore(ERC1967_CODE_SLOT, newCode)
        }
    }

    function versionHash() external pure returns (bytes32) {
        return 0;
    }
}
