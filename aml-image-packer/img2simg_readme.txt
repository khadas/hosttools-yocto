img2simg is a set of tools for Android, We can pull this repository
down from GitHub alone:
https://github.com/arun-madhavan-013/libsparse

get source code:
git clone https://github.com/arun-madhavan-013/libsparse.git

Based on commit id:bef0b1dbbc860a41712c127702bfe9bbf223ef22

Note:
 Modify libsparse.so to compile statically before compiling.
 add_library(sparse SHARED ${SPARSE_SRC_FILES}) ->
 add_library(sparse STATIC ${SPARSE_SRC_FILES})

Compilation step:
  1. cmake -DCMAKE_INSTALL_PREFIX=${Destination_Base_Directory}
  2. make

The target binary in current dir.

