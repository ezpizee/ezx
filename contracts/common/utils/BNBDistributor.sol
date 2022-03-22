/**
 * Ezpizee is about building an ecosystem of web3 services and applications to enable and promote
 * a decentralised digital economy.
 *
 * Web: https://www.ezpizee.com
 * Telegram: https://t.me/ezx
 * Twitter: https://twitter.com/ezpizee
 *
 * SPDX-License-Identifier: MIT
 *
 *  ______  ______  ____      ___
 * |  ____||___  / |__  \   /  __\
 * | |__      / /      \ \ / /
 * |  __|    / /       / /\ \
 * | |___   / /__   __/ /  \ \___
 * |______|/_____\ |___/    \____\
 *
 * Ezpizee Co., Ltd. (last updated v0.0.1) (/contracts/common/utils/BNBDistributor.sol)
 *
 * To distribute BNB to holders
 */

pragma solidity ^0.8.4;

import "./SafeMath.sol";
import "../dex/IDividendDistributor.sol";
import "../dex/IDEXRouter.sol";

contract BNBDistributor is IDividendDistributor {

    using SafeMath for uint256;

    address _token;
    address charityReceiver;
    address marketingReceiver;
    address liquidityReceiver;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    address WBNB;
    IDEXRouter router;

    mapping(address => uint256) _shareAmount;
    mapping(address => uint256) _shareEntry;
    mapping(address => uint256) _accured;
    uint256 _totalShared;
    uint256 _totalReward;
    uint256 _totalAccured;
    uint256 _stakingMagnitude;

    uint256 public minAmount = 0;

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _wbnb, address _router, address _charityReceiver, address _marketingReceiver, address _liquidityReceiver) {
        WBNB = _wbnb;
        router = IDEXRouter(_router);
        _token = msg.sender;
        charityReceiver = _charityReceiver;
        marketingReceiver = _marketingReceiver;
        liquidityReceiver = _liquidityReceiver;

        _stakingMagnitude = (5 ** (9 + 9)) / 2; // 500 million
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        // Shareholder has given up their Reward Share
        if (amount < 1000000000) {
            uint256 current_rewards = currentRewards(shareholder);
            if (current_rewards > 0) {
                distributeDividend(shareholder, marketingReceiver);
            }

            _accured[shareholder] = _accured[shareholder] - _accured[shareholder];
            _totalShared = _totalShared - _shareAmount[shareholder];

            _shareAmount[shareholder] = _shareAmount[shareholder] - _shareAmount[shareholder];
            _shareEntry[shareholder] = _totalAccured;
        } else {
            if (_shareAmount[shareholder] > 0) {
                _accured[shareholder] = currentRewards(shareholder);
            }

            _totalShared = _totalShared.sub(_shareAmount[shareholder]).add(amount);
            _shareAmount[shareholder] = amount;

            _shareEntry[shareholder] = _totalAccured;
        }
    }

    function getWalletShare(address shareholder) public view returns (uint256) {
        return _shareAmount[shareholder];
    }

    function deposit(uint256 amount) external override onlyToken {
        _totalReward = _totalReward + amount;
        _totalAccured = _totalAccured + amount * _stakingMagnitude / _totalShared;
    }

    function distributeDividend(address shareholder, address receiver) internal {
        if(_shareAmount[shareholder] == 0){ return; }

        _accured[shareholder] = currentRewards(shareholder);
        require(_accured[shareholder] > minAmount, "Reward amount has to be more than minimum amount");

        payable(receiver).transfer(_accured[shareholder]);
        _totalReward = _totalReward - _accured[shareholder];
        _accured[shareholder] = _accured[shareholder] - _accured[shareholder];

        _shareEntry[shareholder] = _totalAccured;
    }

    function claimDividend(address shareholder) external override onlyToken {
        uint256 amount = currentRewards(shareholder);
        if (amount == 0) {
            return;
        }

        distributeDividend(shareholder, shareholder);
    }

    function setCharityFeeReceiver(address _receiver) external onlyToken {
        charityReceiver = _receiver;
    }

    function setMarketingFeeReceiver(address _receiver) external onlyToken {
        marketingReceiver = _receiver;
    }

    function setLiquidityFeeReceiver(address _receiver) external onlyToken {
        liquidityReceiver = _receiver;
    }

    function donate(address shareholder) onlyToken external {
        distributeDividend(shareholder, charityReceiver);
    }

    function buyToken(address shareholder) external onlyToken {
        if(_shareAmount[shareholder] == 0){ return; }

        uint256 amount = currentRewards(shareholder);

        if (amount == 0) { return; }

        _accured[shareholder] = amount;

        uint256 amountToCharity = amount.mul(2).div(100);
        uint256 amountToLiquify = amount.mul(3).div(100).div(2);
        uint256 walletAmount = amount.mul(95).div(100);

        uint256 amountToSwap = amountToLiquify.add(walletAmount);

        // Pay charity fee
        payable(charityReceiver).transfer(amountToCharity);

        address[] memory path = new address[](2);
        path[0] = WBNB;
        path[1] = _token;

        uint256 balanceBefore = IBEP20(_token).balanceOf(address(this));

        IBEP20(_token).approve(address(router), amountToSwap);
        // Buy more tokens with the BNB of the shareholder and send to them
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountToSwap}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 swapBalance = IBEP20(_token).balanceOf(address(this)).sub(balanceBefore);
        uint256 amountTokensToLiquify = swapBalance.mul(3).div(98);
        uint256 amountTokensToShareholder = swapBalance.sub(amountTokensToLiquify);

        if (amountTokensToShareholder > 0) {
            IBEP20(_token).transfer(shareholder, amountTokensToShareholder);
        }

        if (amountTokensToLiquify > 0 && amountToLiquify > 0){
            IBEP20(_token).approve(address(router), amountTokensToLiquify);
            router.addLiquidityETH{ value: amountToLiquify }(
                _token,
                amountTokensToLiquify,
                0,
                0,
                liquidityReceiver,
                block.timestamp
            );
        }

        _totalReward = _totalReward - _accured[shareholder];
        _accured[shareholder] = _accured[shareholder] - _accured[shareholder];

        _shareEntry[shareholder] = _totalAccured;
    }

    function depositExternalBNB(uint256 amount) external onlyToken {
        _totalReward = _totalReward + amount;
        _totalAccured = _totalAccured + amount * _stakingMagnitude / _totalShared;
    }

    function _calculateReward(address addy) private view returns (uint256) {
        return _shareAmount[addy] * (_totalAccured - _shareEntry[addy]) / _stakingMagnitude;
    }

    function currentRewards(address addy) public view returns (uint256) {
        uint256 totalRewards = address(this).balance;

        uint256 calcReward = _accured[addy] + _calculateReward(addy);

        // Fail safe to ensure rewards are never more than the contract holding.
        if (calcReward > totalRewards) {
            return totalRewards;
        }

        return calcReward;
    }

    receive() external payable { }
}