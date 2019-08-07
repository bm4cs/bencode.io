---
layout: post
title: "C++11 with Clang on Windows and MinGW"
date: "2012-10-20 10:44:33"
comments: false
categories:
- dev
tags:
- c++
---

Installation steps for getting a functional Clang++ build running on Windows 8 and MinGW.

## Step 1
Install [MinGW](https://sourceforge.net/projects/mingw/files/Installer/mingw-get-inst/). Using `mingw-get-inst-20120426.exe` go with the pre-packaged repository catalogues, which bundles in GCC 4.6.1 as opposed to 4.7.x, which at the time of writing Clang does not support seemlessly. You will need the C Compiler, C++ Compiler, MSYS Basic System and MinGW Developer Toolkit MinGW packages.

## Step 2
[Python 2.x](http://www.python.org/download/). Install the Python Interpreter and Libraries into `c:\MinGW\bin`.

##Step 3
Install [Subversion](http://subversion.apache.org/packages.html). I went with the `Subversion 1.7.7 (Windows 64-bit)` package from [CollabNet](http://www.collab.net/downloads/subversion).

Checkout LLVM:

    cd C:\mingw\msys\1.0
    mkdir src
    cd src
    svn co http://llvm.org/svn/llvm-project/llvm/trunk llvm

Checkout Clang:

    cd llvm/tools
    svn co http://llvm.org/svn/llvm-project/cfe/trunk clang
    cd ../..

Checkout Compiler-RT:

    cd llvm/projects
    svn co http://llvm.org/svn/llvm-project/compiler-rt/trunk compiler-rt
    cd ../..


##Step 4
C++ headers and libraries. Clang will attempt to [automatically probe](http://clang.llvm.org/docs/UsersManual.html#target_os_win32) MinGW's directory structure for set of supported `libstdc++` paths. For 32-bit `i686-w64-mingw32`, and 64-bit `x86_64-w64-mingw32`, Clang assumes as below:

    some_directory/bin/gcc.exe
    some_directory/bin/clang.exe
    some_directory/bin/clang++.exe
    some_directory/bin/../include/c++/GCC_version
    some_directory/bin/../include/c++/GCC_version/x86_64-w64-mingw32
    some_directory/bin/../include/c++/GCC_version/i686-w64-mingw32
    some_directory/bin/../include/c++/GCC_version/backward
    some_directory/bin/../x86_64-w64-mingw32/include
    some_directory/bin/../i686-w64-mingw32/include
    some_directory/bin/../include

This probing logic can be found in `InitHeaderSearch.cpp` located here `C:\mingw\msys\1.0\src\llvm\tools\clang\lib\Frontend\InitHeaderSearch.cpp`.

    ... //line 374
    switch (os) {
    case llvm::Triple::Linux:
    case llvm::Triple::Win32:
      llvm_unreachable("Include management is handled in the driver.");

    case llvm::Triple::Cygwin:
      // Cygwin-1.7
      AddMinGWCPlusPlusIncludePaths("/usr/lib/gcc", "i686-pc-cygwin", "4.5.3");
      AddMinGWCPlusPlusIncludePaths("/usr/lib/gcc", "i686-pc-cygwin", "4.3.4");
      // g++-4 / Cygwin-1.5
      AddMinGWCPlusPlusIncludePaths("/usr/lib/gcc", "i686-pc-cygwin", "4.3.2");
      break;
    case llvm::Triple::MinGW32:
      // mingw-w64 C++ include paths (i686-w64-mingw32 and x86_64-w64-mingw32)
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.5.0");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.5.1");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.5.2");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.5.3");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.5.4");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.6.0");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.6.1");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.6.2");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.6.3");
      AddMinGW64CXXPaths(HSOpts.ResourceDir, "4.7.0");
    ...


Ensure that the version of gcc that your MinGW installer used, matches a supported version (e.g. `4.6.2` is my case) by looking here `C:\mingw\lib\gcc\mingw32\4.6.2`.

If your version of gcc does not seem to be supported automatically, Clang will be usable to resolve standard libraries and headers - you want this. Some popular way to help Clang find these (if it doesn't already):

1.  Specify the `--with-gcc-toolchain` configure option (prior to build) to tell Clang where the gcc containing the desired `libstdc++` is installed.
2.  Create a symbolic link, e.g. if you have `4.7.2` and only upto `4.7.0` is in the auto probe logic, create a `4.7.0` symbolic link to `4.7.2`.
3.  Modify `InitHeaderSearch.cpp` to your specific environment prior to building Clang.


##Step 5
Build. Using a MinGW shell. Credits to [Pete](http://pete.akeo.ie/2011/10/building-and-running-clang-static.html) for this.

    cd /src
    mkdir build
    cd build
    export CC=gcc
    export CXX=g++
    ../llvm/configure --disable-docs --enable-optimized --enable-targets=x86,x86_64 --prefix=/mingw
    make
    make install


##Step 6
Take Clang++ for a test drive. Create `foo.cpp`:

    #include <iostream>
    int main() {
        std::cotut << "Hello World"; //typo
        return 0;
    }

and Clang it `clang++ foo.cpp`

    test.cpp:4:7: error: no member named 'cotut' in namespace 'std'; did you mean 'cout'?
            std::cotut << "Hello World";
            ~~~~~^~~~~
                 cout
    /usr/include/c++/4.2.1/iostream:63:18: note: 'cout' declared here
      extern ostream cout;          ///< Linked to standard output


For a nice intro to Clang, checkout Chandler Carruth's GoingNative 2012 lecture [Clang: Defending C++ from Murphy's Million Monkeys](http://channel9.msdn.com/Events/GoingNative/GoingNative-2012/Clang-Defending-C-from-Murphy-s-Million-Monkeys)
