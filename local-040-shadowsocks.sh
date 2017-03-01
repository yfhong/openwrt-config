# push_shadowsocks() {
#     local version git_version ipk_version
#     version="2.4.6"
#     v_git="98cf545"
#     v_ipk="1"
#     download_push "http://jaist.dl.sourceforge.net/project/openwrt-dist/shadowsocks-libev/${version}-${v_git}/${arch}/shadowsocks-libev-spec_${version}-${v_ipk}_${arch}.ipk" /tmp/shadowsocks-libev-spec.ipk shadowsocks-libev-spec
# }
# push_shadowsocks

chn_cidr() {
    awk -F\| '/CN\|ipv4/ { printf("%s/%d\n", $4, 32-log($5)/log(2)) }'
}
if [ ! -e files/chn-cidr ]; then
    download http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest
    chn_cidr < files/tmp/delegated-apnic-latest > files/chn-cidr
    cat >> files/chn-cidr <<EOF
64.62.200.2/32
1.1.1.0/24
EOF
fi
push files/chn-cidr /etc/chn-cidr
push files/shadowsocks.keep /lib/upgrade/keep.d/shadowsocks
push files/ss /root/bin/ss

# push_dnsproxy() {
#     local version
#     version='0.4.6.1-1'
#     download_push "https://github.com/wongsyrone/openwrt-Pcap_DNSProxy/raw/prebuilt-ipks/chaos_calmer/15.05.1/x86/generic/pcap-dnsproxy_${version}_${arch}.ipk" /tmp/pcap-dnsproxy.ipk pcap-dnsproxy
# }
# push_dnsproxy