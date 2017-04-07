# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools-utils eutils versionator user

MY_PV=$(get_version_component_range 1-2)

DESCRIPTION="An implementation of the Infinote protocol written in GObject-based C"
HOMEPAGE="https://gobby.github.io/"
SRC_URI="https://github.com/gobby/${PN}/archive/${PV}.zip -> ${P}.zip
http://releases.0x539.de/${PN}/${P}.tar.gz"
LICENSE="LGPL-2.1"
SLOT="0.7"
KEYWORDS="~amd64 ~x86"
IUSE="-avahi doc gtk +gtk3 server static-libs"

RDEPEND="dev-libs/glib:2
	dev-libs/libxml2
	net-libs/gnutls
	virtual/pam
	virtual/gsasl
	avahi? ( net-dns/avahi )
	gtk3? ( x11-libs/gtk+:3 )
	gtk? ( x11-libs/gtk+:2 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	sys-devel/gettext
	doc? ( dev-util/gtk-doc )"

DOCS=( AUTHORS ChangeLog NEWS README.md TODO )

pkg_setup() {
	if use server ; then
		enewgroup infinote 100
		enewuser infinote 100 /bin/bash /var/lib/infinote infinote
	fi
	#
	if use gtk && use gtk3; then
		eerror "You can select either gtk or gtk3, but not both at the same time" && die
	fi
}

src_configure() {
	local myeconfargs=(
		$(use_enable doc gtk-doc)
		$(use_with gtk inftextgtk)
		$(use_with gtk infgtk)
		$(use_with gtk)
		$(use_with gtk3)
		$(use_with server infinoted)
		$(use_with avahi)
		$(use_with avahi libdaemon)
	)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install

	if use server ; then
		newinitd "${FILESDIR}/infinoted.initd" infinoted
		newconfd "${FILESDIR}/infinoted.confd" infinoted

		keepdir /var/lib/infinote
		fowners infinote:infinote /var/lib/infinote
		fperms 770 /var/lib/infinote

		dosym /usr/bin/infinoted-${MY_PV} /usr/bin/infinoted

		elog "Add local users who should have local access to the documents"
		elog "created by infinoted to the infinote group."
		elog "The documents are saved in /var/lib/infinote per default."
	fi
}