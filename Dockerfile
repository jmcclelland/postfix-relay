FROM my-jessie:latest
MAINTAINER Jamie McClelland <jamie@mayfirst.org>

# rsyslog is not going to run by default, but useful to have (along with bsd-mailx
# and vim) for debugging problems since I can't get postfix to output errors to 
# stderr or stdout. postfix-pcre will pull in the base postfix pacage.
RUN apt-get update && \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get install --no-install-recommends -y \
  postfix-pcre  \
  bsd-mailx \
  rsyslog \
  vim-tiny && \
  rm -rf /var/lib/apt/lists/*

COPY main.cf /etc/postfix/
COPY recipient_canonical /etc/postfix/recipient_canonical
RUN postmap /etc/postfix/recipient_canonical

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["postfix"]

