FROM centos:latest
MAINTAINER Wu Ping <wuping@seall.cn>

ENV MAXSCALE_VERSION 2.2.19
ENV MAXSCALE_URL https://downloads.mariadb.com/MaxScale/${MAXSCALE_VERSION}/rhel/7/x86_64/maxscale-${MAXSCALE_VERSION}-1.rhel.7.x86_64.rpm

RUN curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --skip-server --skip-tools \
 && yum -y update \
 && yum -y install keepalived \
 && yum deplist maxscale | grep provider | awk '{print $2}' | sort | uniq | grep -v maxscale | sed ':a;N;$!ba;s/\n/ /g' | xargs yum -y install \
 && rpm -Uvh ${MAXSCALE_URL} \
 && yum clean all \
 && rm -rf /tmp/*

# Enable maxadmin cli
RUN echo '[{"name": "root", "account": "admin", "password": ""}, {"name": "maxscale", "account": "admin", "password": ""}]' > /var/lib/maxscale/maxadmin-users \
 && chown maxscale:maxscale /var/lib/maxscale/maxadmin-users

# VOLUME for custom configuration
VOLUME ["/var/lib/maxscale"]

# EXPOSE the MaxScale default ports

## RW Split Listener
EXPOSE 4006

## Read Connection Listener
EXPOSE 4008

## Debug Listener
EXPOSE 4442

## CLI Listener
EXPOSE 6603

# Running Keepalived and MaxScale
ENTRYPOINT ["/docker-entrypoint.sh"]
