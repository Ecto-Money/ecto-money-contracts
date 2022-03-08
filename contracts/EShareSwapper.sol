// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./owner/Operator.sol";

contract EShareSwapper is Operator {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    IERC20 public ecto;
    IERC20 public ebond;
    IERC20 public eshare;

    address public ectoSpookyLpPair;
    address public eshareSpookyLpPair;

    address public wftmAddress;

    address public daoAddress;

    event EBondSwapPerformed(address indexed sender, uint256 ebondAmount, uint256 eshareAmount);


    constructor(
            address _ecto,
            address _ebond,
            address _eshare,
            address _wftmAddress,
            address _ectoSpookyLpPair,
            address _eshareSpookyLpPair,
            address _daoAddress
    ) public {
        ecto = IERC20(_ecto);
        ebond = IERC20(_ebond);
        eshare = IERC20(_eshare);
        wftmAddress = _wftmAddress; 
        ectoSpookyLpPair = _ectoSpookyLpPair;
        eshareSpookyLpPair = _eshareSpookyLpPair;
        daoAddress = _daoAddress;
    }


    modifier isSwappable() {
        //TODO: What is a good number here?
        require(ecto.totalSupply() >= 60 ether, "ChipSwapMechanismV2.isSwappable(): Insufficient supply.");
        _;
    }

    function estimateAmountOfEShare(uint256 _ebondAmount) external view returns (uint256) {
        uint256 eshareAmountPerEcto = getEShareAmountPerEcto();
        return _ebondAmount.mul(eshareAmountPerEcto).div(1e18);
    }

    function swapEBondToEShare(uint256 _ebondAmount) external {
        require(getEBondBalance(msg.sender) >= _ebondAmount, "Not enough EBond in wallet");

        uint256 eshareAmountPerEcto = getEShareAmountPerEcto();
        uint256 eshareAmount = _ebondAmount.mul(eshareAmountPerEcto).div(1e18);
        require(getEShareBalance() >= eshareAmount, "Not enough EShare.");

        ebond.safeTransferFrom(msg.sender, daoAddress, _ebondAmount);
        eshare.safeTransfer(msg.sender, eshareAmount);

        emit EBondSwapPerformed(msg.sender, _ebondAmount, eshareAmount);
    }

    function withdrawEShare(uint256 _amount) external onlyOperator {
        require(getEShareBalance() >= _amount, "ChipSwapMechanism.withdrawFish(): Insufficient FISH balance.");
        eshare.safeTransfer(msg.sender, _amount);
    }

    function getEShareBalance() public view returns (uint256) {
        return eshare.balanceOf(address(this));
    }

    function getEBondBalance(address _user) public view returns (uint256) {
        return ebond.balanceOf(_user);
    }

    function getEctoPrice() public view returns (uint256) {
        return IERC20(wftmAddress).balanceOf(ectoSpookyLpPair)
            .mul(1e18)
	    .div(ecto.balanceOf(ectoSpookyLpPair));
    }

    function getESharePrice() public view returns (uint256) {
        return IERC20(wftmAddress).balanceOf(eshareSpookyLpPair)
            .mul(1e18)
            .div(eshare.balanceOf(eshareSpookyLpPair));
    }

    function getEShareAmountPerEcto() public view returns (uint256) {
        uint256 ectoPrice = IERC20(wftmAddress).balanceOf(ectoSpookyLpPair)
            .mul(1e18)
	    .div(ecto.balanceOf(ectoSpookyLpPair));

        uint256 esharePrice =
            IERC20(wftmAddress).balanceOf(eshareSpookyLpPair)
	    .mul(1e18)
            .div(eshare.balanceOf(eshareSpookyLpPair));
            

        return ectoPrice.mul(1e18).div(esharePrice);
    }

}