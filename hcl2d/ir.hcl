register pP {  
	pc:64 = 0;
}

register cC {
    SF:1 = 0;
    ZF:1 = 0;
}


Stat = [
	icode in {HALT} : STAT_HLT;
	icode > 0xb : STAT_INS;
	1: STAT_AOK;
];

#######Fetch#######

pc = P_pc;

wire icode:4, ifun:4, rA:4, rB:4, valC:64, valP:64, valA:64, valB:64, valE:64, valM:64, conditionsMet:1;

icode = i10bytes[4..8];
ifun = i10bytes[0..4];

rA = i10bytes[12..16];
rB = i10bytes[8..12];

valC = [
	icode in { JXX} : i10bytes[8..72];
	1: i10bytes[16..80];
];

valP = [
	icode in { HALT, NOP} : P_pc + 1;
	icode in { RRMOVQ, OPQ, CMOVXX, PUSHQ, POPQ} : P_pc + 2;
	icode in { JXX} : P_pc + 9;
	icode in { IRMOVQ, MRMOVQ, RMMOVQ} : P_pc + 10;
];



#######Decode#####################

reg_srcA = [
	icode in { RRMOVQ, OPQ, CMOVXX, RMMOVQ, PUSHQ} : rA;
	icode in { POPQ} : REG_RSP;
	1: REG_NONE;
];

valA = [
	icode in { RRMOVQ, OPQ, CMOVXX, RMMOVQ, PUSHQ, POPQ} : reg_outputA;
	1: 0;
];

reg_srcB = [
	icode in { OPQ, RMMOVQ, MRMOVQ} : rB;
	icode in { PUSHQ, POPQ} : REG_RSP;
	1: REG_NONE;
];

valB = [
	icode in { OPQ, RMMOVQ, MRMOVQ, PUSHQ, POPQ} : reg_outputB;
	1: 0;
];


#######Execute#####################

conditionsMet = [
	ifun == ALWAYS : true;
	ifun == LE : C_SF || C_ZF;
	ifun == LT : C_SF;
	ifun == EQ : C_ZF;
	ifun == NE : !C_ZF;
	ifun == GE : !C_SF;
	ifun == GT : !C_SF && !C_ZF;
	1 : false;
];

valE = [
	icode in { IRMOVQ} : valC;
	icode in { RRMOVQ, CMOVXX} : valA;
	icode in { RMMOVQ, MRMOVQ} : valB + valC;
	icode in { PUSHQ} : valB - 8;
	icode in { POPQ} : valB + 8;
	icode == OPQ && ifun == XORQ : valA ^ valB;
	icode == OPQ && ifun == ADDQ : valA + valB;
	icode == OPQ && ifun == SUBQ : valB - valA;
	icode == OPQ && ifun == ANDQ : valA & valB;
	1: 0;
];

stall_C = (icode != OPQ);
c_ZF = (valE == 0);
c_SF = (valE >= 0x8000000000000000);


#######Memory#####################

mem_readbit = [
	icode in { RMMOVQ, PUSHQ} : 0;
	icode in { MRMOVQ, POPQ} : 1;
];

mem_writebit = [
	icode in { RMMOVQ, PUSHQ} : 1;
	icode in { MRMOVQ, POPQ} : 0;
];

mem_addr = [
	icode in { RMMOVQ, MRMOVQ, PUSHQ} : valE;
	icode in { POPQ} : valA;
];

mem_input = [
	icode in { RMMOVQ, PUSHQ} : valA;
];

valM = [
	icode in {MRMOVQ, POPQ} : mem_output;
];

#######Write back#####################



reg_dstE = [
	!conditionsMet && icode == CMOVXX : REG_NONE;
	icode in {IRMOVQ, RRMOVQ, OPQ, CMOVXX} : rB;
	icode in { PUSHQ, POPQ} : REG_RSP;
	icode in { MRMOVQ} : rA;
	1: REG_NONE;
];

reg_inputE = [
	!conditionsMet && icode == CMOVXX : 0;
	icode in {IRMOVQ, RRMOVQ, OPQ, CMOVXX, PUSHQ, POPQ} : valE;
	icode in { MRMOVQ} : valM;
	1: 0;
];

reg_dstM = [
	icode in { POPQ} : rA;
];

reg_inputM = [
	icode in { POPQ} : valM;
];

#######PC update#####################

p_pc = [
	icode == JXX && conditionsMet : valC;
	1: valP;
];