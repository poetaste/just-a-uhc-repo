# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 desktop xdg

DESCRIPTION="An offline collection of Homestuck and its related works"
HOMEPAGE="https://github.com/GiovanH/unofficial-homestuck-collection"
EGIT_REPO_URI="https://github.com/GiovanH/unofficial-homestuck-collection.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

BDEPEND="
	>=net-libs/nodejs-18
	sys-apps/yarn
	dev-python/setuptools
	dev-build/make
	app-arch/tar
"

RDEPEND="
	!games-misc/unofficial-homestuck-collection-bin
	media-libs/alsa-lib
	app-accessibility/at-spi2-core
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	x11-libs/cairo
	media-libs/mesa
	x11-libs/pango
	net-print/cups
	x11-libs/gdk-pixbuf:2
	x11-misc/shared-mime-info
	dev-libs/expat
	sys-libs/libxcrypt[compat]
	x11-libs/libdrm
	sys-apps/dbus
"

RESTRICT="strip"

S="${WORKDIR}/${P}"

src_prepare() {
	default

	einfo "Relaxing Node.js version requirement in package.json"
	sed -i 's/"node": "18\.20"/"node": ">=18.20"/' package.json || die "failed to patch package.json"
}

src_compile() {
	export SHARP_IGNORE_GLOBAL_LIBVIPS=true

	cd "${S}" || die

	yarn install --frozen-lockfile --ignore-engines || die "yarn install failed"

	if [[ -f Makefile ]]; then
		emake build || die "emake build failed"
	else
		yarn electron:build --ignore-engines || die "yarn electron:build failed"
	fi
}

src_install() {
	local dest="/usr/lib/${PN}"
	local builddir="${S}/dist_electron/linux-unpacked"

	if [[ ! -d "${builddir}" ]]; then
		die "Build directory ${builddir} not found"
	fi

	insinto "${dest}"
	doins -r "${builddir}"/*

	fperms +x "${dest}/${PN}"

	if [[ -f "${builddir}/LICENSES.chromium.html" ]]; then
		dosym "${dest}/LICENSES.chromium.html" "/usr/share/licenses/${PN}/LICENSES.chromium.html"
	fi
	if [[ -f "${builddir}/LICENSE.electron.txt" ]]; then
		dosym "${dest}/LICENSE.electron.txt" "/usr/share/licenses/${PN}/LICENSE.electron.txt"
	fi

	cat > "${T}/${PN}" <<-EOF || die
		#!/bin/sh
		exec /usr/lib/${PN}/${PN} "\$@"
	EOF
	dobin "${T}/${PN}"

	local iconpath="${builddir}/resources/icons"
	if [[ ! -d "${iconpath}" ]]; then
		iconpath="${S}/build/icons"
	fi

	if [[ -d "${iconpath}" ]]; then
		local size
		for size in 16 24 32 48 64 128 256 512 1024; do
			if [[ -f "${iconpath}/${size}x${size}.png" ]]; then
				newicon -s "${size}" "${iconpath}/${size}x${size}.png" "${PN}.png"
			fi
		done
	fi

	if [[ -f "${S}/${PN}.desktop" ]]; then
		domenu "${S}/${PN}.desktop"
	else
		make_desktop_entry \
			"${PN}" \
			"Unofficial Homestuck Collection" \
			"${PN}" \
			"Game;AdventureGame" \
			"Comment=Unofficial Reader For Homestuck"
	fi
}
