---
title: "Akash第二周挑战2流程"
date: 2020-12-09T01:00:00+08:00
lastmod: 2020-12-09T11:15:00+08:00
draft: false
summary: "介绍第二周挑战2部署RPC节点流程"
tags: ["Akash"]
---

# Akash第二周挑战2流程

## 部署edgenet-2的节点

deployment-2-2会在另一个网络部署akash，下载deployment-2-2.yaml
```
wget https://raw.githubusercontent.com/ovrclk/docs/ac011af1802a7c5fc7bb90d979c4f4877eaa24e1/testnet-challenges/deploy-2-2.yaml
```

按之前流程部署SDL和输出json提交即可。

连不上原来的RPC节点，可以换成下面这个。
AKASH_NODE="https://akash.rpc.best:443"

## 通过部署node的RPC发送一笔交易

.bashrc 里，添加 TESTNET_NODE，值为你上面部署的节点的RPC接口

```
TESTNET_NODE="你上面部署的节点的RPC接口"  # 实在是启动不了就用官方的RPC http://147.75.47.235:26657
```

私钥通用，给原来的钱包地址领币 https://akash.vitwit.com/faucet 

转账的指令，注意meme是用来记录备注的，需要填写你的邀请码。请确保不是空值。

```
akash \
  --node "$TESTNET_NODE" \
  --chain-id akash-edgenet-2 \
  --keyring-backend "$KEYRING_BACKEND" \
  --memo "$CODE" \
  --fees 4000uakt \
  tx send "$KEY_NAME" akash1vl3gun7p8y4ttzajrtyevdy5sa2tjz3a29zuah 1000000uakt
```

转账完成可以用下面指令查看交易

```
akash query tx [上面输出的txhash] --node "$TESTNET_NODE" --chain-id akash-edgenet-2
```


