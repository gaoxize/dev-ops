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

#### 节点负载均衡

