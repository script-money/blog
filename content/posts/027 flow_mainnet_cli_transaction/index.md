---
title: "Flow 主网命令行转账步骤"
date: 2021-06-23T21:00:00+08:00
lastmod: 2021-06-23T22:08:00+08:00
draft: false
summary: "介绍导出私钥并在Flow主网用命令行转账的方法"
tags: ["Flow"]
---

> flow-cli使用版本 v0.24.0

众所周知，flow主网目前由blocto和dapper托管着钱包，自己生成的keys又不能生成账户，所以介绍下如何从blocto转出私钥并用cli转账。

1. 打开blocto的移动端钱包，设定——安全性——自管私钥模式，设定备援密码然后导出。
2. 会收到一封Blocto Account Recovery Kit的邮件，里面的附件是keystore的json。复制保存为keystore.json文件。
3. 参考以下js代码算出私钥，需`npm i ethereum-keystore`
    ```javascript
    const { recoverKeystore } = require('ethereum-keystore')
    const keystoreJson = require('./keystore.json')

    const main = async () => {
        const privateKey = await recoverKeystore(keystoreJson, '你的备援密码')
        console.log(privateKey)
    }

    main()
    ```
4. 回到blocto找到flow账号，类似`0xec41095fd14e6aae`，然后浏览器访问`https://flow-view-source.com/mainnet/account/[地址换成你自己的]/keys`，找到 *Weight: 1000/1000* 且**没有**`REVOKED`的公钥。记住KeyId(应该是3)、Curve(应该是ECDSA_secp256k1)和Hash(应该是SHA3_256)。
5. 创建一个`.env`，之前获取的私钥和账号一起填入`.env`文件，类似这样
    ```bash
    MAINNET_ADDRESS=0xec41095fd14e6aae
    MAINNET_PRIVATE_KEY=[换成第三步的privateKey]
    ```
6. 安装了flow-cli工具后，用`flow init`生成flow.json文件，填入以下内容。
    ```
    {
        "emulators": {
            "default": {
                "port": 9000,
                "serviceAccount": "mainnet-account"
            }
        },
        "contracts": {},
        "networks": {
            "emulator": "127.0.0.1:3569",
            "mainnet": "access.mainnet.nodes.onflow.org:9000",
            "testnet": "access.devnet.nodes.onflow.org:9000"
        },
        "accounts": {
            "emulator-account": {
                "address": "f8d6e0586b0a20c7",
                "keys": "1e457adfd9fe97232df5d30b286f63e661e5e023b4bb110c092ac0626be3096e"
            },
            "mainnet-account": {
                "address": "${MAINNET_ADDRESS}",
                "key": {
                    "type": "hex",
                    "index": 3,
                    "signatureAlgorithm": "ECDSA_secp256k1",
                    "hashAlgorithm": "SHA3_256",
                    "privateKey": "${MAINNET_PRIVATE_KEY}"
                }
            }
        },
        "deployments": {}
    }
    ```
7. 参考`flow transactions send flow-ft/transactions/transfer_tokens.cdc --arg UFix64:0.001 --arg Address:"0xcd321b69db46775d" -n mainnet --signer mainnet-account`进行转账。（除了用cli，当然也可以用fcl去构造transaction进行转账。）
   `flow-ft/transactions/transfer_tokens.cdc`内容是
   ```
    // This transaction is a template for a transaction that
    // could be used by anyone to send tokens to another account
    // that has been set up to receive tokens.
    //
    // The withdraw amount and the account from getAccount
    // would be the parameters to the transaction

    import FungibleToken from 0xf233dcee88fe0abe
    import FlowToken from 0x1654653399040a61

    transaction(amount: UFix64, to: Address) {

        // The Vault resource that holds the tokens that are being transferred
        let sentVault: @FungibleToken.Vault

        prepare(signer: AuthAccount) {

            // Get a reference to the signer's stored vault
            let vaultRef = signer.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
                ?? panic("Could not borrow reference to the owner's Vault!")

            // Withdraw tokens from the signer's stored vault
            self.sentVault <- vaultRef.withdraw(amount: amount)
        }

        execute {

            // Get the recipient's public account object
            let recipient = getAccount(to)

            // Get a reference to the recipient's Receiver
            let receiverRef = recipient.getCapability(/public/flowTokenReceiver)
                .borrow<&{FungibleToken.Receiver}>()
                ?? panic("Could not borrow receiver reference to the recipient's Vault")

            // Deposit the withdrawn tokens in the recipient's receiver
            receiverRef.deposit(from: <-self.sentVault)
        }
    }
   ```

> 成功截图
    ![tx-success](tx-success.png)