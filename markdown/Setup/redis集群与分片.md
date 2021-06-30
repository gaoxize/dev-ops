## redis集群与分片

redis，即远程字典服务，是一个开源的使用ANSI <span style="color:blue;">C语言</span>编写、支持网络、可基于内存，亦可持久化的日志、key-value数据库，并提供多种语言的API。

### sharding集群模式



redis集群分为服务器集群(Cluster)和客户端分片（Sharding）

服务器集群: redis3.0以上版本实现，使用哈希槽，计算key的CRC16结果再摸16834.

**sharding存在的问题**

- 单点故障： 当集群中的某一台服务挂掉后，客户端在根据一致性hash无法从这台服务器获取数据，对于单点故障问题，我们可以使用redis的HA高可用来实现。利用redis-sentinal来通知追的切换。
- 扩容问题： 使用一致性hash进行分片，那么不同的key分配不同的redis-server上。当我们需要扩容时，需要增加机器到分片列表中，这时候会使得同样的key算出来落到与原来不同的机器上。这样如果要取某一个值，会出现取不到的秦光，之前的缓存相当与全部失效。对于扩容的问题，Redis的作者提出了一种名为pre-sharding的方式。即实现部署足够多的redis服务。

**一致性hash算法**

- 环形hash空间,早在1997年就在论文《Consistent hashing and random trees》提出
- 虚拟节点:（解决hash倾斜性，多些虚拟节点）
- 命中率计算公式：(1-n/(n+m)*100% （n：服务器数，m：新增的服务器数）

****

![一致性算法](https://images2018.cnblogs.com/blog/1414161/201806/1414161-20180607200552221-22411673.png)





主从复制（Master-Slave Replication）

实现主从复制(Master-Slave Replication)的工作原理：

1. slave从节点服务启动并连接到master之后，将主动发送一个SYNC命令。

2. master服务主节点收到同步命令后，将开启后台磁盘进程。同时手机所有接受到的用于修改数据集的命令。
3. 在后台进程执行完毕后，Master将传送整个数据库文件到slave，完成一次同步。
4. slave从节点服务在接受到数据库文件数据之后将其存盘并加载到内存中

5. Master主节点继续将所有已经收集到的修改命令，和新的修改命令依次传送给Slaves。
6. Slave将在本次执行这些数据修改命令，从而达到最终的数据同步。

### Cluster集群模式

redis cluster是一个高性能高可用的分布式系统。有多个redis实例组成的整体，数据按照Slot存储分布在多个redis实例上，通过Gossip协议来进行节点通信。

**集群通信**

![cluster meet](http://img.mp.itc.cn/upload/20160810/584f4e78b54e4116b7d175888fe951a4_th.jpg)

需要组建一个真正的可工作的集群，我们必须将各个独立的节点连接起来，构成一个包含多个节点的集群。

Redis Cluster要求至少需要3个master才能组成一个集群，同时每个master至少需要有一个slave节点。

![redis cluster](https://img-blog.csdnimg.cn/img_convert/9ac253408033862ae21982f627c5daa3.png)

slave节点只是充当了一个数据备份的角色，当master发生了宕机，就会将对应的slave节点提拔为master，来重新对外提供服务。

#### 环境部署

以cluster方式搭建redis集群，环境如下

| ip             | port             |
| -------------- | ---------------- |
| 192.168.41.128 | 7000、7001、7002 |
| 192.168.41.129 | 7000、7001、7002 |

在官网下载redis-5.0.12资源包，并解压到/usr/local/src目录下

> tar -xvzf redis-5.0.12.tgz  -C /usr/local/src/

然后进行编译

> make

创建redis的目录

> mkidr /usr/local/redis-5.0.12
>
> mkdir /usr/local/redis-5.0.12/etc
>
> mkdir /usr/local/redis-5.0.12/data
>
> mkdir /usr/local/redis-5.0.12/sbin

创建软连接

> ln -s /usr.local/redis-5.0.12 /usr/local/redis

修改profile

> vi /etc/profile

~~~
export REDIS=/usr/local/redis/
export PATH=$REDIS/sbin:$PATH
~~~

修改redis的配置文件

```
bind 127.0.0.1 192.168.41.129  #bind 绑定ip
protected-mode yes
port 7000  redis 端口
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes  守护进程 
supervised no
pidfile /var/run/nodes_7000.pid  pid文件
loglevel notice
logfile ""
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
masterauth xiaole610
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
replica-priority 100
requirepass xiaole610 密码
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
appendonly yes 追加
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
lua-time-limit 5000
cluster-enabled yes 集群
cluster-config-file nodes-7000.conf 集群配置
cluster-node-timeout 15000
slowlog-log-slower-than 10000
slowlog-max-len 129
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 129
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
```

然后将文件复制两份，分别为 redis-02.conf与redis-03.conf

> cp  redis-01.conf redis-02.conf

> cp redis-01.conf redis-03.conf

修改port端口 与bind的ip地址 以及pidfile 的文件名。

然后，将redis-5.0.12 文件拷贝192.168.41.129中。

> scp -r /usr/local/redis-5.0.12 /usr/local/



修改redis-01.conf redis-02.conf redis-03.conf的bind的ip地址

创建reids-cluster集群环境

> redis-cli --cluster create 192.168.41.128:7000 192.168.41.128:7001 192.168.41.128:7002 192.168.41.129:7000 192.168.41.129:7001 192.168.41.129:7002 --cluster-replicas 1 -a xiaole610

```
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.41.129:7002 to 192.168.41.128:7000
Adding replica 192.168.41.128:7002 to 192.168.41.129:7000
Adding replica 192.168.41.129:7001 to 192.168.41.128:7001
M: 182756db6347faefec5709cbe1746e5de4f2b5a7 192.168.41.128:7000
   slots:[0-5460] (5461 slots) master
M: 0ab351793fad9d4783b2e7077c92351a18ab7c09 192.168.41.128:7001
   slots:[10923-16383] (5461 slots) master
S: 1a7df325e9757c3d8da01d349f2d0e5f26239472 192.168.41.128:7002
   replicates 57491cece65d12aafcb52eecc42118f08497219f
M: 57491cece65d12aafcb52eecc42118f08497219f 192.168.41.129:7000
   slots:[5461-10922] (5462 slots) master
S: b9d7330ae54c5921cf39f6fe718bfab9dd062631 192.168.41.129:7001
   replicates 0ab351793fad9d4783b2e7077c92351a18ab7c09
S: b2f22ffec4ce35b82a128a16a85c6e6723fe3625 192.168.41.129:7002
   replicates 182756db6347faefec5709cbe1746e5de4f2b5a7
Can I set the above configuration? (type 'yes' to accept): yes
```

