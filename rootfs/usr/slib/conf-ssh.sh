#!/bin/sh

debug_conf_script= ;
no_generate_host_keys= ;

show_usage() {
    echo "Usage $0 [FLAGS]" && \
    echo "Flags: " && \
    echo "    -h, --help           - Show this usage information." && \
    echo "    -d, --debug          - Run script in a debug context." && \
    echo "    --no-host-ssh-keygen - Do not generate host keys during docker build."
}

run() {
    # Create custom directory for user-defined runtime authorized-keys atacahed via docker volume
    if [ ! -d "/etc/ssh/authorized_keys.d/" ];
    then
        if [ -z "${debug_conf_script}" ]; then echo "Creating /etc/ssh/authorized_keys.d/ directory..."; fi
        mkdir -p "/etc/ssh/authorized_keys.d/";
    fi

    if [ ! -d "/etc/ssh/ssh_config.d/" ];
    then
        if [ -z "${debug_conf_script}" ]; then echo "Creating /etc/ssh/ssh_config.d/ directory..."; fi
        mkdir -p "/etc/ssh/ssh_config.d/";
    fi

    if [ ! -d "/etc/ssh/sshd_config.d/" ];
    then
        if [ -z "${debug_conf_script}" ]; then echo "Creating /etc/ssh/sshd_config.d/ directory..."; fi
        mkdir -p "/etc/ssh/sshd_config.d/";
    fi

    # Generate new host keys for each build, eat stderr

    if [ -z "${no_generate_host_keys}" ];
    then
        if [ -z "${debug_conf_script}" ]; then echo "Generating new host ssh keys with' ssh-keygen -A'..."; fi
        ssh-keygen -A;
    fi
}

main() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -h | --help)
                show_usage;
                exit 0;
            ;;
            --no-host-ssh-keygen)
                no_generate_host_keys="true";
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
    echo "no_generate_host_keys=${no_generate_host_keys}"
fi

run
