########## the PC and condition codes registers #############
register xF { pc:64 = 0; }


########## Fetch #############
pc = F_pc;

f_icode = i10bytes[4..8];
f_ifun = i10bytes[0..4];
f_rA = i10bytes[12..16];
f_rB = i10bytes[8..12];

f_valC = [
	f_icode in { JXX } : i10bytes[8..72];
	1 : i10bytes[16..80];
];

wire offset:64;
offset = [
	f_icode in { HALT, NOP, RET } : 1;
	f_icode in { RRMOVQ, OPQ, PUSHQ, POPQ } : 2;
	f_icode in { JXX, CALL } : 9;
	1 : 10;
];
f_valP = F_pc + offset;
x_pc = f_valP;

f_Stat = [
	f_icode == HALT : STAT_HLT;
	f_icode > 0xb : STAT_INS;
	1 : STAT_AOK;
];

#stall_F = [
#	f_Stat == STAT_HLT : true;
#	1: false;
#];

register fD { 
	Stat:3 = STAT_BUB;
	icode:4 = NOP;
	ifun:4 = 0;
	rA:4 = REG_NONE;
	rB:4 = REG_NONE;
	valC:64 = 0;
	valP:64 = 0;
}
########## Decode #############

# source selection
reg_srcA = [
	D_icode in {RRMOVQ} : D_rA;
	1 : REG_NONE;
];
reg_srcB = [ # send to register file as read port; creates reg_outputB
	D_icode in {RMMOVQ, MRMOVQ} : D_rB;
	1 : REG_NONE;
];

d_dstM = [
	D_icode in { MRMOVQ } : D_rA;
	1 : REG_NONE;
];

d_valA = [
	reg_srcA == REG_NONE: 0;
	reg_srcA == m_dstM : m_valM; # forward post-memory
	reg_srcA == W_dstM : W_valM; # forward pre-writeback
	(reg_srcA == m_dstE): m_valE;
	(reg_srcA == e_dstE) : e_valE;
	(reg_srcA == W_dstE): W_valE;
	(reg_dstE != REG_NONE) && (reg_dstE == reg_srcA) : reg_inputE;
	1: reg_outputA;
];

d_valB = [
	reg_srcB == REG_NONE: 0;
	# forward from another phase
	reg_srcB == m_dstM : m_valM; # forward post-memory
	reg_srcB == W_dstM : W_valM; # forward pre-writeback
	(reg_srcB == m_dstE): m_valE;
	(reg_srcB == e_dstE) : e_valE;
	(reg_srcB == W_dstE): W_valE;
	1 : reg_outputB; # returned by register file based on reg_srcA
];

# destination selection
d_dstE = [
	d_icode in {IRMOVQ, RRMOVQ} : D_rB;
	1 : REG_NONE;
];


d_Stat = D_Stat;
d_icode = D_icode;
d_ifun = D_ifun;
d_valC = D_valC;

register dE { 
	Stat:3 = STAT_BUB;
	icode:4 = NOP;
	ifun:4 = 0;
	valC:64 = 0;
	valA:64 = 0;
	valB:64 = 0;
    dstE:4 = REG_NONE;
    dstM:4 = REG_NONE;
    #srcA:4 = REG_NONE;
    #srcB:4 = REG_NONE;	
}
########## Execute #############


e_Stat = E_Stat;
e_icode = E_icode;
e_valA = E_valA;
e_dstE = E_dstE;
e_dstM = E_dstM;

e_valE = [
	E_icode in { RMMOVQ, MRMOVQ } : E_valC + E_valB;
	E_icode in { RRMOVQ } : E_valA;
	1 : E_valC;
];

register eM {
	Stat:3 = STAT_BUB;
	icode:4 = NOP;
	# SF:1 = 0;
	# ZF:1 = 0;
	valE:64 = 0;
	valA:64 = 0;
	dstE:4 = REG_NONE;
	dstM:4 = REG_NONE;
}
########## Memory #############


mem_addr = [ # output to memory system
	M_icode in { RMMOVQ, MRMOVQ } : M_valE;
	1 : 0; # Other instructions don't need address
];
mem_readbit =  M_icode in { MRMOVQ }; # output to memory system
mem_writebit = M_icode in { RMMOVQ }; # output to memory system
mem_input = M_valA;

m_valM = [
	M_icode in { RMMOVQ, MRMOVQ } : mem_output; # input from mem_readbit and mem_addr
	1: M_valA;
];

m_dstM = M_dstM;

m_valE = M_valE;

m_Stat = M_Stat;
m_icode = M_icode;
m_dstE = M_dstE;

register mW {
	Stat:3 = STAT_BUB;
	icode:4 = NOP;
	valE:64 = 0;
	valM:64 = 0;
	dstE:4 = REG_NONE;
	dstM:4 = REG_NONE;	
}
########## Writeback #############

reg_inputM = W_valM; # output: sent to register file
reg_dstM = W_dstM; # output: sent to register file

reg_dstE = W_dstE;

reg_inputE = [ # unlike book, we handle the "forwarding" actions (something + 0) here
	W_icode == RRMOVQ : W_valM;
	W_icode in {IRMOVQ} : W_valE;
];


########## PC and Status updates #############

Stat = W_Stat;

################ Pipeline Register Control #########################

wire loadUse:1;

loadUse = (E_icode in {MRMOVQ}) && (E_dstM in {reg_srcA, reg_srcB}); 

### Fetch
stall_F = loadUse || f_Stat != STAT_AOK;

### Decode
stall_D = loadUse;

### Execute
bubble_E = loadUse;

### Memory

### Writeback
