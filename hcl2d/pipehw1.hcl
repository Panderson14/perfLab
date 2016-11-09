# Patrick Anderson psa5dg

########## the PC and condition codes registers #############
register pP { pc:64 = 0; }

register fD {
	Stat:3 = STAT_AOK;
	icode:4 = NOP;
	ifun:4 = 0;
	rA:4 = REG_NONE;
	rB:4 = REG_NONE;
	valC:64 = 0;
	valP: 64 = 0;
}

register dE {
	Stat:3 = STAT_AOK;
	icode:4 = NOP;
	ifun:4 = 0;
	valC:64 = 0;
	#valA
	#valB
	#dstE
	#dstM
	##srcA
	##srcB
}

register eM {
	Stat:3 = STAT_AOK;
	icode:4 = NOP;
	#Cnd
	#valE
	#valA
	#dstE
	#dstM
}

register mW {
	Stat:3 = STAT_AOK;
	icode:4 = NOP;
	#valE
	#valM
	#dstE
	#dstM
}

########## Fetch #############
pc = P_pc;

# wire icode:4, ifun:4, rA:4, rB:4, valC:64;

f_icode = i10bytes[4..8];
f_ifun = i10bytes[0..4];
f_rA = i10bytes[12..16];
f_rB = i10bytes[8..12];

f_valC = [
	f_icode in { JXX } : i10bytes[8..72];
	1 : i10bytes[16..80];
];

wire offset:64;  #, valP:64;
offset = [
	f_icode in { HALT, NOP, RET } : 1;
	f_icode in { RRMOVQ, OPQ, PUSHQ, POPQ } : 2;
	f_icode in { JXX, CALL } : 9;
	1 : 10;
];
f_valP = P_pc + offset;


########## Decode #############

d_Stat = D_Stat;
d_icode = D_icode;
d_ifun = D_ifun;
d_valC = D_valC;

# source selection
reg_srcA = [
	d_icode in {RRMOVQ} : D_rA;
	1 : REG_NONE;
];


########## Execute #############

e_Stat = E_Stat;
e_icode = E_icode;


########## Memory #############

m_Stat = M_Stat;
m_icode = M_icode;


########## Writeback #############


# destination selection
reg_dstE = [
	W_icode in {IRMOVQ, RRMOVQ} : D_rB;
	1 : REG_NONE;
];

reg_inputE = [ # unlike book, we handle the "forwarding" actions (something + 0) here
	W_icode == RRMOVQ : reg_outputA;
	W_icode in {IRMOVQ} : E_valC;
];


########## PC and Status updates #############

Stat = [
	W_icode == HALT : STAT_HLT;
	W_icode > 0xb : STAT_INS;
	1 : STAT_AOK;
];

p_pc = D_valP;