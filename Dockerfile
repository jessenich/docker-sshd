ARG BASE_IMAGE= \
    BASE_IMAGE_TAG=
    
FROM ${BASE_IMAGE:-jessenich91/alpine-zsh}:"${BASE_IMAGE_TAG:-latest}" as build

ARG SSH_USER= \
    SSH_USER_SHELL= 

ENV SSH_USER="${SSH_USER:-sshuser}" \
    SSH_USER_SHELL="${SSH_USER_SHELL:-/bin/zsh}"

RUN apk update && \
    apk add openssh && \
    rm -rf /var/cache/apk/*

COPY resources/etc/ssh/ /etc/ssh/
COPY resources/tmp/docker-build /tmp/docker-build

RUN chmod +x /tmp/docker-build/conf-ssh.sh && \
    chmod +x /tmp/docker-build/conf-ssh-user.sh && \
    /tmp/docker-build/conf-ssh.sh && \
    /tmp/docker-build/conf-ssh-user.sh --username "root" --user-shell "/bin/zsh" && \
    /tmp/docker-build/conf-ssh-user.sh --username "${SSH_USER}" --user-shell "${SSH_USER_SHELL}" 

FROM scratch as artifact
ARG SSH_USER=

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

FROM build as final

COPY entrypoint.sh /entrypoint.sh

EXPOSE 22

ENTRYPOINT [ "/entrypoint.sh" ]
