package main

import "core:fmt"
import "core:os"
import "core:io"
import "core:bufio"
import "core:c/libc"

day_1 :: proc() {
	handle, operr := os.open("inputs/calories.txt")
	if operr != 0 {
		raport_errorno(operr)
		return
	}
	defer os.close(handle)

	stream := os.stream_from_handle(handle)
	reader, ok := io.to_reader(stream)
	if ~ok {
		fmt.println("Failed to get a reader")
		return
	}

	top_cals := [3]uint{0, 0, 0}
	cur_cals : uint = 0

	breader : bufio.Reader

	bufio.reader_init(&breader, reader)
	defer bufio.reader_destroy(&breader)
	str, err := bufio.reader_read_slice(&breader, '\n')
	cont := err == .None

	for cont {
		if num, err := parse_to_number(str); err == .EmptyString {
			last := len(top_cals) - 1

			if cur_cals > top_cals[last] {
				top_cals[last] = cur_cals

				for i in 1..<len(top_cals) {
					it := len(top_cals) - i
					if top_cals[it] > top_cals[it - 1] {
						cur_cals = top_cals[it - 1]
						top_cals[it - 1] = top_cals[it]
						top_cals[it] = cur_cals
					}
				}
			}

			cur_cals = 0
		} else if err == .None {
			cur_cals += num
		} else {
			fmt.println("Failed to parse strint!")
			return
		}

		str, err = bufio.reader_read_slice(&breader, '\n')
		cont = err == .None
	}

	result : uint = 0
	for r in top_cals {
		result += r
	}

	fmt.println("Day 1 answer:")
	fmt.printf("  Largest one: {0:d}\n", top_cals[0])
	fmt.printf("  Top 3 total: {0:d}\n", result)
}

ParsingError :: enum {
	None, EmptyString, NotANumber,
}

parse_to_number :: proc (str: []u8) -> (uint, ParsingError) {
	if len(str) < 2 {
		return 0, .EmptyString
	}
	result : uint = 0
	for c in str {
		switch c {
		case '0'..='9':
			result *= 10
			result += uint(c - '0')
		case '\n':
			return result, .None
		case:
			return 0, .NotANumber
		}
	}
	return result, .None
}
