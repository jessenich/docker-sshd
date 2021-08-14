#!/bin/sh

no_generate_host_keys= ;
no_generate_user_keys= ;
debug_conf_script= ;

run() {
    tag1="local-latest"
    tag2="local-sha$(git log -1 --pretty=%h)"

    docker buildx build \
        --target final \
        --cache-to "type=local,dest=$PWD/cache" \
        --build-arg "BASE_IMAGE=jessenich91/alpine-zsh" \
        --build-arg "BASE_IMAGE_TAG=glibc-latest" \
        --build-arg "SSH_USER=jesse" \
        --build-arg "SSH_USER_SHELL=/bin/zsh" \
        -f Dockerfile \
        -t "jessenich91/alpine-sshd:${tag1}" \
        -t "jessenich91/alpine-sshd:${tag2}" \
        --push \
        .

    docker buildx build \
        --target artifact \
        --cache-from "type=local,src=$PWD/cache" \
        --output "type=local,dest=$(PWD)/out/" \
        --build-arg "BASE_IMAGE=jessenich91/alpine-zsh" \
        --build-arg "BASE_IMAGE_TAG=glibc-latest" \
        --build-arg "SSH_USER=jesse" \
        --build-arg "SSH_USER_SHELL=/bin/zsh" \
        -t "jessenich91/alpine-sshd:artifact" \
        -f Dockerfile \
        .
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
                shift;
            ;;
            --no-user-ssh-keygen)
                no_generate_user_keys="true";
                shift;
            ;;
            -d | --debug)
                debug_conf_script="true";
                shift;
            ;;
        esac
        shift
    done
}

main "$@"

if [ "${debug_conf_script}" = "true" ];
then
    echo "Debug var dump:" && \
    echo "    no_generate_host_keys=${no_generate_host_keys}" && \
    echo "    no_generate_user_keys=${no_generate_user_keys}"
fi

run
