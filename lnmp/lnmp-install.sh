#!/bin/bash
#date	2015-11-17
#author	liush
#ver	1
##############################
#variables
num=0
DATE=`date +"%Y-%m-%d %H:%M:%S"`
SYSTEM=`cat /etc/issue |awk 'NR==1{print $1,$2,$3}'`
HOSTNAME=`hostname -s`
USER=`whoami`
IP=`ifconfig eth0 |grep 'inet addr' |awk '{print $2}' |awk -F: '{print $2}'`
DISK_FREE=`df -h |awk 'NR==2{print $4}'`
CPU_AVG=`cat /proc/loadavg |cut -c 1-14`
MEM_FREE=`free -m |awk 'NR==2{print $4}'`
SCRIPT_DIR=`dirname $0`
CURRENT_DIR=`pwd`
FILE_DIR=/usr/local/src/lnmp
SOFT=/usr/local/src/lnmp/soft
PCRE=pcre-8.31.tar.gz
JEMALLOC=jemalloc-4.0.4.tar.bz2
CMAKE=cmake-2.8.8.tar.gz 
LIBMCRYPT=libmcrypt-2.5.8.tar.gz
LIBICONV=libiconv-1.7.tar.gz
MHASH=mhash-0.9.9.9.tar.gz
MCRYPT=mcrypt-2.6.8.tar.gz
MEMCACHE=memcache-3.0.8.tgz
LIBMEMCACHED=libmemcached-1.0.2.tar.gz
MEMCACHED=memcached-2.1.0.tgz
IMAGEMAGICK=ImageMagick-6.9.2-0.tar.gz
IMAGICK=imagick-3.1.1.tgz
PDO_MYSQL=PDO_MYSQL-1.0.2.tgz
#################################################################

#set time
start_time() {
	clear
	start_time="$(date +%s)"
	START_TIME="$(date +'%Y-%m-%d %H:%M:%S')"
	echo "Start at: "${START_TIME} >>/tmp/runtime  
}  
end_time() {  
	end_time="$(date +%s)"
	END_TIME="$(date +'%Y-%m-%d %H:%M:%S')"
	total_s=$(($end_time - $start_time))  
	total_m=$(($total_s / 60))  
	if [ $total_s -lt 60 ]; then  
		time_en="${total_s} Seconds" 
	else  
		time_en="${total_m} Minutes" 
	fi 
	clear
	echo "End in: "${END_TIME} >>/tmp/runtime  
	echo "Total runtime: "${time_en}  
}  

#set Echo_Color
Color_Text() {
  	echo -e " \e[0;$2m$1\e[0m"
}

Red() {
  	echo $(Color_Text "$1" "31")
}

Green() {
  	echo $(Color_Text "$1" "32")
}

Yellow() {
  	echo $(Color_Text "$1" "33")
}

Blue() {
  	echo $(Color_Text "$1" "34")
}
Violet() {
  	echo $(Color_Text "$1" "35")
}

#choose version
choose_nginx_version() {
	Yellow "You have 3 options for your Nginx install."
	echo "1: Install Nginx 1.8.0 (Default)"
	echo "2: Install Nginx 1.9.5"
	echo "3: Install Tengine 2.1.1"
	echo "0: Return"
	read -p "Please enter your choice[0-3]: " Nginx
	case $Nginx in
		1)
		NGINX=nginx-1.8.0.tar.gz
		Blue "You will install $NGINX"
		sleep 2
		;;
		2)
		NGINX=nginx-1.9.5.tar.gz
		Blue "You will install $NGINX"
		sleep 2
		;;
		3)
		NGINX=tengine-2.1.1.tar.gz
		Blue "You will install $NGINX"
		sleep 2
		;;
		0)
		clear
		break
		;;
		*)
		NGINX=nginx-1.8.0.tar.gz
		Blue "You will install $NGINX"
		sleep 2
		;;
	esac	
}

choose_mysql_version() {
	Yellow "You have 2 options for your Mysql install."
	echo "1: Install Mysql 5.5"
	echo "2: Install Mysql 5.6 (Default)"
	echo "0: Return"
	read -p "Please enter your choice[0-2]: " Mysql
	case $Mysql in
		1)
		MYSQL=mysql-5.5.32.tar.gz
		Blue "You will install $MYSQL"
		sleep 2
		;;
		2)
		MYSQL=mysql-5.6.25.tar.gz
		Blue "You will install $MYSQL"
		sleep 2
		;;
		0)
		clear
		break
		;;
		*)
		MYSQL=mysql-5.6.25.tar.gz
		Blue "You will install $MYSQL"
		sleep 2
		;;
	esac	
}

choose_php_version() {
	Yellow "You have 3 options for your Php install."
	echo "1: Install Php 5.4"
	echo "2: Install Php 5.5"
	echo "3: Install Php 5.6 (Default)"
	echo "0: Return"
	read -p "Please enter your choice[0-3]: " Php
	case $Php in
		1)
		PHP=php-5.4.36.tar.gz
		Blue "You will install $PHP"
		sleep 2
		;;
		2)
		PHP=php-5.5.30.tar.gz
		Blue "You will install $PHP"
		sleep 2
		;;
		3)
		PHP=php-5.6.14.tar.gz
		Blue "You will install $PHP"
		sleep 2
		;;
		0)
		clear
		break
		;;
		*)
		PHP=php-5.6.14.tar.gz
		Blue "You will install $PHP"
		sleep 2
		;;
	esac
}			

#check install environment
env_check() {
	[ $UID -ne 0 ] && (echo "Must be root to run this script!";exit 1)
	[ !-d $FILE_DIR ] && mkdir -p $FILE_DIR
	[ !-d $SOFT ] && mkdir -p $SOFT
	[ "$CURRENT_DIR" != "$FILE_DIR" ] &&  cp -r $SCRIPT_DIR/../lnmp/* $FILE_DIR/
	echo "Yum install dependencies.............."
	#yum install -y gcc* openssl-devel zlib-devel pcre-devel ncurses-devel libtool libxml2-devel libpng-devel bzip2-devel curl-devel libjpeg-devel freetype-devel net-snmp-devel openldap openldap-devel
	yum -y install gcc gcc-c++ pcre-devel make gd-devel autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel net-snmp-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel  openldap-clients openldap-servers libxslt-devel libevent-devel ntp libtidy libtidy-devel libtool-ltdl bison libtool vim-enhanced dos2unix
	[ $? -eq 0 ] && echo "yum install dependencies success!" || (echo "yum install dependencies fail!";exit 1)
}

#nginx install
nginx_install() {
	[ ! -f $SOFT/$NGINX ] && (echo "There is no $NGINX";exit 1)
	echo "tar $NGINX>>>>>>>>>>>>>>>>>>>>>"
	cd $SOFT
	tar fx $SOFT/$NGINX
	nginx=`echo $NGINX |awk -F ".tar" '{print $1}'`
	cd $nginx
	./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_realip_module --with-http_dav_module --with-http_flv_module --with-http_addition_module --with-http_sub_module
	if [ $? -eq 0 ];then
		make
		if [ $? -eq 0 ];then
			make install
			if [ $? -eq 0 ];then
				cp $FILE_DIR/nginxd /etc/init.d/nginxd && chmod 755 /etc/init.d/nginxd
				mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
				cp $FILE_DIR/nginx.conf /usr/local/nginx/conf/nginx.conf
				clear
				echo "nginx install success"
			else
				clear
				echo "nginx make_install fail";exit 1
			fi
		else
			clear
			echo "nginx make fail";exit 1
		fi
	else
		clear
		echo "nginx configure fail";exit 1
	fi
}
pcre_install() {
	[ ! -f $SOFT/$PCRE ] && (echo "There is no $PCRE";exit 1)
	cd $SOFT && tar fx $SOFT/$PCRE
	pcre=`echo $PCRE |awk -F ".tar" '{print $1}'`
	cd  $pcre
	./configure --prefix=/usr/local/pcre
	if [ $? -eq 0 ];then
		make && make install 
		if [ $? -eq 0 ];then
			clear
			echo "$PCRE install successed"
		else
			clear
			echo "pcre install failed";exit 1
		fi
	else
		clear
		echo "pcre configure failed";exit 1
	fi
}
jemalloc_install() {
	[ ! -f $SOFT/$JEMALLOC ] && (echo "There is no $JEMALLOC";exit 1)
	cd $SOFT && tar fx $SOFT/$JEMALLOC
	jemalloc=`echo $JEMALLOC |awk -F ".tar" '{print $1}'`
	cd $jemalloc
	./configure --prefix=/usr/local/jemalloc
	if [ $? -eq 0 ];then
		make && make install
		if [ $? -eq 0 ];then
			clear
			echo "jemalloc install successed"
		else
			clear
			echo "jemalloc install failed"exit 1
		fi
	else
		clear
		echo "jemalloc configure failed";exit 1
	fi
}

#tengine install
tengine_install() {
	[ ! -f $SOFT/$NGINX ] && (echo "There is no $NGINX";exit 1)
	echo "tar $NGINX>>>>>>>>>>>>>>>>>>>>>"
	cd $SOFT
	tar fx $SOFT/$NGINX
	nginx=`echo $NGINX |awk -F ".tar" '{print $1}'`
	cd $nginx
	./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_realip_module --with-http_concat_module=shared --with-http_sysguard_module=shared --with-http_limit_conn_module=shared --with-http_limit_req_module=shared --with-http_footer_filter_module=shared --with-http_upstream_ip_hash_module=shared --with-http_upstream_least_conn_module=shared --with-http_upstream_session_sticky_module=shared --with-jemalloc=$SOFT/$jemalloc --with-pcre=$SOFT/$pcre
	if [ $? -eq 0 ];then
		make
		if [ $? -eq 0 ];then
			make install
			if [ $? -eq 0 ];then
				clear
				echo "nginx install success"
			else
				clear
				echo "nginx make_install fail";exit 1
			fi
		else
			clear
			echo "nginx make fail";exit 1
		fi
	else
		clear
		echo "nginx configure fail";exit 1
	fi
}

nginx_set() {
	cp $FILE_DIR/nginxd /etc/init.d/nginxd && chmod 755 /etc/init.d/nginxd
	mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
	cp $FILE_DIR/nginx.conf /usr/local/nginx/conf/nginx.conf
	dos2unix /etc/init.d/nginxd
	dos2unix /usr/local/nginx/conf/nginx.conf
	echo "<?php phpinfo() ?>" >/usr/local/nginx/html/index.php
}
#cmake install
cmake_install() {
	[ ! -f $SOFT/$CMAKE ] && (echo "There is no $CMAKE";exit 1)
	cd $SOFT && tar fx $SOFT/$CMAKE
	cmake=`echo $CMAKE |awk -F ".tar" '{print $1}'`
	cd $cmake
	./bootstrap
	if [ $? -eq 0 ];then
		gmake
		if [ $? -eq 0 ];then
			gmake install
			if [ $? -eq 0 ];then
				clear
				echo "Cmake install success"
			else
				clear
				echo "Cmake gmake_install fail";exit 1
			fi
		else
			clear
			echo "Cmake gmake fail";exit 1
		fi
	else
		clear
		echo "Cmake configure fail";exit 1
	fi
}
#mysql install
mysql_install() {
	[ ! -d /usr/local/mysql/data ] && mkdir -p /usr/local/mysql/data
	[ ! -f $SOFT/$MYSQL ] && (echo "There is no $MYSQL!";exit 1)
	cd $SOFT && tar fx $SOFT/$MYSQL
	mysql=`echo $MYSQL |awk -F ".tar" '{print $1}'`
	cd $SOFT/$mysql
	cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DMYSQL_DATADIR=/usr/local/mysql/data/ -DMYSQL_UNIX_ADDR=/usr/local/mysql/mysql.sock -DWITH_INNODBBASE_STORAGE_ENGINE=1 -DENABLE_LOCAL_INFILE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci -DMYSQL_USER=mysql -DWITH_DEBUG=0 -DWITH_EMBEDED_SERVER=0
	if [ $? -eq 0 ];then
		make
		if [ $? -eq 0 ];then
		   	make install
		     if [ $? -eq 0 ];then
		     	clear
				echo "Mysql install success!"
		     else
		     	clear
				echo "Mysql make install fail!";exit 1
			 fi
		else
			clear
		   	echo "Mysql make fail!";exit 1
		fi
	else
	    clear
		echo "Mysql cmake fail!";exit 1
	fi
}

#mysql set
mysql_set() {
	[ id mysql >/dev/null 2>&1 ] || useradd -s /sbin/nologin mysql
	chown -R mysql.mysql /usr/local/mysql
	cd $SOFT/$mysql
	mv /etc/my.cnf /etc/my.cnf.def
	rm -fr /etc/init.d/mysqld
	cp support-files/my-default.cnf /etc/my.cnf
	cp support-files/mysql.server /etc/init.d/mysqld
	chmod 755 /etc/init.d/mysqld
	chmod 755 scripts/mysql_install_db
	scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/usr/local/mysql/data/
	ln -s /usr/local/mysql/bin/* /usr/bin/
	ln -s /usr/local/mysql/lib/* /usr/lib/
}

#libiconv install
libiconv_install() {
	[ ! -f $SOFT/$LIBICONV ] && (echo "There is no $LIBICONV!";exit 1)
	cd $SOFT && tar fx $SOFT/$LIBICONV
	libiconv=`echo $LIBICONV |awk -F '.tar' '{print $1}'`
	cd $SOFT/$libiconv
	./configure --prefix=/usr/local/libiconv
    if [ $? -eq 0 ];then
		make
		if [ $? -eq 0 ];then
			make install
			if [ $? -eq 0 ];then
				clear
		   		echo "Libiconv install success!"
			else
				clear
		   		echo "Libiconv make install fail!";exit 1
			fi
		else
	  		clear
			echo "Libiconv make fail!";exit 1
	   	fi
	else
	  	clear
	   	echo "Libiconv configure fail!";exit 1
  	fi
}

#mhash install
mhash_install() {
	[ ! -f $SOFT/$MHASH ] && (echo "There is no $MHASH!";exit 1)
	cd $SOFT && tar fx $SOFT/$MHASH
	mhash=`echo $MHASH |awk -F '.tar' '{print $1}'`
	cd $SOFT/$mhash
	./configure
	if [ $? -eq 0 ];then
	    make
	    if [ $? -eq 0 ];then
			make install
			if [ $? -eq 0 ];then
				clear
		   		echo "Mhash install success!"
		   		ln -sf /usr/local/lib/libmhash.a /usr/lib/libmhash.a
				ln -sf /usr/local/lib/libmhash.la /usr/lib/libmhash.la
				ln -sf /usr/local/lib/libmhash.so /usr/lib/libmhash.so
				ln -sf /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
				ln -sf /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
				ldconfig
			else
				clear
			   	echo "Mhash make install fail!";exit 1
			fi
		else
		 	clear
			echo "Mhash make fail!";exit 1
		fi
	else
	  	clear
	    echo "Mhash configure fail!";exit 1
	fi
}

#libmcrypt install
libmcrypt_install() {
	[ ! -f $SOFT/$LIBMCRYPT ] && (echo "There is no $LIBMCRYPT!";exit 1)
	cd $SOFT && tar fx $SOFT/$LIBMCRYPT
	libmcrypt=`echo $LIBMCRYPT |awk -F '.tar' '{print $1}'`
	./configure
	if [ $? -eq 0 ];then
	    make
	    if [ $? -eq 0 ];then
			make install
			if [ $? -eq 0 ];then
				clear
				echo "libmcrypt install success!"
				/sbin/ldconfig
				if [ -d libltdl ];then
					cd libltdl
					./configure --enable-ltdl-install;make;make install
					if [ $? -eq 0 ];then
						clear
						echo "ltdl install success"
						ln -sf /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	    				ln -sf /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	    				ln -sf /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	    				ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
						#ln -s /usr/local/bin/libmcrypt-config /usr/bin/
						ldconfig
						#export LD_LIBRARY_PATH=/usr/local/lib: LD_LIBRARY_PATH
					else
						echo "ltdl install fail"
					fi
				else
					clear
					echo "there is no libltdl"
				fi	
			else
			    clear
				echo "Libmcrypt make install fail!";exit 1
			fi
		else
			clear
			echo "Libmcrypt make fail!";exit 1
		fi
	else
	    clear
	    echo "Libmcrypt configure fail!";exit 1
	fi
}
#mcrypt install
mcrypt_install() {
	[ ! -f $SOFT/$MCRYPT ] && (echo "There is no $MCRYPT!";exit 1)
	cd $SOFT && tar fx $SOFT/$MCRYPT
	mcrypt=`echo $MCRYPT |awk -F '.tar' '{print $1}'`
	cd $SOFT/$mcrypt && /sbin/ldconfig
	./configure
	if [ $? -eq 0 ];then
		make
		if [ $? -eq 0 ];then
			make install
			if [ $? -eq 0 ];then
				clear
				echo "mcrypt install success!"
			else
			    clear
				echo "mcrypt make install fail!";exit 1
			fi
		else
			clear
			echo "mcrypt make fail!";exit 1
		fi
	else
	    clear
	    echo "mcrypt configure fail!";exit 1
	fi
}
php_install() {
	ln -s /usr/lib64/libldap* /usr/lib/
	[ ! -f $SOFT/$PHP ] && (echo "There is no $PHP!";exit 1)
	cd $SOFT && tar fx $SOFT/$PHP
	php=`echo $PHP |awk -F '.tar' '{print $1}'`
	cd $SOFT/$php
	./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-pdo-mysql=/usr/local/mysql --with-gd --enable-gd-native-ttf --with-libxml-dir=/usr --enable-xml--disable-rpath --enable-discard-path --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap
	if [ $? -eq 0 ];then
	   	make
	    if [ $? -eq 0 ];then
			make install
			if [ $? -eq 0 ];then
				clear
		   		echo "Php install success!"
			else
				clear
		   		echo "Php make install fail!";exit 1
			fi
	    else
	     	clear
			echo "Php make fail!";exit 1
	    fi
	else
	  	clear
	    echo "Php configure fail!";exit 1
	fi
}
install_memcache() {
    [ ! -f $SOFT/$MEMCACHE ] && echo "There is no $MEMCACHE"
    cd $SOFT
    memcache=`echo $MEMCACHE |awk -F ".tgz" '{print $1}'`
    tar fx $SOFT/$MEMCACHE && cd $SOFT/$memcache
    [ ! -x /usr/local/php/bin/phpize ] && (echo "There is no '/usr/local/php/bin/phpize'";exit 1)
	/usr/local/php/bin/phpize
	if [ $? -eq 0 ];then
	    ./configure --enable-memcache --with-php-config=/usr/local/php/bin/php-config --with-zlib-dir
	    if [ $? -eq 0 ];then
            make
	        if [ $? -eq 0 ];then
	            make install
	            if [ $? -eq 0 ];then
	                echo "$MEMCACHE install successed."
	            else
	                echo "$MEMCACHE make install failed!!";exit 1
	            fi
	        else
	            echo "$MEMCACHE make failed!!";exit 1
	        fi
	    else
	        echo "$MEMCACHE configure failed!!";exit 1
	    fi
	else
	    echo "$MEMCACHE create configure file failed!!";exit 1
	fi
}
install_libmemcached() {
    [ ! -f $SOFT/$LIBMEMCACHED ] && (echo "There is no $LIBMEMCACHED";exit 1)
    cd $SOFT
    libmemcached=`echo $LIBMEMCACHED |awk -F ".tar" '{print $1}'`
    tar fx $SOFT/$LIBMEMCACHED && cd $SOFT/$libmemcached
    ./configure --prefix=/usr/local/libmemcached  --with-memcached
    if [ $? -eq 0 ];then
        make
        if [ $? -eq 0 ];then
            make install
            if [ $? -eq 0 ];then
                echo "$LIBMEMCACHED install successed."
            else
                echo "$LIBMEMCACHED make install failed!!";exit 1
            fi
        else
            echo "$LIBMEMCACHED make failed!!";exit 1
        fi
    else
        echo "$LIBMEMCACHED configure failed!!";exit 1
    fi
}

install_memcached() {
    [ ! -f $SOFT/$MEMCACHED ] && (echo "There is no $MEMCACHED";exit 1)
    cd $SOFT
    memcached=`echo $MEMCACHED |awk -F ".tgz" '{print $1}'`
    tar fx $SOFT/$MEMCACHED && cd $SOFT/$memcached
    [ ! -x /usr/local/php/bin/phpize ] && (echo "There is no '/usr/local/php/bin/phpize'";exit 1)
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config --with-libmemcached-dir=/usr/local/libmemcached/ --enable-memcached
	if [ $? -eq 0 ];then
	    make
	    if [ $? -eq 0 ];then
	        make install
	        if [ $? -eq 0 ];then
	            echo "$MEMCACHED install successed."
	        else
	            echo "$MEMCACHED make install failed!!";exit 1
	        fi
	    else
	        echo "$MEMCACHED make failed!!";exit 1
	    fi
	else
	    echo "$MEMCACHED configure failed!!";exit 1
	fi
}
install_imagemagick() {
    [ ! -f $SOFT/$IMAGEMAGICK ] && (echo "There is no $IMAGEMAGICK";exit 1)
    cd $SOFT
    imagemagick=`echo $IMAGEMAGICK |awk -F ".tar" '{print $1}'`
#   imagemagick='ImageMagick-6.9.2-0'
    tar fx $SOFT/$IMAGEMAGICK && cd $SOFT/$imagemagick
    ./configure --prefix=/usr/local/imagemagick
    if [ $? -eq 0 ];then
        make
        if [ $? -eq 0 ];then
            make install
            if [ $? -eq 0 ];then
                echo "$IMAGEMAGICK install successde."
            else
                echo "$IMAGEMAGICK make install failed!!";exit 1
            fi
        else
            echo "$IMAGEMAGICK make failed!!";exit 1
        fi
    else
        echo "$IMAGEMAGICK configure failed!!";exit 1
    fi
}
install_imagick() {
    [ ! -f $SOFT/$IMAGICK ] && (echo "There is no $IMAGICK";exit 1)
    cd $SOFT
    imagick=`echo $IMAGICK |awk -F ".tgz" '{print $1}'`
    tar fx $SOFT/$IMAGICK && cd $SOFT/$imagick
    [ ! -x /usr/local/php/bin/phpize ] && (echo "There is no '/usr/local/php/bin/phpize'";exit 1)
	/usr/local/php/bin/phpize
	if [ $? -eq 0 ];then
	    ./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/local/imagemagick
	    if [ $? -eq 0 ];then
	        make
	        if [ $? -eq 0 ];then
	            make install
	            if [ $? -eq 0 ];then
	                echo "$IMAGICK install successed."
	            else
	                echo "$IMAGICK make install failed!!";exit 1
	            fi
	        else
	            echo "$IMAGICK make failed!!";exit 1
	        fi
	    else
	        echo "$IMAGICK configure failed!!";exit 1
	    fi
	else
	    echo "$IMAGICK create configure file failed!!";exit 1
	fi
}

install_pdo_mysql() {
	 ln -s /usr/local/mysql/include/* /usr/local/include/	
    [ ! -f $SOFT/$POD_MYSQL ] && (echo "There is no $POD_MYSQL";exit 1)
    cd $SOFT
    pdo_mysql=`echo $POD_MYSQL |awk -F ".tgz" '{print $1}'`
    tar fx $SOFT/$POD_MYSQL && cd $SOFT/$pdo_mysql
    [ ! -x /usr/local/php/bin/phpize ] && (echo "There is no '/usr/local/php/bin/phpize'";exit 1)
	/usr/local/php/bin/phpize
	if [ $? -eq 0 ];then
	    ./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
	    if [ $? -eq 0 ];then
	        make
	        if [ $? -eq 0 ];then
	            make install
	            if [ $? -eq 0 ];then
	                echo "$POD_MYSQL install successed."
	            else
	                echo "$POD_MYSQL make install failed!!";exit 1
	            fi
	        else
	            echo "$POD_MYSQL make failed!!";exit 1
	        fi
	    else
	        echo "$POD_MYSQL configure failed!!";exit 1
	    fi
	else
	    echo "$POD_MYSQL create configure file failed!!";exit 1
    fi
}

install_gettext() {
	cd $SOFT/$php/ext/gettext
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	if [ $? -eq 0 ];then
		make && make install 
		if [ $? -eq 0 ];then
			echo "gettext install successed."
		else
			echo "make failed":exit
		fi
	else
		echo "configure failed!";exit 1
	fi
}
install_ftp() {
	cd $SOFT/$php/ext/ftp
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	if [ $? -eq 0 ];then
		make && make install 
		if [ $? -eq 0 ];then
			echo "ftp install successed."
		else
			echo "make failed":exit
		fi
	else
		echo "configure failed!";exit 1
	fi
}

install_tidy() {
	cd $SOFT/$php/ext/tidy
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	if [ $? -eq 0 ];then
		make && make install 
		if [ $? -eq 0 ];then
			echo "tidy install successed."
		else
			echo "make failed":exit
		fi
	else
		echo "configure failed!";exit 1
	fi
}

#set
set_php () {
[ id www >/dev/null 2>&1 ] || useradd -s /sbin/nologin www
php=`echo $PHP |awk -F '.tar' '{print $1}'`
cd $SOFT/$php
cp php.ini-production /usr/local/php/etc/php.ini
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
chmod 755 /usr/local/php/etc/*
chmod 755 /etc/init.d/php-fpm
echo '
extension = imagick.so
extension = ftp.so
extension = tidy.so
extension = memcache.so
extension = memcached.so
extension = gettext.so
;extension = mysql.so
;extension = mysqli.so' >>/usr/local/php/etc/php.ini
sed -i 's#; date.timezone =#date.timezone = Asia/Shanghai#' /usr/local/php/etc/php.ini
}


##################################################################
while :
do
	clear
	echo "===========Print System Infomation==========="
	cat << EOF
	|-------------System Infomation-------------
	| DATE			:$DATE
	| SYSTEM		:$SYSTEM
	| HOSTNAME		:$HOSTNAME
	| USER			:$USER
	| IP			:$IP
	| DISK_FREE		:$DISK_FREE
	| MEM_FREE		:${MEM_FREE}M
	| CPU_AVG		:$CPU_AVG
	|-------------------------------------------
	--------------------------------------------
	|******Please Enter Your Choice:[0-4]******|
	--------------------------------------------
	(1) Install and Config Nginx
	(2) Install and Config Mysql
	(3) Install and Config Php
	(4) Install and Config LNMP
	(0) Quit
EOF
	read -p "Please enter your choice[0-4]: " input
	case $input in
		1)
		clear
		while :
		do
			read -p "Are you ready to install Nginx? [y/n]  " yn
			case $yn in
				y)
				clear
				start_time
				choose_nginx_version
				if [ $Nginx -eq 3 ];then
					env_check
					pcre_install;jemalloc_install
					tengine_install
					nginx_set
				else
					env_check
					nginx_install
					nginx_set
				fi
				end_time
				if [ $? -eq 0 ];then
					Green "Congratulation!You had installed $NGINX successed!"
					exit 0
				fi
				;;					
				n)
				clear
				Violet "Return to the superior directory"
				sleep 1
				break
				;;
				*)
				clear
				Red "Wrong Choice!!!Try Again!!"
				continue
				;;
			esac
		done
		;;
		2)
		clear
		while :
		do
			read -p "Are you ready to install Mysql? [y/n]  " yn
			case $yn in
				y)
				clear
				start_time
				choose_mysql_version
				env_check
				cmake_install;mysql_install;mysql_set
				end_time
				if [ $? -eq 0 ];then
					Green "Congratulation!You had installed $MYSQL successed!"
					exit 0
				fi
				;;
				n)
				clear
				Violet "Return to the superior directory"
				sleep 1
				break
				;;
				*)
				clear
				Red "Wrong Choice!!!Try Again!!"
				continue
				;;
			esac
		done
		;;
		3)
		clear
		while :
		do
			read -p "Are you ready to install Php? [y/n]  " yn
			case $yn in
				y)
				clear
				start_time
				choose_mysql_version
				choose_php_version
				env_check
				cmake_install;mysql_install;mysql_set
				libiconv_install;libmcrypt_install;mhash_install;mcrypt_install
				php_install
				install_memcache;install_libmemcached;install_memcached;install_imagemagick;install_imagick
				install_gettext;install_ftp;install_tidy
				set_php
				end_time
				if [ $? -eq 0 ];then
					Green "Congratulation!You had installed $PHP successed!"
					exit 0
				fi
				;;
				n)
				clear
				Violet "Return to the superior directory"
				sleep 1
				break
				;;
				*)
				clear
				Red "Wrong Choice!!!Try Again!!"
				continue
				;;
			esac
		done
		;;
		4)
		clear
		while :
		do
			read -p "Are you ready to install LNMP? [y/n]  " yn
			case $yn in
				y)
				clear
				start_time
				choose_nginx_version
				choose_mysql_version
				choose_php_version
				clear
				Blue "You had chose $NGINX $MYSQL $PHP for LNMP install."
				sleep 3
				env_check
				nginx_install;nginx_set
				cmake_install;mysql_install;mysql_set
				libiconv_install;libmcrypt_install;mhash_install;mcrypt_install
				php_install
				install_memcache;install_libmemcached;install_memcached;install_imagemagick;install_imagick
				install_gettext;install_ftp;install_tidy
				set_php
				end_time
				if [ $? -eq 0 ];then
					Green "Congratulation!You had installed $NGINX $MYSQL $PHP for LNMP successed!"
					exit 0
				fi
				;;
				n)
				clear
				Violet "Return to the superior directory"
				sleep 1
				break
				;;
				*)
				clear
				Red "Wrong Choice!!!Try Again!!"
				continue
				;;
			esac
		done
		;;
		0)
		clear
		break
		;;
		*)
		if [ $num -lt 3 ];then
			num=$(($num+1))
			Red "============Wrong input,try again!!!=========="
			sleep 1
			clear
		else
			echo 	"==========================================="
	       		Red 	"|Warning!!You had too many wrong input!!! |"
	       		Red 	"|Please Enter Right Choice Again After 5s |"
	       		echo 	"==========================================="
			for i in `seq -w 5 -1 1`
			do
				echo -en "\b\b$i"
					sleep 1
			done
			clear
		fi
		;;
	esac
done
