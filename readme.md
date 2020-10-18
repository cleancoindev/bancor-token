## 合约说明

### 部署步骤:

   a. 部署BancorFormula合约
   b. 部署PriceOracle合约
   c. 部署BancorToken合约
   d. 执行BancorToken.init方法初始化合约


### 投票过程:

   a: 合约管理员开启投票: createVote
   b: 持币人投反对票:   opposeVote
      持币人撤销反对票:  undoOpposeVote
   c: 投票周期结束，合约管理员公示投票: publicizeVote


### 部署合约

a. 安装`truffle`

版本信息如下:

```
Truffle v5.1.48 (core: 5.1.48)
Solidity - 0.6.12 (solc-js)
Node v11.10.1
Web3.js v1.2.1
```

b. 编译合约

```
truffle compile
```

c. 部署合约

修改.env文件中MNEMONIC内容

```
truffle migrate --network kovan --skip-dry-run
```




### Kovan测试地址

BancorFormula: 0x55a836217EB3888dbfC5b40789a8bd1Df808453a

稳定币测试地址: 0xc277D918BFea177EfFB5330eD857F13f6d262c40

PriceOracle: 0x8ff1422580c9Cf9daf663Ab20EedDaD3486a2b1E

BancorToken地址： 0xdceB1CD8819Af07AD6dc83D847Baee36bA96EB52
    参数: _name: BT
         _symbol: BT
         _decimals: 18
         _totalSupply: 0
         _reserveToken: 0xc277D918BFea177EfFB5330eD857F13f6d262c40
         _weight: 5000


BancorToken.init:
    参数: _cm: 0xe45217628722E522AdA72A2597cE8D8714395074
         _fm: 0xe45217628722E522AdA72A2597cE8D8714395074
         _oracle: 0x8ff1422580c9Cf9daf663Ab20EedDaD3486a2b1E
         _bancorFormula: 0x55a836217EB3888dbfC5b40789a8bd1Df808453a
         _votePeriodblock: 2000
         _voteOpposeRate: 75
         _expectPrivateReserveToken: 1000


### BancorToken方法

* constructor: 构造合约
* init: 初始化合约， 仅合约所有者可执行
* transfer: 转账
* transferFrom: 授权转账
* approve: 授权
* destroy: 销毁代币, 仅合约所有者可执行
* reserveBalance: 查询募集USDT数量
* issueByBancor: 通过bancor发行代币
* createVote: 开启投票 ， 仅合约管理员可执行
* publicizeVote: 投票结束公示结果 ， 仅合约管理员可执行
* opposeVote: 代币持有者投反对票
* undoOpposeVote: 代币持有者撤销反对票
* setContractManager: 设置合约管理员地址， 仅合约所有者可执行
* setFinancialManager: 设置财务管理员地址， 仅合约所有者可执行
* setBancorFormula: 设置bancor计算地址， 仅合约所有者可执行
* setOracleAddress:  设置oralce地址， 仅合约所有者可执行
* setConversionFee: 设置发行代币手续费， 仅合约管理员可执行
* setConversionWeight: 设置bancor权重， 仅合约管理员可执行
* setExpectPrivateReserveToken： 设置私募阶段预期融资的USDT数量， 仅合约管理员可执行


### Oracle

oracle合约中设置Price= BT/USDT * 10^16


### TODO

3. 验证公式： 验证初始价格:
   不同的USDT范围可以配置不同的CW
