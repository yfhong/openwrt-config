oc_opkg_install ca-bundle ddns-scripts

oc_uci_delete ddns.myddns_ipv4 ddns.myddns_ipv6
# uci batch <<EOF
# set ddns.global.use_curl='1'
# EOF
oc_uci_merge ddns "$config_ddns"
oc_service restart ddns
