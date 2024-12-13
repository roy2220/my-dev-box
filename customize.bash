set -euxo pipefail

# proxy
#export http_proxy=http://host.docker.internal:7890 \
#	HTTP_PROXY=http://host.docker.internal:7890 \
#	https_proxy=http://host.docker.internal:7890 \
#	HTTPS_PROXY=http://host.docker.internal:7890 \
#	GOPROXY=https://goproxy.cn,direct

# rpm packages
dnf makecache
dnf upgrade --assumeyes
# dnf install --assumeyes 'dnf-command(config-manager)' 'dnf-command(copr)'
# dnf makecache
dnf remove --assumeyes \
	vi
dnf autoremove --assumeyes
dnf install --assumeyes \
	glibc-langpack-en findutils procps-ng psmisc iproute iputils iptables traceroute bind-utils lsof tcpdump diffutils patch unzip fuse3 cronie \
	stow nmap-ncat socat lsyncd jq fd-find \
	zsh vim tmux \
	gcc gcc-c++ python-devel python-pip nodejs-npm sqlite \
	git make cmake the_silver_searcher cloc ShellCheck \
	protobuf-compiler protobuf-devel \
	autoconf automake `# for ctags`
dnf clean all

# python packages
pip install pip-autoremove sshuttle pyyaml pure-protobuf bashlex \
	git+https://github.com/largecats/sparksql-formatter.git

# dotfiles
find ~ -mindepth 1 -delete
mkdir ~/.config
git clone --depth 1 --recurse-submodules https://github.com/roy2220/dotfiles.git ~/.files
# shellcheck disable=SC2011
ls -1 ~/.files | xargs stow --dir ~/.files

# cli binaries
bash ~/.local/src/1-install-rclone.bash
base64 --decode </run/secrets/gdfuse_service_account_data >/tmp/gdrive_service_account.json
mkdir /gdrive
~/.local/bin/_rclone --config=/dev/null mount --daemon \
	:drive: \
	--drive-scope=drive \
	--drive-service-account-file=/tmp/gdrive_service_account.json \
	/gdrive
# shellcheck disable=SC2016
find ~/.local/src -mindepth 1 -maxdepth 1 -type f ! -name '1-install-rclone.bash' -name '*-install-*.bash' -print0 |
	sort --zero-terminated | xargs --null --max-lines=1 \
	-- bash -c 'echo "${@@Q}"; "${@}" || exit 255' \
	-- bash
PATH=/usr/local/go/bin:${PATH}

# tmux plugins
~/.tmux/plugins/tpm/bin/install_plugins

# zsh plugins
TERM=xterm-256color zsh -c \
	'eval "$(sed -n '\''/^source ~\/\.zplug\/init\.zsh$/,/^zplug load$/p'\'' ~/.zshrc)" && zplug install' \
	</dev/null

# vim plugins
vim +PlugInstall +qall <<<$'\n\n\n'
vim +PlugInstall +qall <<<$'\n\n\n'
vim +PlugInstall +qall <<<$'\n\n\n'

# cleanup
rm --recursive --force "$(go env GOCACHE)"
rm --recursive --force "$(go env GOMODCACHE)"
rm --recursive --force "$(pip cache dir)"
rm --recursive --force "$(npm config get cache)"
find /tmp -mindepth 1 -delete
