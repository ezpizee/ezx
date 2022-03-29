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
 * Ezpizee Co., Ltd. (last updated v0.0.1) (contracts/EZXToken.sol)
 */

pragma solidity ^0.8.4;

import "../common/protocol/BEP20/BEP20.sol";

contract EZXBEP20Token is BEP20 {

    string constant _name = "Ezpizee Token";
    string constant _symbol = "EZX";
    uint8 constant _decimals = 9;
    uint256 constant _totalSupply = 1000000000 * 10 ** (9 + _decimals); // 1 billion

    constructor() BEP20(_name, _symbol) {
        _mint(msg.sender, _totalSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}