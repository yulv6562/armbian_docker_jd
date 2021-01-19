#!/bin/bash
trap 'cp /jd-scripts-docker/sync.sh /sync' Exit
(
  exec 2<>/dev/null
  set -e
  cd /jd-scripts-docker
  git pull
) || {
  git clone https://github.com/yulv6562/armbian_docker_jd.git /jd-scripts-docker_tmp
  [ -d /jd-scripts-docker_tmp ] && {
    rm -rf /jd-scripts-docker
    mv /jd-scripts-docker_tmp /jd-scripts-docker
  }
}
(
  exec 2<>/dev/null
  set -e
  cd /scripts
  git pull
) || {
  git clone --branch=master https://gitee.com/lxk0301/jd_scripts.git /scripts_tmp
  [ -d /scripts_tmp ] && {
    rm -rf /scripts
    mv /scripts_tmp /scripts
  }
}
cd /scripts || exit 1
npm install || npm install --registry=https://registry.npm.taobao.org || exit 1
[ -f /crontab.list ] && {
  cp /crontab.list /crontab.list.old
}
cat /etc/os-release | grep -q ubuntu && {
  cp /jd-scripts-docker/crontab.list /crontab.list
  crontab -r
} || {
  cat /scripts/docker/crontab_list.sh | grep 'node' | sed 's/>>.*$//' | awk '
  BEGIN{
    print("55 */3 * * *  bash /jd-scripts-docker/cron_wrapper bash /sync")
  }
  {
    for(i=1;i<=5;i++)printf("%s ",$i);
    printf("bash /jd-scripts-docker/cron_wrapper \"");
    for(i=6;i<=NF;i++)printf(" %s", $i);
    print "\"";
  }
  ' > /crontab.list
}

crontab /crontab.list || {
  cp /crontab.list.old /crontab.list
  crontab /crontab.list
}
crontab -l


