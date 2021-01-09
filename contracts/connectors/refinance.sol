pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface TokenInterface {
    function approve(address, uint256) external;
    function transfer(address, uint) external;
    function transferFrom(address, address, uint) external;
    function deposit() external payable;
    function withdraw(uint) external;
    function balanceOf(address) external view returns (uint);
    function decimals() external view returns (uint);
}

// Compound Helpers
interface CTokenInterface {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
    function repayBorrowBehalf(address borrower, uint repayAmount) external returns (uint); // For ERC20
    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) external returns (uint);

    function borrowBalanceCurrent(address account) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function exchangeRateCurrent() external returns (uint);

    function balanceOf(address owner) external view returns (uint256 balance);
    function transferFrom(address, address, uint) external returns (bool);
}

interface CETHInterface {
    function mint() external payable;
    function repayBorrow() external payable;
    function repayBorrowBehalf(address borrower) external payable;
    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;
}

interface InstaMapping {
    function cTokenMapping(address) external view returns (address);
    function gemJoinMapping(bytes32) external view returns (address);
}

interface ComptrollerInterface {
    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    function exitMarket(address cTokenAddress) external returns (uint);
    function getAssetsIn(address account) external view returns (address[] memory);
    function getAccountLiquidity(address account) external view returns (uint, uint, uint);
}
// End Compound Helpers

// Aave v1 Helpers
interface AaveV1Interface {
    function deposit(address _reserve, uint256 _amount, uint16 _referralCode) external payable;
    function redeemUnderlying(
        address _reserve,
        address payable _user,
        uint256 _amount,
        uint256 _aTokenBalanceAfterRedeem
    ) external;
    
    function setUserUseReserveAsCollateral(address _reserve, bool _useAsCollateral) external;
    function getUserReserveData(address _reserve, address _user) external view returns (
        uint256 currentATokenBalance,
        uint256 currentBorrowBalance,
        uint256 principalBorrowBalance,
        uint256 borrowRateMode,
        uint256 borrowRate,
        uint256 liquidityRate,
        uint256 originationFee,
        uint256 variableBorrowIndex,
        uint256 lastUpdateTimestamp,
        bool usageAsCollateralEnabled
    );
    function borrow(address _reserve, uint256 _amount, uint256 _interestRateMode, uint16 _referralCode) external;
    function repay(address _reserve, uint256 _amount, address payable _onBehalfOf) external payable;
}

interface AaveV1ProviderInterface {
    function getLendingPool() external view returns (address);
    function getLendingPoolCore() external view returns (address);
}

interface AaveV1CoreInterface {
    function getReserveATokenAddress(address _reserve) external view returns (address);
}

interface ATokenV1Interface {
    function redeem(uint256 _amount) external;
    function balanceOf(address _user) external view returns(uint256);
    function principalBalanceOf(address _user) external view returns(uint256);

    function allowance(address, address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}
// End Aave v1 Helpers

// Aave v2 Helpers
interface AaveV2Interface {
    function deposit(address _asset, uint256 _amount, address _onBehalfOf, uint16 _referralCode) external;
    function withdraw(address _asset, uint256 _amount, address _to) external;
    function borrow(
        address _asset,
        uint256 _amount,
        uint256 _interestRateMode,
        uint16 _referralCode,
        address _onBehalfOf
    ) external;
    function repay(address _asset, uint256 _amount, uint256 _rateMode, address _onBehalfOf) external;
    function setUserUseReserveAsCollateral(address _asset, bool _useAsCollateral) external;
    function getUserAccountData(address user) external view returns (
        uint256 totalCollateralETH,
        uint256 totalDebtETH,
        uint256 availableBorrowsETH,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    );
}

interface AaveV2LendingPoolProviderInterface {
    function getLendingPool() external view returns (address);
}

// Aave Protocol Data Provider
interface AaveV2DataProviderInterface {
    function getReserveTokensAddresses(address _asset) external view returns (
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress
    );
    function getUserReserveData(address _asset, address _user) external view returns (
        uint256 currentATokenBalance,
        uint256 currentStableDebt,
        uint256 currentVariableDebt,
        uint256 principalStableDebt,
        uint256 scaledVariableDebt,
        uint256 stableBorrowRate,
        uint256 liquidityRate,
        uint40 stableRateLastUpdated,
        bool usageAsCollateralEnabled
    );
    function getReserveConfigurationData(address asset) external view returns (
        uint256 decimals,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus,
        uint256 reserveFactor,
        bool usageAsCollateralEnabled,
        bool borrowingEnabled,
        bool stableBorrowRateEnabled,
        bool isActive,
        bool isFrozen
    );
}
// End Aave v2 Helpers

// MakerDAO Helpers
interface ManagerLike {
    function cdpCan(address, uint, address) external view returns (uint);
    function ilks(uint) external view returns (bytes32);
    function last(address) external view returns (uint);
    function count(address) external view returns (uint);
    function owns(uint) external view returns (address);
    function urns(uint) external view returns (address);
    function vat() external view returns (address);
    function open(bytes32, address) external returns (uint);
    function give(uint, address) external;
    function frob(uint, int, int) external;
    function flux(uint, address, uint) external;
    function move(uint, address, uint) external;
}

interface VatLike {
    function can(address, address) external view returns (uint);
    function ilks(bytes32) external view returns (uint, uint, uint, uint, uint);
    function dai(address) external view returns (uint);
    function urns(bytes32, address) external view returns (uint, uint);
    function frob(
        bytes32,
        address,
        address,
        address,
        int,
        int
    ) external;
    function hope(address) external;
    function move(address, address, uint) external;
    function gem(bytes32, address) external view returns (uint);
}

interface TokenJoinInterface {
    function dec() external returns (uint);
    function gem() external returns (TokenInterface);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface DaiJoinInterface {
    function vat() external returns (VatLike);
    function dai() external returns (TokenInterface);
    function join(address, uint) external payable;
    function exit(address, uint) external;
}

interface JugLike {
    function drip(bytes32) external returns (uint);
}
// End MakerDAO Helpers

contract DSMath {

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-overflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function toRad(uint wad) internal pure returns (uint rad) {
        rad = mul(wad, 10 ** 27);
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    function convertTo18(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = mul(_amt, 10 ** (18 - _dec));
    }

    function convert18ToDec(uint _dec, uint256 _amt) internal pure returns (uint256 amt) {
        amt = (_amt / 10 ** (18 - _dec));
    }

}

contract Helpers is DSMath {

    using SafeERC20 for IERC20;

    address payable constant feeCollector = 0xb1DC62EC38E6E3857a887210C38418E4A17Da5B2;

    /**
     * @dev Return ethereum address
     */
    function getEthAddr() internal pure returns (address) {
        return 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE; // ETH Address
    }

    /**
     * @dev Return Weth address
    */
    function getWethAddr() internal pure returns (address) {
        return 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Mainnet WETH Address
        // return 0xd0A1E359811322d97991E03f863a0C30C2cF029C; // Kovan WETH Address
    }

    /**
     * @dev Return InstaDApp Mapping Address
     */
    function getMappingAddr() internal pure returns (address) {
        return 0xe81F70Cc7C0D46e12d70efc60607F16bbD617E88; // InstaMapping Address
    }

    /**
     * @dev Return Compound Comptroller Address
     */
    function getComptrollerAddress() internal pure returns (address) {
        return 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    }

    /**
     * @dev Return Maker MCD DAI_Join Address.
    */
    function getMcdDaiJoin() internal pure returns (address) {
        return 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    }

    /**
     * @dev Return Maker MCD Manager Address.
    */
    function getMcdManager() internal pure returns (address) {
        return 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    }

    /**
     * @dev Return Maker MCD DAI Address.
    */
    function getMcdDai() internal pure returns (address) {
        return 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    /**
     * @dev Return Maker MCD Jug Address.
    */
    function getMcdJug() internal pure returns (address) {
        return 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    }

    /**
     * @dev get Aave Provider
    */
    function getAaveProvider() internal pure returns (AaveV1ProviderInterface) {
        return AaveV1ProviderInterface(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8); //mainnet
        // return AaveV1ProviderInterface(0x506B0B2CF20FAA8f38a4E2B524EE43e1f4458Cc5); //kovan
    }

    /**
     * @dev get Aave Lending Pool Provider
    */
    function getAaveV2Provider() internal pure returns (AaveV2LendingPoolProviderInterface) {
        return AaveV2LendingPoolProviderInterface(0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5); //mainnet
        // return AaveV2LendingPoolProviderInterface(0x652B2937Efd0B5beA1c8d54293FC1289672AFC6b); //kovan
    }

    /**
     * @dev get Aave Protocol Data Provider
    */
    function getAaveV2DataProvider() internal pure returns (AaveV2DataProviderInterface) {
        return AaveV2DataProviderInterface(0x057835Ad21a177dbdd3090bB1CAE03EaCF78Fc6d); //mainnet
        // return AaveV2DataProviderInterface(0x744C1aaA95232EeF8A9994C4E0b3a89659D9AB79); //kovan
    }

    /**
     * @dev get Referral Code
    */
    function getReferralCode() internal pure returns (uint16) {
        return 3228;
    }

    function getWithdrawBalance(AaveV1Interface aave, address token) internal view returns (uint bal) {
        (bal, , , , , , , , , ) = aave.getUserReserveData(token, address(this));
    }

    function getPaybackBalance(AaveV1Interface aave, address token) internal view returns (uint bal, uint fee) {
        (, bal, , , , , fee, , , ) = aave.getUserReserveData(token, address(this));
    }

    function getTotalBorrowBalance(AaveV1Interface aave, address token) internal view returns (uint amt) {
        (, uint bal, , , , , uint fee, , , ) = aave.getUserReserveData(token, address(this));
        amt = add(bal, fee);
    }

    function getWithdrawBalanceV2(AaveV2DataProviderInterface aaveData, address token) internal view returns (uint bal) {
        (bal, , , , , , , , ) = aaveData.getUserReserveData(token, address(this));
    }

    function getPaybackBalanceV2(AaveV2DataProviderInterface aaveData, address token, uint rateMode) internal view returns (uint bal) {
        if (rateMode == 1) {
            (, bal, , , , , , , ) = aaveData.getUserReserveData(token, address(this));
        } else {
            (, , bal, , , , , , ) = aaveData.getUserReserveData(token, address(this));
        }
    }

    function getIsColl(AaveV1Interface aave, address token) internal view returns (bool isCol) {
        (, , , , , , , , , isCol) = aave.getUserReserveData(token, address(this));
    }

    function getIsCollV2(AaveV2DataProviderInterface aaveData, address token) internal view returns (bool isCol) {
        (, , , , , , , , isCol) = aaveData.getUserReserveData(token, address(this));
    }

    /**
     * @dev Get Vault's ilk.
    */
    function getVaultData(ManagerLike managerContract, uint vault) internal view returns (bytes32 ilk, address urn) {
        ilk = managerContract.ilks(vault);
        urn = managerContract.urns(vault);
    }

    /**
     * @dev Get Vault Debt Amount.
    */
    function _getVaultDebt(
        address vat,
        bytes32 ilk,
        address urn
    ) internal view returns (uint wad) {
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);
        uint dai = VatLike(vat).dai(urn);

        uint rad = sub(mul(art, rate), dai);
        wad = rad / RAY;

        wad = mul(wad, RAY) < rad ? wad + 1 : wad;
    }

    /**
     * @dev Get Payback Amount.
    */
    function _getWipeAmt(
        address vat,
        uint amt,
        address urn,
        bytes32 ilk
    ) internal view returns (int dart)
    {
        (, uint rate,,,) = VatLike(vat).ilks(ilk);
        (, uint art) = VatLike(vat).urns(ilk, urn);
        dart = toInt(amt / rate);
        dart = uint(dart) <= art ? - dart : - toInt(art);
    }

    /**
     * @dev Convert String to bytes32.
    */
    function stringToBytes32(string memory str) internal pure returns (bytes32 result) {
        require(bytes(str).length != 0, "string-empty");
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            result := mload(add(str, 32))
        }
    }

    /**
     * @dev Get vault ID. If `vault` is 0, get last opened vault.
    */
    function getVault(ManagerLike managerContract, uint vault) internal view returns (uint _vault) {
        if (vault == 0) {
            require(managerContract.count(address(this)) > 0, "no-vault-opened");
            _vault = managerContract.last(address(this));
        } else {
            _vault = vault;
        }
    }

    /**
     * @dev Get Borrow Amount [MakerDAO]
    */
    function _getBorrowAmt(
        address vat,
        address urn,
        bytes32 ilk,
        uint amt
    ) internal returns (int dart)
    {
        address jug = getMcdJug();
        uint rate = JugLike(jug).drip(ilk);
        uint dai = VatLike(vat).dai(urn);
        if (dai < mul(amt, RAY)) {
            dart = toInt(sub(mul(amt, RAY), dai) / rate);
            dart = mul(uint(dart), rate) < mul(amt, RAY) ? dart + 1 : dart;
        }
    }

    function convertEthToWeth(bool isEth, TokenInterface token, uint amount) internal {
        if(isEth) token.deposit.value(amount)();
    }

    function convertWethToEth(bool isEth, TokenInterface token, uint amount) internal {
       if(isEth) {
            token.approve(address(token), amount);
            token.withdraw(amount);
        }
    }

    function getMaxBorrow(uint target, address token, uint rateMode) internal returns (uint amt) {
        AaveV1Interface aaveV1 = AaveV1Interface(getAaveProvider().getLendingPool());
        AaveV2DataProviderInterface aaveData = getAaveV2DataProvider();

        if (target == 1) {
            (uint _amt, uint _fee) = getPaybackBalance(aaveV1, token);
            amt = _amt + _fee;
        } else if (target == 2) {
            amt = getPaybackBalanceV2(aaveData, token, rateMode);
        } else if (target == 3) {
            address cToken = InstaMapping(getMappingAddr()).cTokenMapping(token);
            amt = CTokenInterface(cToken).borrowBalanceCurrent(address(this));
        }
    }

    function transferFees(address token, uint feeAmt) internal {
        if (token == getEthAddr()) {
            feeCollector.transfer(feeAmt);
        } else {
            IERC20(token).safeTransfer(feeCollector, feeAmt);
        }
    }
}

contract CompoundHelpers is Helpers {

    function _compEnterMarkets(uint length, address[] memory tokens) internal {
        ComptrollerInterface troller = ComptrollerInterface(getComptrollerAddress());
        address[] memory cTokens = new address[](length);

        for (uint i = 0; i < length; i++) {
            cTokens[i] = InstaMapping(getMappingAddr()).cTokenMapping(tokens[i]);
        }
        troller.enterMarkets(cTokens);
    }

    function _compBorrowOne(uint fee, address token, uint amt, uint target, uint rateMode) internal returns (uint) {
        if (amt > 0) {

            if (amt == uint(-1)) {
                amt = getMaxBorrow(target, token, rateMode);
            }

            address cToken = InstaMapping(getMappingAddr()).cTokenMapping(token);
            uint feeAmt = wmul(amt, fee);
            uint _amt = add(amt, feeAmt);

            require(CTokenInterface(cToken).borrow(_amt) == 0, "borrow-failed-collateral?");
            transferFees(token, feeAmt);
        }
        return amt;
    }

    function _compBorrow(
        uint length,
        uint fee,
        uint target,
        address[] memory tokens,
        uint[] memory amts,
        uint[] memory rateModes
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _compBorrowOne(fee, tokens[i], amts[i], target, rateModes[i]);
        }
        return finalAmts;
    }

    function _compDepositOne(uint fee, address token, uint amt) internal {
        if (amt > 0) {
            address cToken = InstaMapping(getMappingAddr()).cTokenMapping(token);

            uint feeAmt = wmul(amt, fee);
            uint _amt = sub(amt, feeAmt);

            if (token != getEthAddr()) {
                TokenInterface tokenContract = TokenInterface(token);
                tokenContract.approve(cToken, _amt);
                require(CTokenInterface(cToken).mint(_amt) == 0, "deposit-failed");
            } else {
                CETHInterface(cToken).mint.value(_amt)();
            }
            transferFees(token, feeAmt);
        }
    }

    function _compDeposit(
        uint length,
        uint fee,
        address[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _compDepositOne(fee, tokens[i], amts[i]);
        }
    }

    function _compWithdrawOne(address token, uint amt) internal returns (uint) {
        if (amt > 0) {
            address cToken = InstaMapping(getMappingAddr()).cTokenMapping(token);
            CTokenInterface cTokenContract = CTokenInterface(cToken);
            if (amt == uint(-1)) {
                amt = cTokenContract.balanceOf(address(this));
            }
            require(cTokenContract.redeemUnderlying(amt) == 0, "withdraw-failed");
        }
        return amt;
    }

    function _compWithdraw(
        uint length,
        address[] memory tokens,
        uint[] memory amts
    ) internal returns(uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _compWithdrawOne(tokens[i], amts[i]);
        }
        return finalAmts;
    }

    function _compPaybackOne(address token, uint amt) internal returns (uint) {
        if (amt > 0) {
            address cToken = InstaMapping(getMappingAddr()).cTokenMapping(token);
            CTokenInterface cTokenContract = CTokenInterface(cToken);

            if (amt == uint(-1)) {
                amt = cTokenContract.borrowBalanceCurrent(address(this));
            }
            if (token != getEthAddr()) {
                TokenInterface tokenContract = TokenInterface(token);
                tokenContract.approve(cToken, amt);
                require(cTokenContract.repayBorrow(amt) == 0, "repay-failed.");
            } else {
                CETHInterface(cToken).repayBorrow.value(amt)();
            }
        }
        return amt;
    }

    function _compPayback(
        uint length,
        address[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _compPaybackOne(tokens[i], amts[i]);
        }
    }
}

contract AaveV1Helpers is CompoundHelpers {

    function _aaveV1BorrowOne(
        AaveV1Interface aave,
        uint fee,
        uint target,
        address token,
        uint amt,
        uint borrowRateMode,
        uint paybackRateMode
    ) internal returns (uint) {
        if (amt > 0) {

            if (amt == uint(-1)) {
                amt = getMaxBorrow(target, token, paybackRateMode);
            }

            uint feeAmt = wmul(amt, fee);
            uint _amt = add(amt, feeAmt);

            aave.borrow(token, _amt, borrowRateMode, getReferralCode());
            transferFees(token, feeAmt);
        }
        return amt;
    }

    function _aaveV1Borrow(
        AaveV1Interface aave,
        uint length,
        uint fee,
        uint target,
        address[] memory tokens,
        uint[] memory amts,
        uint[] memory borrowRateModes,
        uint[] memory paybackRateModes
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _aaveV1BorrowOne(
                aave,
                fee,
                target,
                tokens[i],
                amts[i],
                borrowRateModes[i],
                paybackRateModes[i]
            );
        }
        return finalAmts;
    }

    function _aaveV1DepositOne(
        AaveV1Interface aave,
        uint fee,
        address token,
        uint amt
    ) internal {
        if (amt > 0) {
            uint ethAmt;
            uint feeAmt = wmul(amt, fee);
            uint _amt = sub(amt, feeAmt);

            bool isEth = token == getEthAddr();
            if (isEth) {
                ethAmt = _amt;
            } else {
                TokenInterface tokenContract = TokenInterface(token);
                tokenContract.approve(address(aave), _amt);
            }

            transferFees(token, feeAmt);

            aave.deposit.value(ethAmt)(token, _amt, getReferralCode());

            if (!getIsColl(aave, token))
                aave.setUserUseReserveAsCollateral(token, true);
        }
    }

    function _aaveV1Deposit(
        AaveV1Interface aave,
        uint length,
        uint fee,
        address[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _aaveV1DepositOne(aave, fee, tokens[i], amts[i]);
        }
    }

    function _aaveV1WithdrawOne(
        AaveV1Interface aave,
        AaveV1CoreInterface aaveCore,
        address token,
        uint amt
    ) internal returns (uint) {
        if (amt > 0) {
            ATokenV1Interface atoken = ATokenV1Interface(aaveCore.getReserveATokenAddress(token));
            atoken.redeem(amt);
            if (amt == uint(-1)) {
                amt = getWithdrawBalance(aave, token);
            }
        }
        return amt;
    }

    function _aaveV1Withdraw(
        AaveV1Interface aave,
        AaveV1CoreInterface aaveCore,
        uint length,
        address[] memory tokens,
        uint[] memory amts
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _aaveV1WithdrawOne(aave, aaveCore, tokens[i], amts[i]);
        }
        return finalAmts;
    }

    function _aaveV1PaybackOne(
        AaveV1Interface aave,
        address token,
        uint amt
    ) internal returns (uint) {
        if (amt > 0) {
            uint ethAmt;

            if (amt == uint(-1)) {
                (uint _amt, uint _fee) = getPaybackBalance(aave, token);
                amt = _amt + _fee;
            }

            bool isEth = token == getEthAddr();
            if (isEth) {
                ethAmt = amt;
            } else {
                TokenInterface tokenContract = TokenInterface(token);
                tokenContract.approve(address(aave), amt);
            }

            aave.repay.value(ethAmt)(token, amt, payable(address(this)));
        }
        return amt;
    }

    function _aaveV1Payback(
        AaveV1Interface aave,
        uint length,
        address[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _aaveV1PaybackOne(aave, tokens[i], amts[i]);
        }
    }
}

contract AaveV2Helpers is AaveV1Helpers {

    function _aaveV2BorrowOne(
        AaveV2Interface aave,
        uint fee,
        uint target,
        address token,
        uint amt,
        uint rateMode
    ) internal returns (uint) {
        if (amt > 0) {
            if (amt == uint(-1)) {
                amt = getMaxBorrow(target, token, rateMode);
            }

            uint feeAmt = wmul(amt, fee);
            uint _amt = add(amt, feeAmt);

            bool isEth = token == getEthAddr();
            address _token = isEth ? getWethAddr() : token;

            aave.borrow(_token, _amt, rateMode, getReferralCode(), address(this));
            convertWethToEth(isEth, TokenInterface(_token), amt);

            transferFees(token, feeAmt);
        }
        return amt;
    }

    function _aaveV2Borrow(
        AaveV2Interface aave,
        uint length,
        uint fee,
        uint target,
        address[] memory tokens,
        uint[] memory amts,
        uint[] memory rateModes
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _aaveV2BorrowOne(aave, fee, target, tokens[i], amts[i], rateModes[i]);
        }
        return finalAmts;
    }

    function _aaveV2DepositOne(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        uint fee,
        address token,
        uint amt
    ) internal {
        if (amt > 0) {
            uint feeAmt = wmul(amt, fee);
            uint _amt = sub(amt, feeAmt);

            bool isEth = token == getEthAddr();
            address _token = isEth ? getWethAddr() : token;
            TokenInterface tokenContract = TokenInterface(_token);

            transferFees(token, feeAmt);

            convertEthToWeth(isEth, tokenContract, _amt);

            tokenContract.approve(address(aave), _amt);

            aave.deposit(_token, _amt, address(this), getReferralCode());

            if (!getIsCollV2(aaveData, _token)) {
                aave.setUserUseReserveAsCollateral(_token, true);
            }
        }
    }

    function _aaveV2Deposit(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        uint length,
        uint fee,
        address[] memory tokens,
        uint[] memory amts
    ) internal {
        for (uint i = 0; i < length; i++) {
            _aaveV2DepositOne(aave, aaveData, fee, tokens[i], amts[i]);
        }
    }

    function _aaveV2WithdrawOne(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        address token,
        uint amt
    ) internal returns (uint _amt) {
        if (amt > 0) {
            bool isEth = token == getEthAddr();
            address _token = isEth ? getWethAddr() : token;
            TokenInterface tokenContract = TokenInterface(_token);

            aave.withdraw(_token, amt, address(this));

            _amt = amt == uint(-1) ? getWithdrawBalanceV2(aaveData, _token) : amt;

            convertWethToEth(isEth, tokenContract, _amt);
        }
    }

    function _aaveV2Withdraw(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        uint length,
        address[] memory tokens,
        uint[] memory amts
    ) internal returns (uint[] memory) {
        uint[] memory finalAmts = new uint[](length);
        for (uint i = 0; i < length; i++) {
            finalAmts[i] = _aaveV2WithdrawOne(aave, aaveData, tokens[i], amts[i]);
        }
        return finalAmts;
    }

    function _aaveV2PaybackOne(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        address token,
        uint amt,
        uint rateMode
    ) internal returns (uint _amt) {
        if (amt > 0) {
            bool isEth = token == getEthAddr();
            address _token = isEth ? getWethAddr() : token;
            TokenInterface tokenContract = TokenInterface(_token);

            _amt = amt == uint(-1) ? getPaybackBalanceV2(aaveData, _token, rateMode) : amt;

            convertEthToWeth(isEth, tokenContract, amt);

            aave.repay(_token, _amt, rateMode, address(this));
        }
    }

    function _aaveV2Payback(
        AaveV2Interface aave,
        AaveV2DataProviderInterface aaveData,
        uint length,
        address[] memory tokens,
        uint[] memory amts,
        uint[] memory rateModes
    ) internal {
        for (uint i = 0; i < length; i++) {
            _aaveV2PaybackOne(aave, aaveData, tokens[i], amts[i], rateModes[i]);
        }
    }
}

contract MakerHelpers is AaveV2Helpers {

    function _makerOpen(string memory colType) internal {
        bytes32 ilk = stringToBytes32(colType);
        require(InstaMapping(getMappingAddr()).gemJoinMapping(ilk) != address(0), "wrong-col-type");
        ManagerLike(getMcdManager()).open(ilk, address(this));
    }

    function _makerDepositAndBorrow(
        uint vault,
        uint collateralAmt,
        uint debtAmt,
        uint collateralFee,
        uint debtFee
    ) internal {
        uint collateralFeeAmt = wmul(collateralAmt, collateralFee);
        uint _collateralAmt = sub(collateralAmt, collateralFeeAmt);

        uint debtFeeAmt = wmul(debtAmt, debtFee);
        uint _debtAmt = add(debtAmt, debtFeeAmt);

        ManagerLike managerContract = ManagerLike(getMcdManager());

        uint _vault = getVault(managerContract, vault);
        (bytes32 ilk, address urn) = getVaultData(managerContract, _vault);

        address colAddr = InstaMapping(getMappingAddr()).gemJoinMapping(ilk);
        TokenJoinInterface tokenJoinContract = TokenJoinInterface(colAddr);
        TokenInterface tokenContract = tokenJoinContract.gem();
        address daiJoin = getMcdDaiJoin();
        VatLike vatContract = VatLike(managerContract.vat());

        transferFees(address(tokenContract), collateralFeeAmt);

        if (address(tokenContract) == getWethAddr()) {
            tokenContract.deposit.value(_collateralAmt)();
        }

        tokenContract.approve(address(colAddr), _collateralAmt);
        tokenJoinContract.join(address(this), _collateralAmt);

        int intAmt = toInt(convertTo18(tokenJoinContract.dec(), _collateralAmt));

        int dart = _getBorrowAmt(address(vatContract), urn, ilk, _debtAmt);

        managerContract.frob(
            _vault,
            intAmt,
            dart
        );

        managerContract.move(
            _vault,
            address(this),
            toRad(_debtAmt)
        );

        if (vatContract.can(address(this), address(daiJoin)) == 0) {
            vatContract.hope(daiJoin);
        }

        DaiJoinInterface(daiJoin).exit(address(this), _debtAmt);
    }

    function _makerWithdraw(uint vault, uint amt) internal returns (uint) {
        ManagerLike managerContract = ManagerLike(getMcdManager());

        uint _vault = getVault(managerContract, vault);
        (bytes32 ilk, address urn) = getVaultData(managerContract, _vault);

        address colAddr = InstaMapping(getMappingAddr()).gemJoinMapping(ilk);
        TokenJoinInterface tokenJoinContract = TokenJoinInterface(colAddr);

        uint _amt18;
        if (amt == uint(-1)) {
            (_amt18,) = VatLike(managerContract.vat()).urns(ilk, urn);
            amt = convert18ToDec(tokenJoinContract.dec(), _amt18);
        } else {
            _amt18 = convertTo18(tokenJoinContract.dec(), amt);
        }

        managerContract.frob(
            _vault,
            -toInt(_amt18),
            0
        );

        managerContract.flux(
            _vault,
            address(this),
            _amt18
        );

        TokenInterface tokenContract = tokenJoinContract.gem();

        if (address(tokenContract) == getWethAddr()) {
            tokenJoinContract.exit(address(this), amt);
            tokenContract.withdraw(amt);
        } else {
            tokenJoinContract.exit(address(this), amt);
        }

        return amt;
    }

    function _makerPayback(uint vault, uint amt) internal returns (uint) {
        ManagerLike managerContract = ManagerLike(getMcdManager());

        uint _vault = getVault(managerContract, vault);
        (bytes32 ilk, address urn) = getVaultData(managerContract, _vault);

        address vat = managerContract.vat();

        uint _maxDebt = _getVaultDebt(vat, ilk, urn);

        uint _amt = amt == uint(-1) ? _maxDebt : amt;

        require(_maxDebt >= _amt, "paying-excess-debt");

        DaiJoinInterface daiJoinContract = DaiJoinInterface(getMcdDaiJoin());
        daiJoinContract.dai().approve(getMcdDaiJoin(), _amt);
        daiJoinContract.join(urn, _amt);

        managerContract.frob(
            _vault,
            0,
            _getWipeAmt(
                vat,
                VatLike(vat).dai(urn),
                urn,
                ilk
            )
        );

        return _amt;
    }
}

contract RefinanceResolver is MakerHelpers {

    // Aave v1 Id - 1
    // Aave v2 Id - 2
    // Compound Id - 3
    struct RefinanceData {
        uint source;
        uint target;
        uint collateralFee;
        uint debtFee;
        address[] tokens;
        uint[] borrowAmts;
        uint[] withdrawAmts;
        uint[] borrowRateModes;
        uint[] paybackRateModes;
    }

    // Aave v1 Id - 1
    // Aave v2 Id - 2
    // Compound Id - 3
    struct RefinanceMakerData {
        uint fromVaultId;
        uint toVaultId;
        uint source;
        uint target;
        uint collateralFee;
        uint debtFee;
        bool isFrom;
        string colType;
        address token;
        uint debt;
        uint collateral;
        uint borrowRateMode;
        uint paybackRateMode;
    }

    function refinance(RefinanceData calldata data) external payable {

        require(data.source != data.target, "source-and-target-unequal");

        uint length = data.tokens.length;

        require(data.borrowAmts.length == length, "length-mismatch");
        require(data.withdrawAmts.length == length, "length-mismatch");
        require(data.borrowRateModes.length == length, "length-mismatch");
        require(data.paybackRateModes.length == length, "length-mismatch");

        AaveV2Interface aaveV2 = AaveV2Interface(getAaveV2Provider().getLendingPool());
        AaveV1Interface aaveV1 = AaveV1Interface(getAaveProvider().getLendingPool());
        AaveV1CoreInterface aaveCore = AaveV1CoreInterface(getAaveProvider().getLendingPoolCore());
        AaveV2DataProviderInterface aaveData = getAaveV2DataProvider();

        uint[] memory depositAmts;
        uint[] memory paybackAmts;

        if (data.source == 1 && data.target == 2) {
            paybackAmts = _aaveV2Borrow(
                aaveV2,
                length,
                data.debtFee,
                data.target,
                data.tokens, 
                data.borrowAmts,
                data.borrowRateModes
            );
            _aaveV1Payback(aaveV1, length, data.tokens, paybackAmts);
            depositAmts = _aaveV1Withdraw(aaveV1, aaveCore, length, data.tokens, data.withdrawAmts);
            _aaveV2Deposit(aaveV2, aaveData, length, data.collateralFee, data.tokens, depositAmts);
        } else if (data.source == 1 && data.target == 3) {
            _compEnterMarkets(length, data.tokens);

            paybackAmts = _compBorrow(
                length,
                data.debtFee,
                data.target,
                data.tokens,
                data.borrowAmts,
                data.borrowRateModes
            );
            
            _aaveV1Payback(aaveV1, length, data.tokens, paybackAmts);
            depositAmts = _aaveV1Withdraw(aaveV1, aaveCore, length, data.tokens, data.withdrawAmts);
            _compDeposit(length, data.collateralFee, data.tokens, depositAmts);
        } else if (data.source == 2 && data.target == 1) {
            paybackAmts = _aaveV1Borrow(
                aaveV1,
                length,
                data.debtFee,
                data.target,
                data.tokens,
                data.borrowAmts,
                data.borrowRateModes,
                data.paybackRateModes
            );
            _aaveV2Payback(aaveV2, aaveData, length, data.tokens, paybackAmts, data.paybackRateModes);
            depositAmts = _aaveV2Withdraw(aaveV2, aaveData, length, data.tokens, data.withdrawAmts);
            _aaveV1Deposit(aaveV1, length, data.collateralFee, data.tokens, depositAmts);
        } else if (data.source == 2 && data.target == 3) {
            _compEnterMarkets(length, data.tokens);
            
            paybackAmts = _compBorrow(
                length,
                data.debtFee,
                data.target,
                data.tokens,
                data.borrowAmts,
                data.borrowRateModes
            );
            _aaveV2Payback(aaveV2, aaveData, length, data.tokens, paybackAmts, data.paybackRateModes);
            depositAmts = _aaveV2Withdraw(aaveV2, aaveData, length, data.tokens, data.withdrawAmts);
            _compDeposit(length, data.collateralFee, data.tokens, depositAmts);
        } else if (data.source == 3 && data.target == 1) {
            paybackAmts = _aaveV1Borrow(
                aaveV1,
                length,
                data.debtFee,
                data.target,
                data.tokens,
                data.borrowAmts,
                data.borrowRateModes,
                data.paybackRateModes
            );
            _compPayback(length, data.tokens, paybackAmts);
            depositAmts = _compWithdraw(length, data.tokens, data.withdrawAmts);
            _aaveV1Deposit(aaveV1, length, data.collateralFee, data.tokens, depositAmts);
        } else if (data.source == 3 && data.target == 2) {
            paybackAmts = _aaveV2Borrow(
                aaveV2,
                length,
                data.debtFee,
                data.target,
                data.tokens, 
                data.borrowAmts,
                data.borrowRateModes
            );
            _compPayback(length, data.tokens, paybackAmts);
            depositAmts = _compWithdraw(length, data.tokens, data.withdrawAmts);
            _aaveV2Deposit(aaveV2, aaveData, length, data.collateralFee, data.tokens, depositAmts);
        } else {
            revert("invalid-options");
        }
    }

    function refinanceMaker(RefinanceMakerData calldata data) external payable {

        AaveV2Interface aaveV2 = AaveV2Interface(getAaveV2Provider().getLendingPool());
        AaveV1Interface aaveV1 = AaveV1Interface(getAaveProvider().getLendingPool());
        AaveV1CoreInterface aaveCore = AaveV1CoreInterface(getAaveProvider().getLendingPoolCore());
        AaveV2DataProviderInterface aaveData = getAaveV2DataProvider();

        address dai = getMcdDai();

        uint depositAmt;
        uint borrowAmt;

        if (data.isFrom) {
            if (data.debt > 0) {
                borrowAmt = _makerPayback(data.fromVaultId, data.debt);
            }
            if (data.collateral > 0) {
                depositAmt = _makerWithdraw(data.fromVaultId, data.collateral);
            }

            if (data.target == 1) {
                _aaveV1DepositOne(aaveV1, data.collateralFee, data.token, depositAmt);
                _aaveV1BorrowOne(aaveV1, data.debtFee, 2, dai, borrowAmt, data.borrowRateMode, 1);
            } else if (data.target == 2) {
                _aaveV2DepositOne(aaveV2, aaveData, data.collateralFee, data.token, depositAmt);
                _aaveV2BorrowOne(aaveV2, data.debtFee, 1, dai, borrowAmt, data.borrowRateMode);
            } else if (data.target == 3) {
                address[] memory tokens = new address[](2);
                tokens[0] = dai;
                tokens[1] = data.token;

                _compEnterMarkets(2, tokens);

                _compDepositOne(data.collateralFee, data.token, depositAmt);
                _compBorrowOne(data.debtFee, dai, borrowAmt, 1, 1);
            } else {
                revert("invalid-option");
            }
        } else {
            if (data.toVaultId == 0) {
                _makerOpen(data.colType);
            }

            if (data.source == 1) {
                borrowAmt = _aaveV1PaybackOne(aaveV1, dai, data.debt);
                depositAmt = _aaveV1WithdrawOne(aaveV1, aaveCore, data.token, data.collateral);
            } else if (data.source == 2) {
                borrowAmt = _aaveV2PaybackOne(aaveV2, aaveData, dai, data.debt, data.paybackRateMode);
                depositAmt = _aaveV2WithdrawOne(aaveV2, aaveData, data.token, data.collateral);
            } else if (data.source == 3) {
                borrowAmt = _compPaybackOne(dai, data.debt);
                depositAmt = _compWithdrawOne(data.token, data.collateral);
            } else {
                revert("invalid-option");
            }

            _makerDepositAndBorrow(data.toVaultId, depositAmt, borrowAmt, data.collateralFee, data.debtFee);
        }
    }
}

contract ConnectRefinace is RefinanceResolver {
    string public name = "Refinance-v1";
}