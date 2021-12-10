---
title: 'Akash第二周挑战3流程（已结束）'
date: 2020-12-09T22:00:00+08:00
lastmod: 2020-12-12T14:00:00+08:00
draft: false
summary: '介绍第二周挑战3部署验证节点流程'
tags: ['Akash']
---

# Akash 第二周挑战 3 流程

最后的挑战是综合前面，有一定难度。前面的都搞清楚的话，部署没啥问题。

大致流程是用 deploy-2-3.yaml（和 2-2 的基本一样），跑云节点，然后通过调用云节点的 RPC，去生成验证人信息，并部署成验证人。验证人加入列表之后就可以关闭部署了。最关键的地方是把验证人节点名（MONIKER）设置成邀请码，验证人列表里就能看到。

官方文档 https://docs.akash.network/testnet-challenges/testnet-challenges/guided-deployments#challenge-3-week-2

部署前需先生成钱包并领测试币，参考 [Akash 节点部署流程]({{< ref "/post/005 akash_node/index.md" >}} "akash_node") 的前半部分运行 akash 本地程序 和 [Akash 挑战 1 流程（已结束）]({{< ref "/post/006 akash_challenge1/index.md" >}}) 的生成钱包。

运行代码都在下面。

```
#!/bin/bash
AKASH_NET="https://raw.githubusercontent.com/ovrclk/net/master/edgenet"
AKASH_NODE="https://akash.rpc.best:443"
TESTNET_NODE="http://174.138.34.238:26657"
AKASH_CHAIN_ID="akash-edgenet-1"
ACCOUNT_ADDRESS="" #需要填你自己的
KEY_NAME="" #需要填你自己的
KEYRING_BACKEND="os"
PROVIDER= #需要填你自己的
DSEQ= #需要填你自己的
GSEQ=1
OSEQ=1
CODE= #需要填你自己的

SECONDARY_NODE=$TESTNET_NODE
SECONDARY_MONIKER=$CODE
SECONDARY_KEY_NAME=$KEY_NAME
SECONDARY_CHAIN_ID=akash-edgenet-2
DEPLOY_YML=deploy-2-3.yaml

# 1. 发起部署交易，注意改yml文件
akash tx deployment create $DEPLOY_YML --from $KEY_NAME --node $AKASH_NODE \
 --chain-id $AKASH_CHAIN_ID  --fees 50000uakt -y

# 2. 查询部署的镜像列表，需要等会儿，输出的PROVIDER和DSEQ后修改上方的变量
akash query market lease list --owner $ACCOUNT_ADDRESS --node $AKASH_NODE \
--chain-id $AKASH_CHAIN_ID --state active

# 3. 上传部署许可，无输出
akash provider send-manifest $DEPLOY_YML --node $AKASH_NODE --dseq $DSEQ \
--oseq $OSEQ --gseq $GSEQ --owner $ACCOUNT_ADDRESS --provider $PROVIDER

# 4. 查询单个部署许可的状态，可获得服务地址。Mac电脑没jq的用 brew install jq 安装
akash provider lease-status \
  --dseq $DSEQ \
  --gseq $GSEQ \
  --oseq $OSEQ \
  --provider $PROVIDER \
  --owner $ACCOUNT_ADDRESS \
  --node $AKASH_NODE \
  | jq -r '.["forwarded-ports"].akash[] | select(.port==26657)'

# 5. 设置上面输出到DEPLOY_NODE_RPC变量
DEPLOY_NODE_RPC= #需要填你自己的

# 6. 查看同步状态
akash --node "$DEPLOY_NODE_RPC" status | jq '.sync_info.latest_block_height,\
.sync_info.latest_block_time,.sync_info.catching_up'

# 7. 查看RPC
akash provider lease-status \
  --dseq $DSEQ \
  --gseq $GSEQ \
  --oseq $OSEQ \
  --provider $PROVIDER \
  --owner $ACCOUNT_ADDRESS \
  --node $AKASH_NODE \
  | jq -r '.services.akash.uris[0]'

# 8. 上一步的结果设置到NODE_ENDPOINT变量
NODE_ENDPOINT= #需要填你自己的

# 9. 获取验证人信息
VALIDATOR_PUBKEY="$(curl -s "$NODE_ENDPOINT/validator-pubkey.txt")"

# 10. 创建验证人
akash tx staking create-validator \
  --node="$SECONDARY_NODE" \
  --amount=1000000uakt \
  --pubkey="$VALIDATOR_PUBKEY" \
  --moniker="$SECONDARY_MONIKER" \
  --chain-id="$SECONDARY_CHAIN_ID" \
  --commission-rate="0.10" \
  --commission-max-rate="0.20" \
  --commission-max-change-rate="0.01" \
  --min-self-delegation="1" \
  --gas-prices="0.025uakt" \
  --from="$SECONDARY_KEY_NAME"

# 11. 查看验证状态，有结果说明在验证人里了，可以提交并关闭部署
SECONDARY_VALOPER_ADDRESS="$(akash keys show "$SECONDARY_KEY_NAME" --bech=val -a)"
akash --node "$SECONDARY_NODE" query staking validator "$SECONDARY_VALOPER_ADDRESS"

# 12. 获取pull request用的json
akash query market lease get \
  --dseq $DSEQ \
  --gseq $GSEQ \
  --oseq $OSEQ \
  --provider $PROVIDER \
  --owner $ACCOUNT_ADDRESS \
  --node $AKASH_NODE -o json \
  > $CODE.json

# 13. 关闭部署
akash tx deployment close --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID --dseq $DSEQ\
 --owner $ACCOUNT_ADDRESS --from $KEY_NAME --fees 50000uakt  -y

```

提交方法参考 [Akash 挑战 1 流程（已结束）]({{< ref "/post/006 akash_challenge1/index.md" >}} "akash_challenge1") 的后面。

最后一个任务了。提交得越早的人奖励越多，大家冲起来。

> 如果 Provider 实在太坑老报错，万不得已，就参考之前的教程自己租服务器部署验证人吧。我们凌晨测试云节点很流畅。
> RPC 的使用方法可以参考 [Akash 第二周挑战 2 流程]({{< ref "/post/012 akash_challenge5/index.md" >}} "akash_challenge5") 。
> 验证人部署可以参考 [Akash 节点部署流程]({{< ref "/post/005 akash_node/index.md" >}} "akash_node") 的最后。
