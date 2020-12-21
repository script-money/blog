---
title: "STX 采矿挑战第一阶段教程"
date: 2020-12-20T18:30:00+08:00
lastmod: 2020-12-21T16:07:00+08:00
draft: false
summary: "对活动流程简介，帮读者排一些坑"
tags: ["node"]
---

# STX 采矿挑战第一阶段教程

【12-21 06:00 更新：链又重启了，请重新去领BTC，然后重启节点】

活动开始时间是北京时间2020年12月21日22:00，持续两周，预计有100刀的 STX 奖励。（根据挖矿效率和参与人数而定）

先点击 [活动报名页面链接](https://daemontechnologies.co/minestx-challenge-zh) 报名，最好用英文页面去报名。中文页面报名得到的邮件不显示BTC地址，最后领奖可能需要联系官方解决。

需要生成地址，具体生成方式参考[该视频](https://www.youtube.com/watch?v=82b8PGoQYpI)。如果在本机生成遇到困难，可以先看后面，在服务器上去生成。或者设置npm镜像，参考[该文章](https://segmentfault.com/a/1190000027083723)。或者加我微信 script-money 帮忙生成。

有两个测试网 krypton 和 xenon ，目前一阶段活动是 krypton，使用的软件版本是 24.0.0.0-xenon，自己看文档的大佬别挖错了。

有两种挖矿方式，租 VPS 或者 运行挖矿机器人。

## 租 VPS

我使用的VPS厂商是vultr，可以用 [该邀请链接](https://www.vultr.com/?ref=8744080-6G) 注册，有为期一个月 $100 的免费额度可用。

vultr 基本的界面操作在 [「akash节点部署视频流程」](https://www.bilibili.com/video/BV1Zz4y1k7FF/)里有，小白可以看看。

服务器配置至少选择 $20/mo 2核4G的。因为有 $100 免费额度，选更高配也行。如果选择4G内存需要设置8GB的swap，否则运行节点程序会内存不足秒退。

设置swap参考 [该文章](https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-20-04)

我租用的是 Ubuntu 20.10 x64，默认是root用户，无需sudo。若自建用户，后面的指令遇到 no permission，在指令前加 `sudo` 运行。例如 `sudo apt update`

连上服务器后，先更新系统并安装 unzip 包

```shell
apt update
apt upgrade -y
apt install unzip -y
```

输入 `curl -sS -X POST https://stacks-node-api.krypton.blockstack.org/extended/v1/faucets/btc?address=YOURBTCADDRESS` 领测试的BTC，YOURBTCADDRESS 换成文章开头生成地址里面的btcAddress。（出现`{"error":"[object Object]`"则重新运行一次）

创建一个名为 blockstack 文件夹 进去后下载节点包并解压

```shell
mkdir blockstack
cd blockstack
wget https://github.com/blockstack/stacks-blockchain/releases/download/v24.0.0.0-xenon/linux-x64.zip
unzip linux-x64.zip
```

在 blockstack 文件夹下创建挖矿配置文件 miner-config.toml，内容参考下面，注意第5行的 seed = "" 要在引号内加上文章开头生成的地址里面的privateKey。

```shell
[node]
rpc_bind = "0.0.0.0:20443"
p2p_bind = "0.0.0.0:20444"
bootstrap_node = "048dd4f26101715853533dee005f0915375854fd5be73405f679c1917a5d4d16aaaf3c4c0d7a9c132a36b8c5fe1287f07dad8c910174d789eb24bdfb5ae26f5f27@krypton.blockstack.org:20444"
seed = "" # Enter your private key here!
miner = true

[burnchain]
chain = "bitcoin"
mode = "krypton"
peer_host = "bitcoind.krypton.blockstack.org"
rpc_port = 18443
peer_port = 18444
burn_fee_cap = 20000

[[mstx_balance]]
address = "STB44HYPYAT2BB2QE513NSP81HTMYWBJP02HPGK6"
amount = 10000000000000000

[[mstx_balance]]
address = "ST11NJTTKGVT6D1HY4NJRVQWMQM7TVAR091EJ8P2Y"
amount = 10000000000000000

[[mstx_balance]]
address = "ST1HB1T8WRNBYB0Y3T7WXZS38NKKPTBR3EG9EPJKR"
amount = 10000000000000000

[[mstx_balance]]
address = "STRYYQQ9M8KAF4NS7WNZQYY59X93XEKR31JP64CP"
amount = 10000000000000000
```

配置镜像守护，注意ExecStart的执行路径指向你下载的stacks-node和miner-config的路径，例如你的用户根目录是/home/ubuntu，就改为`ExecStart=/home/ubuntu/blockstack/stacks-node start --config=/home/ubuntu/blockstack/miner-config.toml`

```shell
sudo echo '
[Unit]
Description=stack miner server
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/root/blockstack/stacks-node start --config=/root/blockstack/miner-config.toml

[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/miner.service
systemctl enable miner
```

配置 journald 并重新加载

```bash
sed -i 's/#Storage=auto/Storage=persistent/g' /etc/systemd/journald.conf
journalctl --vacuum-size=500M
systemctl restart systemd-journald
```

输入 `systemctl start miner` 启动节点

输入 `journalctl -u miner -f` 查看节点运行日志

输入 `journalctl -u miner.service | grep "Miner node: starting up, UTXOs found."` ，有结果输出说明你的BTC是有余额的，否则重新领币并重启节点。

输入 `curl http://localhost:20443/v2/info` 查看本地节点运行状态。如果是下面这样说明节点运行成功了，在同步区块。

![状态](stack.png)

隔几分钟看看状态，一开始 burn_block_height 会增加，stacks_tip_height 是0。但如果 burn_block_height 已经300了，stacks_tip_height 还是0的话，可能挖到分叉链上了，需要输入 `systemctl restart miner` 重启节点重新同步。

输入 `curl http://krypton.blockstack.org:20443/v2/info` 查看官方的节点运行状态。burn_block_height 和 stacks_tip_height 和官方的一样（或者多1个块），说明同步完成，会自动开始挖矿了。你就可以断开与VPS的连接了。

stacks_tip_height 超出很多也可能是挖到了分叉链，需重启。

查看是否挖到矿的方法：
`journalctl -u miner.service | grep 输入你的btc地址` 。如果出现类似 `including block_commit_op (winning) - mv8Vudk9SQNjxabG7fmvGqqTUe77WKspYA (7888dfc3aba1b3226bca19b625c10192bfd0c2bdfd6abc4e1f984cb5b350946e)`
的消息说明是你有成功挖到了块。

遇到其他问题可以下面评论区看看，有疑问欢迎留言。

或者查询 [stx-mining-faq](https://stacks101.com/stx-mining-faq/#running-stacks-node)，或者进官方discord去搜索。

## 运行挖矿机器人

官方文档是介绍挖矿机器人的，我非常不建议用 Windows 电脑去运行，一是因为不能24小时在线影响挖矿效率，二是国内网络太坑，下载同步东西都慢，而且极易挖到分叉链上。如果非要用，我简单说一下遇到一些坑。

可以先参考 [无代理环境下载 WSL 安装包]({{< ref "/posts/017 wsl_download/index.md" >}}) 下载 WSL 的包，并根据微软官方的文档安装 WSL2的ubuntu

可能需要参考 [配置apt镜像](https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/) 不然 `apt update` 很慢

WSL运行起来后，参考 [wsl安装nodejs 14](https://computingforgeeks.com/install-node-js-14-on-ubuntu-debian-linux/)，安装nodejs和npm

如果 `sudo npm install -g yarn` 有权限问题，可参考 [该文章](https://cmatskas.com/resolve-npm-access-denied-errors/) 重新设置npm的路径

可能需要 [配置yrm](https://blog.csdn.net/qq_42094345/article/details/109307308)，不然下载npm的包很慢

yarn正常后，可以参考 [官方录制的视频](https://www.youtube.com/watch?v=FXifFx0Akzc&t=49s) 继续后面的操作即可。