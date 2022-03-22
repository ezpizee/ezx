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

import {BEP20} from "./common/protocol/BEP20/BEP20.sol";
import {SafeMath} from "./common/utils/SafeMath.sol";

contract EZXToken is BEP20 {

    using SafeMath for uint256;

    string  constant _name = "Ezpizee Token T1";
    string  constant _symbol = "EZXT1";
    uint8   constant _decimals = 9;
    uint256 _totalSupply = 10 ** (9 + _decimals); // 1 billion

    constructor() BEP20(_name, _symbol) {
        _mint(msg.sender, _totalSupply);
    }
}