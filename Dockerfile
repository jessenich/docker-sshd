ARG VARIANT=sudo

FROM jessenich91/alpine:"${VARIANT:-sudo}" as build

ARG USER_SSH_SHELL="/bin/zsh"

ENV VARIANT="${VARIANT:-latest}" \
    SSH_USER_SHELL="${SSH_USER_SHELL:-/bin/zsh}" \
    RUNNING_IN_DOCKER="true"

RUN apk update && \
    apk add --update --no-cache \
        openssh \
        supervisor

COPY ./rootfs /

RUN chmod +x /usr/slib/conf-ssh.sh && \
    chmod +x /usr/slib/conf-ssh-user.sh && \
    /usr/slib/conf-ssh.sh && \
    /usr/slib/conf-ssh-user.sh --username root --user-shell "${SSH_USER_SHELL}"  && \
    /usr/slib/conf-ssh-user.sh --username "${SSH_USER}" --user-shell "${SSH_USER_SHELL}"

FROM scratch as export_keys

COPY --from=build "/home/${SSH_USER}/.ssh/id_ed25519"     "/user_keys/id_ed_25519"
COPY --from=build "/home/${SSH_USER}/.ssh/id_ed25519.pub" "/user_keys/id_ed_25519.pub"
COPY --from=build "/home/${SSH_USER}/.ssh/id_rsa"         "/user_keys/id_rsa"
COPY --from=build "/home/${SSH_USER}/.ssh/id_rsa.pub"     "/user_keys/id_rsa.pub"
COPY --from=build "/home/${SSH_USER}/.ssh/id_ecdsa"       "/user_keys/id_ecdsa"
COPY --from=build "/home/${SSH_USER}/.ssh/id_ecdsa.pub"   "/user_keys/id_ecdsa.pub"

COPY --from=build "/root/.ssh/id_ed25519"     "/root_keys/id_ed_25519"
COPY --from=build "/root/.ssh/id_ed25519.pub" "/root_keys/id_ed_25519.pub"
COPY --from=build "/root/.ssh/id_rsa"         "/root_keys/id_rsa"
COPY --from=build "/root/.ssh/id_rsa.pub"     "/root_keys/id_rsa.pub"
COPY --from=build "/root/.ssh/id_ecdsa"       "/root_keys/id_ecdsa"
COPY --from=build "/root/.ssh/id_ecdsa.pub"   "/root_keys/id_ecdsa.pub"

COPY --from=build "/etc/ssh/ssh_host_ed25519_key"     "/host_keys/ssh_host_ed_25519_key"
COPY --from=build "/etc/ssh/ssh_host_ed25519_key.pub" "/host_keys/ssh_host_ed_25519_key.pub"
COPY --from=build "/etc/ssh/ssh_host_rsa_key"         "/host_keys/ssh_host_rsa_key"
COPY --from=build "/etc/ssh/ssh_host_rsa_key.pub"     "/host_keys/ssh_host_rsa_key.pub"
COPY --from=build "/etc/ssh/ssh_host_ecdsa_key"       "/host_keys/ssh_host_ecdsa_key"
COPY --from=build "/etc/ssh/ssh_host_ecdsa_key.pub"   "/host_keys/ssh_host_ecdsa_key.pub"

FROM build as sshd

WORKDIR '/home/${USER}'
EXPOSE 22
ENTRYPOINT [ "/usr/bin/supervisord" ]
