ARG VARIANT="${VARIANT:-glibc-latest}"

FROM jessenich91/alpine-zsh:"${VARIANT}"

ARG SSH_ADMIN_USER="${SSH_ADMIN_USER:-sshadm}"

RUN apk add --update --no-cache openssh && \
    mkdir /etc/ssh/authorized_keys.d/ && \
    adduser -D -g "${SSH_ADMIN_USER}" -s /bin/zsh "${SSH_ADMIN_USER}" && \
    if [ ! -d "/home/${SSH_ADMIN_USER}" ]; then mkdir "/home/${SSH_ADMIN_USER}"; fi && \
    chown -R "${SSH_ADMIN_USER}:${SSH_ADMIN_USER}" "/home/${SSH_ADMIN_USER}" && \
    ssh-keygen -A

COPY resources/etc/ssh/ /etc/ssh/

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh
VOLUME /etc/ssh/sshd_config.d/
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]