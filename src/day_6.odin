package main

import "core:testing"
import "core:fmt"
import "core:os"
import "core:bufio"

day_6 :: proc() {
	handle, buffer, ok := read_input("signal-markers.txt")
	if !ok {
		fmt.eprintln("Failed to open input file for day 6")
		return
	}
	defer os.close(handle)
	defer bufio.reader_destroy(&buffer)
	buf, err := bufio.reader_read_slice(&buffer, '\n')
	if err != .None {
		fmt.eprintln("Failed to read buffer for day 6")
		return
	}

	fourth, fok := find_unique(buf, 4)
	if !fok {
		fmt.eprintln("Failed to find correct value for first part of day 6")
		return
	}

	fourteen, sok := find_unique(buf, 14)
	if !sok {
		fmt.eprintln("Failed to find correct value for second part of day 6")
		return
	}

	fmt.println("Day 6:\n  Part 1:", fourth, "\n  Part 2:", fourteen)
}

find_unique :: proc(stream : []u8, length : uint) -> (position : uint, ok : bool = true) {
	if uint( len(stream) ) < length {
		return 0, false
	}
	position = length - 1
	outer: for position < len(stream) {
		set : Lowercase
		incl(&set, stream[position])

		for cursor in 1..<length {
			if stream[position - cursor] in set {
				position += length - cursor
				continue outer
			}
			else {
				incl(&set, stream[position - cursor])
			}
		}
		position += 1
		return
	}

	return 0, false
}

@(test)
day_6_test_1 :: proc(t : ^testing.T) {
	line : [30]u8 = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"
	pos, ok := find_unique(line[:], 4)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 7)
}

@(test)
day_6_test_2 :: proc(t : ^testing.T) {
	line : [28]u8 = "bvwbjplbgvbhsrlpgdmjqwftvncz"
	pos, ok := find_unique(line[:], 4)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 5)
}
@(test)
day_6_test_3 :: proc(t : ^testing.T) {
	line : [28]u8 = "nppdvjthqldpwncqszvftbrmjlhg"
	pos, ok := find_unique(line[:], 4)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 6)
}
@(test)
day_6_test_4 :: proc(t : ^testing.T) {
	line : [33]u8 = "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"
	pos, ok := find_unique(line[:], 4)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 10)
}
@(test)
day_6_test_5 :: proc(t : ^testing.T) {
	line : [32]u8 = "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
	pos, ok := find_unique(line[:], 4)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 11)
}

@(test)
day_6_test_1_2 :: proc(t : ^testing.T) {
	line : [30]u8 = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"
	pos, ok := find_unique(line[:], 14)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 19)
}

@(test)
day_6_test_2_2 :: proc(t : ^testing.T) {
	line : [28]u8 = "bvwbjplbgvbhsrlpgdmjqwftvncz"
	pos, ok := find_unique(line[:], 14)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 23)
}
@(test)
day_6_test_3_2 :: proc(t : ^testing.T) {
	line : [28]u8 = "nppdvjthqldpwncqszvftbrmjlhg"
	pos, ok := find_unique(line[:], 14)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 23)
}
@(test)
day_6_test_4_2 :: proc(t : ^testing.T) {
	line : [33]u8 = "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"
	pos, ok := find_unique(line[:], 14)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 29)
}
@(test)
day_6_test_5_2 :: proc(t : ^testing.T) {
	line : [32]u8 = "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
	pos, ok := find_unique(line[:], 14)
	testing.expect(t, ok)
	testing.expect_value(t, pos, 26)
}
