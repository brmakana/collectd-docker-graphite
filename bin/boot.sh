#!/bin/bash

# Fail hard and fast
set -eo pipefail
. /etc/environment
export ETCD_PORT=${ETCD_PORT:-4001}
export HOST_IP=${HOST_IP:-172.17.42.1}
export ETCD=$HOST_IP:4001

echo "[collectd-graphite] booting container. ETCD: $ETCD"

# Loop until confd has updated the config
if [[ -z "$GRAPHITE_HOST" ]]
then
 echo "No GRAPHITE_HOST set, looking in etcd"
 until confd -onetime -node $ETCD -config-file /etc/confd/conf.d/local_settings.toml; do
  echo "[skyline] waiting for confd to refresh"
  sleep 5
 done
else
 echo "Setting graphite host to ${GRAPHITE_HOST}"
 sed -i "s/__GRAPHITE_HOST__/$GRAPHITE_HOST/" /etc/collectd/collectd.conf
fi

if [ -d /mnt/proc ]; then
  umount /proc
  mount -o bind /mnt/proc /proc
fi

if [ -z "$@" ]; then
  exec /usr/sbin/collectd -C /etc/collectd/collectd.conf -f
else
  exec $@
fi

# Start
echo "[collectd] starting"
