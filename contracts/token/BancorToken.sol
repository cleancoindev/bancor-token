// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;
import "./interfaces/IBancorToken.sol";
import "../utility/Utils.sol";
import "../utility/SafeMath.sol";
import "../utility/Owned.sol";
import "../bancor/IBancorFormula.sol";


contract BancorToken is IBancorToken,Owned,Utils {
    using SafeMath for uint256;


    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint256 public override totalSupply;
    mapping (address => uint256) public override balanceOf;
    mapping (address => mapping (address => uint256)) public override allowance;

    //bancor协议字段
    uint32 internal constant PPM_CW = 1000000; //CW单位: 百万
    address public bancorFormula; //bancor计算地址
    address public  reserveToken; //储备金代币地址: 稳定币地址
    uint32 public  conversionWeight; //权重: 1-1000000
    uint32 public  conversionFee = 0; //手续费

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Issuance(uint256 _amount);
    event Destruction(uint256 _amount);
    event IssuanceByBancor(address indexed _from,uint256 _amount);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply,address _reserveToken, uint32 _weight) public {
        require(bytes(_name).length > 0, "ERR_INVALID_NAME");
        require(bytes(_symbol).length > 0, "ERR_INVALID_SYMBOL");
        require(_weight >= 1 && _weight <= 1000000, "ERR_RESERVE_WEIGHT");

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        conversionWeight = _weight;
        reserveToken = _reserveToken;
        balanceOf[msg.sender] = _totalSupply;
    }

    /**
       转账
     */
    function transfer(address _to, uint256 _value) public virtual override validAddress(_to) returns (bool) {
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
      授权转账
     */
    function transferFrom(address _from, address _to, uint256 _value) public virtual override validAddress(_from) validAddress(_to) returns (bool) {
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
      授权
     */
    function approve(address _spender, uint256 _value) public virtual override validAddress(_spender) returns (bool)
    {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
      发行代币
     */
    function issue(address _to, uint256 _amount) public override ownerOnly validAddress(_to) notThis(_to) returns(bool) {
        totalSupply = totalSupply.add(_amount);
        balanceOf[_to] = balanceOf[_to].add(_amount);

        emit Issuance(_amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
      销毁代币
     */
    function destroy(address _from, uint256 _amount) public override ownerOnly returns(bool) {
        balanceOf[_from] = balanceOf[_from].sub(_amount);
        totalSupply = totalSupply.sub(_amount);

        emit Transfer(_from, address(0), _amount);
        emit Destruction(_amount);
        return true;
    }


    /**
      查询当前储备代币金额
     */
    function reserveBalance() public view returns (uint256)
    {
        return IERC20Token(reserveToken).balanceOf(address(this));
    }

    /**
      使用bancor公式发行代币:
      1. 用户首先先授权给bancorToken指定_amount金额
      2. 调用bancorToken.issue方法发行token
     */
    function issueByBancor(uint256 _amount) public override returns(bool) {
        require(IERC20Token(reserveToken).balanceOf(msg.sender) >= _amount, "ERR_NOT_ENOUGH_TOKEN");
        require(IERC20Token(reserveToken).allowance(msg.sender, address(this)) >= _amount, "ERR_NOT_ENOUGH_APPROVE");

        (uint256 amount, uint256 fee) = purchaseTokenAmount(_amount);
        require(amount != 0, "ERR_ZERO_TOKEN_AMOUNT");

        uint256 oldBalance = reserveBalance();
        require(IERC20Token(reserveToken).transferFrom(msg.sender, address(this), _amount), "ERR_TRANSFER_RESERVE_TOKEN");
        require(reserveBalance().sub(oldBalance) >= _amount, "ERR_INVALID_AMOUNT");

        totalSupply = totalSupply.add(amount).add(fee);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(_amount);
        balanceOf[owner] = balanceOf[owner].add(fee);

        emit IssuanceByBancor(msg.sender, amount);
        emit Transfer(address(0), msg.sender, amount);
        emit Transfer(address(0), owner, fee);
        return true;
    }


    /**
       计算购买代币数及手续费: Price = reserveBalance() / (totalSupply * CW)
     */
    function purchaseTokenAmount(uint256 _amount) internal view returns (uint256, uint256) {
        if (totalSupply == 0)
            return (_amount.mul(PPM_CW).div(conversionWeight), 0);

        uint256 amount = IBancorFormula(bancorFormula).purchaseTargetAmount(
            totalSupply,
            reserveBalance(),
            conversionWeight,
            _amount
        );

        uint256 fee = calculateFee(amount);
        return (amount - fee, fee);
    }

    function calculateFee(uint256 _targetAmount) internal view returns (uint256) {
        return _targetAmount.mul(conversionFee).div(PPM_CW);
    }

    /**
      设置bancor协议相关内容: 设置bancor公式地址
     */
    function setBancorFormula(address _bancorFormula) public ownerOnly validAddress(_bancorFormula) {
        bancorFormula = _bancorFormula;
    }

    /**
      设置bancor协议相关内容: 设置手续费
     */
    function setConversionFee(uint32 _conversionFee) public ownerOnly {
        require(_conversionFee >= 1 && _conversionFee <= 1000000, "ERR_CONVERSION_FEE");
        conversionFee = _conversionFee;
    }

    /**
      设置bancor协议相关内容: 设置CW
     */
    function setConversionWeight(uint32 _conversionWeight) public ownerOnly {
        require(_conversionWeight >= 1 && _conversionWeight <= 1000000, "ERR_CONVERSION_WEIGHT");
        conversionWeight = _conversionWeight;
    }

}
