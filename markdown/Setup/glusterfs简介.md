### glusterfs简介

GlusterFS是scale-out存储解决方案Gluster的核心，它是一个开源的分布式文件系统，具有强大的横向扩展能力，通过扩展能够支持数PB存储容量和处理数千客户端。GluterFS借助TCP/IP IniniBandRDMA网络将物理分布的存储资源聚集在一起，使用单一全局明明空间管理数据。

GlusterFS采用可堆叠的用户空间设计

![design](https://upload-images.jianshu.io/upload_images/6334838-d6d3e27eae1f4239?imageMogr2/auto-orient/strip|imageView2/2/w/640)

#### glusterfs堆栈式结构

GlusterFS是根据fuse提供的结构实现的一个用户态的文件系统，主要包括gluster、glusterd、glusterfs和glusterfsd四大模块组成：



- gluster: 是cli命令行工具，主要功能是解析命令参数，然后把命令发送给glusterd模块执行。
- glusterd: 式一个管理模块，处理gluster发送过来的命令，处理集群管理，存储管理、brick管理、负载均衡、快找管理。集群信息，存储池信息和快找信息等都是以配置文件的形式存放在服务器中，当客户端挂在存储时，glusterfs会把存储池的配置文件发送给客户端。
- glusterfsd: 是服务端模块，存储池中的每个brick都会启动一个glusterfsd进行。因此，模块主要功能是处理客户端的读写请求，从关联的brick所在磁盘中读写数据，然后返回给客户端。
- glusterfs: 是客户端模块，负责通过mount挂载集群中某台服务器的存储池，以目录的形式呈现给用户。当用户从此目录读写数据时，客户端根据从glusterd模块获取的存储池的配置文件信息，通过DHT算法计算文件所在服务器的brick位置，然后通过Infiniband RDMA 或Tcp/Ip 方式把数据发送给brick，等brick处理完，给用户返回结果。存储池的副本、条带、hash、EC等逻辑都在客户端处理。

在使用glusterfs提供的存储服务之前，需要先挂载存储池，向挂载点写数据，会经过fuse内核模块传给客户端，客户端检查存储池的类型，然后计算数据所在服务器 ，最后通过socket或rdma与服务器通信。

![通讯](https://upload-images.jianshu.io/upload_images/6334838-c0f16dedbf731822?imageMogr2/auto-orient/strip|imageView2/2/w/640)

### Glusterfs特点

- **扩展性和高性能**

GlusterFS利用双重特性来提供几TB至数PB的高可用扩展存储方案。Scale-Out架构允许通过简单地增加资源来提高存储容量和性能，磁盘、计算和I/O的资源都可以独立增加，支持10GbE和InfiniBand等高速网络和脸。 Gluster弹性哈希(ElasticHash)对元数据服务器的要求，消除了单点故障和性能瓶颈，真正实现了并行化数据访问。

- **高可用**

GlusterFS可以对文件进行自动复制，如果镜像或多次复制，从而确保数据总是可以访问，甚至是在硬件故障的情况下也能正常访问。自我修复能力能够吧数据恢复到正确状态，而且修复是以增量方式在后台执行，几乎不羁产生性能负载。GlusterFS没有设计自己的私有数据文件格式，而是采用操作系统中主流标准的磁盘文件系统（EXT3、ZFS）来存储文件，因此数据可以使用各种标准工具进行复制和访问。

- **弹性卷管理**

数据存储在逻辑卷中，逻辑卷可以从虚拟化的无力存储池中独立逻辑划分而得到。存储在服务器可以在线进行增加和移除，不会导致应用中断。逻辑卷可以在所有配置服务器中增长和所见，可以在不同服务器迁移进行容量均衡，或增加和移除系统，这些操作可以在线进行。文件系统配置更改也可以试试在线进行比ing应用，从而可以适应工作负载条件变化或在线性能调优。

### 环境搭建

| ip             | hostname                 |
| -------------- | ------------------------ |
| 192.168.41.128 | mysql.master.easy.com.cn |
| 192.168.41.129 | mysql.slave.easy.com.cn  |



glusterfs 软件包下载地址：https://download.gluster.org/pub/gluster/glusterfs/7/7.4/CentOS/el-8/x86_64/

编写glusterfs.conf

```
[myglusterfs]
name=glusterfs
baseurl=https://buildlogs.centos.org/centos/7/storage/x86_64/gluster-5/
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mysql
```

gluster yum 源

> yum install centos-release-gluster41-1.0-3.el7.centos.noarch



1. 下载 安装文件

   1. 软件依赖文件

   > yum -y install libibverbs librdmacm xfsprogs nfs-utils rpcbind  libaio liblvm2app lvm2-devel

   服务器段软件包

   ```
   glusterfs-api-4.1.9-1.el7.x86_64
   glusterfs-server-4.1.9-1.el7.x86_64
   glusterfs-libs-4.1.9-1.el7.x86_64
   glusterfs-4.1.9-1.el7.x86_64
   glusterfs-fuse-4.1.9-1.el7.x86_64
   glusterfs-client-xlators-4.1.9-1.el7.x86_64
   glusterfs-cli-4.1.9-1.el7.x86_64
   ```

   > 
   >
   > ```
   >  yum -y install glusterfs-server
   > ```
   >
   > 

   客户端软件包

   ```
   glusterfs-3.4.6-1.el6.x86_64.rpm
   glusterfs-fuse-3.4.6-1.el6.x86_64.rpm
   glusterfs-libs-3.4.6-1.el6.x86_64.rpm
   ```

   > ```
   > yum  install    glusterfs    glusterfs-fuse  glusterfs-libs 
   > ```

   #### gluster  配置信任池

   在128的机器上执行

   > gluster peer probe 192.168.41.129

   ```
   peer probe: success.
   ```

   在129的奇迹上执行

   > gluster peer probe 192.168.41.128

   ```
   peer probe: success.
   ```

   查看信任池的状态

   > [root@mysql glusterfs]# gluster peer status

   ```
   Number of Peers: 1
   
   Hostname: 192.168.41.129
   Uuid: a3cdd010-a01e-423d-8eaa-899fdea764d2
   State: Accepted peer request (Connected)
   ```

   #### 创建分布式卷

   > mkdir /data/ctdb

   >  gluster volume create test-volume-01 192.168.41.128:/data/ctdb/ 192.168.41.129:/data/ctdb/ force

   ```
   volume create: test-volume-01: success: please start the volume to access data
   ```

   查看卷信息

   > gluster volume info

   ```
   Volume Name: test-volume-01
   Type: Distribute
   Volume ID: 5d06c526-7c0d-4a65-a282-194ee44124ca
   Status: Created
   Snapshot Count: 0
   Number of Bricks: 2
   Transport-type: tcp
   Bricks:
   Brick1: 192.168.41.128:/data/ctdb
   Brick2: 192.168.41.129:/data/ctdb
   Options Reconfigured:
   transport.address-family: inet
   nfs.disable: on
   ```

   #### 创建复制卷

   在128上执行命令，将raid目录创建出来

   > mkdir /data/raid1

   在129上执行命令，将目录创建出来

   > mkdir /data/raid1

   > gluster volume create replicated-volume replica 2 transport tcp 192.168.41.128:/data/raid1/ 192.168.41.129:/data/raid1/ force

   ```
   volume create: replicated-volume: success: please start the volume to access data
   ```

   查看创建卷的状态

   > gluster volume info test-volume-01

   ```
   Volume Name: test-volume-01
   Type: Distribute
   Volume ID: 5d06c526-7c0d-4a65-a282-194ee44124ca
   Status: Created
   Snapshot Count: 0
   Number of Bricks: 2
   Transport-type: tcp
   Bricks:
   Brick1: 192.168.41.128:/data/ctdb
   Brick2: 192.168.41.129:/data/ctdb
   Options Reconfigured:
   transport.address-family: inet
   nfs.disable: on
   ```

   我们需要知道，我们创建卷后是无法直接使用，而是在是哟用之前我们必须启动改卷。操作如下：

   查看卷的启动状态

   > gluster volume status

   ```
   Volume replicated-volume is not started
    
   Volume test-volume-01 is not started
   ```

   启动test卷

> gluster volume start test-volume-01

```
volume start: test-volume-01: success
```

  启动raid卷

> luster volume start replicated-volume 

```
volume start: replicated-volume: success
```

查看卷启动情况

> gluster volume status

```
Status of volume: replicated-volume
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick 192.168.41.128:/data/raid1            49153     0          Y       103332
Brick 192.168.41.129:/data/raid1            49153     0          Y       24329
Self-heal Daemon on localhost               N/A       N/A        Y       103377
Self-heal Daemon on 192.168.41.129          N/A       N/A        Y       24375
 
Task Status of Volume replicated-volume
------------------------------------------------------------------------------
There are no active volume tasks
 
Status of volume: test-volume-01
Gluster process                             TCP Port  RDMA Port  Online  Pid
------------------------------------------------------------------------------
Brick 192.168.41.128:/data/ctdb             49152     0          Y       95849
Brick 192.168.41.129:/data/ctdb             49152     0          Y       18273
 
Task Status of Volume test-volume-01
------------------------------------------------------------------------------
There are no active volume tasks
```

#### 目录挂载



创建挂载目录

> mkdir -p /opt/data/r0

>  mkdir /opt/data/db

将分布卷进行挂载

>  mount.glusterfs 192.168.41.129:/test-volume-01 /opt/data/db/

将复制卷进行挂载

>  mount.glusterfs 192.168.41.129:/replicated-volume /opt/data/r1/

查看 挂载点情况

```
[root@mysql opt]# df -h
Filesystem                         Size  Used Avail Use% Mounted on
devtmpfs                           349M     0  349M   0% /dev
tmpfs                              361M     0  361M   0% /dev/shm
tmpfs                              361M  6.2M  355M   2% /run
tmpfs                              361M     0  361M   0% /sys/fs/cgroup
/dev/mapper/centos-root            6.2G  5.7G  547M  92% /
/dev/sda1                         1014M  137M  877M  14% /boot
tmpfs                               73M     0   73M   0% /run/user/0
192.168.41.129:/test-volume-01      13G   12G  1.1G  92% /opt/data/db
192.168.41.129:/replicated-volume  6.2G  5.8G  484M  93% /opt/data/r1
```

