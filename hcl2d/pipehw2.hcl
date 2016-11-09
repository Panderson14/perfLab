######### The PC #############
register xF {
	pc:64 = 0;
	predPC:64 = 0;
}

register cC {
	SF:1 = 0;
	ZF:1 = 0;
}


########## Fetch #############
pc = F_pc;

f_icode = i10bytes[4..8];
f_ifun = i10bytes[0..4];
f_rA = i10bytes[12..16];
f_rB = i10bytes[8..12];

f_valC = [
	f_icode in { JXX, CALL } : i10bytes[8..72];
	1 : i10bytes[16..80];
];

wire offset:64;
offset = [
	f_icode in { HALT, NOP, RET } : 1;
	f_icode in { RRMOVQ, OPQ, PUSHQ, POPQ, CMOVXX } : 2;
	f_icode in { JXX, CALL } : 9;
	1 : 10;
];

f_valP = F_pc + offset;

x_predPC = [
	# m_icode == RET : m_valM;
	f_icode in { JXX, CALL } : f_valC;
	1 : f_valP;
];

wire mispredicted:1;

mispredicted = [
	(M_icode == JXX) && (!e_conditionsMet) : true;
	1: false;
];

x_pc = [
	W_icode == RET : W_valM;
	mispredicted: M_valA;
	1: F_predPC;

	# f_icode in { JXX } : f_valC;
	# 1 : f_valP;
];

f_stat = [
	f_icode == HALT : STAT_HLT;
	f_icode > 0xb : STAT_INS;
	1 : STAT_AOK;
];


########## Decode #############
# figure 4.56 on page 426

register fD {
	stat:3 = STAT_BUB;
	icode:4 = NOP;
	ifun:4 = 0;
	rA:4 = REG_NONE;
	rB:4 = REG_NONE;
	valC:64 = 0;
	valP:64 = 0;
}



reg_srcA = [ # send to register file as read port; creates reg_outputA
	D_icode in {RMMOVQ, RRMOVQ, OPQ, CMOVXX, PUSHQ} : D_rA;
	D_icode in {POPQ, RET} : REG_RSP;
	1 : REG_NONE;
];
reg_srcB = [ # send to register file as read port; creates reg_outputB
	D_icode in {RMMOVQ, MRMOVQ, OPQ} : D_rB;
	D_icode in {PUSHQ, CALL, POPQ, RET} : REG_RSP;
	1 : REG_NONE;
];

# destination selection
d_dstE = [
	D_icode in {IRMOVQ, RRMOVQ, OPQ, CMOVXX} : D_rB;
	D_icode in {PUSHQ, CALL, POPQ, RET} : REG_RSP;
	1 : REG_NONE;
];

d_dstM = [
	D_icode in { MRMOVQ, POPQ } : D_rA;
	1 : REG_NONE;
];

d_valA = [
	D_icode in {CALL, JXX} : D_valP;
	reg_srcA == REG_NONE: 0;
	reg_srcA == e_dstE : e_valE;
	reg_srcA == m_dstM : m_valM;
	reg_srcA == M_dstE : M_valE;
	reg_srcA == W_dstM : W_valM; # forward pre-writeback
	reg_srcA == W_dstE : W_valE;
	#reg_srcA == m_dstM : m_valM; # forward post-memory

	#(reg_dstE != REG_NONE) && (reg_dstE == reg_srcA) : reg_inputE;
	1 : reg_outputA; # returned by register file based on reg_srcA
];

d_valB = [
	reg_srcB == REG_NONE: 0;
	# forward from another phase
	reg_srcB == e_dstE : e_valE;
	reg_srcB == m_dstM : m_valM;
	reg_srcB == M_dstE : M_valE;
	reg_srcB == W_dstM : W_valM; # forward pre-writeback
	reg_srcB == W_dstE : W_valE;
	#reg_srcB == m_dstM : m_valM; # forward post-memory
	1 : reg_outputB; # returned by register file based on reg_srcA
];



d_stat = D_stat;
d_icode = D_icode;
d_ifun = D_ifun;
d_valC = D_valC;

d_valP = D_valP;

########## Execute #############

register dE {
	stat:3 = STAT_BUB;
	icode:4 = NOP;
	ifun:4 = 0;
	valC:64 = 0;
	valA:64 = 0;
	valB:64 = 0;
	dstE:4 = REG_NONE;
    dstM:4 = REG_NONE;
    #srcA:4 = REG_NONE;
    #srcB:4 = REG_NONE;	
	valP:64 = 0;
}


#wire conditionsMet:1;
e_conditionsMet = [
	E_ifun == ALWAYS : true;
	E_ifun == LE : C_SF || C_ZF;
	E_ifun == LT : C_SF;
	E_ifun == EQ : C_ZF;
	E_ifun == NE : !C_ZF;
	E_ifun == GE : !C_SF;
	E_ifun == GT : !C_SF && !C_ZF;
	1 : false;
];

e_dstE = [
    (E_icode == CMOVXX) && (!e_conditionsMet) : REG_NONE;
    1 : E_dstE;
];

e_valE = [
	E_icode == OPQ && E_ifun == ADDQ : E_valA + E_valB;
	E_icode == OPQ && E_ifun == SUBQ : E_valB - E_valA;
	E_icode == OPQ && E_ifun == ANDQ : E_valA & E_valB;
	E_icode == OPQ && E_ifun == XORQ : E_valA ^ E_valB;
	E_icode in { RMMOVQ, MRMOVQ } : E_valC + E_valB;
	E_icode in { RRMOVQ } : E_valA;
	E_icode in { PUSHQ, CALL } : E_valB - 8;
	E_icode in { POPQ, RET } : E_valB + 8;
	1 : E_valC;
];

### simplified condition codes
c_ZF = e_valE == 0;
c_SF = e_valE >= 0x8000000000000000;
stall_C = E_icode != OPQ;

#e_SF = C_SF;
#e_ZF = C_ZF;

e_stat =  E_stat;
e_icode = E_icode;
e_valA = E_valA;
e_dstM = E_dstM;

e_valP = E_valP;

########## Memory #############


register eM {
	stat:3 = STAT_BUB;
	icode:4 = NOP;
	conditionsMet:1 = 0;
	#SF:1 = 0;
	#ZF:1 = 0;
	valE:64 = 0;
	valA:64 = 0;
	dstE:4 = REG_NONE;
	dstM:4 = REG_NONE;
	valP:64 = 0;
}


mem_addr = [ # output to memory system
	M_icode in { RMMOVQ, MRMOVQ, PUSHQ, CALL } : M_valE;
	M_icode in { POPQ, RET } : M_valA;
	1 : 0; # Other instructions don't need address
];
mem_readbit =  M_icode in { MRMOVQ, POPQ, RET }; # output to memory system
mem_writebit = M_icode in { RMMOVQ, PUSHQ, CALL }; # output to memory system
mem_input = [
	M_icode in { CALL } : M_valP;
	1 : M_valA;
];

m_stat = M_stat;
m_dstE = M_dstE;
m_valE = M_valE;
m_valM = [
	M_icode in { RMMOVQ, MRMOVQ, POPQ, RET } : mem_output; # input from mem_readbit and mem_addr
	1: M_valA;
];

m_dstM = M_dstM;
m_icode = M_icode;

########## Writeback #############
register mW {
	stat:3 = STAT_BUB;
	icode:4 = NOP;
	valE:64 = 0;
	valM:64 = 0;
	dstE:4 = REG_NONE;
	dstM:4 = REG_NONE;
}

reg_inputM = W_valM; # output: sent to register file
reg_dstM = W_dstM; # output: sent to register file

reg_dstE = W_dstE;
reg_inputE = [ # unlike book, we handle the "forwarding" actions (something + 0) here
	W_icode == RRMOVQ : W_valM;
	W_icode in {IRMOVQ, OPQ, CMOVXX, PUSHQ, CALL, POPQ, RET} : W_valE;
];

Stat = [
	W_stat == STAT_BUB : STAT_AOK;
	1: W_stat; # output; halts execution and reports errors
];


################ Pipeline Register Control #########################

wire loadUse:1;

loadUse = (E_icode in {MRMOVQ, POPQ}) && (E_dstM in {reg_srcA, reg_srcB}); 

### Fetch
stall_F = loadUse || f_stat != STAT_AOK || RET in {D_icode, E_icode, M_icode};

### Decode
bubble_D = mispredicted || !loadUse && (RET in {D_icode, E_icode, M_icode});
stall_D = loadUse;

### Execute
# bubble_E = loadUse;
bubble_E = loadUse || mispredicted;

### Memory

### Writeback
