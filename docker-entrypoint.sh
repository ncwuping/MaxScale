#!/usr/bin/env bash

if [ -z "${SERVER2_ADDR}" -o -z "${SERVER3_ADDR}" ]; then
  echo "No sufficient nodes for read-write split service"
  exit 1
fi

chown maxscale:maxscale /var/lib/maxscale/{maxscale.cnf,maxadmin-users}

if [ -n "${SERVER1_ADDR}" ]; then
  sed -e 's!<ip_addr_of_server1>!'"${SERVER1_ADDR}"'!' -i /var/lib/maxscale/maxscale.cnf
fi

sed -e 's!<ip_addr_of_server2>!'"${SERVER2_ADDR}"'!' \
    -e 's!<ip_addr_of_server3>!'"${SERVER3_ADDR}"'!' \
    -i /var/lib/maxscale/maxscale.cnf

if [ ! -f /var/lib/maxscale/.secrets ]; then
  chroot --userspec=maxscale:maxscale / /usr/bin/maxkeys
fi

cipher=$( maxpasswd /var/lib/maxscale ${MAXSCALE_SECRET:-"maxscale-proxy"} )
sed -e 's!<cipher_of_secret>!'"${cipher}"'!g' -i /var/lib/maxscale/maxscale.cnf

exec "$@"
