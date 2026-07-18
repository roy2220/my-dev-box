set -euo pipefail

case $(arch) in
x86_64)
	ARCH=amd64
	;;
aarch64)
	ARCH=arm64
	;;
*)
	echo 'unknown architecture' 1>&2
	exit 1
	;;
esac

DOWNLOAD_URL=$(
	curl --retry 3 -SsLf https://api.github.com/repos/phlx0/drift/releases/latest |
		grep --perl-regexp --only-matching '(?<="browser_download_url":\s?")[^"]+(?=")' |
		grep --fixed-strings --max-count=1 "/drift_linux_${ARCH}.tar.gz"
)

curl --retry 3 -SsLf "${DOWNLOAD_URL}" |
	tar xz --wildcards drift --to-stdout |
	install -D /dev/stdin "${HOME}/.local/bin/drift"
