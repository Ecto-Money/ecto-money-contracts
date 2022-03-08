// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

contract TaxOfficeV2 is Operator {
    using SafeMath for uint256;

    address public ecto = address(0x3Ccf8274A57dEa42E6538Dc0B53FAC5cf49e64cF);
    address public wftm = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
    address public uniRouter = address(0xF491e7B69E4244ad4002BC14e878a34207E38c29);

    mapping(address => bool) public taxExclusionEnabled;

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(ecto).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(ecto).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(ecto).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(ecto).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(ecto).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(ecto).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(ecto).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return _excludeAddressFromTax(_address);
    }

    function _excludeAddressFromTax(address _address) private returns (bool) {
        if (!ITaxable(ecto).isAddressExcluded(_address)) {
            return ITaxable(ecto).excludeAddress(_address);
        }
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return _includeAddressInTax(_address);
    }

    function _includeAddressInTax(address _address) private returns (bool) {
        if (ITaxable(ecto).isAddressExcluded(_address)) {
            return ITaxable(ecto).includeAddress(_address);
        }
    }

    function taxRate() external view returns (uint256) {
        return ITaxable(ecto).taxRate();
    }

    function addLiquidityTaxFree(
        address token,
        uint256 amtEcto,
        uint256 amtToken,
        uint256 amtEctoMin,
        uint256 amtTokenMin
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtEcto != 0 && amtToken != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(ecto).transferFrom(msg.sender, address(this), amtEcto);
        IERC20(token).transferFrom(msg.sender, address(this), amtToken);
        _approveTokenIfNeeded(ecto, uniRouter);
        _approveTokenIfNeeded(token, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtEcto;
        uint256 resultAmtToken;
        uint256 liquidity;
        (resultAmtEcto, resultAmtToken, liquidity) = IUniswapV2Router(uniRouter).addLiquidity(
            ecto,
            token,
            amtEcto,
            amtToken,
            amtEctoMin,
            amtTokenMin,
            msg.sender,
            block.timestamp
        );

        if(amtEcto.sub(resultAmtEcto) > 0) {
            IERC20(ecto).transfer(msg.sender, amtEcto.sub(resultAmtEcto));
        }
        if(amtToken.sub(resultAmtToken) > 0) {
            IERC20(token).transfer(msg.sender, amtToken.sub(resultAmtToken));
        }
        return (resultAmtEcto, resultAmtToken, liquidity);
    }

    function addLiquidityETHTaxFree(
        uint256 amtEcto,
        uint256 amtEctoMin,
        uint256 amtFtmMin
    )
        external
        payable
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtEcto != 0 && msg.value != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(ecto).transferFrom(msg.sender, address(this), amtEcto);
        _approveTokenIfNeeded(ecto, uniRouter);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtEcto;
        uint256 resultAmtFtm;
        uint256 liquidity;
        (resultAmtEcto, resultAmtFtm, liquidity) = IUniswapV2Router(uniRouter).addLiquidityETH{value: msg.value}(
            ecto,
            amtEcto,
            amtEctoMin,
            amtFtmMin,
            msg.sender,
            block.timestamp
        );

        if(amtEcto.sub(resultAmtEcto) > 0) {
            IERC20(ecto).transfer(msg.sender, amtEcto.sub(resultAmtEcto));
        }
        return (resultAmtEcto, resultAmtFtm, liquidity);
    }

    function setTaxableEctoOracle(address _ectoOracle) external onlyOperator {
        ITaxable(ecto).setEctoOracle(_ectoOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(ecto).setTaxOffice(_newTaxOffice);
    }

    function taxFreeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amt
    ) external {
        require(taxExclusionEnabled[msg.sender], "Address not approved for tax free transfers");
        _excludeAddressFromTax(_sender);
        IERC20(ecto).transferFrom(_sender, _recipient, _amt);
        _includeAddressInTax(_sender);
    }

    function setTaxExclusionForAddress(address _address, bool _excluded) external onlyOperator {
        taxExclusionEnabled[_address] = _excluded;
    }

    function _approveTokenIfNeeded(address _token, address _router) private {
        if (IERC20(_token).allowance(address(this), _router) == 0) {
            IERC20(_token).approve(_router, type(uint256).max);
        }
    }
}