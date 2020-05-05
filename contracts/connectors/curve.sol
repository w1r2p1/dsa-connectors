pragma solidity ^0.6.0;

// import files from common directory
import { TokenInterface , MemoryInterface, EventInterface} from "../common/interfaces.sol";
import { Stores } from "../common/stores.sol";
import { DSMath } from "../common/math.sol";

interface ICurve {
    function get_virtual_price() external returns (uint256 out);

    function underlying_coins(int128 i) external view returns (address token);

    function calc_token_amount(uint256[4] calldata amounts, bool deposit) external returns (uint256 amount);

    function add_liquidity(uint256[4] calldata amounts, uint256 min_mint_amount) external;

    function get_dy(int128 i, int128 j, uint256 dx)
        external
        returns (uint256 out);

    function get_dy_underlying(int128 i, int128 j, uint256 dx)
        external
        returns (uint256 out);

    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function remove_liquidity(
        uint256 _amount,
        uint256[4] calldata min_amounts
    ) external;

    function remove_liquidity_imbalance(uint256[4] calldata amounts, uint256 max_burn_amount)
        external;
}

interface ICurveZap {
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external returns (uint256 amount);

    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount
    ) external;

}


contract CurveHelpers is Stores, DSMath {
    /**
     * @dev Return Curve Swap Address
     */
    function getCurveSwapAddr() internal pure returns (address) {
        return 0xA5407eAE9Ba41422680e2e00537571bcC53efBfD;
    }

    /**
     * @dev Return Curve Token Address
     */
    function getCurveTokenAddr() internal pure returns (address) {
        return 0xC25a3A3b969415c80451098fa907EC722572917F;
    }

    /**
     * @dev Return Curve Zap Address
     */
    function getCurveZapAddr() internal pure returns (address) {
        return 0xFCBa3E75865d2d561BE8D220616520c171F12851;
    }

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = (_amt / 10 ** (18 - _dec));
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = mul(_amt, 10 ** (18 - _dec));
    }

    function getTokenI(address token) internal pure returns (int128 i) {
        if (token == address(0x6B175474E89094C44Da98b954EedeAC495271d0F)) {
            // DAI Token
            i = 0;
        } else if (token == address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48)) {
            // USDC Token
            i = 1;
        } else if (token == address(0xdAC17F958D2ee523a2206206994597C13D831ec7)) {
            // USDT Token
            i = 2;
        } else if (token == address(0x57Ab1ec28D129707052df4dF418D58a2D46d5f51)) {
            // sUSD Token
            i = 3;
        } else {
            revert("token-not-found.");
        }
    }

    function getTokenAddr(ICurve curve, uint256 i) internal view returns (address token) {
        token = curve.underlying_coins(int128(i));
        require(token != address(0), "token-not-found.");
    }
}


contract CurveProtocol is CurveHelpers {

     event LogSell(
        address indexed buyToken,
        address indexed sellToken,
        uint256 buyAmt,
        uint256 sellAmt,
        uint256 getId,
        uint256 setId
    );
    event LogDepositLiquidity(uint256[4] amts, uint256 mintAmt, uint256[4] getId,  uint256 setId);
    event LogWithdrawLiquidityImbalance(uint256[4] amts, uint256 burnAmt, uint256[4] getId,  uint256 setId);
    event LogWithdrawLiquidityOneCoin(address receiveCoin, uint256 withdrawnAmt, uint256 curveAmt, uint256 getId,  uint256 setId);

    function exchange(address buyAddr, address sellAddr, uint256 sellAmt, uint256 unitAmt, uint getId, uint setId) external {
        uint _sellAmt = getUint(getId, sellAmt);
        ICurve curve = ICurve(getCurveSwapAddr());
        TokenInterface _buyToken = TokenInterface(buyAddr);
        TokenInterface _sellToken = TokenInterface(sellAddr);
        _sellAmt = _sellAmt == uint(-1) ? _sellToken.balanceOf(address(this)) : _sellAmt;
        _sellToken.approve(address(curve), _sellAmt);

        uint initalBal = _buyToken.balanceOf(address(this));
        uint _sellAmt18 = convertTo18(_sellToken.decimals(), _sellAmt);
        uint _slippageAmt = convert18ToDec(_buyToken.decimals(), wmul(unitAmt, _sellAmt18));

        curve.exchange(getTokenI(sellAddr), getTokenI(buyAddr), _sellAmt, _slippageAmt);

        uint finialBal = _buyToken.balanceOf(address(this));

        uint256 _buyAmt = sub(finialBal, initalBal);
        setUint(setId, _buyAmt);

        emit LogSell(buyAddr, sellAddr, _buyAmt, _sellAmt, getId, setId);
        bytes32 _eventCode = keccak256("LogSell(address,address,uint256,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(buyAddr, sellAddr, _buyAmt, _sellAmt, getId, setId);
        emitEvent(_eventCode, _eventParam);

    }

    function deposit(uint256[4] calldata amounts, uint256 slippage, uint256[4] calldata getId, uint256 setId) external {
        uint256[4] memory _amts;
        ICurve curve = ICurve(getCurveSwapAddr());

        for(uint256 i = 0; i < 4; i++) {
            uint256 _amt = getUint(getId[i], amounts[i]);
            TokenInterface token = TokenInterface(getTokenAddr(curve, i));
            _amt = _amt == uint(-1) ? token.balanceOf(address(this)) : _amt;
            _amts[i] = _amt;
            if(_amt == 0) continue;
            token.approve(address(curve), _amt);
        }

        uint256 min_mint_amount = ICurve(address(curve)).calc_token_amount(_amts, true);
        curve.add_liquidity(_amts, mul(min_mint_amount, sub(100, slippage)) / 100);

        uint256 mintAmount = TokenInterface(getCurveTokenAddr()).balanceOf(address(this));
        emit LogDepositLiquidity(_amts, mintAmount, getId, setId);
        bytes32 _eventCode = keccak256("LogDepositLiquidity(uint256[],uint256,uint256[],uint256)");
        bytes memory _eventParam = abi.encode(_amts, mintAmount, getId, setId);
        emitEvent(_eventCode, _eventParam);
    }

    function withdraw_imbalance(uint256[4] calldata amounts, uint256[4] calldata getId, uint256 setId) external {
        uint256[4] memory _amts;
        ICurve curve = ICurve(getCurveSwapAddr());

        for(uint256 i = 0; i < 4; i++) {
            uint256 _amt = getUint(getId[i], amounts[i]);
            _amt = _amt == uint(-1) ? TokenInterface(getTokenAddr(curve, i)).balanceOf(address(this)) : _amt;
            _amts[i] = _amt;
        }

        uint256 max_burn_amount = curve.calc_token_amount(_amts, false);
        uint256 balance = TokenInterface(getCurveTokenAddr()).balanceOf(address(this));

        curve.remove_liquidity_imbalance(_amts, mul(max_burn_amount, 101) / 100);

        uint burnAmount = sub(balance, TokenInterface(getCurveTokenAddr()).balanceOf(address(this)));
        emit LogWithdrawLiquidityImbalance(_amts, burnAmount, getId, setId);
        bytes32 _eventCode = keccak256("LogWithdrawLiquidityImbalance(uint256[],uint256,uint256[],uint256)");
        bytes memory _eventParam = abi.encode(_amts, burnAmount, getId, setId);
        emitEvent(_eventCode, _eventParam);
    }

    function withdraw_one_coin(address token, uint256 amt, uint256 slippage, uint getId, uint setId) external {
        uint _amt = getUint(getId, amt);
        int128 i = getTokenI(token);

        TokenInterface curveTokenContract = TokenInterface(getCurveTokenAddr());
        TokenInterface tokenContract = TokenInterface(token);
        ICurveZap curveZap = ICurveZap(getCurveZapAddr());

        _amt = _amt == uint(-1) ? curveTokenContract.balanceOf(address(this)) : _amt;
        curveTokenContract.approve(address(curveZap), _amt);

        uint256 min_uamount = curveZap.calc_withdraw_one_coin(_amt, i);
        min_uamount = mul(min_uamount, sub(100, slippage) / 100);

        uint256 intialBal = tokenContract.balanceOf(address(this));

        curveZap.remove_liquidity_one_coin(_amt, i, min_uamount);

        uint256 finalBal = tokenContract.balanceOf(address(this));
        uint256 withdrawnAmt = sub(finalBal, intialBal);

        emit LogWithdrawLiquidityOneCoin(token, withdrawnAmt, _amt, getId, setId);
        bytes32 _eventCode = keccak256("LogWithdrawLiquidityOneCoin(address,uint256,uint256,uint256,uint256)");
        bytes memory _eventParam = abi.encode(token, withdrawnAmt, _amt, getId, setId);
        emitEvent(_eventCode, _eventParam);
    }

}

contract ConnectCurve is CurveProtocol {
    string public name = "Curve-v1";
}
