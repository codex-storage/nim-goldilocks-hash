
import os
import ./types

#-------------------------------------------------------------------------------
# build system hack

const
  # REMARK: currentSourcePath = ~/.nimble/pkgs/goldilocks_hash-0.0.1/goldilocks_hash/goldilocks.nim
  root = currentSourcePath.parentDir.parentDir

{. passc: "-I" & root & "/cbits" .}
{. compile: root & "/cbits/goldilocks.c" .}

#-------------------------------------------------------------------------------

func neg* (x: F   ): F {. header: "goldilocks.h", importc: "goldilocks_neg", cdecl .}
func `+`* (x, y: F): F {. header: "goldilocks.h", importc: "goldilocks_add", cdecl .}
func `-`* (x, y: F): F {. header: "goldilocks.h", importc: "goldilocks_sub", cdecl .}
func `*`* (x, y: F): F {. header: "goldilocks.h", importc: "goldilocks_mul", cdecl .}

proc `+=`* (x: var F, y: F) = x = x + y
proc `-=`* (x: var F, y: F) = x = x - y
proc `*=`* (x: var F, y: F) = x = x * y
