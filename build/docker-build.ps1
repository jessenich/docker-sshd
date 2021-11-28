docker build . `
    --target final `
    --build-arg "BASE_IMAGE=jessenich91/alpine-zsh" `
    --build-arg "BASE_IMAGE_TAG=glibc-latest" `
    --build-arg "SSH_USER=jesse" `
    --build-arg "SSH_USER_SHELL=/bin/zsh" `
    -f Dockerfile `
    -t jessenich91/alpine-sshd:glibc-latest `
    -t jessenich91/alpine-sshd:glibc-1.0.0-alpha1

docker build . `
    --target artifact `
    --output "type=local,dest=$(Get-Location)/out/" `
    --build-arg "BASE_IMAGE=jessenich91/alpine-zsh" `
    --build-arg "BASE_IMAGE_TAG=glibc-latest" `
    --build-arg "SSH_USER=jesse" `
    --build-arg "SSH_USER_SHELL=/bin/zsh" `
    -f Dockerfile