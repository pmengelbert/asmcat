A simple, limited version of `cat` written in x86-64 assembly. It was written as an exercise in pure assembly;
C functions are only used for allocating and freeing memory. Everything else is pure assembly.

A notable limitation of this example is its lack of error handling. I would recommend using `gdb` to debug this
if you run into issues.

This is intended to be a reference for anyone who is interested in going beyond the very basics of x86-64 assembly.
You could try to build this on your machine, but that kind of defeats the purpose :) If you were to assemble this,
you would likely need to adjust the linking stage in the Makefile to match the location of the libc object files on your
machine.

To find the correct files for the linker, I followed this [answer on stack overflow](https://stackoverflow.com/a/30705769).
Basically, write a simple C file that uses the library functions you need:

```c
// malloc-example.c
#include <stdio.h>

int main(int argc, char **argv) {
    void *x = malloc(1);
    free(x);
    return 0;
}
```

Then, compile it with `gcc`'s `-v` flag, for verbose output, and search for `collect2`, which is what gcc uses under the
hood as a linker:

```bash
gcc -v hello_world.c |& grep 'collect2' | tr ' ' '\n'
```

This will give you output like the following:
```
/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/collect2
-plugin
/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/liblto_plugin.so
-plugin-opt=/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/lto-wrapper
-plugin-opt=-fresolution=/tmp/ccL3S9l7.res
-plugin-opt=-pass-through=-lgcc
-plugin-opt=-pass-through=-lgcc_s
-plugin-opt=-pass-through=-lc
-plugin-opt=-pass-through=-lgcc
-plugin-opt=-pass-through=-lgcc_s
--build-id
--eh-frame-hdr
--hash-style=gnu
-m
elf_x86_64
-dynamic-linker
/lib64/ld-linux-x86-64.so.2
-pie
/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../../../lib/Scrt1.o
/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../../../lib/crti.o
/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/crtbeginS.o
-L/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0
-L/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../../../lib
-L/lib/../lib
-L/usr/lib/../lib
-L/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../..
/tmp/ccSycpUx.o
-lgcc
--push-state
--as-needed
-lgcc_s
--pop-state
-lc
-lgcc
--push-state
--as-needed
-lgcc_s
--pop-state
/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/crtendS.o
/usr/lib/gcc/x86_64-pc-linux-gnu/10.2.0/../../../../lib/crtn.o
```

Of interest were the `.o` files used before and after `/tmp/ccSycpUx.o`, which I can only assume is the object file created
from the C code I wrote. As such, I experimented with linking various `.o` files before and after `asmcat.o` until it worked.
I haven't gotten to the chapter on linking yet, so I am guessing there is a better way to go about finding the proper files to link.

For additional information on how the program itself works, see the comments in `asmcat.s`.
