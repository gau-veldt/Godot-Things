GDNative via GDScript toolchain-free autocompiler project
License: MIT (same as Godot engine)

**Goal:** Ability to have automatic acceleration of existing GDScripted objects to from vanilla
      Godot with no additional toolchain suites required (tool chains are commonly present
      in linux but more complex to use in Windows due to the extensive footprint of proprietary
      tools in the windows development ecosystem).  Any tools that are included (like
      assemblers) must have suitable licensing.

**Note:** includes NASM which is licnesed separately via 2-clause BSD license.  I believe this to
      be compatible to MIT so it should be usable in an exported game without restriction.

**Note 2:** Temporary use of GoLink for development.  GoLink is distributable *non-commercially only*
        precluding its use in exported games and any project becomming commercial in any way
        (for example I would have to ditch GoLink prior to asking for Patreon assistance).
        Therefore I'll need to migrate away from a linker eventually and generate binary
        dynalib (DLL, dylib, so, etc.) GDNative blobs directly in NASM.

At this point not much here yet other than random PoC asm sources, stub nodes, scripts and assembler tests.
