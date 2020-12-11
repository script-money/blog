---
title: "Akash deploy secure application stratgies"
date: 2020-12-10T17:00:00+08:00
lastmod: 2020-12-11T10:45:00+08:00
draft: false
summary: "For Community Content Submission"
tags: ["Akash"]
---

# Akash deploy secure application stratgies

Akash is a decloud compute platform run on blockchain, so the most important secure rule is **Do not lost your private key!**

There are some other security stratgies, including build containers and write SDL file.

## Build Container

### use minimal base images

Some popular images like "From Node"  is actually based on a fully installed Debian distribution, which means that the container image will contain a complete operating system, which has many vulnerabilities in their system libraries. You prefer use them as building container,then copy neccessary file to alpline-base images as running container. 

### use multi-statge builds for small secure images

When using Dockerfile to build application container images, it generates many image layers that are only needed for build time, including development tools and libraries needed for compilation, dependencies, temporary files, confidential information needed to run unit tests, and so on. For minimizing the attack surface for bundled docker image dependencies, you should use multi-statge builds for small and secure image.

### least privileged user

If USER is not specified in the Dockerfile, Docker will run the container as super user root by default, and the namespace to which the container belongs is therefore mapped to root, which means that the container may obtain super administrative privileges of the Docker host. In addition, running the container as root expands the attack surface and can easily cause privilege escalation if there are security vulnerabilities in the container application.In practice, it is generally not necessary for a container to have root privileges. To minimize security threats, create dedicated users and user groups, and use `USER` to specify users in Dockerfile to ensure that container applications are run as the least privileged user.

### don't leak sensitive information to docker image

Sometimes, when you build a container image containing an application, you need to use some sensitive information, such as the SSH private key required to pull code from a private repository, or the token required to secure a private package. If the Dockerfile contains a command to copy sensitive information, when building the image, the intermediate container corresponding to this line of command will be cached, resulting in confidential data being cached as well, potentially causing confidential information leakage. Therefore, sensitive information such as tokens and keys must be stored outside of the Dockerfile. 

Use multi-stage build, `.dockerignore` and ENV parameters to avoid thies issue.

### check, fix and minitor for image vulnerabilities

Specifying the base image of the container also introduces all the possible security risks that the operating system and system libraries contained in that image have. It is best to choose a minimal image that can run the application code properly, which helps reduce the attack surface by limiting the number of possible security vulnerabilities. However, doing so does not provide a security audit of the image and does not protect against new vulnerabilities that may be discovered in the future.

Therefore, one way to protect against security software vulnerabilities is to use a tool like Snyk that continuously scans and monitors Docker images for possible vulnerabilities at all layers.

## Write SDL file

SDL(Stack Definition Language) is akash decloud config file to described deployment services, datacenters, pricing, etc. There are some tips when write SDL files.

### services.expose.as
`services.expose.as` is port number to expose the container port as. 

If it is not set, a random ports will be assigned. Use random ports to avoid services being guessed and attacked by known vulnerabilities.

### services.expose.accept 

`services.expose.accept` is used to list of hosts to accept connections for service. 

You should set CNAME domain to services.expose.accept, that hide the real address of the service center.

### services.expose.to

`services.expose.to` is used to list of entities allowed to connect service.

For services that require user access, such as web or message queue, set "to" to "global: true"

For services that support applications, does not need user connect directly, such as database or logging, set "to" to specific services.

An example from akash source code below:
```
services:
  bind:
    image: bind9
    expose:
      - port: 53
        proto: udp
        to:
          - global: true

  pg:
    image: postgresql
    expose: 
      - port: 5463
        to:
          - service: bind
```

### profiles.placement.signedBy

The signedBy section allows you to state attributes that must be signed by one or more accounts of your choosing. This allows for requiring a third-party certification of any provider that you deploy to. If you don't trust provider, you can set a group of validators in signedBy.

### redundant resources and multiple instances

Use redundant resources to avoid overloading the service in extreme situations may cause unpredictable security issues. 

In `profiles.compute.resources`, you can set more cpu, memory and storage. In `placement.pricing.amount` set more uakt for matching better service providers. And set up more than one deployment to guaranteed availability with multiple deployments in different datacenter.
