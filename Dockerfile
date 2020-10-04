FROM fedora:32

RUN # 8ba09eed-f2ad-411e-b107-aeed36b8d73a

RUN ( \
        dnf makecache \
        && dnf upgrade --assumeyes \
        && dnf install --assumeyes 'dnf-command(config-manager)' 'dnf-command(copr)' \
        && dnf copr enable --assumeyes jgoguen/universal-ctags \
        && dnf makecache \
        && dnf remove --assumeyes \
               vi \
        && dnf autoremove --assumeyes \
        && dnf install --assumeyes \
               zsh tmux vim \
               gcc gcc-c++ golang python3-pip node npm sqlite \
               git make cmake universal-ctags the_silver_searcher cloc ydiff \
               stow gnupg pinentry proxychains-ng sshuttle \
               findutils procps-ng psmisc iproute iputils traceroute nmap-ncat socat bind-utils lsof tcpdump lsyncd \
               glibc-langpack-en python-devel \
        && dnf copr disable jgoguen/universal-ctags \
        && dnf clean all \
    ) && ( \
        find "${HOME}" -mindepth 1 -name '*' -delete \
        && mkdir "${HOME}/.config" \
        && git clone --depth 1 --recurse-submodules https://github.com/roy2220/dotfiles.git "${HOME}/.files" \
        && stow --dir "${HOME}/.files" $(ls "${HOME}/.files") \
    ) && ( \
        (cd "${HOME}/.local/bin"; find "${HOME}/.local/src" -mindepth 1 -maxdepth 1 -type f -name 'get-*.bash' -exec bash {} \;) \
        && tmux -c ~/.tmux/plugins/tpm/bin/install_plugins \
        && LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 TERM=xterm-256color zsh -c \
           'eval "$(sed -n '\''/^source ~\/\.zplug\/init\.zsh$/,/^zplug load$/p'\'' ~/.zshrc)" && zplug install' \
           < /dev/null \
        && yes '' | vim +PlugInstall +qall \
        && go clean -cache -testcache -modcache \
        && npm cache clean --force \
        && rm --recursive --force ~/.cache/pip \
    )

ENV HOST=my-dev-box \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Asia/Shanghai

CMD ["/usr/bin/zsh", "--login"]
WORKDIR /root
