rm -rf /tmp/lqxcore-linux/

userdel nm01
rm -rf /home/nm01
userdel nm02
rm -rf /home/nm02

rm -rf etc/rc.local
rm -rf /etc/fail2ban/jail.local
rm -rf /etc/cron.d/lqx_sentinel