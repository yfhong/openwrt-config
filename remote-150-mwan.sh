setup_mwan() {
    # network
    oc_opkg_install kmod-macvlan

    uci set network.wan.metric=10
    for i in $(seq 1 "$config_mwan")
    do
        uci batch <<EOF
set network.macvlan_mwan${i}=device
set network.macvlan_mwan${i}.name=macvlan-mwan${i}
set network.macvlan_mwan${i}.type=macvlan
set network.macvlan_mwan${i}.ifname=$(uci -q get network.wan.ifname)
set network.mwan${i}=interface
set network.mwan${i}.ifname=macvlan-mwan${i}
set network.mwan${i}.proto=pppoe
set network.mwan${i}.username=$(uci -q get network.wan.username)
set network.mwan${i}.password=$(uci -q get network.wan.password)
set network.mwan${i}.ipv6=0
set network.mwan${i}.metric=${i}0
EOF
    done
    oc_service reload network

    # firewall
    for i in $(seq 1 "$config_mwan")
    do
        oc_uci_add_list 'firewall.@zone[1].network' "mwan${i}"
    done
    oc_service reload firewall 2>/dev/null

    # sqm
    if oc_opkg_installed sqm-scripts && /etc/init.d/sqm enabled; then
        for i in $(seq 1 "$config_mwan")
        do
            uci -q show sqm.wan | sed -e "s/sqm.wan/sqm.mwan${i}/" -e "s/pppoe-wan/pppoe-mwan${i}/" -e 's/^/set /' | uci batch
        done
    fi
    oc_service restart sqm

    # mwan3
    oc_opkg_install mwan3

    (
        cat <<EOF
config interface 'wan'
	option enabled '1'
EOF
        for i in $(seq 1 "$config_mwan")
        do
            cat <<EOF
config interface 'mwan${i}'
	option enabled '1'
EOF
        done
        cat <<EOF
config member 'wan_m1_w3'
	option interface 'wan'
	option metric '1'
	option weight '3'
EOF
        for i in $(seq 1 "$config_mwan")
        do
            cat <<EOF
config member 'mwan${i}_m1_w3'
	option interface 'mwan${i}'
	option metric '1'
	option weight '3'
EOF
        done
        cat <<EOF
config policy 'wan_only'
	list use_member 'wan_m1_w3'

config policy 'balanced'
	list use_member 'wan_m1_w3'
EOF
        for i in $(seq 1 "$config_mwan")
        do
            cat <<EOF
	list use_member 'mwan${i}_m1_w3'
EOF
            done
        cat <<EOF
config rule 'arukas'
	option dest_ip '153.125.235.0/24'
	option use_policy 'balanced'

config rule 'default_rule'
	option dest_ip '0.0.0.0/0'
	option use_policy 'wan_only'
EOF
    ) | uci import mwan3

    if oc_uci_commit mwan3; then
        echo "restart mwan3"
        mwan3 restart 2>/dev/null
    fi
}

if [ "$config_mwan" -gt 0 ]; then
    setup_mwan
fi