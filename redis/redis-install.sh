#!/bin/bash
######################################################
### Author:	liush                                  ###   
### Date:	2016-07-05                             ###
### Func:	Install Redis-3.0.5                    ###
### Desc:	The Script will open 1 ports default   ###
### Desc:	Maxmemory 10G default                  ###
######################################################

SoftDir="/redis/soft"
Redis="redis-3.0.5.tar.gz"

UserInput() {
    read -p "请输入Redis的安装目录:[default /usr/local/redis]" RedisPre
    [ "${RedisPre}" == "" ] && RedisPre="/usr/local/redis"
    #read -p "请输入服务器内网IP地址:[default eth0]" IpAddr
    #[ "$IpAddr" == "" ] && IpAddr=`ifconfig eth0|grep "inet addr" |awk -F: '{print $2}'|awk '{print $1}'`
    IpAddr=`ifconfig |grep 192.168.1.255|awk 'NR==1{print $2}'|awk -F: '{print $2}'`
}
RedisInstall() {
    ### Install Redis
    cd ${SoftDir}
    [ ! -f ./${Redis} ] && (echo "There is no ${Redis}.";exit 2)
    tar fx ./${Redis}
    cd `echo ${Redis}|awk -F ".tar" '{print $1}'`
    make || (echo "${Redis} make failed!";exit 2)
    make install && (echo "${Redis} install successed.") || (echo "${Redis} make install failed!!";exit 2)
    mkdir -p ${RedisPre}/{bin,conf,log,data}
    ### Set Redis Config File    
    cp redis.conf ${RedisPre}/conf
    cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server,redis-trib.rb} ${RedisPre}/bin/
    cd ${RedisPre}/conf
    cp redis.conf redis.6379.conf
    sed -i "s/daemonize no/daemonize yes/" redis.6379.conf
    sed -i "s#pidfile /var/run/redis.pid#pidfile ${RedisPre}/log/redis.6379.pid#" redis.6379.conf
    sed -i "s&logfile \"\"&logfile \"${RedisPre}/log/redis.6379.log\"&" redis.6379.conf
    sed -i "s/dbfilename dump.rdb/dbfilename dump.6379.rdb/" redis.6379.conf
    sed -i "s&dir ./&dir ${RedisPre}/data/&" redis.6379.conf
    sed -i "/# bind 127.0.0.1/a\bind 127.0.0.1 ${IpAddr}" redis.6379.conf
    sed -i "s/# maxmemory <bytes>/maxmemory 10737418240/g" redis.6379.conf
    ### Copy And Set Ports
    #cp redis.6379.conf redis.6380.conf
    #sed -i "s/6379/6380/g" redis.6380.conf
    #cp redis.6379.conf redis.6381.conf
    #sed -i "s/6379/6381/g" redis.6381.conf
    #cp redis.6379.conf redis.6382.conf
    #sed -i "s/6379/6382/g" redis.6382.conf
    ### Copy Redis Manage Script
    cp ${SoftDir}/../bin/redis /etc/init.d/ && chmod 755 /etc/init.d/redis
    sed -i "s&RedisPre=\"/usr/local/redis\"&RedisPre=\"${RedisPre}\"&" /etc/init.d/redis
}

UserInput
RedisInstall
