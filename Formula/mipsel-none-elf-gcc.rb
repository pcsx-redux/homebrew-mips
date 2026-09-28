class MipselNoneElfGcc < Formula
  desc "GNU compiler collection for mipsel-none-elf cross development"
  homepage "https://gcc.gnu.org"
  url "https://ftpmirror.gnu.org/gnu/gcc/gcc-16.2.0/gcc-16.2.0.tar.xz"
  mirror "https://mirrors.kernel.org/gnu/gcc/gcc-16.2.0/gcc-16.2.0.tar.xz"
  sha256 "e6738e29597f733270731aa90600f37ffdc045079dfc27ec7e8192cc81085c3e"
  license "GPL-3.0-or-later" => { with: "GCC-exception-3.1" }

  depends_on "gnu-sed" => :build
  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mipsel-none-elf-binutils"
  depends_on "mpfr"

  def install
    ENV.prepend_path "PATH", formula_opt_libexec("gnu-sed")/"gnubin"
    binutils_bin = formula_opt_bin("mipsel-none-elf-binutils")
    mkdir "mipsel-none-elf-gcc-build" do
      system "../configure", "--target=mipsel-none-elf",
                             "--prefix=#{prefix}",
                             "--without-isl",
                             "--disable-nls",
                             "--disable-threads",
                             "--disable-shared",
                             "--disable-libssp",
                             "--disable-libstdcxx-pch",
                             "--disable-libgomp",
                             "--disable-werror",
                             "--without-headers",
                             "--disable-hosted-libstdcxx",
                             "--with-as=#{binutils_bin}/mipsel-none-elf-as",
                             "--with-ld=#{binutils_bin}/mipsel-none-elf-ld",
                             "--enable-languages=c,c++"
      system "make", "all-gcc"
      system "make", "install-strip-gcc"
      system "make", "all-target-libgcc"
      system "make", "install-strip-target-libgcc"
      system "make", "all-target-libstdc++-v3"
      system "make", "install-strip-target-libstdc++-v3"
    end
  end

  test do
    (testpath/"test.c").write <<~C
      int main(void)
      {
        int i = 0;
        while (i < 10) i++;
        return i;
      }
    C
    system bin/"mipsel-none-elf-gcc", "-c", "-o", "test.o", "test.c"
    assert_path_exists testpath/"test.o"
  end
end
