---
title: "Akash第二周挑战3流程"
date: 2020-12-09T22:00:00+08:00
lastmod: 2020-12-09T22:00:00+08:00
draft: false
summary: "介绍第二周挑战3部署验证节点流程"
tags: ["Akash"]
---

# Akash第二周挑战3流程

虽然[官方文档](https://docs.akash.network/testnet-challenges/testnet-challenges/guided-deployments#challenge-3-week-2) 上写了"Instructions will be revealed when the challenge starts."，还看不到流程，实际GitHub上已经有说明了 https://github.com/ovrclk/docs/blob/master/testnet-challenges/guided-deployments.md

最后的挑战是综合前面，有一定难度。前面的都搞清楚的话，部署没啥问题。

大致流程是用 deploy-2-3.yaml（和2-2的基本一样），跑云节点，然后通过调用云节点的RPC，去生成验证人信息，并部署成验证人。验证人签名了几个块之后就可以关闭部署了。最关键的地方是**把验证人节点名（MONIKER）设置成邀请码**。

RPC的使用方法可以参考 [Akash第二周挑战2流程]({{< ref "/posts/012 akash_challenge5/index.md" >}} "akash_challenge5") 。

验证人部署可以参考 [Akash节点部署流程]({{< ref "/posts/005 akash_node/index.md" >}} "akash_node") 的最后。

所有配置文件在 https://github.com/ovrclk/net/tree/master/definet ，可以看到和挑战5一样，还是在edgenet-2上运行。

~~如果Provider实在太坑不接单或者报错，万不得已，就参考之前的教程自己租VPS部署验证人吧。~~

最后一个任务了。提交得越早的人奖励越多，大家冲起来。