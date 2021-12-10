---
title: 'Flow服务端签名'
date: 2021-11-04T21:20:00+08:00
lastmod: 2021-11-04T22:20:00+08:00
draft: false
summary: '简单说下如何服务端代付手续费'
tags: ['flow']
---

今天在写服务端代付手续费的功能，遇到一些坑，写文章说一下。

Flow 的每笔交易有 Proposer,Payer,Authorizers 三种角色：

Proposer —— 交易发起人
Authorizer —— 授权人
Payer —— 费用支付人

交易发起人和费用支付人只会有一个，授权人可以有多个。

服务端可以实现签名功能，作为费用支付人或授权人，返回签名给用户，以达到特殊的功能。

当作费用支付人时，可以让用户使用免手续费，体验更好；当作授权人时，可以在不暴露管理员私钥的情况下，进行一些需要管理员权限的合约操作。

要实现该功能，官方文档是以下两个链接

> [FCL Transaction Payer Service](ht://github.com/onflow/flow/blob/82ed633caeafd96702baaa93e9ba748662475191/flips/20210824-fcl-tx-payer-service.md)

> [Authorization Function](ht://github.com/onflow/fcl-js/blob/master/packages/fcl/src/wallet-provider-spec/authorization-function.md)

但由于是 js 代码，没有类型，我在写的时候出现不少错误，搞半天才弄清楚。下文以服务端作为 Payer 举例：

首先，前端构造交易时，要实现一个 Authorization Function 填入 payer 中，即下面的 remoteAuthz

```js
const transaction = await mutate({
  cadence,
  args,
  payer: remoteAuthz
});
await tx(transaction).onceSealed();
```

remoteAuthz 是 `(account: Account) => Account`的函数，传入和返回都是一个 Account 对象，结构如下。传入的 account fcl 会自动帮你构造。

```Typescript
export interface Account {
  kind: 'ACCOUNT'
  tempId: string
  addr: Address
  keyId: number
  sequenceNum: number | null
  signature: string | null
  signingFunction: (signable: string) => compositeSignature | null
  resolve: () => Promise<any> | null
  role: {
    proposer: boolean
    authorizer: boolean
    payer: boolean
    param: boolean
  }
}
```

最终的 addr，keyId 需要填写服务端付款的账户的 addr 和 keyId，可以写死，也可以服务端写个 resolve 函数来获取可用的 key。官方的示例是在服务端准备了两个账户，函数可以返回不同的可用账户。写死的话就一个请求获取签名就行，下面示例是二次请求的

服务端的 controller（代码只截取部分，下同）

```Typescript
@Post('/resolve-account')
async resolveAccount(@Body() account: Account): Promise<Account> {
  const resolveaccount = await this.flowService.AccountResolver(account);
  return resolveaccount;
}

@Post('/sign')
async sign(@Body() signable: signable) {
  const compositeSignature = await this.flowService.Sign(signable);
  return compositeSignature;
}
```

前端的请求

```Typescript
async function remoteAuthz(account: Account) {
  const resolvedAccount = await fetch(BASE_URL + '/resolve-account', {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(account)
  }).then(res => res.json())

  return {
    ...resolvedAccount,
    signingFunction: async (signable: any) => {
      return await fetch(BASE_URL + '/sign',
        {
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(signable)
        }).then(r => r.json())
    },
  }
}
```

两个请求组成的 Account 最终成为 remoteAuthz。

第一次请求的 resolvedAccount 需要去读取管理员的 Address 和 keyId，并且生成一个 tempID，重写发送的 Account，返回给前端

服务端的 service

```Typescript
AccountResolver = async (account: Account) => {
  const PayerAddress = this.minterFlowAddress;
  const PayerKeyID = (await this.getFreeKey()).keyId;
  const TempID = `${PayerAddress}-${PayerKeyID}`;
  return {
    ...account,
    tempId: TempID,
    addr: PayerAddress,
    keyId: PayerKeyID,
  };
};
```

返回的样子如下。只有 addr，keyId，tempId 是服务端添加的，其余都是之前前端上传的

```Typescript
{
  addr: "0x8c11b7ccf9449100"
  keyId: "0"
  kind: "ACCOUNT"
  role: {proposer: false, authorizer: false, payer: true, param: false}
  sequenceNum: null
  signature: null
  signingFunction: null
  tempId: "0x8c11b7ccf9449100-0"
}
```

接下来再添上 signingFunction 即可。前端请求如下

```Typescript
 signingFunction: async (signable: any) => {
      return await fetch(BASE_URL + '/sign',
        {
          method: "POST",
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(signable)
        }).then(r => r.json())
    },
```

服务端的 service。signable 是个很复杂的对象，服务端需要对其签名。用内置的 `fcl.WalletUtils.encodeMessageFromSignable` 去签名

```Typescript
  Sign = async (signable: signable) => {
    const encodedMessage = fcl.WalletUtils.encodeMessageFromSignable(
      signable,
      this.minterFlowAddress,
    );
    const keyToUse = await this.getFreeKey();
    const signature = this.signWithKey(keyToUse.privateKey, encodedMessage);
    return {
      addr: this.minterFlowAddress;,
      keyId: keyToUse.keyId,
      signature,
    };
  };
```

签名后返回一个 compositeSignature，类型如下

```Typescript
{
  addr: Address;
  keyId: number;
  signature: string;
}
```

这样就实现了服务端签名。签 Authorizer 是一个道理。
