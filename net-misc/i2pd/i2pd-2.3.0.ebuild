# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils systemd user

DESCRIPTION="A C++ daemon for accessing the I2P anonymous network"
HOMEPAGE="https://github.com/PrivacySolutions/i2pd"
SRC_URI="https://bitbucket.org/orignal/${PN}/get/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="cpu_flags_x86_aes i2p-hardening static"

RDEPEND="!static? ( >=dev-libs/boost-1.46[threads] )
	!static? ( dev-libs/crypto++ )"
DEPEND="${RDEPEND}
	static? ( >=dev-libs/boost-1.46[static-libs,threads] )
	static? ( dev-libs/crypto++[static-libs] )
	>=dev-util/cmake-2.8.5
	i2p-hardening? ( >=sys-devel/gcc-4.6 )
	|| ( >=sys-devel/gcc-4.6 >=sys-devel/clang-3.3 )
	dev-libs/openssl[-bindist]"

I2PD_USER="${I2PD_USER:-i2pd}"
I2PD_GROUP="${I2PD_GROUP:-i2pd}"

S="${WORKDIR}/orignal-i2pd-96fd6b72910c/"
#CMAKE_USE_DIR="${S}/build"

#src_configure() {
#	mycmakeargs=(
#		$(cmake-utils_use_with cpu_flags_x86_aes AESNI)
#		$(cmake-utils_use_with i2p-hardening HARDENING)
#		$(cmake-utils_use_with static STATIC)
#		-DWITH_LIBRARY=OFF
#		-DWITH_BINARY=ON
#	)
#	cmake-utils_src_configure
#}

src_install() {
#	cmake-utils_src_install
	dodoc README.md
	doman "${FILESDIR}/${PN}.1"
	keepdir /var/lib/i2pd/
	fowners "${I2PD_USER}:${I2PD_GROUP}" /var/lib/i2pd/
	fperms 700 /var/lib/i2pd/
	insinto /etc/
	doins "${FILESDIR}/${PN}.conf"
	fowners "${I2PD_USER}:${I2PD_GROUP}" "/etc/${PN}.conf"
	fperms 600 "/etc/${PN}.conf"
	dodir /usr/share/i2pd
	cp -R "${S}/certificates" "${D}/var/lib/i2pd" || die "Install failed!"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"
	doenvd "${FILESDIR}/99${PN}"
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate" "${PN}"
}

pkg_setup() {
	enewgroup "${I2PD_GROUP}"
	enewuser "${I2PD_USER}" -1 -1 "/var/lib/run/${PN}" "${I2PD_GROUP}"
}