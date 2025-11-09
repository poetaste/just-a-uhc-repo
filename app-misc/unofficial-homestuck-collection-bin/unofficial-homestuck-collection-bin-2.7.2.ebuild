# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

_pkgbase="unofficial-homestuck-collection"

DESCRIPTION="The Unofficial Homestuck Collection (prebuilt binary)"
HOMEPAGE="https://homestuck.giovanh.com/unofficial-homestuck-collection/"
SRC_URI="
    https://github.com/GiovanH/${_pkgbase}/releases/download/v${PV}/${_pkgbase}-${PV}.tar.gz
    -> ${P}.tar.gz
"

LICENSE="GPL-3 chrome electron"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="strip mirror"

DEPEND="
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
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${_pkgbase}-${PV}"

src_prepare() {
    default

    cat > "${T}/${_pkgbase}.desktop" <<EOF
[Desktop Entry]
Name=Unofficial Homestuck Collection
Comment=${DESCRIPTION}
Exec=/usr/bin/${_pkgbase}
Icon=${_pkgbase}
Terminal=false
Type=Application
Categories=Game;
EOF
}

src_install() {
    insinto /usr/lib/${_pkgbase}
    doins -r *

    fperms +x /usr/lib/${_pkgbase}/${_pkgbase}

    dosym /usr/lib/${_pkgbase}/${_pkgbase} /usr/bin/${_pkgbase}

    local size
    for size in 16 24 32 48 64 128 256 512 1024; do
        insinto /usr/share/icons/hicolor/${size}x${size}/apps
        newins "${FILESDIR}/${size}x${size}.png" ${_pkgbase}.png
    done

    insinto /usr/share/applications
    doins "${T}/${_pkgbase}.desktop"

    dodir /usr/share/licenses/${PN}
    dosym /usr/lib/${_pkgbase}/LICENSES.chromium.html \
        /usr/share/licenses/${PN}/LICENSES.chromium.html
    dosym /usr/lib/${_pkgbase}/LICENSE.electron.txt \
        /usr/share/licenses/${PN}/LICENSE.electron.txt
}
