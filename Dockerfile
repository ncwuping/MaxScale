FROM centos:7
MAINTAINER Wu Ping <ncwuping@hotmail.com>

#ENV MAXSCALE_VERSION 2.3.20
#ENV MAXSCALE_URL https://downloads.mariadb.com/MaxScale/${MAXSCALE_VERSION}/rhel/7/x86_64/maxscale-${MAXSCALE_VERSION}-1.centos.7.x86_64.rpm

RUN curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --skip-server --skip-tools --mariadb-maxscale-version=2.3 \
 && yum -y update \
# && yum deplist maxscale | grep provider | awk '{print $2}' | sort | uniq | grep -v maxscale | grep -v i686 | sed ':a;N;$!ba;s/\n/ /g' | xargs yum -y install \
# && rpm -Uvh ${MAXSCALE_URL} \
 && yum -y install maxscale \
 && yum clean all \
 && rm -rf /tmp/*

# Enable maxadmin cli
COPY maxscale.cnf /var/lib/maxscale/
COPY maxadmin-users /var/lib/maxscale/

COPY docker-entrypoint.sh /usr/local/bin/
# backwards compat
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
 && ln -s usr/local/bin/docker-entrypoint.sh /
ENTRYPOINT ["docker-entrypoint.sh"]

# VOLUME for custom configuration
VOLUME ["/var/lib/maxscale"]

# EXPOSE the MaxScale default ports

## RW Split Listener
EXPOSE 4006

## Read Connection Listener
EXPOSE 4008

## Debug Listener
#EXPOSE 4442

## CLI Listener
#EXPOSE 6603

## REST API for MaxCtrl
EXPOSE 8989

# Running MaxScale
CMD ["maxscale", "-d", "-U", "maxscale", "-f", "/var/lib/maxscale/maxscale.cnf"]
