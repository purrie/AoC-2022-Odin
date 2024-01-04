package main

import "core:bufio"
import "core:fmt"
import "core:bytes"
import "core:strings"
import "core:testing"
import "core:os"

day_7 :: proc() {
	handle, buffer, ok := read_input("space-on-device.txt")
	if !ok {
		fmt.eprintln("Failed to open input file for day 6")
		return
	}
	defer os.close(handle)
	defer bufio.reader_destroy(&buffer)

	fs := build_file_system(&buffer)
	defer tear_down_file_system(&fs)
	sum : uint = 0
	count_size(&fs.root, &sum)
	space := calculate_size(&fs)

	fmt.println("Day 7 answer:\n  Part 1:", sum, "\n  Part 2:", space)
}

Command :: enum {
	cd, cd_root, cd_up, ls,
}

is_command :: proc(line : []u8) -> bool {
	return len(line) >= 4 && line[0] == '$'
}

// can't have string literals be treated as array of bytes?
str_eql :: proc(a: []u8, b : string) -> bool {
	length := len(a)
	if length != len(b) { return false }
	for i := 0; i < length; i += 1 {
		if a[i] != b[i] { return false }
	}
	return true
}

parse_uint :: proc(str : []u8) -> ( result : uint = 0, success : bool = false ) {
	for i := 0; i < len(str); i += 1 {
		c := str[i]
		switch c {
		case '0'..='9':
			result *= 10
			result += uint(c - '0')
		case:
			return
		}
	}
	success = true
	return
}

get_command_type :: proc(line : []u8) -> (command : Command = nil, dir : []u8 = nil) {
	if str_eql(line[2:4], "ls") {
		command = .ls
	}
	else if str_eql(line[2:4], "cd") {
		if line [5] == '.' {
			command = .cd_up
		}
		else if line[5] == '/' {
			command = .cd_root
		}
		else {
			command = .cd
			dir = line[5:]
		}
	}
	return
}

get_contents :: proc(line : []u8) -> (name : []u8 = nil, size : uint = 0, is_dir : bool = false) {
	if str_eql(line[:3], `dir`) {
		is_dir = true
		name = line[4:]
	}
	else {
		is_dir = false
		div : uint = 0
		for line[div] != ' ' && div < len(line) { div += 1 }
		size = parse_uint(line[:div]) or_return
		div += 1
		name = line[div:]
	}
	return
}

File :: struct {
	name : []u8,
	size : uint,
}

Directory :: struct {
	name    : []u8,
	subdirs : [dynamic]Directory,
	files   : [dynamic]File,
	parent  : ^Directory,
	size    : uint,
}

FileSystem :: struct {
	root : Directory,
	cwd  : ^Directory,
}

count_size :: proc(dir : ^Directory, sum : ^uint) -> (result : uint = 0) {
	if dir.size == 0 {
		for _, i in dir.subdirs {
			result += count_size(&dir.subdirs[i], sum)
		}
		for _, i in dir.files {
			result += dir.files[i].size
		}
		dir.size = result;
	}
	else {
		result = dir.size
	}

	if result <= 100000 && sum != nil {
		sum^ += result
	}

	return
}

find_size :: proc(dir : ^Directory, threshold : uint) -> (result : uint = 0) {
	result = dir.size
	for _, i in dir.subdirs {
		child := find_size(&dir.subdirs[i], threshold)
		if child < result && child >= threshold {
			result = child
		}
	}

	return
}

calculate_size :: proc(fs : ^FileSystem) -> (result : uint = 0) {
	total_space  : uint : 70000000
	update_size  : uint : 30000000
	total_used   : uint = count_size(&fs.root, nil)
	needed_space : uint = update_size - (total_space - total_used)

	result = find_size(&fs.root, needed_space)

	return
}

execute_command :: proc(fs : ^FileSystem, cmd : Command, arg : []u8) {
	switch cmd {
	case .cd:
		for _, i in fs.cwd.subdirs {
			if bytes.equal(arg, fs.cwd.subdirs[i].name) {
				fs.cwd = &fs.cwd.subdirs[i];
				return
			}
		}
		fmt.eprintln("Failed to find directory", arg, "in folder", fs.cwd.name)
	case .cd_root:
		fs.cwd = &fs.root
	case .cd_up:
		fs.cwd = fs.cwd.parent
	case .ls:
	}
}

add_file :: proc(fs : ^FileSystem, name : []u8, size : uint) {
	file : File
	file.name = make([]u8, len(name))
	copy_slice(file.name, name)
	file.size = size
	append(&fs.cwd.files, file)
	dir := fs.cwd
	for dir != nil {
		dir.size = 0
		dir = dir.parent
	}
}

add_folder :: proc(fs : ^FileSystem, name : []u8) {
	folder : Directory
	folder.name = make([]u8, len(name))
	copy(folder.name, name)
	folder.parent = fs.cwd
	folder.subdirs = make([dynamic]Directory)
	folder.files = make([dynamic]File)
	append(&fs.cwd.subdirs, folder)
}

build_file_system :: proc(reader : ^bufio.Reader) -> (result : FileSystem) {
	result.root.name = make([]u8, 1)
	result.root.name[0] = '/'
	result.cwd = &result.root

	line, err := bufio.reader_read_slice(reader, '\n');

	for err == .None {
		if is_command(line) {
			command, data := get_command_type(line)
			execute_command(&result, command, data)
		}
		else {
			name, size, dir := get_contents(line)
			if dir {
				add_folder(&result, name)
			}
			else {
				add_file(&result, name, size)
			}
		}
		line, err = bufio.reader_read_slice(reader, '\n');
	}

	return
}

tear_down_file_system :: proc(fs : ^FileSystem) {
	tear_down_directory(&fs.root)
}

tear_down_directory :: proc(dir : ^Directory) {
	for _, i in dir.subdirs {
		tear_down_directory(&dir.subdirs[i])
	}
	delete(dir.subdirs)
	for _, i in dir.files {
		delete(dir.files[i].name)
	}
	delete(dir.files)
	delete(dir.name)
}

@(test)
day_7_test_1 :: proc (t : ^testing.T) {
	input ::"$ cd /\n" +
			"$ ls\n" +
			"dir a\n" +
			"14848514 b.txt\n" +
			"8504156 c.dat\n" +
			"dir d\n" +
			"$ cd a\n" +
			"$ ls\n" +
			"dir e\n" +
			"29116 f\n" +
			"2557 g\n" +
			"62596 h.lst\n" +
			"$ cd e\n" +
			"$ ls\n" +
			"584 i\n" +
			"$ cd ..\n" +
			"$ cd ..\n" +
			"$ cd d\n" +
			"$ ls\n" +
			"4060174 j\n" +
			"8033020 d.log\n" +
			"5626152 d.ext\n" +
			"7214296 k\n"

	r : strings.Reader
	ior := strings.to_reader(&r, input)
	br : bufio.Reader
	bufio.reader_init(&br, ior)
	defer bufio.reader_destroy(&br)

	fs := build_file_system(&br)
	sum : uint = 0
	count_size(&fs.root, &sum)
	testing.expect_value(t, sum, 95437)
}

@(test)
day_7_test_2 :: proc (t : ^testing.T) {
	input ::"$ cd /\n" +
			"$ ls\n" +
			"dir a\n" +
			"14848514 b.txt\n" +
			"8504156 c.dat\n" +
			"dir d\n" +
			"$ cd a\n" +
			"$ ls\n" +
			"dir e\n" +
			"29116 f\n" +
			"2557 g\n" +
			"62596 h.lst\n" +
			"$ cd e\n" +
			"$ ls\n" +
			"584 i\n" +
			"$ cd ..\n" +
			"$ cd ..\n" +
			"$ cd d\n" +
			"$ ls\n" +
			"4060174 j\n" +
			"8033020 d.log\n" +
			"5626152 d.ext\n" +
			"7214296 k\n"

	r : strings.Reader
	ior := strings.to_reader(&r, input)
	br : bufio.Reader
	bufio.reader_init(&br, ior)
	defer bufio.reader_destroy(&br)

	fs := build_file_system(&br)
	space := calculate_size(&fs)
	testing.expect_value(t, space, 24933642)
}
