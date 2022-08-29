---
title: 'Cairo开发工具 nile 介绍'
date: 2022-08-29T21:00:00+08:00
lastmod: 2022-08-29T22:00:00+08:00
draft: false
summary: '介绍nile的主要功能和适用范围'
---

[nile](https://github.com/OpenZeppelin/nile) 是由 OpenZeppelin 主导的开源项目，是一款开发 StarkNet 项目的 cli 工具，帮助用户编译、部署、测试，主要由 Python 编写，如果你在学习 StarkNet 开发，那么在各种教程都能见到它。nile 的安装和基本使用，参考README，链接是 [https://github.com/OpenZeppelin/nile](https://github.com/OpenZeppelin/nile) ，按着步骤一步一步走，不多做介绍。主要说一下它的功能和范围：

 StarkNet 有官方的 Python 库（cairo-lang），那么 cairo-nile 的作用是什么呢？经过一番使用和源码阅读，以下是我的回答：

 1. nile 有个项目模版，用户可以用`nile init`初始化一个Cairo的新项目，会安装最新的依赖包，初始化文件夹，提供基础合约和测试用例。
 2. 用户设置别名运行了部署账户和合约命令后，都会以json的形式存储在根目录，后续无论是用指令访问，还是手动查看，都很方便。
 3. 转译了常用的 starknet cli 的指令，并通过访问存储的json信息，可以简化大量的参数输入。
 4. 提供run script 的功能，可以编写Python代码去运行nile运行时环境暴露出来的指令。避免编写shell代码。
 5. 最新版本0.8.1提供了一些int、felt、uint256互转的一些utils函数。

在我使用的过程中也发现了一些缺点，当然这些问题肯定会随着版本更新慢慢解决：

1. 缺少测试网生产环境的一些功能，比如没有 estimate_gas，需要用户手动去修改源码扩展，或者用官方的 starknet cli 的指令完成。
2. 只支持venv环境，如果用 conda 会报错。
3. 文档有一些缺失的部分，可以参考[https://github.com/OpenZeppelin/cairo-contracts](https://github.com/OpenZeppelin/cairo-contracts)会有更详细的安装说明。

## 总结

nile 是一款基本可以平替官方 starknet cli 的 cairo开发工具，能提高不少合约编写、开发、测试的效率，适合 Python 工程师使用。
