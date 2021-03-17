#!/bin/zsh
AKASH_NET="https://raw.githubusercontent.com/ovrclk/net/master/mainnet"
AKASH_NODE="http://135.181.60.250:26657"
AKASH_CHAIN_ID="akashnet-2"
ACCOUNT_ADDRESS="akash1msh7cceezcl556n3nx3grz8quq8scnj7mrnnnm"
KEY_NAME="main"
KEYRING_BACKEND="os"
DEPLOY_YML=deploy.yaml
FEES=500uakt

TX="E01A0D970FB870E6DC770291087F32A67BB3137A3965C073E0472B82665754BE"
PROVIDER=akash1ccktptfkvdc67msasmesuy5m7gpc76z75kukpz
DSEQ=120486
GSEQ=1
OSEQ=1
CODE=c8xse9yeozxk71z
SERVICE_NAME=

# 查询交易
# akash query tx $TX --node "$AKASH_NODE" --chain-id $AKASH_CHAIN_ID --log_level info

# 0. certificate must first be created
# akash tx cert create client --broadcast-mode sync --chain-id $AKASH_CHAIN_ID --keyring-backend $KEYRING_BACKEND --from $KEY_NAME --node=$AKASH_NODE --fees $FEES --log_level info
# akash query cert list --owner $ACCOUNT_ADDRESS --node=$AKASH_NODE

# 1. 提交部署交易，需要5akt，注意设置DEPLOY_YML变量
# akash tx deployment create $DEPLOY_YML --from $KEY_NAME --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID  --broadcast-mode sync --log_level info --fees $FEES -y



# 2.4 查询可用的provider
# akash query audit list --node $AKASH_NODE --log_level info
# 2.5 查询当前用户的活动租约
# akash query market lease list --owner $ACCOUNT_ADDRESS --node $AKASH_NODE --log_level info --state active
# 2. 查询当前用户的全部bid
# akash query market bid list --owner $ACCOUNT_ADDRESS --node $AKASH_NODE --log_level info
# 2.6 查询全部请求
# akash query market bid list --node $AKASH_NODE --log_level info --state active
# 2.6 查询全部订单
# akash query market order list --node $AKASH_NODE --log_level info 
# 2.6 查询当前用户的全部订单
# akash query market order list --owner $ACCOUNT_ADDRESS --node $AKASH_NODE --log_level info 
# 2.7 查询cert
# akash query cert list --owner $ACCOUNT_ADDRESS --log_level info  --node $AKASH_NODE
# 2.9 查询当前账户的deployment
# akash query deployment list --owner $ACCOUNT_ADDRESS --log_level info  --node $AKASH_NODE


# 3. from bid create lease. modify dseq and provider
# akash tx market lease create --provider $PROVIDER --dseq $DSEQ --broadcast-mode async \
# --gseq 1 --oseq 1 --node $AKASH_NODE --owner $ACCOUNT_ADDRESS \
# --from $KEY_NAME --log_level info --chain-id $AKASH_CHAIN_ID --fees $FEES -y

# 4. check lease
# akash query market lease list --owner $ACCOUNT_ADDRESS --node $AKASH_NODE --log_level info

# new
# akash deploy create $DEPLOY_YML --from $KEY_NAME --chain-id $AKASH_CHAIN_ID --keyring-backend $KEYRING_BACKEND --node $AKASH_NODE --fees $FEES --log_level info

# 5. 发送配置文件，无输出
# akash provider send-manifest $DEPLOY_YML --log_level info --from $KEY_NAME --home ~/.akash --node $AKASH_NODE --dseq $DSEQ --provider $PROVIDER

# 5.1. check lease
# akash provider lease-status --log_level info --dseq $DSEQ --from $KEY_NAME --home ~/.akash  --provider $PROVIDER --node $AKASH_NODE

# 4. 查询单个部署租约的状态，可获得服务web地址
# akash provider lease-status --node $AKASH_NODE --from $KEY_NAME --dseq $DSEQ --home ~/.akash --provider $PROVIDER
# akash provider lease-logs --node $AKASH_NODE --from $KEY_NAME --dseq $DSEQ --home ~/.akash --provider $PROVIDER
akash provider lease-events --node $AKASH_NODE --from $KEY_NAME --dseq $DSEQ --home ~/.akash --provider $PROVIDER

# 5. 获取要提交的json
# akash query market lease get --dseq $DSEQ --gseq $GSEQ --oseq $OSEQ \
#  --provider $PROVIDER --owner $ACCOUNT_ADDRESS --node $AKASH_NODE -o json > $CODE.json

# 发送更新部署
# akash tx deployment update $DEPLOY_YML --dseq $DSEQ --from $KEY_NAME --broadcast-mode sync --owner $ACCOUNT_ADDRESS \
#  --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID  --fees $FEES --log_level info -y

# akash tx deployment group start --owner=$ACCOUNT_ADDRESS \
# --dseq $DSEQ --gseq $GSEQ --node $AKASH_NODE --home ~/.akash \
# --chain-id $AKASH_CHAIN_ID --fees $FEES -y

# 查询账户余额
# akash query bank balances --node $AKASH_NODE $ACCOUNT_ADDRESS

# 取消部署
# akash tx deployment close --node $AKASH_NODE --chain-id $AKASH_CHAIN_ID --gas 500000 \
# --broadcast-mode sync --dseq $DSEQ --owner $ACCOUNT_ADDRESS --from $KEY_NAME \
# --fees $FEES --log_level info -y

# 查看运行日志
# akash --home "$AKASH_HOME" --node "$AKASH_NODE" provider service-logs --service $SERVICE_NAME \
#   --owner "$ACCOUNT_ADDRESS" --dseq "$DSEQ" --gseq 1  --oseq $OSEQ --provider "$PROVIDER"

# 查看provider状态
# akash provider status --provider $PROVIDER --node "$AKASH_NODE" | grep "deployments"

## 转账
# akash --node "$AKASH_NODE" tx send $KEY_NAME  akash1msh7cceezcl556n3nx3grz8quq8scnj7mrnnnm 99999500uakt --broadcast-mode sync --chain-id $AKASH_CHAIN_ID  --fees 200uakt --log_level info -y

# # 转账
# akash --node "$TESTNET_NODE" --chain-id akash-edgenet-2 --keyring-backend "os" \
#   --memo "" --fees 4000uakt tx send "$KEY_NAME" akash1gwcgaqn848k8ezpk4uq9gcxju5qhd3f5pwpr6z 99990000uakt -y

# 查看验证人列表
# akash query tendermint-validator-set --chain-id="akash-edgenet-2" --node=$TESTNET_NODE

# 查看验证人列表2
# akash query staking validators  --chain-id="akash-edgenet-2" --node=$TESTNET_NODE

# 生成钱包
# akash  --keyring-backend "$KEYRING_BACKEND" keys add "$KEY_NAME" 

# 查看提案
# akash q gov proposals --chain-id $AKASH_CHAIN_ID --node $AKASH_NODE

# 投票 
# akash tx gov vote 4 Yes --broadcast-mode sync --chain-id $AKASH_CHAIN_ID --node $AKASH_NODE --from $KEY_NAME --fees $FEES