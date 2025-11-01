
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "./interfaces/ITrap.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
}

/// @title FlashloanVolumeTrap
/// @notice Detects sudden spikes in token supply or liquidity volume (e.g. from flashloans)
contract FlashloanVolumeTrap is ITrap {
    // ✅ Verified ERC20 token on Hoodi testnet
    address public constant TOKEN = 0x7728A33EBEBCfa852cf7f7Fc377BfC87C24a701A;
    uint256 public constant THRESHOLD_BPS = 3000; // 30%

    function collect() external view override returns (bytes memory) {
        uint256 metric = 1;

        try IERC20(TOKEN).totalSupply() returns (uint256 s) {
            if (s > 0) metric = s;
        } catch {
            metric = 1;
        }

        return abi.encode(metric);
    }

    function shouldRespond(bytes[] calldata data)
        external
        pure
        override
        returns (bool incident, bytes memory responseData)
    {
        uint256 len = data.length;
        if (len < 2) return (false, "");

        uint256 sum;
        uint256 count = len - 1;

        for (uint256 i = 1; i < len; i++) {
            sum += abi.decode(data[i], (uint256));
        }

        uint256 avg = sum / count;
        uint256 latest = abi.decode(data[0], (uint256));

        if (avg == 0) return (false, "");

        if (latest > avg) {
            uint256 diff = latest - avg;
            uint256 diffBps = (diff * 10000) / avg;
            if (diffBps >= THRESHOLD_BPS) {
                return (true, abi.encode(latest, avg, diffBps));
            }
        }

        return (false, "");
    }
}
