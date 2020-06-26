#Dockerfile for a Postfix email relay service
FROM centos:7
MAINTAINER test

ENV DEBUG=fasle DOMAIN=test.com

RUN yum install -y epel-release && yum update -y && \
    yum install -y cyrus-sasl cyrus-sasl-plain cyrus-sasl-md5 mailx \
    perl supervisor postfix rsyslog \
    && rm -rf /var/cache/yum/* \
    && yum clean all
RUN sed -i -e "s/^nodaemon=false/nodaemon=true/" /etc/supervisord.conf
RUN sed -i -e 's/inet_interfaces = localhost/inet_interfaces = all/g' /etc/postfix/main.cf
RUN echo '/^Received:/ IGNORE' >> /etc/postfix/header_checks \
    && echo '/^Authentication-Results:/ IGNORE' >> /etc/postfix/header_checks \
    && echo '/^Message-ID:/ IGNORE' >> /etc/postfix/header_checks

COPY etc/ /etc/
COPY run.sh /

RUN chmod +x /run.sh \
    && newaliases

EXPOSE 25

CMD ["./run.sh"]
