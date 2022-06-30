import subprocess

import rlp
from eth_account import Account
from eth_utils import keccak, to_bytes, to_checksum_address


def contract_address(sender: str, nonce=0) -> str:
    sender_bytes = to_bytes(hexstr=sender)
    raw = rlp.encode([sender_bytes, nonce])
    h = keccak(raw)
    address_bytes = h[12:]
    return to_checksum_address(address_bytes)


print(contract_address("0xD0C8568eb0E0f99786882511eD24762dCA447E06", 1))
