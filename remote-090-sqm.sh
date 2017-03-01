oc_opkg_install sqm-scripts kmod-sched-cake

. /lib/functions/network.sh
network_get_device iface_wan wan

oc_uci_rename sqm.eth1 wan
uci batch <<EOF
set sqm.wan.enabled='0'
set sqm.wan.interface='${iface_wan}'
set sqm.wan.script='piece_of_cake.qos'
EOF
oc_uci_batch_set "$config_sqm"
oc_service restart sqm