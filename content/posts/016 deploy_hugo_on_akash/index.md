---
title: "akash decloud 上部署 hugo 博客教程"
date: 2020-12-11T18:00:00+08:00
lastmod: 2020-12-11T24:00:00+08:00
draft: false
summary: "多阶段打包部署hugo博客并更新"
tags: ["Akash"]
---

# akash decloud 上部署 hugo 博客教程

Hugo 是一款开源的由 go 语言开发的静态网站生成器，很适合个人博客使用。优势是 build速度和运行速度很快，适合容器化运行。[本博客](https://github.com/script-money/blog)网站就是基于 Hugo 所建。

## 快速入门

网站上的教程很多，可以参考[官方入门](https://gohugo.io/getting-started/quick-start/) 或者 [如何用hugo 搭建博客](https://zhuanlan.zhihu.com/p/126298572)。

搭建完成后，本地输入 `hugo server -D`，出现以下提示，打开 `localhost:1313` 能看到内容说明成功了。

```
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at //localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

## 打包镜像

遵从多阶段构建和最小化基础镜像运行的原则，不采用上一篇指导 [Akash DeCloud部署Uniswap]({{< ref "/posts/009 akash_deploy_uniswap/index.md" >}} "Akash DeCloud部署Uniswap") 中打包静态文件放入Nginx运行的方式，而是用Go镜像作为构建，把可执行的二进制程序和文章内容直接拷贝进 alpine 镜像中运行。

以下是Dockerfile文件。
```
# Dockerfile for Hugo (HUGO=hugo) / Hugo Extended (HUGO=hugo_extended)
# HUGO_VERSION / HUGO_SHA / HUGO_EXTENDED_SHA is automatically updated
# by update.py when new release is available on the upstream.
# Utilize multi-stage builds to make images optimized in size.

# First stage - download prebuilt hugo binary from the GitHub release.
# Use golang image to run https://github.com/yaegashi/muslstack
# on hugo executable to extend its default thread stack size to 8MB
# to work around segmentation fault issues.
FROM golang:1.13-alpine
ARG HUGO=hugo
ARG HUGO_VERSION=0.78.2
ARG HUGO_SHA=6c139580bf42dd66615f61cb33d62fc47cb855790d744050d78924bf1f48df0d
ARG HUGO_EXTENDED_SHA=26410c5ddf2124d6d99b3d0ee00dcae1e16c1a3ccb9feae025d76c0f3c04745e
RUN set -eux && \
    case ${HUGO} in \
      *_extended) \
        HUGO_SHA="${HUGO_EXTENDED_SHA}" ;; \
    esac && \
    apk add --update --no-cache ca-certificates openssl git && \
    wget -O ${HUGO_VERSION}.tar.gz https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO}_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    echo "${HUGO_SHA}  ${HUGO_VERSION}.tar.gz" | sha256sum -c && \
    tar xf ${HUGO_VERSION}.tar.gz && mv hugo* /usr/bin/hugo
RUN go get github.com/yaegashi/muslstack
RUN muslstack -s 0x800000 /usr/bin/hugo

# Second stage - build the final image with minimal apk dependencies.
# alpine:edge is required for muslstack to work as of June 2019.
FROM alpine:edge
ARG HUGO=hugo
COPY --from=0 /usr/bin/hugo /usr/bin
RUN set -eux && \
    case ${HUGO} in \
      *_extended) \
        apk add --update --no-cache libc6-compat libstdc++ && \
        rm -rf /var/cache/apk/* ;; \
    esac && \
    hugo version
EXPOSE 1313
WORKDIR /src
COPY . .
CMD hugo --renderToDisk=true --watch=true --bind="0.0.0.0" server /src

```

整个文件来源于 [hugo的gitlab页面](https://gitlab.com/pages/hugo/-/blob/0.78.2/Dockerfile)，除了最后两行根据自己的需求进行了修改。

`COPY . .`是把本地的文章和主题拷贝进容器，但要排除 public/ 中打包后的静态文件，所以需要新建一个 `.dockerignore`内容如下，就不会拷贝进容器中
```
public/
.DS_Store
Dockerfile
deploy.yaml
```

相比用 Nginx 运行的Uniswap，体积减少了2/3。
![](size.png)

然后根据之前的教程，把镜像push到dockerhub，根据更新的日期来打tag。

## 编写 SDL

参考之前的web应用的 SDL 编写。如果需要设置域名，需要添加accept到特定的域名。

```
services:
  web:
    image: scriptmoney/blog:20201211
    expose:
      - port: 1313
        as: 80
        accept:
          - akash.script.money
        to:
          - global: true
```