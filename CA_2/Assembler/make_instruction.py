'------------------------------------------------------Instructions---------------------------------------------------'
"add x_i, x_j, x_k"
"sub x_i, x_j, x_k"
"and x_i, x_j, x_k"
"or x_i, x_j, x_k"
"addi x_i, x_j, Number"
"ori x_i, x_j, Number"
"lw x_i, offset(x_j)"
"slti x_i, x_j, Number"
"jalr x_i, x_j"
"jal x_i, label(Number)"
"beq x_i, x_j, label(Number)"
"bne x_i, x_j, label(Number)"
"lui x_i, Number(20 bit)"

"you can replace your assembly file name into the empty strings: "
InputFileName = "testcases/1.txt"
OutputFileName = "hex_testcases/1.txt"

"you can change the output format, True for hex, False for decimal"
HexFlag = True
'--------------------------------------------------------------------------------------------------------------------'

REGISTER_MAP = {
    "zero": "x0",  "ra": "x1",   "sp": "x2",   "gp": "x3",
    "tp": "x4",    "t0": "x5",   "t1": "x6",   "t2": "x7",
    "s0": "x8",    "fp": "x8",   "s1": "x9",   "a0": "x10",
    "a1": "x11",   "a2": "x12",  "a3": "x13",  "a4": "x14",
    "a5": "x15",   "a6": "x16",  "a7": "x17",  "s2": "x18",
    "s3": "x19",   "s4": "x20",  "s5": "x21",  "s6": "x22",
    "s7": "x23",   "s8": "x24",  "s9": "x25",  "s10": "x26",
    "s11": "x27",  "t3": "x28",  "t4": "x29",  "t5": "x30",
    "t6": "x31"
}

def normalize_registers(assembly_parts):
    return [REGISTER_MAP.get(part, part) for part in assembly_parts]

def parse_labels(filename):
    label_addresses = {}
    clean_lines = []

    with open(filename, 'r') as file:
        address = 0
        for line in file:
            line = line.strip()
            if not line:
                continue
            if ':' in line:
                label = line.replace(':', '').strip()
                label_addresses[label] = address
                continue
            line = line.replace(',', '')
            line = line.replace('(', ' ')
            line = line.replace(')', ' ')
            parts = line.split()
            clean_lines.append(parts)
            address += 1

    return label_addresses, clean_lines


def decimal_to_binary(n, num):
    num_int = int(num)
    if num_int >= 0:
        bits = bin(num_int)[2:]
    else:
        bits = bin((1 << n) + num_int)[2:]
    return bits.zfill(n)

def opcodeDecider(type):
    if type == "R_Type":
        inst = "0110011"
    elif type == "I_Type(lw)":
        inst = "0000011"
    elif type == "I_Type(Alu)":
        inst = "0010011"
    elif type == "I_Type(jalr)":
        inst = "1100111"
    elif type == "S_Type":
        inst = "0100011"
    elif type == "B_Type":
        inst = "1100011"
    elif type == "U_Type":
        inst = "0110111"
    elif type == "J_Type":
        inst = "1101111"
    else:
        inst = "0000000"
    return inst

def functionType(func):
    r_type = ["add", "sub", "and", "or", "slt"]
    i_type_lw = ["lw"]
    i_type_alu = ["addi", "ori", "slti"]
    i_type_jalr = ["jalr"]
    s_type = ["sw"]
    b_type = ["beq", "bne"]
    j_type = ["jal"]
    u_type = ["lui"]
    if func.lower() in r_type:
        return "R_Type"
    elif func.lower() in i_type_lw:
        return "I_Type(lw)"
    elif func.lower() in i_type_alu:
        return "I_Type(Alu)"
    elif func.lower() in i_type_jalr:
        return "I_Type(jalr)"
    elif func.lower() in s_type:
        return "S_Type"
    elif func.lower() in b_type:
        return "B_Type"
    elif func.lower() in j_type:
        return "J_Type"
    elif func.lower() in u_type:
        return "U_Type"

def InstMaker(functionName="r_type"):
    def R_TypeInstMaker(func_type, rd, x1, x2, opcode):
        inst = decimal_to_binary(5, rd[1:]) + opcode
        if func_type.lower() == "add":
            inst = "000" + inst
        elif func_type.lower() == "sub":
            inst = "000" + inst
        elif func_type.lower() == "and":
            inst = "111" + inst
        elif func_type.lower() == "or":
            inst = "110" + inst
        elif func_type.lower() == "slt":
            inst = "010" + inst
        else :
            raise ValueError("can't make instruction")
        
        inst = decimal_to_binary(5, x2[1:]) + decimal_to_binary(5, x1[1:]) + inst
        if func_type.lower() == "add":
            inst = "0000000" + inst
        elif func_type.lower() == "sub":
            inst = "0100000" + inst
        elif func_type.lower() == "and":
            inst = "0000000" + inst
        elif func_type.lower() == "or":
            inst = "0000000" + inst
        elif func_type.lower() == "slt":
            inst = "0000000" + inst
        else :
            raise ValueError("can't make instruction")
        
        return inst

    def I_TypeInstMaker(func_type, rd, rs, imm, opcode):
        inst = decimal_to_binary(5, rd[1:]) + opcode
        if func_type.lower() == "lw":
            inst = "010" + inst
        elif func_type.lower() == "addi":
            inst = "000" + inst
        elif func_type.lower() == "ori":
            inst = "110" + inst
        elif func_type.lower() == "slti":
            inst = "010" + inst
        elif func_type.lower() == "jalr":
            inst = "000" + inst
        else :
            raise ValueError("can't make instruction")
        
        inst = decimal_to_binary(5, rs[1:]) + inst
        inst = decimal_to_binary(12, imm) + inst

        return inst

    def S_TypeInstMaker(func_type, x1, x2, imm, opcode):
        imm_bin = decimal_to_binary(12, imm)
        inst = imm_bin[-5:] + opcode
        if func_type.lower() == "sw":
            inst = "010" + inst
        else:
            raise ValueError("can't make instruction")
        
        inst = decimal_to_binary(5, x1[1:]) + inst
        inst = decimal_to_binary(5, x2[1:]) + inst
        inst = imm_bin[:-5] + inst

        return inst

    def B_TypeInstMaker(func_type, x1, x2, imm, opcode):
        imm_bin = decimal_to_binary(12, imm)
        inst = imm_bin[-5:-1] + imm_bin[-11] + opcode
        if func_type.lower() == "beq":
            inst = "000" + inst
        elif func_type.lower() == "bne":
            inst = "001" + inst
        else:
            raise ValueError("can't make instruction")
        inst = decimal_to_binary(5, x1[1:]) + inst
        inst = decimal_to_binary(5, x2[1:]) + inst
        inst = imm_bin[-12] + imm_bin[-11:-5] + inst

        return inst

    def J_TypeInstMaker(rd, imm, opcode):
        imm_bin = decimal_to_binary(20, imm)
        imm_bin = imm_bin[0] + imm_bin
        inst = decimal_to_binary(5, rd[1:]) + opcode
        inst = imm_bin[-20] + imm_bin[-11:-1] + imm_bin[-11] + imm_bin[-20:-12] + inst

        return inst

    def U_TypeInstMaker(rd, imm, opcode):
        inst = decimal_to_binary(5, rd[1:]) + opcode
        inst = decimal_to_binary(20, imm) + inst
        
        return inst

    functionOptions = {
        "r_type": R_TypeInstMaker,
        "i_type(lw)": I_TypeInstMaker,
        "i_type(alu)": I_TypeInstMaker,
        "i_type(jalr)": I_TypeInstMaker,
        "s_type": S_TypeInstMaker,
        "b_type": B_TypeInstMaker,
        "u_type": U_TypeInstMaker,
        "j_type": J_TypeInstMaker
    }

    selectedFunction = functionOptions.get(functionName.lower())
    if selectedFunction:
        return selectedFunction


def assembler_sim():
    label_map, lines = parse_labels(InputFileName)
    machine_codes = []

    for pc, parts in enumerate(lines):
        parts = normalize_registers(parts)
        mnemonic = parts[0].lower()
        itype = functionType(mnemonic)
        opcode = opcodeDecider(itype)
        maker = InstMaker(itype)

        rd = rs1 = rs2 = imm_val = None
        if itype == 'R_Type':
            rd, rs1, rs2 = parts[1], parts[2], parts[3]

        elif itype == 'I_Type(lw)':
            rd, imm_val, rs1 = parts[1], parts[2], parts[3]

        elif itype in ['I_Type(Alu)', 'I_Type(jalr)']:
            rd, rs1, imm_val = parts[1], parts[2], parts[3]

        elif itype == 'S_Type':
            rs2, imm_val, rs1 = parts[1], parts[2], parts[3]

        elif itype == 'B_Type':
            rs1, rs2, label = parts[1], parts[2], parts[3]
            if label not in label_map:
                raise ValueError(f"Undefined label: {label}")
            # offset in bytes from next instruction
            offset = (label_map[label] - pc) << 2
            imm_val = str(offset)

        elif itype == 'U_Type':
            rd, imm_val = parts[1], parts[2]

        elif itype == 'J_Type':
            rd, label = parts[1], parts[2]
            if label not in label_map:
                raise ValueError(f"Undefined label: {label}")
            offset = (label_map[label] - pc) << 2
            imm_val = str(offset)

        else:
            raise ValueError(f"Unsupported mnemonic: {mnemonic}")


        if itype == 'R_Type':
            bin_inst = maker(mnemonic, rd, rs1, rs2, opcode)
        elif itype in ['I_Type(lw)', 'I_Type(Alu)', 'I_Type(jalr)']:
            bin_inst = maker(mnemonic, rd, rs1, imm_val, opcode)
        elif itype == 'S_Type':
            bin_inst = maker(mnemonic, rs1, rs2, imm_val, opcode)
        elif itype == 'B_Type':
            bin_inst = maker(mnemonic, rs1, rs2, imm_val, opcode)
        elif itype == 'U_Type':
            bin_inst = maker(rd, imm_val, opcode)
        elif itype == 'J_Type':
            bin_inst = maker(rd, imm_val, opcode)

        machine_codes.append(bin_inst)

    return machine_codes


insts = assembler_sim()
if HexFlag:
    hex_list = [format(int(b, 2), '08X') for b in insts]
else:
    hex_list = insts

with open(OutputFileName, 'w') as file:
    for i, item in enumerate(hex_list):
        if i < len(hex_list) - 1:
            file.write(str(item) + '\n')
        else:
            file.write(str(item))