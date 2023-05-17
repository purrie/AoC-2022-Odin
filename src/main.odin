package main

import "core:fmt"
import "core:os"
import "core:c/libc"

main :: proc () {
	fmt.print("Advent of code 2022\n\n")
	day_1()
	day_2()
	day_3()
}

raport_errorno :: proc (err : os.Errno) {
	fmt.printf("Error: %s\n", libc.strerror(i32(err)))
}
