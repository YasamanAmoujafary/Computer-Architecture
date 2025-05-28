def assemble(instruction_line):
    opcode_map = {
        "ADD": "000",
        "SUB": "001",
        "AND": "010",
        "NOT": "011",
        "PUSH": "100",
        "POP": "101",
        "JMP": "110",
        "JZ": "111"
    }

    parts = instruction_line.strip().split()

    if len(parts) == 1:
        mnemonic = parts[0].upper()
        opcode = opcode_map.get(mnemonic)
        if opcode:
            return opcode + "00000"
    elif len(parts) == 2:
        mnemonic = parts[0].upper()
        operand = int(parts[1])
        opcode = opcode_map.get(mnemonic)
        if opcode and 0 <= operand < 32:
            operand_bin = format(operand, '05b')
            return opcode + operand_bin

    raise ValueError(f"Invalid instruction or operand: {instruction_line}")


def assemble_from_file(input_file_path, output_file_path):
    with open(input_file_path, 'r') as infile, open(output_file_path, 'w') as outfile:
        for line in infile:
            if line.strip():
                try:
                    binary = assemble(line)
                    outfile.write(binary + '\n')
                except ValueError as e:
                    print(f"Error: {e}")


# Run the assembler
assemble_from_file(input_file_path='instructions.txt', output_file_path='inst.mem')
print("Assembly complete. Output written to output.bin.")