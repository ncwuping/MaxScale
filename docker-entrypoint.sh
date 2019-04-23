#!/usr/bin/env bash

echo '[{"name": "root", "account": "admin", "password": ""}, {"name": "maxscale", "account": "admin", "password": ""}]' > /var/lib/maxscale/maxadmin-users
/usr/bin/maxscale -d
