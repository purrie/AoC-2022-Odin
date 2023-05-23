package main

import "core:strconv"
import "core:fmt"
import "core:os"
import "core:bufio"
import "core:strings"

day_5 :: proc() {
	handle, breader, ok := read_input("crate-stacks.txt")
	if !ok {
		fmt.eprintln("Failed to open input for day 5")
		return
	}
	defer os.close(handle)
	defer bufio.reader_destroy(&breader)

	stacks := get_stacks(&breader)
	stacks_9001 := clone_stacks(stacks)
	defer {
		for stack in stacks {
			delete(stack)
		}
		delete(stacks)
		for stack in stacks_9001 {
			delete(stack)
		}
		delete(stacks_9001)
	}

	line, err := bufio.reader_read_slice(&breader, '\n')
	for err == .None {
		move, src, dst, ok := read_instruction(line)
		if !ok {
			fmt.eprintln("Failed to read instruction!", line)
			return
		}
		move_stack_item(dst, src, move, stacks)
		move_stack_items(dst, src, move, stacks_9001)
		line, err = bufio.reader_read_slice(&breader, '\n')
	}

	top := get_top_stacks(&stacks)
	top_9001 := get_top_stacks(&stacks_9001)
	defer delete(top)

	{
		str, err := strings.clone_from_bytes(top[:], context.temp_allocator)
		if err != .None {
			fmt.eprintln("Error: Couldn't stringify result of day 5 part 1", err)
			return
		}
		str2, err2 := strings.clone_from_bytes(top_9001[:], context.temp_allocator)
		if err2 != .None {
			fmt.eprintln("Error: Couldn't stringify result of day 5 part 1", err)
			return
		}
		fmt.printf("Day 5\n  Part 1: {}\n  Part 2: {}\n", str, str2)
	}
}

clone_stacks :: proc ( stacks : [dynamic][dynamic]u8 ) -> [dynamic][dynamic]u8 {
	clone := make([dynamic][dynamic]u8)
	for stack in stacks {
		cloned := make([dynamic]u8)
		for item in stack {
			append(&cloned, item)
		}
		append(&clone, cloned)
	}
	return clone
}

get_stacks :: proc ( breader : ^bufio.Reader ) -> [dynamic][dynamic]u8 {
	crates := make( [dynamic][dynamic]u8 )
	defer {
		for line in crates {
			delete(line)
		}
		delete(crates)
	}
	line, err := bufio.reader_read_slice(breader, '\n')

	for err == .None {
		if len(line) <= 2 {
			break;
		}
		row := make( [dynamic]u8 )
		for c in line {
			append(&row, c)
		}
		append(&crates, row)
		line, err = bufio.reader_read_slice(breader, '\n')
	}

	index_line := len(crates) - 1
	index_cols := len(crates[index_line])

	stacks := make( [dynamic][dynamic]u8 )

	for col in 0..<index_cols {
		c := crates[index_line][col]
		switch c {
		case '0'..='9':
			stack := make( [dynamic]u8 )
			for i := index_line - 1; i >= 0; i -= 1 {
				c := crates[i][col]
				if c != ' ' {
					append(&stack, c)
				} else {
					break
				}
			}
			append(&stacks, stack)
		case ' ', '\n':
		case :
			fmt.eprintln("Unexpected column index", c)
		}
	}

	return stacks
}

move_stack_item :: proc ( dst, src, amount : int, stacks : [dynamic][dynamic]u8 ) {
	for _ in 0..<amount {
		mov : u8 = pop(&stacks[src-1])
		append(&stacks[dst-1], mov)
	}
}

move_stack_items :: proc ( dst, src, amount : int, stacks : [dynamic][dynamic]u8 ) {
	length := len(stacks[src-1])
	index := length - amount
	dest := &stacks[dst-1]
	sorc := stacks[src-1][index:]
	for elm in sorc {
		append_elems(dest, elm)
	}
	remove_range(&stacks[src-1], index, length)
}

get_top_stacks :: proc ( stacks : ^[dynamic][dynamic]u8 ) -> [dynamic]u8 {
	tops := make( [dynamic]u8 )
	for stack in stacks {
		last := len(stack) - 1
		top  := stack[last]
		append(&tops, top)
	}
	return tops
}

read_instruction :: proc ( line : []u8 ) -> ( move : int = -1, source : int = -1, dest : int = -1, ok : bool = true ) {
	cursor, mode := -1, 0
	length := len(line)
	for i in 0..<length {
		if line[i] != ' ' && cursor < 0 {
			cursor = i
		}
		if (line[i] == ' ' || i == length - 1)  && cursor >= 0 {
			defer cursor = -1
			cmd := line[cursor:i]
			str, err := strings.clone_from_bytes(cmd, context.temp_allocator)
			if err != .None {
				fmt.eprintln("Error: Couldn't clone bytes into string", err)
				return move, source, dest, false
			}

			if mode == 0 {
				switch str {
				case "move":
					mode = 1
				case "from":
					mode = 2
				case "to":
					mode = 3
				}
			} else {
				if val, ok := strconv.parse_int(str); ok {
					switch mode {
					case 1:
						move = val
					case 2:
						source = val
					case 3:
						dest = val
					}
				} else {
					fmt.eprintln("Error: Tried to convert", str, "into int but failed")
				}
				mode = 0
			}
		}
	}
	if move == -1 || source == -1 || dest == -1 {
		fmt.eprintln("Error: one or more of returns is 0")
		return move, source, dest, false
	}
	return
}

