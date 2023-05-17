package main

import "core:testing"
import "core:fmt"
import "core:os"
import "core:io"
import "core:bufio"

day_3 :: proc () {
	handle, oser := os.open("inputs/rugsacks.txt")
	if oser != 0 {
		raport_errorno(oser)
		return
	}
	defer os.close(handle)

	stream := os.stream_from_handle(handle)
	reader, iok := io.to_reader(stream)
	if !iok {
		fmt.eprintln("Error: Failed to open reader")
		return
	}
	beader : bufio.Reader
	bufio.reader_init(&beader, reader)
	defer bufio.reader_destroy(&beader)

	sum : u32 = 0
	badge : u32 = 0
	lowers : Lowercase
	uppers : Uppercase
	count : u8 = 0

	for line, error := bufio.reader_read_slice(&beader, '\n');
		error == .None;
		line, error = bufio.reader_read_slice(&beader, '\n') {

			sum += count_priorities(line)

			count = (count + 1) % 3
			switch count {
			case 1:
				uppers, lowers = get_set(line)
			case 0:
				u, l := get_set(line)
				uppers &= u
				lowers &= l
				p := get_from_set(uppers, lowers)
				badge += get_priority(p)
			case :
				u, l := get_set(line)
				uppers &= u
				lowers &= l
			}
	}

	fmt.println("Day 3 answer:")
	fmt.println("  Part 1:", sum)
	fmt.println("  Part 2:", badge)
}

Lowercase :: bit_set[u8('a')..=u8('z'); u32]
Uppercase :: bit_set[u8('A')..=u8('Z'); u32]

get_set :: proc (rugsack : []u8) -> (uppers : Uppercase, lowers : Lowercase) {
	for item in rugsack {
		switch item {
		case 'a'..='z': incl(&lowers, item)
		case 'A'..='Z': incl(&uppers, item)
		case '\n': continue
		case : assert(false, "Unreachable")
		}
	}
	return
}

get_from_set :: proc (uppers : Uppercase, lowers : Lowercase) -> (item : u8) {
	assert( card(uppers) + card(lowers) == 1, "We got more than one item in the set" )
	for l in u8('a')..='z' {
		if l in lowers {
			item = l
			return
		}
	}
	for l in u8('A')..='Z' {
		if l in uppers {
			item = l
			return
		}
	}
	assert(false, "unreachable")
	return
}

count_priorities :: proc (rugsack : []u8) -> (priorities : u32 = 0) {
	leng := len(rugsack)
	half := leng / 2
	lowers : Lowercase
	uppers : Uppercase

	for i in 0..<leng {
		item := rugsack[i]
		if i < half {
			switch item {
			case 'a'..='z': incl(&lowers, item)
			case 'A'..='Z': incl(&uppers, item)
			case : assert(false, "Unreachable")
			}
		} else {
			switch {
			case item in lowers:
				excl(&lowers, item)
			case item in uppers:
				excl(&uppers, item)
			case : continue
			}
			priorities += get_priority(item)
		}
	}
	return
}

get_priority :: proc (item : u8) -> (priority : u32) {
	switch item {
	case 'a'..='z': priority = u32(item - 'a' + 1)
	case 'A'..='Z': priority = u32(item - 'A' + 27)
	case : assert(false, "Only letters get priority")
	}
	return
}

@(test)
day_3_test_priority :: proc (t : ^testing.T) {
	testing.expect_value(t, get_priority('a'), 1)
	testing.expect_value(t, get_priority('z'), 26)
	testing.expect_value(t, get_priority('A'), 27)
	testing.expect_value(t, get_priority('Z'), 52)
}

@(test)
day_3_test_1 :: proc (t : ^testing.T) {
	input : [24]u8 = "vJrwpWtwJgWrhcsFMMfFFhFp"
	priority := count_priorities(input[:])
	testing.expect_value(t, priority, 16)
}

@(test)
day_3_test_2 :: proc (t : ^testing.T) {
	input : [32]u8 = "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"
	priority := count_priorities(input[:])
	testing.expect_value(t, priority, 38)
}

@(test)
day_3_test_3 :: proc (t : ^testing.T) {
	input : [18]u8 = "PmmdzqPrVvPwwTWBwg"
	priority := count_priorities(input[:])
	testing.expect_value(t, priority, 42)
}

@(test)
day_3_test_4 :: proc (t : ^testing.T) {
	input : [30]u8 = "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn"
	priority := count_priorities(input[:])
	testing.expect_value(t, priority, 22)
}

@(test)
day_3_test_5 :: proc (t : ^testing.T) {
	input : [16]u8 = "ttgJtRGJQctTZtZT"
	priority := count_priorities(input[:])
	testing.expect_value(t, priority, 20)
}

@(test)
day_3_test_6 :: proc (t : ^testing.T) {
	input : [24]u8 = "CrZsJsPPZsGzwwsLwLmpwMDw"
	priority := count_priorities(input[:])
	testing.expect_value(t, priority, 19)
}

@(test)
day_3_test_7 :: proc (t : ^testing.T) {
	input1 : [24]u8 = "vJrwpWtwJgWrhcsFMMfFFhFp"
	input2 : [32]u8 = "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"
	input3 : [18]u8 = "PmmdzqPrVvPwwTWBwg"

	uppers, lowers := get_set(input1[:])
	u, l := get_set(input2[:])
	uppers &= u
	lowers &= l
	u, l = get_set(input3[:])
	uppers &= u
	lowers &= l

	item := get_from_set(uppers, lowers)
	priority := get_priority(item)

	testing.expect_value(t, priority, 18)
}

@(test)
day_3_test_8 :: proc (t : ^testing.T) {
	input1 : [30]u8 = "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn"
	input2 : [16]u8 = "ttgJtRGJQctTZtZT"
	input3 : [24]u8 = "CrZsJsPPZsGzwwsLwLmpwMDw"

	uppers, lowers := get_set(input1[:])
	u, l := get_set(input2[:])
	uppers &= u
	lowers &= l
	u, l = get_set(input3[:])
	uppers &= u
	lowers &= l

	item := get_from_set(uppers, lowers)
	priority := get_priority(item)

	testing.expect_value(t, priority, 52)
}
