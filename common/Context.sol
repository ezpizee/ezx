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
 * Ezpizee Co., Ltd. (last updated v0.0.1) (/common/Context.sol)
 *
 * The Smart Contract Context
 */

pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}