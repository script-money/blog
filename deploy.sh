#!/bin/zsh
AKASH_NET="https://raw.githubusercontent.com/ovrclk/net/master/edgenet"
AKASH_NODE="https://akash.rpc.best:443"
TESTNET_NODE="http://174.138.34.238:26657"
AKASH_CHAIN_ID="akash-edgenet-1"
ACCOUNT_ADDRESS="akash1gwcgaqn848k8ezpk4uq9gcxju5qhd3f5pwpr6z"
KEY_NAME="script-money"
KEYRING_BACKEND="os"
PROVIDER=akash174hxdpuxsuys9qkauaf57ym5j8dm4secnz6jd7
DSEQ=203400
GSEQ=1
OSEQ=1
CODE=c8xse9yeozxk71z
DEPLOY_YML=deploy.yaml
SERVICE_NAME=

# 1. 发起部署交易，注意改yml文件
# akash tx deployment create $DEPLOY_YML --from $KEY_NAME --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID  --fees 50000uakt -y

# 2. 查询部署的镜像列表，需要等会儿，输出的PROVIDER和DSEQ后修改上方的变量
# akash query market lease list --owner $ACCOUNT_ADDRESS --node $AKASH_NODE --state active

# # 3. 上传部署许可，无输出
# akash provider send-manifest $DEPLOY_YML --node $AKASH_NODE --dseq $DSEQ \
# --oseq $OSEQ --gseq $GSEQ --owner $ACCOUNT_ADDRESS --provider $PROVIDER

# 4. 查询单个部署许可的状态，可获得服务web地址
# akash provider lease-status --node $AKASH_NODE --dseq $DSEQ --oseq $OSEQ \
# --gseq $GSEQ --provider $PROVIDER --owner $ACCOUNT_ADDRESS

# 5. 获取要提交的json
# akash query market lease get --dseq $DSEQ --gseq $GSEQ --oseq $OSEQ \
#  --provider $PROVIDER --owner $ACCOUNT_ADDRESS --node $AKASH_NODE -o json > $CODE.json

# 更新部署
# akash tx deployment update $DEPLOY_YML --dseq $DSEQ --from $KEY_NAME --owner $ACCOUNT_ADDRESS \
#  --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID  --fees 50000uakt

# 查询账户余额
# akash query bank balances --node $TESTNET_NODE $ACCOUNT_ADDRESS # 余额998806000

# # 取消部署
# akash tx deployment close --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID \
# --dseq $DSEQ --owner $ACCOUNT_ADDRESS --from $KEY_NAME --fees 50000uakt  -y

# 查看运行日志
# akash --home "$AKASH_HOME" --node "$AKASH_NODE" provider service-logs --service $SERVICE_NAME \
#   --owner "$ACCOUNT_ADDRESS" --dseq "$DSEQ" --gseq 1  --oseq $OSEQ --provider "$PROVIDER"

# 查看provider状态
# akash provider status --provider $PROVIDER --node "$AKASH_NODE" | grep "deployments"

## 转账
# akash --node "$AKASH_NODE" tx send $KEY_NAME  akash1sax9ndx9ercawuqwkn49jauxvvrfmzhhx6y0mg 1000000uakt --chain-id $AKASH_CHAIN_ID  --fees 50000uakt  -y

# # 转账
# akash --node "$TESTNET_NODE" --chain-id akash-edgenet-2 --keyring-backend "os" \
#   --memo "" --fees 4000uakt tx send "$KEY_NAME" akash1gwcgaqn848k8ezpk4uq9gcxju5qhd3f5pwpr6z 99990000uakt -y
  
# 查询交易
# akash query tx [tx] --node "$TESTNET_NODE" --chain-id akash-edgenet-2

# 查看验证人列表
# akash query tendermint-validator-set --chain-id="akash-edgenet-2" --node=$TESTNET_NODE

# 查看验证人列表2
# akash query staking validators  --chain-id="akash-edgenet-2" --node=$TESTNET_NODE

# 生成钱包
# akash  --keyring-backend "$KEYRING_BACKEND" keys add "$KEY_NAME" 