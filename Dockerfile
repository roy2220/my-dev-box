FROM fedora:33

SHELL ["/usr/bin/bash", "-euxo", "pipefail", "-c"]

RUN `#===== rpm packages ==============================`; \
    dnf makecache; \
    dnf upgrade --assumeyes; \
    dnf install --assumeyes 'dnf-command(config-manager)' 'dnf-command(copr)'; \
    dnf copr enable --assumeyes jgoguen/universal-ctags; \
    dnf makecache; \
    dnf remove --assumeyes \
        vi; \
    dnf autoremove --assumeyes; \
    dnf install --assumeyes \
        glibc-langpack-en findutils procps-ng psmisc iproute iputils iptables traceroute bind-utils lsof tcpdump \
        stow pinentry proxychains-ng nmap-ncat socat lsyncd \
        tmux zsh vim \
        gcc gcc-c++ golang python-devel python-pip nodejs npm sqlite \
        git make cmake universal-ctags the_silver_searcher cloc; \
    dnf copr disable jgoguen/universal-ctags; \
    dnf clean all; \
    `#===== python packages ===========================`; \
    pip install pip-autoremove ydiff sshuttle pyyaml; \
    `#===== node packages ===========================`; \
    npm install -g fx; \
    `#===== dotfiles ==================================`; \
    find ~ -mindepth 1 -name '*' -delete; \
    mkdir ~/.config; \
    git clone --depth 1 --recurse-submodules https://github.com/roy2220/dotfiles.git ~/.files; \
    stow --dir ~/.files $(ls ~/.files); \
    `#===== cli binaries ==============================`; \
    (cd ~/.local/bin; find ~/.local/src -mindepth 1 -maxdepth 1 -type f -name 'get-*.bash' -exec bash {} \;); \
    `#===== tmux plugins ==============================`; \
    ~/.tmux/plugins/tpm/bin/install_plugins; \
    `#===== zsh plugins ===============================`; \
    LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 TERM=xterm-256color zsh -c \
        'eval "$(sed -n '\''/^source ~\/\.zplug\/init\.zsh$/,/^zplug load$/p'\'' ~/.zshrc)" && zplug install' \
        < /dev/null; \
    `#===== vim plugins ===============================`; \
    vim -E -s -u ~/.vimrc +PlugInstall +qall || true; \
    `#===== cleanup ===================================`; \
    go clean -cache -testcache -modcache; \
    npm cache clean --force; \
    rm --recursive --force ~/.cache/pip

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Hongkong

CMD ["/usr/bin/zsh", "--login"]
WORKDIR /root
