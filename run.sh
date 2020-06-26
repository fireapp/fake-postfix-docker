#!/bin/bash

[ "${DEBUG}" == "yes" ] && set -x

function add_config_value() {
  local key=${1}
  local value=${2}
  local config_file=${3:-/etc/postfix/main.cf}
  [ "${key}" == "" ] && echo "ERROR: No key set !!" && exit 1
  [ "${value}" == "" ] && echo "ERROR: No value set !!" && exit 1

  echo "Setting configuration option ${key} with value: ${value}"
 postconf -e "${key} = ${value}"
}


# Set needed config options
add_config_value "mydomain" ${DOMAIN}
add_config_value "myhostname" 'mail.$mydomain'
add_config_value "myorigin" '$mydomain'
add_config_value "home_mailbox" "Maildir/"
add_config_value "smtpd_banner" '$myhostname ESMTP'
add_config_value "mynetworks" "0.0.0.0/0"
add_config_value "inet_protocols" "ipv4"
add_config_value "inet_interfaces" "all"
add_config_value "mydestination" '$myhostname, localhost.$mydomain, localhost, $mydomain'
add_config_value "header_checks" "regexp:/etc/postfix/header_checks"


#Start services

# If host mounting /var/spool/postfix, we need to delete old pid file before
# starting services
rm -f /var/spool/postfix/pid/master.pid

exec supervisord
