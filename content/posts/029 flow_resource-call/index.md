---
title: 'cadence不同角色资源访问'
date: 2021-08-16T22:00:00+08:00
lastmod: 2021-08-19T1640:00+08:00
draft: false
summary: '介绍 flow 合约语言 cadence 中不同角色资源调用的方式'
tags: ['flow']
---

在参加 decentology 的时候，通过它的样例工程，学习到了不同角色资源调用的方式，做一下简单介绍

> 源码 https://dappstarter.decentology.com/ 的 PackNFT

## 四种不同的资源方法访问设计

### admin 资源的私有方法，admin 自己调用的，比如 mintPacks

这种情况很常见，比如 mint 或者修改合约参数的方法，都需要定义在 admin 资源中并只有合约账户能调用

1. 在 AdminContract 合约中，mintPacks 需定义在 `resource Admin {}` 里面
2. 在 init 函数中去初始化 admin 资源存入账户，以及初始化 Pack 的 collection 并 link 出去
3. 在 transaction 中，直接去 storage 中 borrow，获取 adminRef 后调用 mintPacks 函数。因为 AdminContract 部署时只在合约账户中初始化资源，其他用户使用这个 transaction 会报错，这样保证只有合约账户能使用

### admin 资源的共有方法，由用户调用的，比如 Marketplace 的 purchase

这种情况也很很常见，如果是一些读取不涉及资源操作的函数，可以直接在合约最外层定义函数。如果涉及资源操作，最好是把相同权限的函数定义在接口里，资源去实现接口。初始化资源时 link 到账户和 public 路径。用户发 transaction，去 public 路径去 borrow 接口资源的引用，然后使用。

1.  定义资源接口 SalePublic，并在资源 SaleCollection 中实现 SalePublic 接口。注意 SaleCollection 需要有 ownerVault 和 ownerCollection 两个权限访问字段，用于后续的 purchase 逻辑。接口是 cadence 中常见分离函数权限的手段，在 transaction 中用中括号来引用接口类型，类似`<&SaleCollection{SalePublic}>`
2.  在 SaleCollection 中编写 purchase 的逻辑，类似资源的转账，从一个账户 withdraw 再 desposit 到另一个账户。通过传入@FungibleToken.Vault 并验证数量和类型，来保证函数需要传入资源才能调用
3.  在初始化 marketplace 的 transaction 中，直接调用 marketContract 的 createSaleCollection 来建立资源存入 storage 中再 link 出去

    > provision_marketplace.cdc

        // create a new empty collection
        let packSaleCollection <- MarketplaceContract.createSaleCollection(ownerVault: ownerVault, ownerCollection: ownerPackCollection)

        // save it to the account
        acct.save(<-packSaleCollection, to: /storage/packSaleCollection)

        // create a public capability for the collection
        acct.link<&MarketplaceContract.SaleCollection{MarketplaceContract.SalePublic}>(/public/packSaleCollection, target: /storage/packSaleCollection)

    > MarketplaceContract.cdc

        // createCollection returns a new SaleCollection resource to the caller
        //
        pub fun createSaleCollection(ownerVault: Capability<&AnyResource{FungibleToken.Receiver}>, ownerCollection: Capability<&NonFungibleToken.Collection>): @SaleCollection {
            return <- create SaleCollection(_vault: ownerVault, _collection: ownerCollection)
        }

### 用户资源的方法，但需要 admin 来调用（借助 admin 的能力），比如 openPack

这种方法不常见，是 cadence 面向资源编程的特色,是需要重点学习的点。后续可用到各种用户资源操作，比如升级资源等。重点在于 `access(account)`修饰符。

1.  在 admin 合约的资源中定义 openPack 方法，参数引用 pack 和 nft 合约的接口

        pub fun openPack(id: UInt64, packCollectionRef: &PackContract.Collection{PackContract.IPackCollectionAdminAccessible}, nftCollectionRef: &{NonFungibleToken.CollectionPublic}) {
            packCollectionRef.openPack(id: id, nftCollectionRef: nftCollectionRef)
        }

2.  在 pack 合约中定义接口，注意设置 access(account)

        pub resource interface IPackCollectionAdminAccessible {
          access(account) fun openPack(id: UInt64, nftCollectionRef: &{NonFungibleToken.CollectionPublic})
        }

3.  在 resource collction 中实现 2 中的接口

        access(account) fun openPack(id: UInt64, nftCollectionRef: &{NonFungibleToken.CollectionPublic}) {
            let packRef = self.borrowPack(id: id)
                ?? panic("Could not borrow a reference to a Pack with this id")
            let numberOfNFTs = PackContract.packTypes[packRef.packType]!.numberOfNFTs

            let pack <- self.withdraw(withdrawID: id)

            var i: UInt64 = 0
            // Mints new NFTs into this empty Collection
            while i < numberOfNFTs {
                let newNFT <- NFTContract.mintNFT()

                nftCollectionRef.deposit(token: <-newNFT)

                i = i + (1 as UInt64)
            }

            destroy pack
        }

4.  调用 NFT 合约的 mintNFT，该方法限制了访问范围只有部署了 NFT 合约的 admin 账户可以访问

        pub contract NFTContract: NonFungibleToken {
          // ignore some code here
          access(account) fun mintNFT(): @NFT {
                return <- create NFT()
            }
          // ignore some code here
        }

### 用户账户的公有方法，如 NFT 中的 desposit 等

这种方法常见于标准资源的交换，用于用户资源的操作，比如转账，接收等。和 admin 调用 admin 私有资源类似，多一步 link

1. 定义在一个资源内，并定义和实现接口
2. 在用户可以调用的、初始化账户的 transaction 里，先创建资源，再保存，并 link 到 public
3. 其他 transaction 中，去 getCapability 和 borrow 后，再调用

## 总结

packNFT 的 demo 很好展示了 Flow 合约开发时，资源在 user 或 admin 不同角色中调用时，应该如何设计。

1. admin 资源的私有方法，比如 mint，不能被滥用，直接存在 admin storage 里
2. admin 合约资源的公开方法（非只读），定义在有 public 接口的资源里，让用户去初始化资源后使用。
3. user 的方法需要 admin 调用的，用 access(account) 限制好，且定义好接口，link 出去让 admin 调用
4. user 资源的公开方法，使用 pub 权限 link 出去即可
