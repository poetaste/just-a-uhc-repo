# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 desktop xdg

DESCRIPTION="An offline collection of Homestuck and its related works"
HOMEPAGE="https://github.com/GiovanH/unofficial-homestuck-collection"
EGIT_REPO_URI="https://github.com/GiovanH/unofficial-homestuck-collection.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

BDEPEND="
    dev-util/yarn
    net-libs/nodejs
"

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
"

RESTRICT="strip"

src_prepare() {
    default

    # Ensure Node.js 22 is accepted
    sed -i 's/"node": "[0-9.]\+"/"node": "22"/' package.json || die

    # Add crc dependency
    yarn add crc --exact || die
}

src_compile() {
    export SHARP_IGNORE_GLOBAL_LIBVIPS=true

    yarn install --frozen-lockfile || die
    yarn build || die
}

src_install() {
    local dest="/usr/lib/${PN}"
    local builddir="dist_electron/linux-unpacked"

    # Install resources + locales
    insinto "${dest}"
    doins -r "${builddir}/resources" \
           "${builddir}/locales" || die

    # Install support files
    pushd "${builddir}" >/dev/null || die
    local f
    for f in *.asar *.so *.so.* *.pak *.json *.node; do
        [[ -f ${f} ]] && doins "${f}"
    done
    popd >/dev/null || die

    # Install executable(s)
    exeinto "${dest}"
    doexe "${builddir}/unofficial-homestuck-collection" || die

    for f in "${builddir}"/*.bin; do
        [[ -f $f ]] && doexe "$f"
    done

    # Wrapper script
    dobin "${FILESDIR}/unofficial-homestuck-collection" || die

    # Desktop entry
    make_desktop_entry \
        "${PN}" \
        "Unofficial Homestuck Collection" \
        "${PN}" \
        "AudioVideo;Graphics;Game" \
        "Comment=Unofficial Reader For Homestuck"

    # Icons are stored here in the build output:
    local iconpath="${builddir}/resources/icons"
    local size
    for size in 16 24 48 64 128 256 512 1024; do
        if [[ -f "${iconpath}/${size}x${size}.png" ]]; then
            newicon -s ${size} \
                "${iconpath}/${size}x${size}.png" \
                "${PN}.png"
        fi
    done
}
