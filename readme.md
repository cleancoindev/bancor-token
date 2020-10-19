## 合约说明

### 部署步骤:

   a. 部署BancorFormula合约
   b. 部署PriceOracle合约
   c. 部署BancorToken合约
   d. 执行BancorToken.init方法初始化合约

   e. 执行BancorToken.startPrivatePlacement开启私募

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



### BancorToken方法

* constructor: 构造合约
* init: 初始化合约， 仅合约所有者可执行
* startPrivatePlacement: 开启私募, 仅合约管理员可执行
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



### Kovan测试地址

助记词： MNEMONIC=blue depend prepare team unveil play oblige snack announce say crunch vocal


Starting migrations...
======================
> Network name:    'kovan'
> Network id:      42
> Block gas limit: 12500000 (0xbebc20)


1_deploy_contracts.js
=====================

   Replacing 'BancorFormula'
   -------------------------
   > transaction hash:    0xdc096ac71f12a1f1a0b1d59cf7b26fbc856e3feebca8335ec161dd172a92d4b2
   > Blocks: 3            Seconds: 10
   > contract address:    0x0cCa1a5F8eD003437E98443832645C14ce9943D3
   > block number:        21610065
   > block timestamp:     1603118368
   > account:             0xe45217628722E522AdA72A2597cE8D8714395074
   > balance:             3.23665577716340124
   > gas used:            3366793 (0x335f89)
   > gas price:           2 gwei
   > value sent:          0 ETH
   > total cost:          0.006733586 ETH


   Replacing 'PriceOracle'
   -----------------------
   > transaction hash:    0x87802ee37e5c6fe936e5b72c08d0e4cb688430c519f1067e48a1475cc3ae2dac
   > Blocks: 2            Seconds: 5
   > contract address:    0xE2eD5a7270eDEe70d1Ba0190Cb5aCE4F0C19a5Cb
   > block number:        21610068
   > block timestamp:     1603118384
   > account:             0xe45217628722E522AdA72A2597cE8D8714395074
   > balance:             3.23616659916340124
   > gas used:            244589 (0x3bb6d)
   > gas price:           2 gwei
   > value sent:          0 ETH
   > total cost:          0.000489178 ETH


   Replacing 'ERC20Token'
   ----------------------
   > transaction hash:    0xdc88b186ff230ab501c81cd3bced5e22afaee5a2a3e4099831eebec377e1f0b2
   > Blocks: 1            Seconds: 6
   > contract address:    0x0B2cF7CDE86bCb1f26fD3e2d2C6840fa9892e2cb
   > block number:        21610074
   > block timestamp:     1603118412
   > account:             0xe45217628722E522AdA72A2597cE8D8714395074
   > balance:             3.23498775716340124
   > gas used:            547060 (0x858f4)
   > gas price:           2 gwei
   > value sent:          0 ETH
   > total cost:          0.00109412 ETH


   Replacing 'BancorToken'
   -----------------------
   > transaction hash:    0xbb617b8e75d221d05cc16b311acb2e48c06299e4cb8983cff727dab159f2c222
   > Blocks: 2            Seconds: 6
   > contract address:    0x62438001B14114C9603e3ae844c7F8765fb74d86
   > block number:        21610077
   > block timestamp:     1603118428
   > account:             0xe45217628722E522AdA72A2597cE8D8714395074
   > balance:             3.23003354116340124
   > gas used:            2477108 (0x25cc34)
   > gas price:           2 gwei
   > value sent:          0 ETH
   > total cost:          0.004954216 ETH

   > Saving artifacts
   -------------------------------------
   > Total cost:           0.0132711 ETH


Summary
=======
> Total deployments:   4
> Final cost:          0.0132711 ETH



3. 验证公式： 验证初始价格:
   不同的USDT范围可以配置不同的CW
