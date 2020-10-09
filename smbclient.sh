#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#说明：本脚本可以在宝塔面板上安装的php中使用，其他的请参考安装php的路径进行修改
#个人网站:www.dpsky.cn

public_file=/www/server/panel/install/public.sh
[ ! -f $public_file ] && wget -O $public_file http://download.bt.cn/install/public.sh -T 5;

publicFileMd5=$(md5sum ${public_file}|awk '{print $1}')
md5check="66c89de255c11b64d5215be67dc4fdc6"
[ "${publicFileMd5}" != "${md5check}"  ] && wget -O $public_file http://download.bt.cn/install/public.sh -T 5;

. $public_file
download_Url=$NODE_URL
srcPath='/root';


System_Lib(){
    if [ "${PM}" == "yum" ] || [ "${PM}" == "dnf" ] ; then
        installPack="libsmbclient-devel"
    fi

    [ "${installPack}" != "" ] && ${PM} install ${installPack} -y
}

Ext_Path(){
  case "${version}" in
    '52')
    extFile="/www/server/php/52/lib/php/extensions/no-debug-non-zts-20060613/smbclient.so"
    ;;
    '53')
    extFile="/www/server/php/53/lib/php/extensions/no-debug-non-zts-20090626/smbclient.so"
    ;;
    '54')
    extFile="/www/server/php/54/lib/php/extensions/no-debug-non-zts-20100525/smbclient.so"
    ;;
    '55')
    extFile="/www/server/php/55/lib/php/extensions/no-debug-non-zts-20121212/smbclient.so"
    ;;
    '56')
    extFile="/www/server/php/56/lib/php/extensions/no-debug-non-zts-20131226/smbclient.so"
    ;;
    '70')
    extFile="/www/server/php/70/lib/php/extensions/no-debug-non-zts-20151012/smbclient.so"
    ;;
    '71')
    extFile="/www/server/php/71/lib/php/extensions/no-debug-non-zts-20160303/smbclient.so"
    ;;
    '72')
    extFile="/www/server/php/72/lib/php/extensions/no-debug-non-zts-20170718/smbclient.so"
    ;;
    '73')
    extFile='/www/server/php/73/lib/php/extensions/no-debug-non-zts-20180731/smbclient.so'
    ;;
    '74')
    extFile='/www/server/php/74/lib/php/extensions/no-debug-non-zts-20190902/smbclient.so'
    ;;
    esac
}

Install_LibSmbClient()
{
        #下载smbclient客户端
        cd $srcPath
        wget http://pecl.php.net/get/smbclient-1.0.0.tgz
        tar xvf smbclient-1.0.0.tgz
        cd $srcPath/smbclient-1.0.0
        /www/server/php/$version/bin/phpize
        ./configure --with-php-config=/www/server/php/$version/bin/php-config 
        make && make install
    if [ ! -d /www/server/php/$version ];then
        return;
    fi

    if [ ! -f "/www/server/php/$version/bin/php-config" ];then
        echo "php-$vphp 未安装,请选择其它版本!"
        echo "php-$vphp not install, Plese select other version!"
        return
    fi

    isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'libsmbclient.so'`
    if [ "${isInstall}" != "" ];then
        echo "php-$vphp 已安装过libsmbclient,请选择其它版本!"
        echo "php-$vphp is already install libsmbclient, Plese select other version!"
        return
    fi


    echo "extension=smbclient.so" >> /www/server/php/$version/etc/php.ini
    /etc/init.d/php-fpm-$version reload
    echo '==============================================='
    echo 'successful!'
    /www/server/php/${version}/bin/php -m|grep smbclient
}


Uninstall_LibSmbClient()
{
    if [ ! -d /www/server/php/$version ];then
        rm -rf $srcPath/smbclient-1.0.0
    fi

    if [ ! -f "/www/server/php/$version/bin/php-config" ];then
        echo "php-$vphp 未安装,请选择其它版本!"
        echo "php-$vphp not install, Plese select other version!"
        return
    fi

    isInstall=`cat /www/server/php/$version/etc/php.ini|grep 'libsmbclient.so'`
    if [ "${isInstall}" = "" ];then
        echo "php-$vphp 未安装libsmbclient,请选择其它版本!"
        echo "php-$vphp not install libsmbclient, Plese select other version!"
        return
    fi

    rm -f ${extFile}
    sed -i '/libsmbclient.so/d'  /www/server/php/$version/etc/php.ini
    /etc/init.d/php-fpm-$version reload
    echo '==============================================='
    echo 'successful!'
}
Bt_Check(){
    checkFile="/www/server/panel/install/check.sh"
    wget -O ${checkFile} ${download_Url}/tools/check.sh
    . ${checkFile}
}
actionType=$1
version=$2
vphp=${version:0:1}.${version:1:1}
if [ "$actionType" == 'install' ];then
    Ext_Path
    Install_LibSmbClient
    Bt_Check
elif [ "$actionType" == 'uninstall' ];then
    Ext_Path
    Uninstall_LibSmbClient
fi
