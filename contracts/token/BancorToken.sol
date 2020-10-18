// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;
import "./BancorTokenStorage.sol";
import "./interfaces/IBancorToken.sol";
import "../utility/Utils.sol";
import "../utility/SafeMath.sol";
import "../utility/Owned.sol";
import "../utility/ReentrancyGuard.sol";
import "../bancor/IBancorFormula.sol";
import "../utility/interfaces/IOracle.sol";


contract BancorToken is IBancorToken,BancorTokenStorage , ReentrancyGuard{
    using SafeMath for uint256;

    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint256 public override totalSupply;
    mapping (address => uint256) public override balanceOf;
    mapping (address => mapping (address => uint256)) public override allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Issuance(uint256 _amount);
    event Destruction(uint256 _amount);
    event IssuanceByBancor(address indexed _from,uint256 _amount, uint256 _fee);
    event VoteCreated(uint256 _block,uint32 _voteId);
    event VotePublicize(uint256 _block,uint32 _voteId, bool _pass, uint256 _amount);

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
       初始化合约:
        1. 合约管理员地址
        2. 财务管理员地址
        3. oralce地址
        4. BancorFormula地址
        5. 投票周期
        6. 投票反对百分比
        7. 预期募集Token数量
     */
    function init(address _cm, address _fm, address _oracle, address _bancorFormula, uint32 _votePeriodblock, uint32 _voteOpposeRate, uint32 _expectPrivateReserveToken) public ownerOnly {
        require(!initialize, "ERR_HAS_INIT");
        require(_voteOpposeRate >= 1 && _voteOpposeRate <= 100, "ERR_OPPOES_RATE");

        _validAddress(_cm);
        _validAddress(_fm);
        _validAddress(_oracle);
        _validAddress(_bancorFormula);
        _greaterThanZero(_votePeriodblock);
        _greaterThanZero(_voteOpposeRate);
        _greaterThanZero(_expectPrivateReserveToken);

        contractManager = _cm;
        financialManager = _fm;
        oracleAddress = _oracle;
        bancorFormula = _bancorFormula;
        votePeriodBlock = _votePeriodblock;
        voteOpposeRate = _voteOpposeRate;
        expectPrivateReserveToken = _expectPrivateReserveToken;

        initialize = true;
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

    // /**
    //   发行代币
    //  */
    // function issue(address _to, uint256 _amount) public override ownerOnly validAddress(_to) notThis(_to) returns(bool) {
    //     totalSupply = totalSupply.add(_amount);
    //     balanceOf[_to] = balanceOf[_to].add(_amount);

    //     emit Issuance(_amount);
    //     emit Transfer(address(0), _to, _amount);
    //     return true;
    // }

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
      查询当前储备金数量
     */
    function reserveBalance() public view returns (uint256)
    {
        return IERC20Token(reserveToken).balanceOf(address(this));
    }

    /**
      使用bancor公式发行代币:
      1. 用户首先先授权给bancorToken指定_amount金额
      2. 调用bancorToken.issueByBancor方法发行token
     */
    function issueByBancor(uint256 _usdt) public initialized override returns(bool) {
        require(IERC20Token(reserveToken).balanceOf(msg.sender) >= _usdt, "ERR_NOT_ENOUGH_TOKEN");
        require(IERC20Token(reserveToken).allowance(msg.sender, address(this)) >= _usdt, "ERR_NOT_ENOUGH_APPROVE");

        (uint256 token, uint256 fee) = purchaseTokenAmount(_usdt);
        require(token != 0, "ERR_ZERO_TOKEN_AMOUNT");

        uint256 oldBalance = reserveBalance();
        require(IERC20Token(reserveToken).transferFrom(msg.sender, address(this), _usdt), "ERR_TRANSFER_RESERVE_TOKEN");
        require(reserveBalance().sub(oldBalance) >= _usdt, "ERR_INVALID_AMOUNT");

        totalSupply = totalSupply.add(token).add(fee);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(token);
        balanceOf[owner] = balanceOf[owner].add(fee);

        emit IssuanceByBancor(msg.sender, token, fee);
        emit Transfer(address(0), msg.sender, token);
        emit Transfer(address(0), owner, fee);
        return true;
    }


    /**
       计算购买代币数及手续费: Price = reserveBalance() / (totalSupply * CW)
     */
    function purchaseTokenAmount(uint256 _amount) internal returns (uint256, uint256) {

       uint256 amount = 0;
       uint256 oraclePrice = IOracle(oracleAddress).getPrice();

       if(totalSupply == 0){
           amount = _amount.mul(PPM_CW).div(conversionWeight);
       }else{
           amount = IBancorFormula(bancorFormula).purchaseTargetAmount(
            totalSupply,
            reserveBalance(),
            conversionWeight,
            _amount
        );
       }

       uint256 oracleAmount = _amount.mul(oraclePrice).div(ORACLE_PERCENT);
       if(amount >= oracleAmount){
           amount = oracleAmount;
       }

        uint256 fee = calculateFee(amount);
        return (amount - fee, fee);
    }

    function calculateFee(uint256 _targetAmount) internal view returns (uint256) {
        return _targetAmount.mul(conversionFee).div(PPM_CW);
    }


    /**
      开启投票:
        条件:
            1. 募集金额 >= 预期金额
            2. 上一次投票已公示
     */
    function createVote() public protected initialized cmOnly {
        require(reserveBalance() >= expectPrivateReserveToken, "ERR_NOT_ENGOUGH_BALANCE");
        if(currentVoteId > 1){
            require(voteDetail[currentVoteId-1].publicity, "ERR_LAST_VOTE_NOT_PUBLICITY");
        }
        require(voteDetail[currentVoteId].beginBlock == 0, "ERR_VOTE_BEGIN");

        currentVoteId = currentVoteId + 1;
        voteDetail[currentVoteId] = Vote(block.number, block.number + votePeriodBlock, 0, false, false);

        emit VoteCreated(block.number, currentVoteId);
    }

    /**
      公示投票:
        条件:
            1. 投票已结束
            2. 投票未公示
     */
    function publicizeVote() public protected initialized cmOnly {
       require(currentVoteId >= 1, "ERR_VOTE_NOT_START");
       require(block.number >  voteDetail[currentVoteId].endBlock, "ERR_VOTE_NOT_END");
       require(!voteDetail[currentVoteId].publicity, "ERR_VOTE_PUBLICITIED");

       uint256 currentTotalSupply = totalSupply;
       Vote storage vote = voteDetail[currentVoteId];
       vote.publicity = true;

       bool pass = vote.totalOppose.mul(100) < currentTotalSupply.mul(voteOpposeRate);
       uint256 balance = reserveBalance();
       if(pass){
           require(IERC20Token(reserveToken).transfer(financialManager, balance), "ERR_TRANSFER_FAILED");
       }
       vote.pass = pass;
       emit VotePublicize(block.number, currentVoteId, pass, balance);
    }

    /**
       持币人投反对票
         条件:
           1. 投票已开启
           2. 投票未结束
     */
    function opposeVote() public initialized {
        require(currentVoteId >= 1, "ERR_VOTE_NOT_START");
        require(block.number <=  voteDetail[currentVoteId].endBlock, "ERR_VOTE_END");
        require(voteList[currentVoteId][msg.sender] == 0 , "ERR_HAS_VOTED");

        voteList[currentVoteId][msg.sender] = balanceOf[msg.sender];
        voteDetail[currentVoteId].totalOppose = voteDetail[currentVoteId].totalOppose.add(balanceOf[msg.sender]);
    }


    /**
       持币人撤销投反对票
         条件:
           1. 投票已开启
           2. 投票未结束
           3. 持币人已投票
     */
    function undoOpposeVote() public initialized {
        require(currentVoteId >= 1, "ERR_VOTE_NOT_START");
        require(block.number <=  voteDetail[currentVoteId].endBlock, "ERR_VOTE_END");
        require(voteList[currentVoteId][msg.sender] > 0 , "ERR_NOT_VOTED");

        uint256 voted = voteList[currentVoteId][msg.sender];
        voteList[currentVoteId][msg.sender] = 0;
        voteDetail[currentVoteId].totalOppose = voteDetail[currentVoteId].totalOppose.sub(voted);
    }


}
