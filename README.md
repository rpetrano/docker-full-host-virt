docker-full-host-virt
=====================

Since Docker design is based on a "single service per container" philosophy, it can get quite frustrating to use Docker if you want to replace your hypervisor's insane memory, disk and cpu requirements with lightweightness of Docker.

This repo provides Docker and host configuration that makes it easier to run Docker containers in a similar fashion to full host virtualization solutions like VirtualBox, xen or kvm.

This is intended for sysadmins, as it's takes effort to set up but makes it easy to use afterwards.

Make sure to checkout a branch for a distribution specific files.

Installation
============

First of all, you'll need to install [pipework](https://github.com/jpetazzo/pipework).

Next you need to configure your DNS server. There is an example [bind config](etc/named.conf), and two important zone definition examples: [local.zone](var/named/local.zone), [172.31.0.zone](var/named/172.31.0.zone). The PTR records are optional in fact, but nice to have. The zone files are basically Docker container definitions, so edit them based on what containers you want to run. I use `172.31.0.0/24` network and `\*.local` root domain in examples.

Make sure you [use your local DNS server](etc/resolv.conf).

Make sure [DHCP doesn't overwrite your DNS settings](etc/dhcpcd.conf).

You should create a new bridge interface. There is an example config for [Arch Linux](etc/netctl/docker-bridge). Make sure you assign static IP address to it as configured in zone definition files, or just use mine (172.31.0.1/24). Pipework can create it for you, but you'll have to assign it an IP anyways.

Make sure your kernel allows [IP forwarding](etc/sysctl.d/99-sysctl.conf).

Apply [iptables rules](etc/iptables/iptables.rules).

Edit [run.sh](run.sh). Specify containers you want to run by changing variable `NAMES`, and image they'll be created from by changing variable `IMAGE`.

Build the [ubuntu-ssh image](Dockerfile). It's ubuntu with ssh! Before you can build the image, you need to create a new ssh keypair (id_docker) and use it in your [ssh config](home/.ssh/config).


Usage
=====

Run `run.sh` as root.

Creates a new container from base image, runs it and boots it; or "continues" the stopped container if it already exists.


How it works
============

Every time Docker runs an image, it creates a new randomly named container. That's why it's said running an image is "not persistent", since every time a new container, a copy of image, is made. In fact containers are unique, persistent and can be manually "continued" when stopped.

The [run.sh](run.sh) script creates unique names for each container defined. It uses bridged adapter (default: br0) and paired veths for each container to create a virtual network between containers and host. Each paired device is configured with default route to bridge interface on host, and host is given iptables SNAT rule to allow guests to see the world. When container starts, Upstart (`/sbin/init`) is executed and told to run all services it's configured to run on runlevel 3.

The IP addresses given to host's bridge and guests veths are determined based on container's name. That's where DNS server kicks in. Since the container's hostname is set to container's name, a simple DNS A query with container's name will resolve container's IP address. The DNS server also makes possible for containers to "see each other's names".


TODO
====

 * Enable running a new container whose name is not in the zone files. Create a DDNS service for it: fetch its IP via local DHCP server, and register to it to the DNS server.

 * Make installation easier?

 * Moar config!!!

 * Optionally enable the world to see containers (DNAT).

