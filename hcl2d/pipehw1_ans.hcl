########## the PC and condition codes registers #############
register pP { pc:64 = 0; }
register dW {
	icode:4 = NOP;
	valC:64 = 0;
	valA:64 = 0;
	dstE:4 = REG_NONE;
	Stat:3 = STAT_AOK;
}


########## Fetch #############
pc = P_pc;

wire rA:4, rB:4;
d_icode = i10bytes[4..8];
wire need_regs:1, need_immediate:1;

need_regs = d_icode in {RRMOVQ, IRMOVQ};
need_immediate = d_icode in {IRMOVQ};

rA = [
	need_regs: i10bytes[12..16];
	1: REG_NONE;
];
rB = [
	need_regs: i10bytes[8..12];
	1: REG_NONE;
];
d_valC = [
	need_immediate && need_regs : i10bytes[16..80];
	need_immediate : i10bytes[8..72];
	1 : 0;
];

# new PC (assuming there is no jump)
wire valP:64;
valP = [
	need_immediate && need_regs : pc + 10;
	need_immediate : pc + 9;
	need_regs : pc + 2;
	1 : pc + 1;
];

# pc register update
p_pc = [
	1 : valP;
];
d_Stat = [
	d_icode == HALT : STAT_HLT;
	d_icode in {NOP, RRMOVQ, IRMOVQ} : STAT_AOK;
	1 : STAT_INS;
];
stall_P = d_Stat != STAT_AOK; # so that we see the same final PC as the yis tool



########## Decode #############

# source selection
reg_srcA = [
	d_icode in {RRMOVQ} : rA;
	1 : REG_NONE;
];

# destination selection
d_dstE = [
	d_icode in {IRMOVQ, RRMOVQ} : rB;
	1 : REG_NONE;
];

d_valA = [
	reg_srcA == reg_dstE : reg_inputE;
	1 : reg_outputA;
];

########## Execute #############



########## Memory #############




########## Writeback #############


reg_inputE = [ # unlike book, we handle the "forwarding" actions (something + 0) here
	W_icode == RRMOVQ : W_valA;
	W_icode in {IRMOVQ} : W_valC;
];

reg_dstE = W_dstE;


########## PC and Status updates #############

Stat = W_Stat;


