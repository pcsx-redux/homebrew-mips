class MipselNoneElfGdb < Formula
  desc "GNU debugger for mipsel-none-elf cross development"
  homepage "https://www.gnu.org/software/gdb/"
  url "https://ftpmirror.gnu.org/gnu/gdb/gdb-17.2.tar.xz"
  mirror "https://mirrors.kernel.org/gnu/gdb/gdb-17.2.tar.xz"
  sha256 "1c036c0d72e4b3d1fb5c94c88632add6f9d76f4d7c4d2ea793c12a9f19a3228c"
  license "GPL-3.0-or-later"

  depends_on "pkgconf" => :build
  depends_on "texinfo" => :build
  depends_on "mipsel-none-elf-gcc" => :test
  depends_on "gmp"
  depends_on "mpfr"
  depends_on "ncurses"
  depends_on "python@3.14"
  depends_on "readline"
  depends_on "xz"
  depends_on "zstd"

  uses_from_macos "expat"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  def install
    target = "mipsel-none-elf"
    python3 = formula_opt_bin("python@3.14")/"python3.14"
    args = %W[
      --target=#{target}
      --datarootdir=#{share}/#{target}
      --includedir=#{include}/#{target}
      --infodir=#{info}/#{target}
      --mandir=#{man}
      --disable-binutils
      --disable-nls
      --disable-werror
      --enable-tui
      --with-curses
      --with-expat
      --with-lzma
      --with-python=#{python3}
      --with-system-readline
      --with-system-zlib
      --with-zstd
      --without-isl
    ]

    mkdir "build" do
      system "../configure", *args, *std_configure_args
      ENV.deparallelize
      system "make"
      # bfd and opcodes are provided by mipsel-none-elf-binutils
      system "make", "install-gdb"
    end
  end

  test do
    (testpath/"test.c").write "void _start(void) {}"
    system formula_opt_bin("mipsel-none-elf-gcc")/"mipsel-none-elf-gcc", "-g", "-nostdlib", "test.c"

    output = shell_output("#{bin}/mipsel-none-elf-gdb -batch -ex 'info address _start' a.out")
    assert_match "Symbol \"_start\" is a function at address 0x", output
  end
end
