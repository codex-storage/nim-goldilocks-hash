{. compile: "../cbits/goldilocks.c" .}

import ./types

func neg* (x: F   ): F {. header: "../cbits/goldilocks.h", importc: "goldilocks_neg", cdecl .}
func `+`* (x, y: F): F {. header: "../cbits/goldilocks.h", importc: "goldilocks_add", cdecl .}
func `-`* (x, y: F): F {. header: "../cbits/goldilocks.h", importc: "goldilocks_sub", cdecl .}
func `*`* (x, y: F): F {. header: "../cbits/goldilocks.h", importc: "goldilocks_mul", cdecl .}

proc `+=`* (x: var F, y: F) = x = x + y
proc `-=`* (x: var F, y: F) = x = x - y
proc `*=`* (x: var F, y: F) = x = x * y

