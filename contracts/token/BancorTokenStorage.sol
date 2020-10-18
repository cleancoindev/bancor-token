// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.6.12;

import "../utility/Owned.sol";
import "../utility/Utils.sol";

contract BancorTokenStorage is Owned, Utils{

  bool public initialize = false;

  address public oracleAddress;
  uint32 internal constant ORACLE_PERCENT = 10^16;

  address public contractManager; //合约管理员
  address public financialManager; //财务管理员

  //bancor协议字段
  uint32 internal constant PPM_CW = 1000000; //CW单位: 百万
  address public bancorFormula; //bancor计算地址
  address public  reserveToken; //储备金代币地址: 稳定币地址
  uint32 public  conversionWeight; //权重: 1-1000000
  uint32 public  conversionFee = 0; //手续费


  //投票相关字段
  uint32 public votePeriodBlock; //投票周期
  uint32 public voteOpposeRate; //投票反对百分比 1-100
  uint32 public expectPrivateReserveToken; //预期私募Token

  struct Vote {
       uint256 beginBlock; //投票开始块数
       uint256 endBlock; //投票结束块数
       uint256 totalOppose; //总反对数
       bool publicity; //是否公示
       bool pass; //投票是否通过
    }

  uint32 public currentVoteId; //当前投票ID
  mapping(uint32 => Vote) public voteDetail; //投票详情
  mapping(uint32 => mapping (address => uint256)) public voteList; //投票列表


  modifier initialized() {
        require(initialize, "ERR_NOT_INITIALIZED");
        _;
  }

  modifier cmOnly(){
    require(msg.sender == contractManager, "ERR_ACCESS_DENIED_ONLY_CM");
    _;
  }

  modifier fmOnly(){
    require(msg.sender == financialManager, "ERR_ACCESS_DENIED_ONLY_FM");
    _;
  }

  /**
    设置oracle地址: 合约Owner修改
   */
   function setOracleAddress(address _oracleAddress) public  ownerOnly validAddress(_oracleAddress) {
      oracleAddress = _oracleAddress;
   }

  /**
    设置合约管理员
  */
  function setContractManager(address _contractManager) public ownerOnly validAddress(_contractManager) {
     contractManager = _contractManager;
  }

  /**
    设置财务管理员
   */
  function setFinancialManager(address _financialManager) public ownerOnly validAddress(_financialManager){
     financialManager = _financialManager;
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
  function setConversionFee(uint32 _conversionFee) public cmOnly {
      require(_conversionFee >= 1 && _conversionFee <= 1000000, "ERR_CONVERSION_FEE");
      conversionFee = _conversionFee;
  }

  /**
    设置bancor协议相关内容: 设置CW
    */
  function setConversionWeight(uint32 _conversionWeight) public cmOnly {
      require(_conversionWeight >= 1 && _conversionWeight <= 1000000, "ERR_CONVERSION_WEIGHT");
      conversionWeight = _conversionWeight;
  }

 /**
   设置预期私募Token数
 */
  function setExpectPrivateReserveToken(uint32 _expectPrivateReserveToken) public cmOnly greaterThanZero(_expectPrivateReserveToken) {
      expectPrivateReserveToken = _expectPrivateReserveToken;
  }


}
