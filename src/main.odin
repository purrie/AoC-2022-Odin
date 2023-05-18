package main

import "core:fmt"
import "core:os"
import "core:io"
import "core:bufio"
import "core:c/libc"
import "core:strings"

main :: proc () {
	fmt.print("Advent of code 2022\n\n")
	day_1()
	day_2()
	day_3()
	day_4()
}

raport_errorno :: proc (err : os.Errno) {
	fmt.printf("Error: %s\n", libc.strerror(i32(err)))
}

read_input :: proc ( file_name : string ) -> ( handle : os.Handle, breader : bufio.Reader, ok : bool = true ) {
	errno : os.Errno
	addr, fail := strings.concatenate({"./inputs/", file_name}, context.temp_allocator)
	if fail != .None {
		return 0, {}, false
	}
	handle, errno = os.open(addr)
	if errno != 0 {
		raport_errorno(errno)
		return 0, {}, false
	}

	stream := os.stream_from_handle(handle)
	reader : io.Reader
	reader, ok = io.to_reader(stream)
	if !ok {
		fmt.println("Failed to get a reader for ", file_name)
		os.close(handle)
		return 0, {}, false
	}

	bufio.reader_init(&breader, reader)

	return
}
