// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 
@title FlashloanVolumeResponse
@notice Minimal Drosera response contract that only logs incidents.
@dev Works even when response_contract has no active control logic.*/
contract FlashloanVolumeResponse {
    address public owner;

    event FlashloanIncident(
        uint256 blockNumber,
        uint256 spikeAmount,
        bytes data
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// Called by Drosera when trap triggers.
    /// incidentData format: abi.encode(currentVolume, avgVolume, spikeBps)
    function respondToIncident(bytes calldata incidentData) external {
        // decode what trap sent:
        (uint256 currentVol, uint256 avgVol, uint256 spikeBps) =
            abi.decode(incidentData, (uint256, uint256, uint256));

        emit FlashloanIncident(block.number, spikeBps, incidentData);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
