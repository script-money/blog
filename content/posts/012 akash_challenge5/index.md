---
title: "Akash第二周挑战2流程"
date: 2020-12-09T01:00:00+08:00
lastmod: 2020-12-09T01:24:00+08:00
draft: false
summary: "介绍第二周挑战2部署RPC节点流程"
tags: ["Akash"]
---

# Akash第二周挑战2流程

deployment-2-2会在另一个网络部署akash，下载deployment-2-2.yaml
```
wget https://raw.githubusercontent.com/ovrclk/docs/ac011af1802a7c5fc7bb90d979c4f4877eaa24e1/testnet-challenges/deploy-2-2.yaml
```

按之前流程部署SDL和输出json提交即可。

连不上原来的RPC节点，可以换成下面这个。
AKASH_NODE="https://akash.rpc.best:443"

> 注意，以下非最新的任务要求

原来的任务还要求在akash-edgenet-2上转账给node，后来又取消了这个要求。如果想试试的可以按下面要求修改

网络从akash-edgenet-1换到了akash-edgenet-2，所以 .bashrc 里，修改AKASH_NODE和AKASH_CHAIN_ID
```
AKASH_NODE="http://147.75.47.235:26657"
AKASH_CHAIN_ID="akash-edgenet-2"
```

私钥通用，给原来的钱包地址领币 https://akash.vitwit.com/faucet 

转账的指令
`akash tx send $KEY_NAME  [TO_ADDRESS] [AMOUNT uakt] --chain-id $AKASH_CHAIN_ID --fees 5000uakt -y`

