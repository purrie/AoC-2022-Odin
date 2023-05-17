package main

import "core:fmt"
import "core:os"
import "core:io"
import "core:bufio"
import "core:testing"

day_2 :: proc () {
	handle, operr := os.open("inputs/rock-paper-scisors.txt")
	if operr != 0 {
		raport_errorno(operr)
		return
	}
	defer os.close(handle)

	stream := os.stream_from_handle(handle)
	reader, ok := io.to_reader(stream)
	if !ok {
		fmt.println("Failed to get a reader")
		return
	}

	breader : bufio.Reader
	bufio.reader_init(&breader, reader)
	defer bufio.reader_destroy(&breader)

	total_points   : uint
	total_points_2 : uint
	str, err := bufio.reader_read_slice(&breader, '\n')

	for err == .None {
		if opponent, you, err := get_hands(str); err {
			fmt.println("Error: invalid input")
			return
		} else {
			total_points += get_points(opponent, you)
		}
		if opponent, result, err := get_result(str); err {
			fmt.println("Error: invalid input")
			return
		} else {
			you := get_hand_by_result(opponent, result)
			total_points_2 += get_points(opponent, you)
		}

		str, err = bufio.reader_read_slice(&breader, '\n')
	}

	fmt.println("Day 2 answer:")
	fmt.println("  Total points part 1: ", total_points)
	fmt.println("  Total points part 2: ", total_points_2)
}

Hand :: enum {
	Rock = 'A',
	Paper = 'B',
	Scisors = 'C',
}

Result :: enum u8 {
	Lose = 'X', Draw = 'Y', Win = 'Z',
}

get_hands :: proc ( line: []u8 ) -> ( opponent, you : Hand, err: bool = false) {
	switch line[0] {
	case 'A':
		opponent = .Rock
	case 'B':
		opponent = .Paper
	case 'C':
		opponent = .Scisors
	case:
		err = true
		return
	}
	switch line[2] {
	case 'X':
		you = .Rock
	case 'Y':
		you = .Paper
	case 'Z':
		you = .Scisors
	case:
		err = true
		return
	}
	return
}

get_result :: proc ( line: []u8 ) -> ( opponent : Hand, result : Result, error : bool = false) {
	opponent = Hand(line[0])
	result = Result(line[2])
	return
}

get_hand_by_result :: proc ( opponent : Hand, result : Result ) -> Hand {
	#partial switch result {
	case .Draw:
		return opponent
	case:
		switch opponent {
		case .Rock:
			return .Paper if result == .Win else .Scisors
		case .Paper:
			return .Scisors if result == .Win else .Rock
		case .Scisors:
			return .Rock if result == .Win else .Paper
		}
	}
	return nil
}

get_points :: proc ( opponent, you : Hand ) -> (points: uint) {
	if opponent == you {
		points = 3
	} else {
		switch opponent {
		case .Rock:
			points = 6 if you == .Paper else 0
		case .Paper:
			points = 6 if you == .Scisors else 0
		case .Scisors:
			points = 6 if you == .Rock else 0
		}
	}
	switch you {
	case .Rock:
		points += 1
	case .Paper:
		points += 2
	case .Scisors:
		points += 3
	}
	return
}

@(test)
day_2_test_round_1 :: proc(^testing.T) {
	opponent, you, fail := get_hands([]u8{'A', ' ', 'Y', '\n'})
	assert(fail == false)
	assert(opponent == .Rock)
	assert(you == .Paper)
	points := get_points(opponent, you)
	assert(points == 8)
}

@(test)
day_2_test_round_2 :: proc(^testing.T) {
	opponent, you, fail := get_hands([]u8{'B', ' ', 'X', '\n'})
	assert(fail == false)
	assert(opponent == .Paper)
	assert(you == .Rock)
	points := get_points(opponent, you)
	assert(points == 1)
}

@(test)
day_2_test_round_3 :: proc(t: ^testing.T) {
	opponent, you, fail := get_hands([]u8{'C', ' ', 'Z', '\n'})
	testing.expect_value(t, fail, false)
	assert(opponent == .Scisors)
	assert(you == .Scisors)
	points := get_points(opponent, you)
	assert(points == 6)
}

@(test)
day_2_test_round_4 :: proc(t: ^testing.T) {
	opponent, result, fail := get_result([]u8{'A', ' ', 'Y', '\n'})
	testing.expect_value(t, fail, false)
	you := get_hand_by_result(opponent, result)
	testing.expect_value(t, opponent, Hand.Rock)
	testing.expect_value(t, you, Hand.Rock)
	score := get_points(opponent, you)
	testing.expect_value(t, score, 4)
}

@(test)
day_2_test_round_5 :: proc(t: ^testing.T) {
	opponent, result, fail := get_result([]u8{'B', ' ', 'X', '\n'})
	testing.expect_value(t, fail, false)
	you := get_hand_by_result(opponent, result)
	testing.expect_value(t, opponent, Hand.Paper)
	testing.expect_value(t, you, Hand.Rock)
	score := get_points(opponent, you)
	testing.expect_value(t, score, 1)
}

@(test)
day_2_test_round_6 :: proc(t: ^testing.T) {
	opponent, result, fail := get_result([]u8{'C', ' ', 'Z', '\n'})
	testing.expect_value(t, fail, false)
	you := get_hand_by_result(opponent, result)
	testing.expect_value(t, opponent, Hand.Scisors)
	testing.expect_value(t, you, Hand.Rock)
	score := get_points(opponent, you)
	testing.expect_value(t, score, 7)
}
