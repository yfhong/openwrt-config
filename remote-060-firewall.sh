oc_uci_batch_set "$config_firewall"
# oc_uci_del_type firewall redirect
firewall_redirect_clean() {
    local all_names proto src_dport dest_ip dest_port name
    all_names=''
    while read proto src_dport dest_ip dest_port
    do
        name="${proto}__${src_dport//:/_}__${dest_ip//./_}__${dest_port//:/_}"
        all_names="$all_names $name"
    done
    oc_uci_keep_sections firewall redirect "$all_names"
}
firewall_redirect_apply() {
    local proto src_dport dest_ip dest_port name
    while read proto src_dport dest_ip dest_port
    do
        name="${proto}__${src_dport//:/_}__${dest_ip//./_}__${dest_port//:/_}"
        uci set "firewall.${name}=redirect"
        uci set "firewall.${name}.target=DNAT"
        uci set "firewall.${name}.src=wan"
        uci set "firewall.${name}.dest=lan"
        uci set "firewall.${name}.proto=$proto"
        uci set "firewall.${name}.src_dport=$src_dport"
        if [ x"$dest_ip" != x'-' -a x"$dest_ip" != x ]; then
            uci set "firewall.${name}.dest_ip=$dest_ip"
        fi
        if [ x"$dest_port" != x ]; then
            uci set "firewall.${name}.dest_port=$dest_port"
        fi
    done
}
echo "$config_redirect" | oc_strip_comment | firewall_redirect_clean
echo "$config_redirect" | oc_strip_comment | firewall_redirect_apply
oc_service reload firewall 2>/dev/null
