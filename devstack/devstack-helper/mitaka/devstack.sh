#!/bin/bash

export MY_IP=$(ip route | awk '/src/ { print $9 }')
export GATEWAY=$(/sbin/ip route | awk '/default/ { print $3 }')
export NET=$(echo $MY_IP | awk -F. '{print $1"."$2"."$3}')

git clone https://git.openstack.org/openstack-dev/devstack  -b stable/mitaka

cat <<EOF > devstack/local.conf
[[local|localrc]]
SERVICE_TOKEN=azertytoken
ADMIN_PASSWORD=admin
DATABASE_PASSWORD=stackdb
RABBIT_PASSWORD=stackqueue
SERVICE_PASSWORD=\$ADMIN_PASSWORD
LOGFILE=\$DEST/logs/stack.sh.log
LOGDAYS=2
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=\$DEST/data
LIBVIRT_TYPE=kvm
enable_plugin app-catalog-ui https://git.openstack.org/openstack/app-catalog-ui
#If you want Murano, uncomment the next two lines before running stack.sh
#enable_plugin murano https://github.com/openstack/murano
#enable_service murano murano-api murano-engine
disable_service tempest
enable_service heat h-api h-api-cfn h-api-cw h-eng
disable_service n-net
enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta
PUBLIC_INTERFACE=eth0
Q_USE_PROVIDERNET_FOR_PUBLIC=True
Q_L3_ENABLED=True
Q_USE_SECGROUP=True
HOST_IP=$MY_IP
SERVICE_HOST=$MY_IP
MYSQL_HOST=$MY_IP
RABBIT_HOST=$MY_IP
GLANCE_HOSTPORT=$MY_IP:9292
FLOATING_RANGE="$NET.0/24"
Q_FLOATING_ALLOCATION_POOL=start=$NET.230,end=$NET.254
FIXED_RANGE="10.0.0.0/24"
PUBLIC_NETWORK_GATEWAY="$GATEWAY"

# Use Linuxbridge
Q_AGENT=linuxbridge
LB_PHYSICAL_INTERFACE=eth0
PUBLIC_PHYSICAL_NETWORK=default
LB_INTERFACE_MAPPINGS=default:eth0

# OR use OVS
#OVS_PHYSICAL_BRIDGE=br-ex
#PUBLIC_BRIDGE=br-ex
#OVS_BRIDGE_MAPPINGS=public:br-ex

EOF

echo Now your devstack/local.conf file should be ready to go!
echo To use OVS instead of Linuxbrige, swap the commented-out section
echo in local.conf.
echo Now double-check local.conf just to make sure the network guesses
echo look sane, then your next steps should be:
echo '# cd devstack'
echo '# ./stack.sh'
