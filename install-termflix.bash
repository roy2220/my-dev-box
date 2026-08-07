set -euo pipefail

Linux() {
	case $(arch) in
	x86_64)
		ARCH=x86_64
		;;
	aarch64)
		ARCH=aarch64
		;;
	*)
		echo 'unknown architecture' 1>&2
		exit 1
		;;
	esac

	DOWNLOAD_URL=$(
		curl --retry 3 -SsLf https://api.github.com/repos/paulrobello/termflix/releases/latest |
			grep --perl-regexp --only-matching '(?<="browser_download_url":\s?")[^"]+(?=")' |
			grep --fixed-strings --max-count=1 "/termflix-linux-${ARCH}"
	)

	curl --retry 3 -SsLf "${DOWNLOAD_URL}" |
		install -D /dev/stdin "${HOME}/.local/bin/termflix"
}

Darwin() {
	case $(arch) in
	x86_64)
		ARCH=x86_64
		;;
	arm64)
		ARCH=aarch64
		;;
	*)
		echo 'unknown architecture' 1>&2
		exit 1
		;;
	esac

	DOWNLOAD_URL=$(
		curl --retry 3 -SsLf https://api.github.com/repos/paulrobello/termflix/releases/latest |
			perl -nle 'print $1 while /"browser_download_url":\s?"([^"]+)"/g' |
			grep -F -m 1 "/termflix-macos-${ARCH}"
	)

	mkdir -p "${HOME}/.local/bin"
	curl --retry 3 -SsLf "${DOWNLOAD_URL}" --output "${HOME}/.local/bin/termflix"
	chmod +x "${HOME}/.local/bin/termflix"
}

eval "$(uname -s)"
