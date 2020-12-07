---
title: "Akash第二周挑战1流程"
date: 2020-12-07T21:00:00+08:00
lastmod: 2020-12-07T22:00:00+08:00
draft: false
summary: "介绍第二周挑战1部署API节点流程"
tags: ["Akash"]
---

# Akash第二周挑战1流程

流程还是和上周一样，提交部署，提交json。使用 [deploy-2-1.yaml](https://raw.githubusercontent.com/ovrclk/docs/master/testnet-challenges/deploy-2-1.yaml) 来在akash上部署akash。

要注意版本已经从r11更新到了r13，先输入 `akash version` 看看，是老版本就先更新一下。

更新方式两种，一是切到akash源码文件夹，pull新代码重新make

```
cd $GOPATH/src/github.com/ovrclk/akash
git pull origin v0.9.0-rc13
make deps-install
make install
```

另一种是直接下载官方编译好的

```
wget https://github.com/ovrclk/akash/releases/download/v0.9.0-rc13/akash_0.9.0-rc13_linux_amd64.zip
sudo apt install unzip
unzip akash_0.9.0-rc13_linux_amd64.zip
mv akash_0.9.0-rc13_linux_amd64/akash go/bin/akash
```

Mac的更新方式是 `brew upgrade akash-edge`

更新完成后用 `akash version` 确认下

目前活动还没开始，提交部署老提示 failed to execute message; message index: 0: Deployment closed 

等明天再看吧

> 待后续更新