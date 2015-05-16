require 'formula'

class Sphinx < Formula
  homepage 'http://www.sphinxsearch.com'
  revision 1

  stable do
    url 'http://sphinxsearch.com/files/sphinx-2.2.9-release.tar.gz'
    sha1 '7ddde51bb1d428406acb278c615a2c2fda819daf'
  end

  devel do
    url 'http://sphinxsearch.com/files/sphinx-2.3.1-beta.tar.gz'
    sha1 '4717be87a38c9635aaebf062fa1fcf7d33593709'
  end

  head 'http://sphinxsearch.googlecode.com/svn/trunk/'

  bottle do
    sha256 "306dce352302755160f39c9826deb5e2e6273cfb6e5ab95e4a98c0ff2157a44b" => :yosemite
    sha256 "9556e1329b095ff1621a5ea73872de3706a8c6fc0c75fa9d14a9884b60fa60fd" => :mavericks
    sha256 "a71c292f774b8e449cf8775d21e7a6f41a85497e178ea6ba678b80a2f33b4ebd" => :mountain_lion
  end

  option 'with-mysql',      'Force compiling against MySQL'
  option 'with-postgresql', 'Force compiling against PostgreSQL'
  option 'with-id64',       'Force compiling with 64-bit ID support'

  deprecated_option 'mysql' => 'with-mysql'
  deprecated_option 'pgsql' => 'with-postgresql'
  deprecated_option 'id64'  => 'with-id64'

  depends_on "re2" => :optional
  depends_on :mysql => :optional
  depends_on :postgresql => :optional
  depends_on 'openssl' if build.with?('mysql')

  resource 'stemmer' do
    url "https://github.com/snowballstem/snowball.git",
      :revision => "9b58e92c965cd7e3208247ace3cc00d173397f3c"
  end

  fails_with :llvm do
    build 2334
    cause "ld: rel32 out of range in _GetPrivateProfileString from /usr/lib/libodbc.a(SQLGetPrivateProfileString.o)"
  end

  fails_with :clang do
    build 421
    cause "sphinxexpr.cpp:1802:11: error: use of undeclared identifier 'ExprEval'"
  end

  def install
    resource('stemmer').stage do
      system "make", "dist_libstemmer_c"
      system "tar", "xzf", "dist/libstemmer_c.tgz", "-C", buildpath
    end

    args = %W[--prefix=#{prefix}
              --disable-dependency-tracking
              --localstatedir=#{var}
              --with-libstemmer]

    args << "--enable-id64" if build.with? 'id64'
    args << "--with-re2" if build.with? 're2'

    if build.with? 'mysql'
      args << '--with-mysql'
    else
      args << '--without-mysql'
    end

    if build.with? 'postgresql'
      args << '--with-pgsql'
    else
      args << '--without-pgsql'
    end

    system "./configure", *args
    system "make install"
  end

  def caveats; <<-EOS.undent
    This is not sphinx - the Python Documentation Generator.
    To install sphinx-python: use pip or easy_install,

    Sphinx has been compiled with libstemmer support.

    Sphinx depends on either MySQL or PostreSQL as a datasource.

    You can install these with Homebrew with:
      brew install mysql
        For MySQL server.

      brew install mysql-connector-c
        For MySQL client libraries only.

      brew install postgresql
        For PostgreSQL server.

    We don't install these for you when you install this formula, as
    we don't know which datasource you intend to use.
    EOS
  end
end
