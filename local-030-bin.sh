remote mkdir -p /etc/profile.d/
remote mkdir -p /root/bin/

push files/bin/keep /lib/upgrade/keep.d/bin
push files/bin/profile.sh /etc/profile.d/bin.sh
