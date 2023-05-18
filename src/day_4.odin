package main

import "core:os"
import "core:fmt"
import "core:bufio"
import "core:testing"
import "core:strings"
import "core:strconv"

day_4 :: proc () {
	file, reader, ok := read_input("camp-cleanup.txt")
	if !ok {
		return
	}
	defer os.close(file)
	defer bufio.reader_destroy(&reader)

	line, err := bufio.reader_read_string(&reader, '\n', context.temp_allocator)
	count : uint = 0
	coun2 : uint = 0

	for err == .None {
		line = strings.trim_right(line, "\n")
		first, second := get_pairs(line)
		if is_full_overlap(first, second) {
			count += 1
		}
		if is_overlap(first, second) {
			coun2 += 1
		}
		line, err = bufio.reader_read_string(&reader, '\n', context.temp_allocator)
	}

	fmt.printf("Day 4 answer: \n  Part 1: %d\n  Part 2: %d\n", count, coun2)
}

Pair :: struct {
	bottom	: uint,
	top		: uint,
}

get_pairs :: proc ( line : string ) -> (first, second : Pair ) {
	elves, err := strings.split(line, ",", context.temp_allocator)
	if err != .None {
		fmt.eprintf("Error: memory error %s", err)
		os.exit(1)
	}
	first	= get_pair(elves[0])
	second	= get_pair(elves[1])
	return
}

get_pair :: proc ( line_part : string ) -> ( elf : Pair ) {
	ranges, err := strings.split(line_part, "-", context.temp_allocator)
	if err != .None {
		fmt.eprintf("Error: memory error %s", err)
		os.exit(1)
	}
	if num, ok := strconv.parse_uint(ranges[0]); ok {
		elf.bottom = num
	} else {
		fmt.eprintf("Error: couldn't convert %s to string", ranges[0])
		os.exit(1)
	}
	if num, ok := strconv.parse_uint(ranges[1]); ok {
		elf.top = num
	} else {
		fmt.eprintf("Error: couldn't convert %s to string", ranges[1])
		os.exit(1)
	}
	return
}

is_full_overlap :: proc ( first, second : Pair ) -> bool {
	if first.bottom >= second.bottom && first.top <= second.top {
		return true
	}
	if second.bottom >= first.bottom && second.top <= first.top {
		return true
	}
	return false
}

is_overlap :: proc ( first, second : Pair ) -> bool {
	if first.top >= second.bottom && first.bottom <= second.top {
		return true
	}
	if second.top >= first.bottom && second.bottom <= first.top {
		return true
	}
	return false
}

@(test)
day_4_test_part_1 :: proc ( t : ^testing.T ) {
	input := "2-4,6-8\n" + "2-3,4-5\n" + "5-7,7-9\n" + "2-8,3-7\n" + "6-6,4-6\n" + "2-6,4-8\n"
	r : strings.Reader
	ior := strings.to_reader(&r, input)
	br : bufio.Reader
	bufio.reader_init(&br, ior)
	defer bufio.reader_destroy(&br)

	line, err := bufio.reader_read_string(&br, '\n', context.temp_allocator)

	count : uint = 0

	for err == .None {
		line = strings.trim_right(line, "\n")
		first, second := get_pairs(line)
		if is_full_overlap(first, second) {
			count += 1
		}
		line, err = bufio.reader_read_string(&br, '\n', context.temp_allocator)
	}

	testing.expect_value(t, count, 2)
}

@(test)
day_4_test_part_2 :: proc ( t : ^testing.T ) {
	input := "2-4,6-8\n" + "2-3,4-5\n" + "5-7,7-9\n" + "2-8,3-7\n" + "6-6,4-6\n" + "2-6,4-8\n"
	r : strings.Reader
	ior := strings.to_reader(&r, input)
	br : bufio.Reader
	bufio.reader_init(&br, ior)
	defer bufio.reader_destroy(&br)

	line, err := bufio.reader_read_string(&br, '\n', context.temp_allocator)

	count : uint = 0

	for err == .None {
		line = strings.trim_right(line, "\n")
		first, second := get_pairs(line)
		if is_overlap(first, second) {
			count += 1
		}
		line, err = bufio.reader_read_string(&br, '\n', context.temp_allocator)
	}

	testing.expect_value(t, count, 4)
}
