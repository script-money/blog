---
title: 'StarkNet代码交互流程'
date: 2022-08-29T23:00:00+08:00
lastmod: 2022-09-15T021:00:00+08:00
draft: false
summary: '介绍如何导出钱包，使用代码来进行测试网交互'
---

一些开发类的StarkNet教程教的是创建新的账户、编写新合约和测试。而本文主要介绍如何导出已有钱包账户，并和已经上线的合约进行交互。

## 1. 初始化nile项目

[nile](https://github.com/OpenZeppelin/nile/) 是 StarkNet 上流行的cli开发工具，能简化流程提高效率。根据[README](https://github.com/OpenZeppelin/cairo-contracts)安装后，确保输入 `nile version` 会显示版本号。

然后新建文件夹，输入`nile init`初始化项目

输入`nile compile`编译一下示例合约。compile 后 artifacts 中会出现 json 格式的 ABI 文件。

## 2. 导出私钥

私钥可以本地生成，也可以从钱包导出，重点介绍钱包导出的私钥如何使用。下图分别是argent和braavo的导出位置。

![01 argent导出](01%20%E5%AF%BC%E5%87%BA.png)

![02 braavos导出](./02%20braavos.png)

获得私钥后，在nile init生产的项目的根目录创建一个 `.env`文件，设置一个变量放置私钥，比如PK1=1234，这个**PK1**是alias，可以设置简单一些，后面会用到。

![03 env](./03%20env.png)

然后输入`nile setup PK1 --network goerli`，会在测试网部署一个合约账户，同时根目录会出现一个 *goerli.accounts.json* ，里面包含PK1这个私钥派生出的公钥和地址。这个新生成的合约地址和之前钱包里的不一样，需 **手动替换** 成网页钱包的地址。同样还需要替换 *goerli.deployments.txt* 中的账户合约地址。

![04 替换地址](./04%20%E6%9B%BF%E6%8D%A2%E5%9C%B0%E5%9D%80.png)

## 3. 去浏览器获取目标合约的abi

打开[voyager](https://goerli.voyager.online)，搜索目标合约，在code标签里找到abi，复制到新文件`artifacts/abis/[alias].json`下。alias可以任意取。

![05 获取abi](./05%20%E8%8E%B7%E5%8F%96abi.png)

在根目录的 *goerli.deployments.txt* 下添加 **合约地址:abi路径:alias**，我取的是[starknet-cairo-101](https://github.com/starknet-edu/starknet-cairo-101)的第1个练习，alias写的是ex01。所以 *goerli.deployments.txt* 的新增的内容是：`0x29e2801df18d7333da856467c79aa3eb305724db57f386e3456f85d66cbd58b:artifacts/abis/ex01.json:ex01`

## 4. 发送交易

创建一个python脚本，一般放到scripts或tests目录下，编写`def run(nre)`方法通过`nile run`指令去执行测试脚本。

下面示例代码是让PK1这个账户去执行ex01的`claim_points`方法，没有参数。

> 参数通常需要转换，建议先参考[该教程](https://blog.openzeppelin.com/getting-started-with-openzeppelin-contracts-for-cairo/)。

最后 max_fee 需要用官方cli的`starknet estimate_fee`指令去获取，可以先随意设置，如果debug报错再修改。

```Python
from nile.nre import NileRuntimeEnvironment
from nile.core.account import Account

def run(nre: NileRuntimeEnvironment):
    account: Account = nre.get_or_deploy_account("PK1")
    result = account.send(
        "0x29e2801df18d7333da856467c79aa3eb305724db57f386e3456f85d66cbd58b",  # 目标合约地址
        "claim_points", # 方法
        [],  # 参数
        2278140156336 # max_fee
    )
    print(result)
```

> 如果需要通过发送交易到合约钱包去和其他合约交互，必须使用account.send方法，而不是invoke。

输入`nile run tests/demo.py --network goerli`
会执行上面的脚本，并输出交易的hash和地址

![06 地址和Hash](./06%20%E5%9C%B0%E5%9D%80%E5%92%8Chash.png)

最后用 `nile debug [TxHash] --network goerli` 去检查交易状态。

![07 交易状态](./07%20%E4%BA%A4%E6%98%93%E7%8A%B6%E6%80%81.png)

以上就是StarkNet用钱包和合约进行代码交互的流程，有疑问欢迎和我沟通。
