---
title: "Flow 开发入门指南"
date: 2021-06-06T21:30:00+08:00
lastmod: 2021-06-06T23:30:00+08:00
draft: false
summary: "最近在做 Flow 的项目，进行了完整开发，说一些开发入门的关键点"
tags: ["Flow"]
---

Flow 有完整的文档，合约语言是面向资源编程的Cadence，需要先看看Cadence[入门文档](https://docs.onflow.org/cadence/tutorial/01-first-steps)，跑一下playground，会对面向资源编程有了解。

Cadence 对 struct（用于承载信息的普通数据） 和 Resource（有价值的数据）有严格区分，包括复制、引用、示例化等操作的语法也不同，需要理清楚，不然一些符号如<-、@会很陌生。另外资源存储需要理解下，包括资源的borrow、link、save等操作，都是其他合约语言没有的。其他语法和一般的编程语言类似，用到的时候看文档即可。

如果熟悉 NBA TopShot 的话，推荐看看 [nba-smart-contracts](https://github.com/dapperlabs/nba-smart-contracts)，对理解Cadence会很有帮助。

[kittyItems](https://github.com/onflow/kitty-items) 是最佳实践，包含完整的前后端合约以及第三方钱包集成，也需要看。

写合约的时候，随时需要测试，NBA TopShot 和 kitty-items 两个官方库都是用golang写的测试，可以直接参考。如果是用js来写测试，参考 [flow-js-testing](https://github.com/onflow/flow-js-testing)，该库文档很不完善，需要看源码和样例，看懂了配合jest直接模拟器进行测试，还是很顺畅的。还有个新的测试库[flow-cadence-hrt](https://github.com/onflow/flow-cadence-hrt)还没试过。如果写一些带有特殊逻辑的合约函数，肯定会有点混乱，遇到困难多查文档和discord，以及参考官方样例代码（NBATopShot和kittyItems）

服务端的代码，主要完成需要管理员签名的功能，js版可以参考 kitty-items，golang版参考nba-smart-contracts。

web端的代码，主要完成用户端的功能，同样可以参考kitty-items。另外[fcl-demo](https://github.com/portto/fcl-demo)很有用，有dev-wallet的用法。

另外所有样例代码记得及时pull，flow-cli也及时更新，迭代还是蛮快的。

目前web端和合约端的模拟器环境都完整跑了一遍，代码库是 [FanNFT](https://github.com/script-money/FanNFT)，除了实现标准的NFT接口，还有些特殊的设计。

flow-cli升级到新版本后发现本地钱包不能用了，部署到测试网合约运算有bug，需要完全升级。建议参考重构过的kitty-item。

另外测试网响应慢，本地模拟器看不出来，是需要在UX上做一些设计的。
