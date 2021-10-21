#!/bin/sh

user="root";
user_shell="/bin/zsh";
user_shell_fallback="/bin/ash"
home_dir="/root";
no_generate_user_keys= ;
debug_conf_script= ;

show_usage() {
    echo "Usage $0 [FLAGS]" && \
    echo "Flags: " && \
    echo "    -h, --help          - Show this usage information." && \
    echo "    -u, --username [\$USER] - Run configuration script with the context of \$USER. If not specified, defaults to root." && \
    echo "    -d, --debug         - Run configuration script in debug mode." && \
    echo "    --user-shell        - Create the new \$USER with the specified shell. Ignored when \$USER is root" && \
    echo "    --no-user-keygen    - Do not create user ssh keys during docker build."
}

run() {
    if [ "${user}" != "root" ];
    then
        # If not using zsh, bash, or fish alpine variant, fallback to built-in ash shell
        if [ ! -x "${user_shell}" ];
        then
            echo "'${user_shell} not found. Using fallback shell: '${user_shell_fallback}";
            user_shell="${user_shell_fallback}";
        fi

        # Create the new user passwordless with specified shell. Create home directory at /home/{user}, assign ownership to user.
        if [ ! -d "${home_dir}" ];
        then
            adduser -D -g "${user}" -s "${user_shell}" "${user}";
            mkdir -p "${home_dir}";
            chown -R "${user}:${user}" "${home_dir}";
        fi

    fi

    # Create user .ssh directory if not exists, assign ownership to user.
    if [ ! -d "${home_dir}/.ssh" ];
    then
        mkdir -p "${home_dir}/.ssh";
        chown -R "${user}:${user}" "${home_dir}/.ssh";
    fi


    if [ -z "${no_generate_user_keys}" ];
    then
        ## Fixed keysize for ed25519
        ssh-keygen -q -f "${home_dir}/.ssh/id_ed25519" -t ed25519 -m RFC4716 -N "${user}" -C "$user";
        ## Keysizes: 2048, 3072, 4096
        ssh-keygen -q -b 4096 -f "${home_dir}/.ssh/id_rsa" -t rsa -m RFC4716 -N "${user}" -C "$user";
        ## Keysizes: 256, 384, 521
        ssh-keygen -q -b 521 -f "${home_dir}/.ssh/id_ecdsa" -t ecdsa -m RFC4716 -N "${user}" -C "$user";

        {
            cat "${home_dir}/.ssh/id_ed25519.pub";
            cat "${home_dir}/.ssh/id_rsa.pub";
            cat "${home_dir}/.ssh/id_ecdsa.pub";
        } >> /etc/ssh/authorized_keys;
    fi
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h | --help)
                show_usage;
                exit 0;
            ;;
            -u | --username)
                if [ "$2" != "root" ]; then
                    user="$2";
                    home_dir="/home/${user}";
                fi
            ;;
            --user-shell)
                user_shell="$2";
            ;;
            --no-user-ssh-keygen)
                no_generate_user_keys="true"
            ;;
            -d | --debug)
                debug_conf_script="true";
            ;;
        esac
        shift
    done
}

main "$@"

if [ "${debug_conf_script}" == "true" ];
then
    echo "Running user ssh configuration script in debug mode. Variable dump: " && \
    echo "user=${user}" && \
    echo "user_shell=${user_shell}" && \
    echo "user_shell_fallback=${user_shell_fallback}" && \
    echo "home_dir=${home_dir}" && \
    echo "no_generate_user_keys=${no_generate_user_keys}"
fi

run

exit 0;
