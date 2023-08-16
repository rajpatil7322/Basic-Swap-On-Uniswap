// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.7;


import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Swap {
    ISwapRouter public immutable swapRouter;

    IERC20 public constant dai =IERC20(0xF14f9596430931E177469715c591513308244e8F);

    IERC20 public constant weth =IERC20(0xD087ff96281dcf722AEa82aCA57E8545EA9e6C96);

    uint24 public constant poolFee = 3000;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

        
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        // msg.sender must approve this contract

        // Transfer the specified amount of DAI to this contract.
        TransferHelper.safeTransferFrom(address(dai), msg.sender, address(this), amountIn);

        // Approve the router to spend DAI.
        TransferHelper.safeApprove(address(dai), address(swapRouter), amountIn);

                // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: address(dai),
                tokenOut: address(weth),
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }
}