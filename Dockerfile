ARG BASE_IMAGE_VARIANT="${BASE_IMAGE_VARIANT:-glibc-latest}" \
    SSH_USER="${SSH_USER:-sshuser}" \
    USER_KEYS_DIR= \
    ROOT_KEYS_DIR= \
    SSHD_KEYS_DIR= \
    EXPORT_USER_KEYS_DIR= \
    EXPORT_ROOT_KEYS_DIR= \
    EXPORT_SSHD_KEYS_DIR=

FROM jessenich91/alpine-zsh:"${VARIANT}" as export

ENV USER_KEYS_DIR="${USER_KEYS_DIR:-/home/${SSH_USER}/.ssh}" \
    ROOT_KEYS_DIR="${ROOT_KEYS_DIR:-/root/.ssh}" \
    SSHD_KEYS_DIR="${SSHD_KEYS_DIR:-/etc/ssh}" \
    EXPORT_USER_KEYS_DIR="${EXPORT_USER_KEYS_DIR:-/dockerhost-sshkeys-vol/$SSH_USER}" \
    EXPORT_ROOT_KEYS_DIR="${EXPORT_ROOT_KEYS_DIR:-/dockerhost-sshkeys-vol/root}" \
    EXPORT_SSHD_KEYS_DIR="${EXPORT_SSHD_KEYS_DIR:-/dockerhost-sshkeys-vol/sshd}" \
    SSH_USER="${SSH_USER:-sshuser}"

USER root
RUN if [ "${SSH_USER}" != "root" ]; then \
        apk add --update --no-cache openssh; \
        if [ ! -d "/etc/ssh/authorized_keys.d/" ]; then \
            mkdir "/etc/ssh/authorized_keys.d/"; \
        fi \
        adduser -D -g "${SSH_USER}" -s /bin/zsh "${SSH_USER}" && \
        if [ ! -d "/home/${SSH_USER}" ]; then \
            mkdir "/home/${SSH_USER}"; \
        fi \
        chown -R "${SSH_USER}:${SSH_USER}" "/home/${SSH_USER}"; \
        if [ ! -d "/home/${SSH_USER}/.ssh" ]; then \
            mkdir "/home/${SSH_USER}/.ssh"; \
        fi \
        chown -R "${SSH_USER}:${SSH_USER}" "/home/${SSH_USER}/.ssh"; \
    fi \
    ssh-keygen -A;

USER ${SSH_USER}
RUN if [ "${SSH_USER}" != "root" ]; then \
        ## Fixed keysize for ed25519
        ssh-keygen -q -f "/home/${SSH_USER}/.ssh/id_ed25519" -t ed25519 -m RFC4716 -N "${SSH_USER}"; \
        ## Keysizes: 2048, 3072, 4096
        ssh-keygen -q -b 4096 -f "/home/${SSH_USER}/.ssh/id_rsa" -t rsa -m RFC4716 -N "${SSH_USER}"; \
        ## Keysizes: 256, 384, 521
        ssh-keygen -q -b 521 -f "/home/${SSH_USER}/.ssh/id_ecdsa" -t ecdsa -m RFC4716 -N "${SSH_USER}"; \
        echo $(cat "/home/${SSH_USER}/.ssh/id_ed25519.pub") | tee /etc/ssh/authorized_keys; \
        echo $(cat "/home/${SSH_USER}/.ssh/id_rsa.pub") | tee /etc/ssh/authorized_keys; \
        echo $(cat "/home/${SSH_USER}/.ssh/id_ecdsa.pub") | tee /etc/ssh/authorized_keys; \
    fi

FROM exports as final

COPY --from=container "${USER_KEYS_DIR}/id_ed25519"     "${EXPORT_USER_KEYS_DIR}/id_ed_25519"
COPY --from=contianer "${USER_KEYS_DIR}/id_ed25519.pub" "${EXPORT_USER_KEYS_DIR}/id_ed_25519.pub"
COPY --from=container "${USER_KEYS_DIR}/id_rsa"         "${EXPORT_USER_KEYS_DIR}/id_rsa"
COPY --from=container "${USER_KEYS_DIR}/id_rsa.pub"     "${EXPORT_USER_KEYS_DIR}/id_rsa.pub"
COPY --from=container "${USER_KEYS_DIR}/id_ecdsa"       "${EXPORT_USER_KEYS_DIR}/id_ecdsa"
COPY --from=container "${USER_KEYS_DIR}/id_ecdsa.pub"   "${EXPORT_USER_KEYS_DIR}/id_ecdsa.pub"

COPY --from=container "${ROOT_KEYS_DIR}/id_ed25519"     "${EXPORT_ROOT_KEYS_DIR}/id_ed_25519"
COPY --from=contianer "${ROOT_KEYS_DIR}/id_ed25519.pub" "${EXPORT_ROOT_KEYS_DIR}/id_ed_25519.pub"
COPY --from=container "${ROOT_KEYS_DIR}/id_rsa"         "${EXPORT_ROOT_KEYS_DIR}/id_rsa"
COPY --from=container "${ROOT_KEYS_DIR}/id_rsa.pub"     "${EXPORT_ROOT_KEYS_DIR}/id_rsa.pub"
COPY --from=container "${ROOT_KEYS_DIR}/id_ecdsa"       "${EXPORT_ROOT_KEYS_DIR}/id_ecdsa"
COPY --from=container "${ROOT_KEYS_DIR}/id_ecdsa.pub"   "${EXPORT_ROOT_KEYS_DIR}/id_ecdsa.pub"

COPY --from=container "${SSHD_KEYS_DIR}/id_ed25519"     "${EXPORT_SSHD_KEYS_DIR}/id_ed_25519"
COPY --from=contianer "${SSHD_KEYS_DIR}/id_ed25519.pub" "${EXPORT_SSHD_KEYS_DIR}/id_ed_25519.pub"
COPY --from=container "${SSHD_KEYS_DIR}/id_rsa"         "${EXPORT_SSHD_KEYS_DIR}/id_rsa"
COPY --from=container "${SSHD_KEYS_DIR}/id_rsa.pub"     "${EXPORT_SSHD_KEYS_DIR}/id_rsa.pub"
COPY --from=container "${SSHD_KEYS_DIR}/id_ecdsa"       "${EXPORT_SSHD_KEYS_DIR}/id_ecdsa"
COPY --from=container "${SSHD_KEYS_DIR}/id_ecdsa.pub"   "${EXPORT_SSHD_KEYS_DIR}/id_ecdsa.pub"

COPY resources/etc/ssh/ /etc/ssh/

VOLUME /etc/ssh/authorized_keys.d/
VOLUME /etc/ssh/sshd_config.d/

EXPOSE 22

CMD /bin/zsh -c /usr/sbin/sshd -D -e "$@"