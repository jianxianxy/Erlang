#!/bin/bash
#Author:shadow-guy
#Date:2015-03-13
#Des:这是一个检测Apache是否启动的shell。每分钟检测一次如果没有启动则启动
Apa_stat=`nmap -sT localhost | grep ' 'http$ | awk '{print $2}'`
date=`date`
if [ $Apa_stat == 'open' ]
   then
      echo "${date}：Apache is ok!" > '/tmp/Apa.right.log'
   else
      /etc/rc.d/init.d/httpd stop &> /dev/null
      /etc/rc.d/init.d/httpd start &> /dev/null
      echo "${date}：Apache is reboot!" >> "/tmp/Apa.wrong.log"      
fi
ok
