ARG BASE_IMAGE=jessenich91/alpine-zsh \
    VARIANT=latest

FROM ${BASE_IMAGE}:"${VARIANT}" as build

ARG SSH_USER=sshuser \
    SSH_USER_SHELL="/bin/zsh"

ENV BASE_IMAGE="${BASE_IMAGE}" \
    BASE_IMAGE_TAG="${BASE_IMAGE_TAG}" \
    SSH_USER="${SSH_USER}" \
    SSH_USER_SHELL="${SSH_USER_SHELL}" \
    RUNNING_IN_DOCKER="true"

RUN if [ ! -f "${SSH_USER_SHELL}" ]; then \
        SSH_USER_SHELL="/bin/ash"; \
    fi \
    apk update && \
    apk add openssh && \
    rm -rf /var/cache/apk/*

COPY lxfs/etc/ssh/ /etc/ssh/
COPY lxfs/tmp/docker-build /tmp/docker-build

RUN chmod +x /tmp/docker-build/conf-ssh.sh && \
    chmod +x /tmp/docker-build/conf-ssh-user.sh && \
    /tmp/docker-build/conf-ssh.sh && \
    /tmp/docker-build/conf-ssh-user.sh --username root && \
    /tmp/docker-build/conf-ssh-user.sh --username "${SSH_USER}" --user-shell "${SSH_USER_SHELL}"

FROM scratch as export_keys
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

FROM build as sshd

WORKDIR /root
COPY entrypoint.sh entrypoint.sh
EXPOSE 22
ENTRYPOINT /entrypoint.sh
