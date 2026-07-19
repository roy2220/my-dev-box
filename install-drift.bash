set -euo pipefail

Linux() {
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
		tar xz --to-stdout drift |
		install -D /dev/stdin "${HOME}/.local/bin/drift"
}

Darwin() {
	case $(arch) in
	x86_64)
		ARCH=amd64
		;;
	arm64)
		ARCH=arm64
		;;
	*)
		echo 'unknown architecture' 1>&2
		exit 1
		;;
	esac

	DOWNLOAD_URL=$(
		curl --retry 3 -SsLf https://api.github.com/repos/phlx0/drift/releases/latest |
			perl -nle 'print $1 while /"browser_download_url":\s?"([^"]+)"/g' |
			grep -F -m 1 "/drift_darwin_${ARCH}.tar.gz"
	)

	mkdir -p "${HOME}/.local/bin"
	curl --retry 3 -SsLf "${DOWNLOAD_URL}" |
		tar xz -O drift >"${HOME}/.local/bin/drift"
	chmod +x "${HOME}/.local/bin/drift"
}

eval "$(uname -s)"
