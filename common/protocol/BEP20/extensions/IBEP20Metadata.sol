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
 * Ezpizee Co., Ltd. (last updated v0.0.1) (/common/protocol/BEP20/extensions/IBEP20Metadata.sol)
 */

pragma solidity ^0.8.0;

import "../IBEP20.sol";

/**
 * @dev Interface for the optional metadata functions from the BEP20 standard.
 *
 * _Available since v0.0.1
 */
interface IBEP20Metadata is IBEP20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
