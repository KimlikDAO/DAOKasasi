// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import {CODE_SLOT} from "interfaces/ERC1967.sol";
import {DAO_KASASI_V1} from "./DAOKasasiV1.sol";

contract DAOKasasi {
    constructor() {
        assembly {
            sstore(CODE_SLOT, DAO_KASASI_V1)
        }
    }

    /**
     * DAOKasası does not reach to native token receipt so that ERC-20 assets and
     * the native token behaves the same way.
     */
    receive() external payable {}

    fallback() external payable {
        assembly {
            let codeAddress := sload(CODE_SLOT)
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                codeAddress,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
