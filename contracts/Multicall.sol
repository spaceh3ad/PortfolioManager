contract Multicall {
    function multiCall(address[] calldata targets) external {
        for(uint i; i<targets.length;i++) {
            targets[i].staticcall(latestRoundData)
        }
     }
}