FROM mamohr/centos-java:jre8

MAINTAINER Nguyen Khac Trieu <trieunk@yahoo.com>

# permissions
ARG CONTAINER_UID=7004
ARG CONTAINER_GID=7004

RUN \
  yum update -y && \
  yum install -y epel-release && \
  yum install -y net-tools python-setuptools hostname inotify-tools yum-utils && \
  yum clean all && \
  easy_install supervisor

ENV FILE https://downloads-guests.open.collab.net/files/documents/61/17071/CollabNetSubversionEdge-5.2.0_linux-x86_64.tar.gz

RUN wget -q ${FILE} -O /tmp/csvn.tgz && \
    mkdir -p /opt/csvn && \
    tar -xzf /tmp/csvn.tgz -C /opt/csvn --strip=1 && \
    rm -rf /tmp/csvn.tgz

ENV RUN_AS_USER collabnet

RUN export CONTAINER_USER=collabnet                 &&  \
    export CONTAINER_GROUP=collabnet                &&  \
    groupadd -g $CONTAINER_GID $CONTAINER_GROUP     &&  \
    useradd -u $CONTAINER_UID                           \
            -g $CONTAINER_GID                         \
            -d /home/$CONTAINER_USER                    \
            -s /bin/bash                                \
            $CONTAINER_USER                      

RUN chown -R collabnet.collabnet /opt/csvn && \
    cd /opt/csvn && \
    ./bin/csvn install && \
    mkdir -p ./data-initial && \
    cp -r ./data/* ./data-initial

# httpd_bind is a small application included with CollabNet Subversion Edge to allow the server access
# to the standard ports without the server itself running with elevated privileges. In order for it to work,
# httpd_bind must be owned by root and have its suid bit set such as shown by the commands below. These must be executed as root or sudo.
RUN chown root:collabnet /opt/csvn/lib/httpd_bind/httpd_bind && \
    chmod u+s /opt/csvn/lib/httpd_bind/httpd_bind

EXPOSE 3343 4434 18080

ADD files /

VOLUME /opt/csvn/data

WORKDIR /opt/csvn

ENTRYPOINT ["/config/bootstrap.sh"]
