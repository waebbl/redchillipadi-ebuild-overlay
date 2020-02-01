# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_5,3_6,3_7} )
CMAKE_MAKEFILE_GENERATOR="emake"

inherit cmake-utils flag-o-matic python-single-r1

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"
SRC_URI="https://github.com/AcademySoftwareFoundation/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="openvdb_abi_3 openvdb_abi_4 openvdb_abi_5 openvdb_abi_6 openvdb_abi_7 doc python test"
REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	|| ( openvdb_abi_3 openvdb_abi_4 openvdb_abi_5 openvdb_abi_6 openvdb_abi_7 )
"

RDEPEND="
	>=dev-libs/boost-1.62:=[python?,${PYTHON_USEDEP}]
	>=dev-libs/c-blosc-1.5.0
	dev-libs/jemalloc
	dev-libs/log4cplus
	media-libs/glfw:=
	media-libs/openexr:=
	sys-libs/zlib:=
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	python? (
		${PYTHON_DEPS}
		dev-python/numpy[${PYTHON_USEDEP}]
	)"

DEPEND="${RDEPEND}
	>=dev-util/cmake-3.16.2-r1
	dev-cpp/tbb
	virtual/pkgconfig
	doc? ( app-doc/doxygen[latex] )
	test? ( dev-util/cppunit )"

PATCHES=(
	"${FILESDIR}/${PN}-6.2.1-fix-multilib-header-source.patch"
	"${FILESDIR}/${PN}-6.2.1-find-boost_python.patch"
)
#"${FILESDIR}/${PN}-6.2.1-use-gnuinstalldirs.patch"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local myprefix="${EPREFIX}/usr/"

	if use openvdb_abi_3; then
		local openvdb_version=3
	elif use openvdb_abi_4; then
		local openvdb_version=4
	elif use openvdb_abi_5; then
		local openvdb_version=5
	elif use openvdb_abi_6; then
		local openvdb_version=6
	elif use openvdb_abi_7; then
		local openvdb_version=7
	else
		die "Openvdb ABI version not specified"
	fi

	local mycmakeargs=(
		-DBLOSC_LOCATION="${myprefix}"
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
		-DGLFW3_LOCATION="${myprefix}"
		-DOPENVDB_ABI_VERSION_NUMBER="${openvdb_version}"
		-DOPENVDB_BUILD_DOCS=$(usex doc)
		-DOPENVDB_BUILD_PYTHON_MODULE=$(usex python)
		-DOPENVDB_BUILD_UNITTESTS=$(usex test)
		-DOPENVDB_ENABLE_RPATH=OFF
		-DTBB_LOCATION="${myprefix}"
		-DUSE_GLFW3=ON
		-DCHOST="${CHOST}"
	)

	use python && mycmakeargs+=( -DPYOPENVDB_INSTALL_DIRECTORY="$(python_get_sitedir)" )
	use test && mycmakeargs+=( -DCPPUNIT_LOCATION="${myprefix}" )

	cmake-utils_src_configure
}
