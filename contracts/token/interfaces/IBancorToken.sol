// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

import "./IERC20Token.sol";

interface IBancorToken is IERC20Token{

    function issue(address _to, uint256 _amount) external returns(bool);
    function destroy(address _from, uint256 _amount) external returns(bool);
    function issueByBancor(uint256 _amount) external returns(bool);
}
