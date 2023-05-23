package tests

import main "../src"
import "core:strconv"
import "core:fmt"
import "core:os"
import "core:io"
import "core:bufio"
import "core:strings"
import "core:testing"


@(test)
day_5_part_1_test :: proc ( t : ^testing.T ) {
	input := "    [D]    \n" +
		     "[N] [C]    \n" +
		     "[Z] [M] [P]\n" +
		     " 1   2   3 \n" +
			 " \n" +
		     "move 1 from 2 to 1\n" +
		     "move 3 from 1 to 3\n" +
		     "move 2 from 2 to 1\n" +
		     "move 1 from 1 to 2\n"

	reader : strings.Reader
	breader : bufio.Reader

	bufio.reader_init(&breader, strings.to_reader(&reader, input))

	stacks := main.get_stacks(&breader)
	testing.expect_value(t, len(stacks), 3)
	testing.expect_value(t, len(stacks[0]), 2)
	testing.expect_value(t, len(stacks[1]), 3)
	testing.expect_value(t, len(stacks[2]), 1)

	{
		line, err := bufio.reader_read_slice(&breader, '\n')
		testing.expect_value(t, err, io.Error.None)
		move, src, dst, ok := main.read_instruction(line)
		testing.expect(t, ok)
		testing.expect_value(t, move, 1)
		testing.expect_value(t, src, 2)
		testing.expect_value(t, dst, 1)
		main.move_stack_item(dst, src, move, stacks)
	}
	{
		line, err := bufio.reader_read_slice(&breader, '\n')
		move, src, dst, ok := main.read_instruction(line)
		testing.expect(t, ok)
		testing.expect_value(t, move, 3)
		testing.expect_value(t, src, 1)
		testing.expect_value(t, dst, 3)
		main.move_stack_item(dst, src, move, stacks)
	}
	{
		line, err := bufio.reader_read_slice(&breader, '\n')
		move, src, dst, ok := main.read_instruction(line)
		testing.expect(t, ok)
		testing.expect_value(t, move, 2)
		testing.expect_value(t, src, 2)
		testing.expect_value(t, dst, 1)
		main.move_stack_item(dst, src, move, stacks)
	}
	{
		line, err := bufio.reader_read_slice(&breader, '\n')
		move, src, dst, ok := main.read_instruction(line)
		testing.expect(t, ok)
		testing.expect_value(t, move, 1)
		testing.expect_value(t, src, 1)
		testing.expect_value(t, dst, 2)
		main.move_stack_item(dst, src, move, stacks)
	}
	result := main.get_top_stacks(&stacks)
	testing.expect_value(t, len(result), 3)
	testing.expect_value(t, result[0], 'C')
	testing.expect_value(t, result[1], 'M')
	testing.expect_value(t, result[2], 'Z')
}

@(test)
day_5_part_2_test :: proc ( t : ^testing.T ) {
	input := "    [D]    \n" +
		     "[N] [C]    \n" +
		     "[Z] [M] [P]\n" +
		     " 1   2   3 \n" +
			 " \n" +
		     "move 1 from 2 to 1\n" +
		     "move 3 from 1 to 3\n" +
		     "move 2 from 2 to 1\n" +
		     "move 1 from 1 to 2\n"

	reader : strings.Reader
	breader : bufio.Reader

	bufio.reader_init(&breader, strings.to_reader(&reader, input))

	stacks := main.get_stacks(&breader)
	testing.expect_value(t, len(stacks), 3)
	testing.expect_value(t, len(stacks[0]), 2)
	testing.expect_value(t, len(stacks[1]), 3)
	testing.expect_value(t, len(stacks[2]), 1)

	{
		line, err := bufio.reader_read_slice(&breader, '\n')
		testing.expect_value(t, err, io.Error.None)
		move, src, dst, ok := main.read_instruction(line)
		testing.expect(t, ok)
		testing.expect_value(t, move, 1)
		testing.expect_value(t, src, 2)
		testing.expect_value(t, dst, 1)
		main.move_stack_items(dst, src, move, stacks)
	}
	{
		line, err := bufio.reader_read_slice(&breader, '\n')
		move, src, dst, ok := main.read_instruction(line)
		testing.expect(t, ok)
		testing.expect_value(t, move, 3)
		testing.expect_value(t, src, 1)
		testing.expect_value(t, dst, 3)
		main.move_stack_items(dst, src, move, stacks)
	}
	{
		line, err := bufio.reader_read_slice(&breader, '\n')
		move, src, dst, ok := main.read_instruction(line)
		testing.expect(t, ok)
		testing.expect_value(t, move, 2)
		testing.expect_value(t, src, 2)
		testing.expect_value(t, dst, 1)
		main.move_stack_items(dst, src, move, stacks)
	}
	{
		line, err := bufio.reader_read_slice(&breader, '\n')
		move, src, dst, ok := main.read_instruction(line)
		testing.expect(t, ok)
		testing.expect_value(t, move, 1)
		testing.expect_value(t, src, 1)
		testing.expect_value(t, dst, 2)
		main.move_stack_items(dst, src, move, stacks)
	}

	result := main.get_top_stacks(&stacks)

	testing.expect_value(t, len(result), 3)
	testing.expect_value(t, result[0], 'M')
	testing.expect_value(t, result[1], 'C')
	testing.expect_value(t, result[2], 'D')
}
