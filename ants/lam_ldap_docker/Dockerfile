FROM debian:jessie

MAINTAINER 18001326539@163.com

ENV OPENLDAP_VERSION 2.4.40

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install wget --no-install-recommends -y \
        slapd=${OPENLDAP_VERSION}* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


RUN wget http://ftp.debian.org/debian/pool/main/l/ldap-account-manager/ldap-account-manager_5.5-1_all.deb && \
    dpkg -i ldap-account-manager_5.5-1_all.deb; \
    rm ldap-account-manager_5.5-1_all.deb && \
    apt-get update &&  apt-get -fy install && rm -r /var/lib/apt/lists/*

ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN mv /etc/ldap /etc/ldap.dist

COPY modules/ /etc/ldap.dist/modules

COPY entrypoint.sh /entrypoint.sh

EXPOSE    389    80

VOLUME ["/etc/ldap", "/var/lib/ldap"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["slapd", "-d", "32768", "-u", "openldap", "-g", "openldap"] 
