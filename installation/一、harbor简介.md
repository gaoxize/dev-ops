



[TOC]



#### 一、harbor简介

~~~
Harbor 是一个用于存储和分发Docker镜像的企业级Registry服务器，通过添加一些企业必需的功能特性。包括权限管理(RBAC)、LDAP、审计、安全漏洞扫描，管理界面、自我注册等。
~~~

#### 二、 环境

| IP地址        | 域名                      | 应用   |
| ------------- | ------------------------- | ------ |
| 192.168.5.134 | harbor.docker.easy.com.cn | harbor |



~~~
OS: Centos Linux release 7.5 (Core)
mem: 1GB
~~~

**软件要求**

| 软件           | 版本    | 描述 |
| -------------- | ------- | ---- |
| Docker         | 20.21.6 |      |
| Docker Compuse |         |      |
| Openssl        |         |      |

**网络端口**

| 端口 | 协议  | 描述                                                         |
| ---- | ----- | ------------------------------------------------------------ |
| 443  | HTTPS | harbor门户和核心API将接受此端口的https协议请求               |
| 4443 | HTTPS | 只有在连接到Docker的docker Content Trust服务启用认证时才需要 |
| 80   | HTTP  | harbor端口和核心API将接受此端口的http协议请求                |

#### 	安装

1. 下载docker repo源

> wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -P /etc/yum.repos.d

2. 安装依赖环境

> yum install -y yum-utils device-mapper-persistent-data lvm2

~~~
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * epel: mirrors.ustc.edu.cn
 * extras: mirrors.bfsu.edu.cn
 * updates: mirrors.bfsu.edu.cn
Resolving Dependencies
--> Running transaction check
---> Package device-mapper-persistent-data.x86_64 0:0.8.5-3.el7 will be updated
---> Package device-mapper-persistent-data.x86_64 0:0.8.5-3.el7_9.2 will be an update
---> Package lvm2.x86_64 7:2.02.187-6.el7 will be updated
---> Package lvm2.x86_64 7:2.02.187-6.el7_9.5 will be an update
--> Processing Dependency: lvm2-libs = 7:2.02.187-6.el7_9.5 for package: 7:lvm2-2.02.187-6.el7_9.5.x86_64
---> Package yum-utils.noarch 0:1.1.31-54.el7_8 will be installed
--> Processing Dependency: python-kitchen for package: yum-utils-1.1.31-54.el7_8.noarch
--> Processing Dependency: libxml2-python for package: yum-utils-1.1.31-54.el7_8.noarch
--> Running transaction check
---> Package libxml2-python.x86_64 0:2.9.1-6.el7.5 will be installed
---> Package lvm2-libs.x86_64 7:2.02.187-6.el7 will be updated
---> Package lvm2-libs.x86_64 7:2.02.187-6.el7_9.5 will be an update
--> Processing Dependency: device-mapper-event = 7:1.02.170-6.el7_9.5 for package: 7:lvm2-libs-2.02.187-6.el7_9.5.x86_64
---> Package python-kitchen.noarch 0:1.1.1-5.el7 will be installed
--> Processing Dependency: python-chardet for package: python-kitchen-1.1.1-5.el7.noarch
--> Running transaction check
---> Package device-mapper-event.x86_64 7:1.02.170-6.el7 will be updated
---> Package device-mapper-event.x86_64 7:1.02.170-6.el7_9.5 will be an update
--> Processing Dependency: device-mapper-event-libs = 7:1.02.170-6.el7_9.5 for package: 7:device-mapper-event-1.02.170-6.el7_9.5.x86_64
--> Processing Dependency: device-mapper = 7:1.02.170-6.el7_9.5 for package: 7:device-mapper-event-1.02.170-6.el7_9.5.x86_64
---> Package python-chardet.noarch 0:2.2.1-3.el7 will be installed
--> Running transaction check
---> Package device-mapper.x86_64 7:1.02.170-6.el7 will be updated
--> Processing Dependency: device-mapper = 7:1.02.170-6.el7 for package: 7:device-mapper-libs-1.02.170-6.el7.x86_64
---> Package device-mapper.x86_64 7:1.02.170-6.el7_9.5 will be an update
---> Package device-mapper-event-libs.x86_64 7:1.02.170-6.el7 will be updated
---> Package device-mapper-event-libs.x86_64 7:1.02.170-6.el7_9.5 will be an update
--> Running transaction check
---> Package device-mapper-libs.x86_64 7:1.02.170-6.el7 will be updated
---> Package device-mapper-libs.x86_64 7:1.02.170-6.el7_9.5 will be an update
--> Finished Dependency Resolution

Dependencies Resolved
~~~



3. 安装docker

> yum install docker-ce -y

4. 修改docker国内源

~~~
{
  "registry-mirrors": [
    "https://registry.docker-cn.com",
    "http://hub-mirror.c.163.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
~~~

5. 安装docker-compose

   > yum install docker-compose

   

#### 安装registry

> docker pull registry

~~~
Using default tag: latest
latest: Pulling from library/registry
ddad3d7c1e96: Pull complete 
6eda6749503f: Pull complete 
363ab70c2143: Pull complete 
5b94580856e6: Pull complete 
12008541203a: Pull complete 
Digest: sha256:bac2d7050dc4826516650267fe7dc6627e9e11ad653daca0641437abdf18df27
Status:  newer image for registry:latest
docker.io/library/registry:latest
~~~

**创建docker registry**

> docker run -d --name docker-registry -p 5000:5000 registry



测试

下载nginx 镜像  

> docker pull nginx

创建dockerfile文件

~~~
[root@harbor sndsj]# ls
bigData.tar.gz  Dockerfile  nginx.conf  plantform.tar.gz  plant.tar.gz
~~~

vi Dockerfile的内容

~~~
FROM nginx --基础包
COPY nginx.conf /etc/nginx/  --拷贝文件
COPY bigData.tar.gz /var/www/html/
COPY plant.tar.gz /var/www/html/
COPY plantform.tar.gz /var/www/html/
RUN tar -xvzf /var/www/html/bigData.tar.gz -C /var/www/html/ --执行命令
RUN tar -xvzf /var/www/html/plant.tar.gz -C  /var/www/html/
RUN tar -xvzf /var/www/html/plantform.tar.gz -C /var/www/html/
~~~

通过Dockerfile创建镜像

>docker  build -t nginx-sndsj .

~~~
[root@harbor sndsj]# docker build -t nginx-sndsj .
Sending build context to Docker daemon  16.96MB
Step 1/8 : FROM nginx
 ---> d1a364dc548d
Step 2/8 : COPY nginx.conf /etc/nginx/
 ---> 6e16953934b1
Step 3/8 : COPY bigData.tar.gz /var/www/html/
 ---> 6e7f95ad9e04
Step 4/8 : COPY plant.tar.gz /var/www/html/
 ---> 5fcc92b645db
Step 5/8 : COPY plantform.tar.gz /var/www/html/
 ---> 636c86725659
Step 6/8 : RUN tar -xvzf /var/www/html/bigData.tar.gz -C /var/www/html/
 ---> Running in da9c1f719ca5
bigData/
bigData/index.html
bigData/static/
bigData/static/css/
bigData/static/css/app.ff62e2afd529264792ccb8f8a0c01a61.css
bigData/static/css/app.ff62e2afd529264792ccb8f8a0c01a61.css.map
bigData/static/font/
bigData/static/font/fonts/
bigData/static/font/fonts/icomoon.eot
bigData/static/font/fonts/icomoon.svg
bigData/static/font/fonts/icomoon.ttf
bigData/static/font/fonts/icomoon.woff
bigData/static/font/style.css
bigData/static/fonts/
bigData/static/fonts/element-icons.535877f.woff
bigData/static/fonts/element-icons.732389d.ttf
bigData/static/fonts/icomoon.4d4aa75.ttf
bigData/static/fonts/icomoon.6dcb6b2.woff
bigData/static/fonts/icomoon.a1ec91d.eot
bigData/static/images/
bigData/static/images/1.png
bigData/static/images/2.png
bigData/static/images/3.png
bigData/static/images/a.png
bigData/static/images/arrow.5bca1a1.png
bigData/static/images/arrow.png
bigData/static/images/b.png
bigData/static/images/bg.44fcb33.jpg
bigData/static/images/bg.jpg
bigData/static/images/c.png
bigData/static/images/d.png
bigData/static/images/e.png
bigData/static/images/f.png
bigData/static/images/g.png
bigData/static/images/h.png
bigData/static/images/i.png
bigData/static/images/icomoon.0590590.svg
bigData/static/images/icomoon.abe24d3.svg
bigData/static/images/j.png
bigData/static/images/k.png
bigData/static/images/kselected.fa06d32.png
bigData/static/images/kselected.png
bigData/static/images/kuang.a5eb8b7.png
bigData/static/images/kuang.png
bigData/static/images/l.png
bigData/static/images/logo1.png
bigData/static/images/re.png
bigData/static/images/ss.1cc7a28.png
bigData/static/images/ss.png
bigData/static/images/ti.20d415a.jpg
bigData/static/images/ti.jpg
bigData/static/js/
bigData/static/js/app.624508f248cfeada1c19.js
bigData/static/js/app.624508f248cfeada1c19.js.map
bigData/static/js/manifest.3ad1d5771e9b13dbdad2.js
bigData/static/js/manifest.3ad1d5771e9b13dbdad2.js.map
bigData/static/js/vendor.7efb2adccaaa44417b00.js
bigData/static/js/vendor.7efb2adccaaa44417b00.js.map
bigData/static/media/
bigData/static/media/video11.535fb55.mp4
bigData/static/services/
bigData/static/services/a.js
bigData/static/services/b.js
bigData/static/services/c.js
bigData/static/services/d.js
bigData/static/services/data.json
bigData/static/services/duty.js
bigData/static/services/e.js
bigData/static/services/f.js
bigData/static/services/g.js
bigData/static/services/operating.js
bigData/static/video/
bigData/static/video/video11.mp4
Removing intermediate container da9c1f719ca5
 ---> 00e7342ab282
Step 7/8 : RUN tar -xvzf /var/www/html/plant.tar.gz -C  /var/www/html/
 ---> Running in 98de36711a55
plant/
plant/index.html
plant/static/
plant/static/css/
plant/static/css/app.34777534c2ed0c78fcdb477de0b2abfe.css
plant/static/css/app.34777534c2ed0c78fcdb477de0b2abfe.css.map
plant/static/fonts/
plant/static/fonts/ionicons.143146f.woff2
plant/static/fonts/ionicons.99ac330.woff
plant/static/fonts/ionicons.d535a25.ttf
plant/static/img/
plant/static/img/banner.a053fa1.png
plant/static/img/bg.f250eac.png
plant/static/img/bg2.0b5ce84.png
plant/static/img/center1.046d88e.png
plant/static/img/center2.c81fe90.png
plant/static/img/center4.47302ce.png
plant/static/img/homePage1.e09b33c.png
plant/static/img/homePage2.8607a14.png
plant/static/img/homePage3.7675128.png
plant/static/img/homePage4.80750a9.png
plant/static/img/ionicons.a2c4a26.svg
plant/static/img/logo2.6cd9db1.png
plant/static/img/page.2fbcbbd.jpg
plant/static/img/pageText.c8e2142.png
plant/static/img/qrCode.4cd20ec.png
plant/static/img/solution1.da0bf6e.png
plant/static/img/solution2.1115067.png
plant/static/img/solution3.d41bc68.png
plant/static/img/solution4.51023d4.png
plant/static/js/
plant/static/js/app.4043a5524c45219123de.js
plant/static/js/app.4043a5524c45219123de.js.map
plant/static/js/manifest.c671b31a6294c60d458b.js
plant/static/js/manifest.c671b31a6294c60d458b.js.map
Removing intermediate container 98de36711a55
 ---> b3dcbb49a526
Step 8/8 : RUN tar -xvzf /var/www/html/plantform.tar.gz -C /var/www/html/
 ---> Running in ea9cf90bf428
plantform/
plantform/index.html
plantform/static/
plantform/static/css/
plantform/static/css/app.0c2e425b8ac628ca7ca3e114e3b1db76.css
plantform/static/css/app.0c2e425b8ac628ca7ca3e114e3b1db76.css.map
plantform/static/fonts/
plantform/static/fonts/display_free_tfb.f07da7a.ttf
plantform/static/fonts/element-icons.535877f.woff
plantform/static/fonts/element-icons.732389d.ttf
plantform/static/img/
plantform/static/img/background.e826c15.png
plantform/static/img/header.a76930f.png
plantform/static/img/title.8480bbc.png
plantform/static/js/
plantform/static/js/app.386ff2857f7e4e0628f3.js
plantform/static/js/app.386ff2857f7e4e0628f3.js.map
plantform/static/js/manifest.3ad1d5771e9b13dbdad2.js
plantform/static/js/manifest.3ad1d5771e9b13dbdad2.js.map
plantform/static/js/vendor.4e90262789c037c6b9bd.js
plantform/static/js/vendor.4e90262789c037c6b9bd.js.map
Removing intermediate container ea9cf90bf428
 ---> 3c2eca51263d
Successfully built 3c2eca51263d
Successfully tagged nginx-sndsj:latest
~~~

二、通过编译镜像后的镜像生成容器

> docker run -d --name sndsj -v /data -p 8080:80 nginx-sndsj 

~~~
b5c98f62b60033275f7ae264e85d0a1bfdc211fd580de0eeca7b2107b22f8d2b
~~~

三、访问测试

~~~
http:192.168.5.134:8080/bigData
~~~

![](C:\Users\Administrator\AppData\Roaming\Typora\typora-user-images\image-20210601075139321.png)

四、提交打tag

> docker commit -m "nginx for sndsj web app" 37c25f3a3a79 nginx-sndsj

> docker tag nginx-sndsj 192.168.5.134:5000/web/nginx-sndsj

五、推送至registry

> docker push 192.168.5.134:5000/web/nginx-sndsj

~~~
134e19b2fac5: Pushed 
83634f76e732: Pushed 
766fe2c3fc08: Pushed 
02c055ef67f5: Pushed 
latest: digest: sha256:4727bc5eb472e11689ebab8574b7cb35cdffbb60ddc72b93cfff39cc8d6549e1 size: 3251
~~~



三、harbor安装部署

