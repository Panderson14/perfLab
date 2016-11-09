register pP {  
    # our own internal register. P_pc is its output, p_pc is its input.
	pc:64 = 0; # 64-bits wide; 0 is its default value.
	
	# we could add other registers to the P register bank
	# register bank should be a lower-case letter and an upper-case letter, in that order.
	
	# there are also two other signals we can optionally use:
	# "bubble_P = true" resets every register in P to its default value
	# "stall_P = true" causes P_pc not to change, ignoring p_pc's value
} 

pc = P_pc;

wire opcode:8, icode:4, ifun:4;

opcode = i10bytes[0..8];   # first byte read from instruction memory
icode = opcode[4..8];      # top nibble of that byte
ifun = opcode[0..4];

wire rA:4;
wire rB:4;

rA = [
	icode==RRMOVQ : i10bytes[12..16];
	icode==OPQ : i10bytes[12..16];
];

reg_srcA = rA;
reg_srcB = rB;

rB = [
	icode==IRMOVQ : i10bytes[8..12];
	icode==RRMOVQ : i10bytes[8..12];
	icode==OPQ : i10bytes[12..16];
];

reg_dstE = [
	icode==IRMOVQ : rB;
	icode==RRMOVQ : rB;
	icode==OPQ : rB;
	1 : REG_NONE;
];




wire valC:64;
valC = [
	icode==IRMOVQ : i10bytes[16..80];
	icode==RRMOVQ : reg_outputA;
	icode==OPQ && ifun == ADDQ : reg_outputA + reg_outputB;
	icode==OPQ && ifun == SUBQ : reg_outputB - reg_outputA;
	icode==OPQ && ifun == ANDQ : reg_outputA & reg_outputB;
	icode==OPQ && ifun == XORQ : reg_outputA ^ reg_outputB;
];

reg_inputE = [
	icode==IRMOVQ : valC;
	icode==RRMOVQ : valC;
	icode==OPQ : valC;
];


register cC {
    SF:1 = 0;
    ZF:1 = 0;
}
stall_C = (icode != OPQ);
c_ZF = (valC == 0);
c_SF = (valC >= 0x8000000000000000);



Stat = [
	icode == HALT : STAT_HLT;
	icode > 0xb	  : STAT_INS;
	1             : STAT_AOK;
];




p_pc = [
	icode==NOP : P_pc + 1;
	icode==RRMOVQ : P_pc + 2;
	icode==IRMOVQ : P_pc + 10;
	icode==RMMOVQ : P_pc + 10;
	icode==MRMOVQ : P_pc + 10;
	icode==OPQ : P_pc + 2;
	icode==PUSHQ : P_pc + 2;
	icode==POPQ : P_pc + 2;
	icode==CMOVXX : P_pc + 2;
	icode==JXX : P_pc + 9;
	icode==CALL : P_pc + 9;
	icode==RET : P_pc + 1;
	icode==HALT : P_pc + 1;
];

