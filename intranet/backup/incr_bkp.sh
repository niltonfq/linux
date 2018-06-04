#!/bin/bash
    
data=`date +%Y-%m-%d`
rdir='/srv/asf/backups'

asf='/var/www/asf.com/public_html'
logs='/var/log/apache2'
express='/srv/www/express'

dump=`which xfsdump`
ssh=`which ssh`
dd=`which dd`
gz=`which gzip`


$dump -l 1 -L backup - $asf | $gz | $ssh -p 52030 root@storage $dd of=$rdir/asf/asf-$data.1.dump.gz
$dump -l 1 -L backup - $logs | $gz | $ssh -p 52030 root@storage $dd of=$rdir/logs/logs-$data.1.dump.gz
$dump -l 1 -L backup - $express | $gz | $ssh -p 52030 root@storage $dd of=$rdir/express/express-$data.1.dump.gz

