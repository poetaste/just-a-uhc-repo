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

# Build-time / tool deps
BDEPEND="
	>=net-libs/nodejs-18
	sys-apps/yarn
	dev-python/setuptools
	dev-build/make
	app-arch/tar
"

# Runtime deps
RDEPEND="
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

# Fix: Use ${P} which expands to ${PN}-${PV}
S="${WORKDIR}/${P}"

src_prepare() {
	default

	# Patch package.json to allow newer Node.js versions
	einfo "Relaxing Node.js version requirement in package.json"
	sed -i 's/"node": "18\.20"/"node": ">=18.20"/' package.json || die "failed to patch package.json"
}

src_compile() {
	# Use a stable env for sharp libvips handling
	export SHARP_IGNORE_GLOBAL_LIBVIPS=true

	# Ensure we're in the project dir
	cd "${S}" || die

	# Install node deps using yarn (ignore engine version checks)
	yarn install --frozen-lockfile --ignore-engines || die "yarn install failed"

	# Prefer existing Makefile -> make build, otherwise run electron build target
	if [[ -f Makefile ]]; then
		emake build || die "emake build failed"
	else
		yarn electron:build --ignore-engines || die "yarn electron:build failed"
	fi
}

src_install() {
	local dest="/usr/lib/${PN}"
	local builddir="${S}/dist_electron/linux-unpacked"

	# Ensure build output exists
	if [[ ! -d "${builddir}" ]]; then
		die "Build directory ${builddir} not found"
	fi

	# Create destination dir and copy entire directory tree
	insinto "${dest}"
	doins -r "${builddir}"/*

	# Make the main executable actually executable
	fperms +x "${dest}/${PN}"

	# Install licenses
	if [[ -f "${builddir}/LICENSES.chromium.html" ]]; then
		dosym "${dest}/LICENSES.chromium.html" "/usr/share/licenses/${PN}/LICENSES.chromium.html"
	fi
	if [[ -f "${builddir}/LICENSE.electron.txt" ]]; then
		dosym "${dest}/LICENSE.electron.txt" "/usr/share/licenses/${PN}/LICENSE.electron.txt"
	fi

	# Create wrapper script
	cat > "${T}/${PN}" <<-EOF || die
		#!/bin/sh
		exec /usr/lib/${PN}/${PN} "\$@"
	EOF
	dobin "${T}/${PN}"

	# Install icons
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

	# Install desktop file
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

pkg_postinst() {
	xdg_pkg_postinst

	elog "The Unofficial Homestuck Collection requires the Asset Pack V2"
	elog "to function properly. You will need to download it separately."
	elog ""
	elog "Due to legal issues, asset pack availability may vary."
	elog "Check the project's GitHub page for current information:"
	elog "  https://github.com/GiovanH/unofficial-homestuck-collection"
	elog ""
	elog "On first run, you'll be prompted to select the location of"
	elog "your extracted Asset Pack V2 folder."
}
