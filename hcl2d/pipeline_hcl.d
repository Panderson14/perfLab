// auto-generated HCL2 simulator; DO NOT EDIT THIS FILE
/+++++++++++++++++ generated from the following HCL: ++++++++++++++++++
###################### begin builtin signals ##########################

### constants:

const STAT_BUB = 0b000, STAT_AOK = 0b001, STAT_HLT = 0b010;  # expected behavior
const STAT_ADR = 0b011, STAT_INS = 0b100, STAT_PIP = 0b110;  # error conditions

const REG_RAX = 0b0000, REG_RCX = 0b0001, REG_RDX = 0b0010, REG_RBX = 0b0011;
const REG_RSP = 0b0100, REG_RBP = 0b0101, REG_RSI = 0b0110, REG_RDI = 0b0111;
const REG_R8  = 0b1000, REG_R9  = 0b1001, REG_R10 = 0b1010, REG_R11 = 0b1011;
const REG_R12 = 0b1100, REG_R13 = 0b1101, REG_R14 = 0b1110, REG_NONE= 0b1111;

# icodes; see figure 4.2
const HALT   = 0b0000, NOP    = 0b0001, RRMOVQ = 0b0010, IRMOVQ = 0b0011;
const RMMOVQ = 0b0100, MRMOVQ = 0b0101, OPQ    = 0b0110, JXX    = 0b0111;
const CALL   = 0b1000, RET    = 0b1001, PUSHQ  = 0b1010, POPQ   = 0b1011;
const CMOVXX = RRMOVQ;

# ifuns; see figure 4.3
const ALWAYS = 0b0000, LE   = 0b0001, LT   = 0b0010, EQ   = 0b0011;
const NE     = 0b0100, GE   = 0b0101, GT   = 0b0110;
const ADDQ   = 0b0000, SUBQ = 0b0001, ANDQ = 0b0010, XORQ = 0b0011;


### fixed-functionality inputs (things you should assign to in your HCL)

wire Stat:3;              # should be one of the STAT_... constants
wire pc:64;               # put the address of the next instruction into this

wire reg_srcA:4, reg_srcB:4;        # use to pick which program registers to read from
wire reg_dstE:4, reg_dstM:4;        # use to pick which program registers to write to
wire reg_inputE:64, reg_inputM:64;  # use to provide values to write to program registers

wire mem_writebit:1, mem_readbit:1; # set at most one of these two to 1 to access memory
wire mem_addr:64;                   # if accessing memory, put the address accessed here
wire mem_input:64;                  # if writing to memory, put the value to write here

### fixed-functionality outputs (things you should use but not assign to)

wire i10bytes:80;                     # output value of instruction read; linked to pc
wire reg_outputA:64, reg_outputB:64;  # values from registers; linked to reg_srcA and reg_srcB
wire mem_output:64;                   # value read from memory; linked to mem_readbit and mem_addr

####################### end builtin signals ###########################

# -*-sh-*- # this line enables partial syntax highlighting in emacs

######### The PC #############
register xF { pc:64 = 0; }


########## Fetch #############
pc = F_pc;

wire icode:4, rA:4, rB:4, valC:64;

icode = i10bytes[4..8];
rA = i10bytes[12..16];
rB = i10bytes[8..12];

valC = [
	icode in { JXX } : i10bytes[8..72];
	1 : i10bytes[16..80];
];

wire offset:64, valP:64;
offset = [
	icode in { HALT, NOP, RET } : 1;
	icode in { RRMOVQ, OPQ, PUSHQ, POPQ } : 2;
	icode in { JXX, CALL } : 9;
	1 : 10;
];
valP = F_pc + offset;
x_pc = valP;



f_stat = [
	f_icode == HALT : STAT_HLT;
	f_icode > 0xb : STAT_INS;
	1 : STAT_AOK;
];


f_icode = icode;
f_rA = rA;
f_rB = rB;
f_valC = valC;


########## Decode #############
# figure 4.56 on page 426

register fD {
	stat:3 = STAT_BUB;
	icode:4 = NOP;
	rA:4 = REG_NONE;
	rB:4 = REG_NONE;
	valC:64 = 0;
}



reg_srcA = [ # send to register file as read port; creates reg_outputA
	D_icode in {RMMOVQ} : D_rA;
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
	1 : reg_outputA; # returned by register file based on reg_srcA
];
d_valB = [
	reg_srcB == REG_NONE: 0;
	# forward from another phase
	reg_srcB == m_dstM : m_valM; # forward post-memory
	reg_srcB == W_dstM : W_valM; # forward pre-writeback
	1 : reg_outputB; # returned by register file based on reg_srcA
];



d_stat = D_stat;
d_icode = D_icode;
d_valC = D_valC;

########## Execute #############

register dE {
	stat:3 = STAT_BUB;
	icode:4 = NOP;
	valC:64 = 0;
	valA:64 = 0;
	valB:64 = 0;
	dstM:4 = REG_NONE;
}


e_valE = [
	E_icode in { RMMOVQ, MRMOVQ } : E_valC + E_valB;
	1 : 0;
];

e_stat =  E_stat;
e_icode = E_icode;
e_valA = E_valA;
e_dstM = E_dstM;

########## Memory #############

register eM {
	stat:3 = STAT_BUB;
	icode:4 = NOP;
	valE:64 = 0;
	valA:64 = 0;
	dstM:4 = REG_NONE;
}


mem_addr = [ # output to memory system
	M_icode in { RMMOVQ, MRMOVQ } : M_valE;
	1 : 0; # Other instructions don't need address
];
mem_readbit =  M_icode in { MRMOVQ }; # output to memory system
mem_writebit = M_icode in { RMMOVQ }; # output to memory system
mem_input = M_valA;

m_stat = M_stat;
m_valM = mem_output; # input from mem_readbit and mem_addr

m_dstM = M_dstM;
m_icode = M_icode;

########## Writeback #############
register mW {
	stat:3 = STAT_BUB;
	icode:4 = NOP;
	valM:64 = 0;
	dstM:4 = REG_NONE;
}

reg_inputM = W_valM; # output: sent to register file
reg_dstM = W_dstM; # output: sent to register file

Stat = W_stat; # output; halts execution and reports errors


################ Pipeline Register Control #########################

wire loadUse:1;

loadUse = (E_icode in {MRMOVQ}) && (E_dstM in {reg_srcA, reg_srcB}); 

### Fetch
stall_F = loadUse || f_stat != STAT_AOK;

### Decode
stall_D = loadUse;

### Execute
bubble_E = loadUse;

### Memory

### Writeback
++++++++++++++++++ generated from the preceeding HCL ++++++++++++++++++/




/////////////////////// int type bigger than long ///////////////////
private template negOneList(uint length) {
	static if (length == 1) enum negOneList = "-1";
	else enum negOneList = negOneList!(length-1)~", -1";
}

struct bvec(uint bits) if (bits != 0) {
	static enum words = (bits+31)/32;
	static enum min = bvec.init;
	mixin("static enum max = bvec(["~negOneList!words~"]);");
	uint[words] data;
	ubyte *data_bytes() { return cast(ubyte*)&(this.data[0]); }

	this(uint x) { data[0] = x; truncate; }
	this(ulong x) { data[0] = cast(uint)x; static if (words > 1) data[1] = cast(uint)(x>>32); truncate; }
	this(uint[] dat) { this.data[] = dat[]; truncate; }
	this(uint o)(bvec!o x) if (o < bits) { data[0..x.words] = x.data[]; truncate; }
	this(uint o)(bvec!o x) if (o > bits) { data[] = x.data[0..words]; truncate; }
	
	ref bvec opAssign(uint x) { data[0] = x; static if(words > 1) data[1..$] = 0; return truncate; }
	ref bvec opAssign(ulong x) { data[0] = cast(uint)x; static if (words > 1) data[1] = cast(uint)(x>>32); static if(words > 2) data[2..$] = 0; return truncate; }
	ref bvec opAssign(uint[] dat) { this.data[] = dat[]; return truncate; }
	ref bvec opAssign(uint o)(bvec!o x) if (o < bits) { data[0..x.words] = x.data[]; static if (x.words < words) data[x.words..$] = 0; return truncate; }
	ref bvec opAssign(uint o)(bvec!o x) if (o > bits) { data[] = x.data[0..words]; return truncate; }

	ref bvec truncate() {
		static if ((bits&31) != 0) {
			data[$-1] &= 0xffffffffU >> (32-(bits&31));
		}
		return this;
	}
	bvec!(bits+b1) cat(uint b2)(bvec!b2 other) {
		bvec!(bits+b1) ans;
		foreach(i,v; data) ans.data[i] = v;
		static if ((bits&31) == 0) {
			foreach(i,v; other.data) ans.data[i+words] = v;
		} else {
			foreach(i,v; other.data) {
				ans.data[i+words-1] |= (v<<(bits&31));
				if (i+words < ans.words) ans.data[i+words] = (v>>(32-(bits&31)));
			}
		}
		return ans;
	}
	bvec!(e-s) slice(uint s, uint e)() if (s <= e && e <= bits) {
		bvec!(e-s) ans;
		static if ((s&31) == 0) {
			ans.data[] = data[s/32 .. s/32+ans.words];
		} else {
			foreach(i; s/32..((e-s)+31)/32) {
				ans.data[i-s/32] = data[i]>>(s&31);
				if(i > s/32) ans.data[i-s/32-1] |= data[i]<<(32-(s&31));
			}
		}
		return ans.truncate;
	}
	string hex() {
		import std.format, std.range;
		static if (words > 0) {
			return format("%0"~format("%d",((bits&31)+3)/4)~"x%(%08x%)", data[$-1], retro(data[0..$-1]));
		} else {
			return format("%0"~format("%d",(bits+3)/4)~"x", data[0]);
		}
	}
	string smallhex() {
		auto ans = hex;
		while (ans.length > 1 && ans[0] == '0') ans = ans[1..$];
		return ans;
	}
	version (BigEndian) {
		pragma(msg, "hexbytes not implemented on big endian hardware");
	} else {
		string hexbytes() {
			import std.format;
			return format("%(%02x%| %)", data_bytes[0..((bits+7)/8)]);
		}
	}
	string toString() {
		return "0x"~smallhex;
	}
	string bin() {
		import std.format, std.range;
		ubyte[words*4] tmp = *(cast(ubyte[words*4]*)&data);
		static if (bits <= 8) {
			return format("%0"~format("%d",bits)~"b", tmp[0]);
		} else static if ((bits&7) != 0) {
			return format("%0"~format("%d",bits&7)~"b_%(%08b%|_%)", tmp[(bits-1)/8], retro(tmp[0..(bits-1)/8]));
		} else {
			return format("%(%08b%|_%)", retro(tmp[0..bits/8]));
		} 
	}
	static bvec hex(string s)
	in {
		assert(s.length <= (bits+3)/4, "too many hex digits for this type");
		foreach(c; s) assert((c >= '0' && c <= '9') || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f'), "expected a raw hex string");
		if (s.length > bits/4) assert(s[0]-'0' < (1<<(bits&3)), "most-significant digit too big for this type");
	} body {
		uint place = 0, shift = 0;
		bvec ans;
		foreach_reverse(c; s) {
			uint val = c - (c < 'Z' ? c < 'A' ? '0' : 'A'-10 : 'a'-10);
			ans.data[place] |= shift ? val<<shift : val;
			shift += 4;
			place += shift>=32;
			shift &= 31;
		}
		return ans; // no need to truncate; the in conditions take care of that
	}
	
	bool getBit(uint i) pure nothrow {
		return i >= bits ? false 
			: ((0==(i&31)) ? data[i/32]&1 : data[i/32]&(1<<(i&31))) != 0; 
	}
	
	ref bvec setBit(uint i, bool v) pure nothrow
	in { assert(i < bits, "illegal bit index"); }
	body { 
		if (v) if (0==(i&31)) data[i/32]|=1;
		       else           data[i/32]|=(1<<(i&31));
		else if (0==(i&31)) data[i/32]&=~1;
		     else           data[i/32]&=~(1<<(i&31));
		return this;
	}
	
	int opCmp(T)(T x) if (is(T : uint)) {
		foreach(i; 1..data.length) if (data[i] != 0) return 1;
		return data[0] < x ? -1 : data[0] == x ? 0 : 1;
	}
	int opCmp(uint b2)(bvec!b2 x) {
		static if (x.words == words) {
			foreach_reverse(i; 0..x.words) if (data[i] != x.data[i]) return data[i] < x.data[i] ? -1 : 1;
			return 0;
		} else static if (x.words < words) {
			foreach(i; x.words..words) if (data[i] != 0) return 1;
			foreach_reverse(i; 0..x.words) if (data[i] != x.data[i]) return data[i] < x.data[i] ? -1 : 1;
			return 0;
		} else {
			foreach(i; words..x.words) if (x.data[i] != 0) return -1;
			foreach_reverse(i; 0..words) if (data[i] != x.data[i]) return data[i] < x.data[i] ? -1 : 1;
			return 0;
		}
	}
	bool opEquals(T)(T x) { return this.opCmp(x) == 0; }
	T opCast(T)() if (is(T == bool)) { return opCmp!uint(0) != 0; }
	T opCast(T)() if (is(T == ulong)) { 
		static if (words > 1) return ((cast(ulong)data[1])<<32) | data[0];
		return data[0];
	}
	T opCast(T)() if (is(T == uint)) { return data[0]; }
	
	ref bvec opOpAssign(string op)(bvec s) pure nothrow if (op == "<<" || op == ">>") {
		if (s >= bits) data[] = 0;
		return this.opOpAssign!s(data[0]);
	}
	ref bvec opOpAssign(string op)(ulong s) pure nothrow if (op == "<<" || op == ">>") {
		return opOpAssign!op(cast(uint)s);
	}
	ref bvec opOpAssign(string op)(uint s) pure nothrow if (op == "<<") {
		if (s >= bits) data[] = 0;
		else {
			if (s >= 32) {
				auto ds = s/32;
				s &= 31;
				data[ds..$] = data[0..$-ds].dup;
				data[0..ds] = 0;
			}
			if (s != 0)
				foreach_reverse(i; 0..words)
					data[i] = (data[i]<<s) | (i > 0 ? data[i-1]>>(32-s) : 0);
		}
		return this.truncate;
	}
	ref bvec opOpAssign(string op)(uint s) pure nothrow if (op == ">>") {
		if (s >= bits) data[] = 0;
		else {
			if (s >= 32) {
				auto ds = s/32;
				s &= 31;
				data[0..$-ds] = data[ds..$].dup;
				data[$-ds..$] = 0;
			}
			if (s != 0)
				foreach(i; 0..words)
					data[i] = (data[i]>>s) | (i+1 < data.length ? data[i+1]<<(32-s) : 0);
		}
		return this.truncate;
	}
	ref bvec opOpAssign(string op)(bvec x) pure nothrow if (op == "&" || op == "|" || op == "^") {
		foreach(i,ref v; this.data) mixin("v "~op~"= x.data[i];");
		return this.truncate;
	}
	ref bvec opOpAssign(string s)(bvec x) pure nothrow if (s == "+" || s == "-") {
		ulong carry = s == "+" ? 0 : 1;
		foreach(i, ref v; data) {
			carry += v;
			carry += s == "+" ? x.data[i] : ~x.data[i];
			v = cast(uint)carry;
			carry >>= 32;
		}
		return this.truncate;
	}
	ref bvec opOpAssign(string op)(bvec x) pure nothrow if (op == "*") {
		bvec ans;
		ulong carry = 0;
		foreach(digit; 0..words) {
			ulong accum = carry&uint.max;
			carry >>= 32;
			foreach(i; 0..digit+1) {
				ulong tmp = data[i] * cast(ulong)x.data[digit-i];
				accum += tmp&uint.max;
				carry += tmp>>32;
			}
			ans.data[digit] = cast(uint)accum;
			carry += accum>>32;
		}
		this.data[] = ans.data[];
		return this.truncate;
	}
	ref bvec opOpAssign(string s)(bvec div) pure nothrow if (s == "/" || s == "%") {
		import std.stdio;
		bvec rem = this;
		bvec num;
		uint place = 0;
		while (div < rem && !div.getBit(bits-1)) { place += 1; div <<= 1; }
		while (true) {
			if (rem >= div) {
				num.setBit(place, true);
				rem -= div;
			}
			if (place == 0) break;
			div >>= 1;
			place -= 1;
		}
		static if (s == "/") this.data[] = num.data[];
		else this.data[] = rem.data[];
		return this;
	}
	ref bvec opOpAssign(string s)(ulong x) pure nothrow if (s != "<<" && s != ">>") {
		return this.opOpAssign!s(bvec(x));
	}
	ref bvec opOpAssign(string s)(uint x) pure nothrow if (s != "<<" && s != ">>") {
		return this.opOpAssign!s(bvec(x));
	}

	bvec opUnary(string s)() pure nothrow if (s == "~") {
		bvec ans = this;
		foreach(i,ref v; ans.data) v ^= max.data[i];
		return ans;
	}
	bvec opUnary(string s)() pure nothrow if (s == "-") { bvec ans; ans -= this; return ans; }

	bvec opBinary(string op, T)(T x) if (__traits(compiles, this.opOpAssign!op(x))) {
		bvec ans = this; return ans.opOpAssign!op(x);
	}
}
unittest { bvec!10 x = [-1]; assert(x.data[0] == 0x3ff,"expected 0x3ff"); }
unittest { bvec!40 x = [-1,-1]; assert(x.data == [0xffffffffU,0xffu]); }
unittest { bvec!64 x = [-1,-1]; assert(x.data == [0xffffffffU,0xffffffffu]); }
unittest { 
	bvec!35 x = [0x40000000,0x2]; 
	assert((x>>1).data == [0x20000000,0x1]); 
	assert((x<<1).data == [0x80000000,0x4]); 
	assert((x<<2).data == [0x00000000,0x1]); 
}
unittest { 
	bvec!128 x = [0x4,0x40000000,0x2, 0x4]; 
	assert((x<<33).data == [0,0x8,0x80000000,0x4]); 
	assert((x>>33).data == [0x20000000,0x1,0x2,0]); 
}alias bvec!80 ulonger;


/////////////////////////// register file ///////////////////////////
ulong[15] __regfile = [0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0];

////////////////////////////// memory ///////////////////////////////
ubyte[ulong] __memory;
bool __can_read_imem(ulong mem_addr) { return mem_addr < ulong.max-10; }
bool __can_read_dmem(ulong mem_addr) { return mem_addr < ulong.max-8; }
bool __can_write_dmem(ulong mem_addr) { return mem_addr < ulong.max-8; }
ubyte[] __read_bytes(ulong baseAddr, uint bytes) {
    ubyte[] ans = new ubyte[bytes];
    foreach_reverse(i; 0..bytes) {
        if ((baseAddr + i) in __memory) ans[i] = __memory[baseAddr+i];
        else ans[i] = 0;
    }
    return ans;
}
ulong __asUlong(ubyte[] arg) {
    ulong ans = 0;
    foreach_reverse(i; 0..8) if (i < arg.length) {
        ans <<= 8;
        ans |= arg[i];
    }
    return ans;
}
ulonger __asUlonger(ubyte[] arg) {
    ulonger ans = 0;
    foreach_reverse(i; 0..10) if (i < arg.length) {
        ans <<= 8;
        ans |= arg[i];
    }
    return ans;
}
void __write_bytes(ulong baseAddr, ulong value, uint bytes) {
    foreach(i; 0..bytes) {
        __memory[baseAddr+i] = cast(ubyte)value;
        value >>= 8;
    }
}
ulonger __read_imem(ulong mem_addr) { return __asUlonger(__read_bytes(mem_addr, 10)); }
ulong __read_dmem(ulong mem_addr) { return __asUlong(__read_bytes(mem_addr, 8)); }
void __write_dmem(ulong mem_addr, ulong value) { __write_bytes(mem_addr, value, 8); }

//////////////// pipeline registers' initial values ////////////////
// register bank D:
bool _HCL_bubble_D = false;
bool _HCL_stall_D  = false;
ulong _HCL_D_rB = 15;
ulong _HCL_D_stat = 0;
ulong _HCL_D_icode = 1;
ulong _HCL_D_valC = 0;
ulong _HCL_D_rA = 15;
// register bank W:
bool _HCL_bubble_W = false;
bool _HCL_stall_W  = false;
ulong _HCL_W_stat = 0;
ulong _HCL_W_icode = 1;
ulong _HCL_W_dstM = 15;
ulong _HCL_W_valM = 0;
// register bank F:
bool _HCL_bubble_F = false;
bool _HCL_stall_F  = false;
ulong _HCL_F_pc = 0;
// register bank E:
bool _HCL_bubble_E = false;
bool _HCL_stall_E  = false;
ulong _HCL_E_dstM = 15;
ulong _HCL_E_stat = 0;
ulong _HCL_E_icode = 1;
ulong _HCL_E_valC = 0;
ulong _HCL_E_valA = 0;
ulong _HCL_E_valB = 0;
// register bank M:
bool _HCL_bubble_M = false;
bool _HCL_stall_M  = false;
ulong _HCL_M_stat = 0;
ulong _HCL_M_icode = 1;
ulong _HCL_M_dstM = 15;
ulong _HCL_M_valA = 0;
ulong _HCL_M_valE = 0;

////////////////////////// disassembler /////////////////////////////

enum RNAMES = [ "%rax", "%rcx", "%rdx", "%rbx", "%rsp", "%rbp", "%rsi", "%rdi",
"%r8", "%r9", "%r10", "%r11", "%r12", "%r13", "%r14", "none"];
enum OPNAMES = [ "addq", "subq", "andq", "xorq", "op4", "op5", "op6", "op7",
"op8", "op9", "op10", "op11", "op12", "op13", "op14", "op15"];
enum JMPNAMES = [ "jmp", "jle", "jl", "je", "jne", "jge", "jg", "jXX",
"jXX", "jXX", "jXX", "jXX", "jXX", "jXX", "jXX", "jXX"];
enum RRMOVQNAMES = [ "rrmovq", "cmovle", "cmovl", "cmove", "cmovne", "cmovge", "cmovg", "cmovXX",
"cmovXX", "cmovXX", "cmovXX", "cmovXX", "cmovXX", "cmovXX", "cmovXX", "cmovXX"];
string disas(ulonger i10bytes) {
    auto b = i10bytes.data_bytes;
    auto s = i10bytes.hexbytes;
    switch((i10bytes.data[0]&0xf0)>>4) {
        case 0 : return s[0..3*1-1]~" : halt";
        case 1 : return s[0..3*1-1]~" : nop";
        case 2 : return s[0..3*2-1]~" : "~RRMOVQNAMES[b[0]&0xf]~" "~RNAMES[(b[1]>>4)&0xf]~", "~RNAMES[b[1]&0xf];
        case 3 : return s[0..3*10-1]~" : irmovq $0x"~(i10bytes.slice!(16,80).smallhex)~", "~RNAMES[b[1]&0xf];
        case 4 : return s[0..3*10-1]~" : rmmovq "~RNAMES[(b[1]>>4)&0xf]~", 0x"~(i10bytes.slice!(16,80).smallhex)~"("~RNAMES[b[1]&0xf]~")";
        case 5 : return s[0..3*10-1]~" : mrmovq 0x"~(i10bytes.slice!(16,80).smallhex)~"("~RNAMES[b[1]&0xf]~"), "~RNAMES[(b[1]>>4)&0xf];
        case 6 : return s[0..3*2-1]~" : "~OPNAMES[b[0]&0xf]~" "~RNAMES[(b[1]>>4)&0xf]~", "~RNAMES[b[1]&0xf];
        case 7 : return s[0..3*9-1]~" : "~JMPNAMES[b[0]&0xf]~" 0x"~(i10bytes.slice!(8,72).smallhex);
        case 8 : return s[0..3*9-1]~" : call  0x"~(i10bytes.slice!(8,72).smallhex);
        case 9 : return s[0..3*1-1]~" : ret";
        case 10 : return s[0..3*2-1]~" : pushq "~RNAMES[(b[1]>>4)&0xf];
        case 11 : return s[0..3*2-1]~" : popq "~RNAMES[(b[1]>>4)&0xf];
        default: return "unknown operation";
    }
}

////////////////////////// update cycle /////////////////////////////
int tick(bool showpc=true, bool showall=false) {
    ulong _HCL_pc = _HCL_F_pc;
    _HCL_pc &= 0xffffffffffffffff;
    if (showall) writefln("set pc to 0x%x",_HCL_pc);
    ulong _HCL_reg_srcA = ((((_HCL_D_icode)==(4))) ? (_HCL_D_rA) :
		(15));
    _HCL_reg_srcA &= 0xf;
    if (showall) writefln("set reg_srcA to 0x%x",_HCL_reg_srcA);
    ulong _HCL_reg_srcB = (((((_HCL_D_icode)==(4)))||(((_HCL_D_icode)==(5)))) ? (_HCL_D_rB) :
		(15));
    _HCL_reg_srcB &= 0xf;
    if (showall) writefln("set reg_srcB to 0x%x",_HCL_reg_srcB);
    ulong _HCL_d_dstM = ((((_HCL_D_icode)==(5))) ? (_HCL_D_rA) :
		(15));
    _HCL_d_dstM &= 0xf;
    if (showall) writefln("set d_dstM to 0x%x",_HCL_d_dstM);
    ulong _HCL_d_stat = _HCL_D_stat;
    _HCL_d_stat &= 0x7;
    if (showall) writefln("set d_stat to 0x%x",_HCL_d_stat);
    ulong _HCL_d_icode = _HCL_D_icode;
    _HCL_d_icode &= 0xf;
    if (showall) writefln("set d_icode to 0x%x",_HCL_d_icode);
    ulong _HCL_d_valC = _HCL_D_valC;
    _HCL_d_valC &= 0xffffffffffffffff;
    if (showall) writefln("set d_valC to 0x%x",_HCL_d_valC);
    ulong _HCL_e_valE = (((((_HCL_E_icode)==(4)))||(((_HCL_E_icode)==(5)))) ? ((_HCL_E_valC)+(_HCL_E_valB)) :
		(0UL));
    _HCL_e_valE &= 0xffffffffffffffff;
    if (showall) writefln("set e_valE to 0x%x",_HCL_e_valE);
    ulong _HCL_e_stat = _HCL_E_stat;
    _HCL_e_stat &= 0x7;
    if (showall) writefln("set e_stat to 0x%x",_HCL_e_stat);
    ulong _HCL_e_icode = _HCL_E_icode;
    _HCL_e_icode &= 0xf;
    if (showall) writefln("set e_icode to 0x%x",_HCL_e_icode);
    ulong _HCL_e_valA = _HCL_E_valA;
    _HCL_e_valA &= 0xffffffffffffffff;
    if (showall) writefln("set e_valA to 0x%x",_HCL_e_valA);
    ulong _HCL_e_dstM = _HCL_E_dstM;
    _HCL_e_dstM &= 0xf;
    if (showall) writefln("set e_dstM to 0x%x",_HCL_e_dstM);
    ulong _HCL_mem_addr = (((((_HCL_M_icode)==(4)))||(((_HCL_M_icode)==(5)))) ? (_HCL_M_valE) :
		(0UL));
    _HCL_mem_addr &= 0xffffffffffffffff;
    if (showall) writefln("set mem_addr to 0x%x",_HCL_mem_addr);
    ulong _HCL_mem_readbit = ((_HCL_M_icode)==(5));
    _HCL_mem_readbit &= 0x1;
    if (showall) writefln("set mem_readbit to 0x%x",_HCL_mem_readbit);
    ulong _HCL_mem_writebit = ((_HCL_M_icode)==(4));
    _HCL_mem_writebit &= 0x1;
    if (showall) writefln("set mem_writebit to 0x%x",_HCL_mem_writebit);
    ulong _HCL_mem_input = _HCL_M_valA;
    _HCL_mem_input &= 0xffffffffffffffff;
    if (showall) writefln("set mem_input to 0x%x",_HCL_mem_input);
    ulong _HCL_m_stat = _HCL_M_stat;
    _HCL_m_stat &= 0x7;
    if (showall) writefln("set m_stat to 0x%x",_HCL_m_stat);
    ulong _HCL_m_dstM = _HCL_M_dstM;
    _HCL_m_dstM &= 0xf;
    if (showall) writefln("set m_dstM to 0x%x",_HCL_m_dstM);
    ulong _HCL_m_icode = _HCL_M_icode;
    _HCL_m_icode &= 0xf;
    if (showall) writefln("set m_icode to 0x%x",_HCL_m_icode);
    ulong _HCL_reg_inputM = _HCL_W_valM;
    _HCL_reg_inputM &= 0xffffffffffffffff;
    if (showall) writefln("set reg_inputM to 0x%x",_HCL_reg_inputM);
    ulong _HCL_reg_dstM = _HCL_W_dstM;
    _HCL_reg_dstM &= 0xf;
    if (showall) writefln("set reg_dstM to 0x%x",_HCL_reg_dstM);
    ulong _HCL_Stat = _HCL_W_stat;
    _HCL_Stat &= 0x7;
    if (showall) writefln("set Stat to 0x%x",_HCL_Stat);
    ulong _HCL_loadUse = ((((_HCL_E_icode)==(5))))&&(((((_HCL_E_dstM)==(_HCL_reg_srcA)))||(((_HCL_E_dstM)==(_HCL_reg_srcB)))));
    _HCL_loadUse &= 0x1;
    if (showall) writefln("set loadUse to 0x%x",_HCL_loadUse);
    _HCL_stall_D = cast(bool)(_HCL_loadUse);
    if (showall) writefln("set stall_D to %s",_HCL_stall_D);
    _HCL_bubble_E = cast(bool)(_HCL_loadUse);
    if (showall) writefln("set bubble_E to %s",_HCL_bubble_E);
    ulonger _HCL_i10bytes = __read_imem(_HCL_pc);
    if (showpc) writef(`pc = 0x%x; `, _HCL_pc);
    if (showall || showpc) writefln(`loaded [%s]`, disas(_HCL_i10bytes));
    ulong _HCL_reg_outputA = _HCL_reg_srcA < __regfile.length ? __regfile[cast(size_t)_HCL_reg_srcA] : 0;
    if (showall && _HCL_reg_srcA < __regfile.length) writefln("because reg_srcA was set to %x (%s), set reg_outputA to 0x%x", _HCL_reg_srcA, RNAMES[cast(size_t)_HCL_reg_srcA], _HCL_reg_outputA);
    ulong _HCL_reg_outputB = _HCL_reg_srcB < cast(ulong)__regfile.length ? __regfile[cast(size_t)_HCL_reg_srcB] : 0;
    if (showall && _HCL_reg_srcB < __regfile.length) writefln("because reg_srcB was set to %x (%s), set reg_outputB to 0x%x", _HCL_reg_srcB, RNAMES[cast(size_t)_HCL_reg_srcB], _HCL_reg_outputB);
    if (_HCL_reg_dstM < __regfile.length) { __regfile[cast(size_t)_HCL_reg_dstM] = cast(ulong)_HCL_reg_inputM; }
    if (showall && _HCL_reg_dstM < __regfile.length) writefln("wrote reg_inputM (0x%x) to register reg_dstM (%x, which is %s)", _HCL_reg_inputM, _HCL_reg_dstM, RNAMES[cast(size_t)_HCL_reg_dstM]);
    ulong _HCL_mem_output = _HCL_mem_readbit ? __read_dmem(_HCL_mem_addr) : 0;
    if (showall && _HCL_mem_readbit) writefln("because mem_readbit was 1, set mem_output to 0x%x by reading memory from mem_addr (0x%x)", _HCL_mem_output, _HCL_mem_addr);
    if (_HCL_mem_writebit) __write_dmem(_HCL_mem_addr, _HCL_mem_input);
    if (showall && _HCL_mem_writebit) writefln("because mem_writebit was 1, set memory at mem_addr (0x%x) to mem_input (0x%x)", _HCL_mem_addr, _HCL_mem_input);
    ulong _HCL_icode = cast(ulong)(((_HCL_i10bytes)>>4UL)&0xf);
    _HCL_icode &= 0xf;
    if (showall) writefln("set icode to 0x%x",_HCL_icode);
    ulong _HCL_rA = cast(ulong)(((_HCL_i10bytes)>>12UL)&0xf);
    _HCL_rA &= 0xf;
    if (showall) writefln("set rA to 0x%x",_HCL_rA);
    ulong _HCL_rB = cast(ulong)(((_HCL_i10bytes)>>8UL)&0xf);
    _HCL_rB &= 0xf;
    if (showall) writefln("set rB to 0x%x",_HCL_rB);
    ulong _HCL_valC = ((((_HCL_icode)==(7))) ? (cast(ulong)(((_HCL_i10bytes)>>8UL)&0xffffffffffffffff)) :
		(cast(ulong)(((_HCL_i10bytes)>>16UL)&0xffffffffffffffff)));
    _HCL_valC &= 0xffffffffffffffff;
    if (showall) writefln("set valC to 0x%x",_HCL_valC);
    ulong _HCL_offset = ((((((_HCL_icode)==(0)))||(((_HCL_icode)==(1))))||(((_HCL_icode)==(9)))) ? (1UL) :
		((((((_HCL_icode)==(2)))||(((_HCL_icode)==(6))))||(((_HCL_icode)==(10))))||(((_HCL_icode)==(11)))) ? (2UL) :
		((((_HCL_icode)==(7)))||(((_HCL_icode)==(8)))) ? (9UL) :
		(10UL));
    _HCL_offset &= 0xffffffffffffffff;
    if (showall) writefln("set offset to 0x%x",_HCL_offset);
    ulong _HCL_valP = (_HCL_F_pc)+(_HCL_offset);
    _HCL_valP &= 0xffffffffffffffff;
    if (showall) writefln("set valP to 0x%x",_HCL_valP);
    ulong _HCL_x_pc = _HCL_valP;
    _HCL_x_pc &= 0xffffffffffffffff;
    if (showall) writefln("set x_pc to 0x%x",_HCL_x_pc);
    ulong _HCL_f_icode = _HCL_icode;
    _HCL_f_icode &= 0xf;
    if (showall) writefln("set f_icode to 0x%x",_HCL_f_icode);
    ulong _HCL_f_rA = _HCL_rA;
    _HCL_f_rA &= 0xf;
    if (showall) writefln("set f_rA to 0x%x",_HCL_f_rA);
    ulong _HCL_f_rB = _HCL_rB;
    _HCL_f_rB &= 0xf;
    if (showall) writefln("set f_rB to 0x%x",_HCL_f_rB);
    ulong _HCL_f_valC = _HCL_valC;
    _HCL_f_valC &= 0xffffffffffffffff;
    if (showall) writefln("set f_valC to 0x%x",_HCL_f_valC);
    ulong _HCL_m_valM = _HCL_mem_output;
    _HCL_m_valM &= 0xffffffffffffffff;
    if (showall) writefln("set m_valM to 0x%x",_HCL_m_valM);
    ulong _HCL_f_stat = (((_HCL_f_icode)==(0)) ? (2) :
		((_HCL_f_icode)>(0xbUL)) ? (4) :
		(1));
    _HCL_f_stat &= 0x7;
    if (showall) writefln("set f_stat to 0x%x",_HCL_f_stat);
    ulong _HCL_d_valA = (((_HCL_reg_srcA)==(15)) ? (0UL) :
		((_HCL_reg_srcA)==(_HCL_m_dstM)) ? (_HCL_m_valM) :
		((_HCL_reg_srcA)==(_HCL_W_dstM)) ? (_HCL_W_valM) :
		(_HCL_reg_outputA));
    _HCL_d_valA &= 0xffffffffffffffff;
    if (showall) writefln("set d_valA to 0x%x",_HCL_d_valA);
    ulong _HCL_d_valB = (((_HCL_reg_srcB)==(15)) ? (0UL) :
		((_HCL_reg_srcB)==(_HCL_m_dstM)) ? (_HCL_m_valM) :
		((_HCL_reg_srcB)==(_HCL_W_dstM)) ? (_HCL_W_valM) :
		(_HCL_reg_outputB));
    _HCL_d_valB &= 0xffffffffffffffff;
    if (showall) writefln("set d_valB to 0x%x",_HCL_d_valB);
    _HCL_stall_F = cast(bool)((_HCL_loadUse)||((_HCL_f_stat)!=(1)));
    if (showall) writefln("set stall_F to %s",_HCL_stall_F);

	 // rising clock edge: lock register writes
    if (_HCL_bubble_D) _HCL_D_rB = 15;
    else if (!_HCL_stall_D) _HCL_D_rB = _HCL_f_rB;
    if (_HCL_bubble_D) _HCL_D_stat = 0;
    else if (!_HCL_stall_D) _HCL_D_stat = _HCL_f_stat;
    if (_HCL_bubble_D) _HCL_D_icode = 1;
    else if (!_HCL_stall_D) _HCL_D_icode = _HCL_f_icode;
    if (_HCL_bubble_D) _HCL_D_valC = 0;
    else if (!_HCL_stall_D) _HCL_D_valC = _HCL_f_valC;
    if (_HCL_bubble_D) _HCL_D_rA = 15;
    else if (!_HCL_stall_D) _HCL_D_rA = _HCL_f_rA;
    if (_HCL_bubble_W) _HCL_W_stat = 0;
    else if (!_HCL_stall_W) _HCL_W_stat = _HCL_m_stat;
    if (_HCL_bubble_W) _HCL_W_icode = 1;
    else if (!_HCL_stall_W) _HCL_W_icode = _HCL_m_icode;
    if (_HCL_bubble_W) _HCL_W_dstM = 15;
    else if (!_HCL_stall_W) _HCL_W_dstM = _HCL_m_dstM;
    if (_HCL_bubble_W) _HCL_W_valM = 0;
    else if (!_HCL_stall_W) _HCL_W_valM = _HCL_m_valM;
    if (_HCL_bubble_F) _HCL_F_pc = 0;
    else if (!_HCL_stall_F) _HCL_F_pc = _HCL_x_pc;
    if (_HCL_bubble_E) _HCL_E_dstM = 15;
    else if (!_HCL_stall_E) _HCL_E_dstM = _HCL_d_dstM;
    if (_HCL_bubble_E) _HCL_E_stat = 0;
    else if (!_HCL_stall_E) _HCL_E_stat = _HCL_d_stat;
    if (_HCL_bubble_E) _HCL_E_icode = 1;
    else if (!_HCL_stall_E) _HCL_E_icode = _HCL_d_icode;
    if (_HCL_bubble_E) _HCL_E_valC = 0;
    else if (!_HCL_stall_E) _HCL_E_valC = _HCL_d_valC;
    if (_HCL_bubble_E) _HCL_E_valA = 0;
    else if (!_HCL_stall_E) _HCL_E_valA = _HCL_d_valA;
    if (_HCL_bubble_E) _HCL_E_valB = 0;
    else if (!_HCL_stall_E) _HCL_E_valB = _HCL_d_valB;
    if (_HCL_bubble_M) _HCL_M_stat = 0;
    else if (!_HCL_stall_M) _HCL_M_stat = _HCL_e_stat;
    if (_HCL_bubble_M) _HCL_M_icode = 1;
    else if (!_HCL_stall_M) _HCL_M_icode = _HCL_e_icode;
    if (_HCL_bubble_M) _HCL_M_dstM = 15;
    else if (!_HCL_stall_M) _HCL_M_dstM = _HCL_e_dstM;
    if (_HCL_bubble_M) _HCL_M_valA = 0;
    else if (!_HCL_stall_M) _HCL_M_valA = _HCL_e_valA;
    if (_HCL_bubble_M) _HCL_M_valE = 0;
    else if (!_HCL_stall_M) _HCL_M_valE = _HCL_e_valE;
	pragma(msg,`INFO: did not specify reg_dstE; disabling register write port E`);

	return cast(int)_HCL_Stat;
}
pragma(msg,`Estimated clock delay: 54`);
enum tpt = 54;

import std.stdio, std.file, std.string, std.conv, std.algorithm;
int main(string[] args) {
    bool verbose = true;
    bool pause = false;
    bool showall = false;
    uint maxsteps = 10000;
    string fname;
    foreach(a; args[1..$]) {
        if      (a == "-i" || a == "--interactive") pause   = true;
        else if (a == "-d" || a == "--debug"      ) showall = true;
        else if (a == "-q" || a == "--quiet"      ) verbose = false;
        else if (exists(a)) {
            if (fname.length > 0)
                writeln("WARNING: multiple files; ignoring \"",a,"\" in preference of \"",fname,"\"");
            else
                fname = a;
        } else if (a[0] > '0' && a[0] <= '9') {
            maxsteps = to!uint(a);
        } else {
            writeln("ERROR: unexpected argument \"",a,"\"");
            return 1;
        }
    }
    if (showall && !verbose) {
        writeln("ERROR: cannot be in both quiet and debug mode");
        return 2;
    }
    if (fname.length == 0) {
        writeln("USAGE: ",args[0]," [options] somefile.yo");
        writeln("Options:");
        writefln("    [a number]       : time out after that many steps (default: %d)",maxsteps);
        writeln("    -i --interactive : pause every clock cycle");
        writeln("    -q --quiet       : only show final state");
        writeln("    -d --debug       : show every action during simulation");
        return 3;
    }
    // load .yo input
    auto f = File(fname,"r");
    foreach(string line; lines(f)) {
        // each line is 0xaddress : hex data | junk, or just junk
        // fixed width:
        //     01234567890123456789012345678...
        //     0x000: 30f40001000000000000 |    irmovq $0x100,%rsp  # Initialize stack pointer
        if (line[0..2] == "0x") {
            auto address = to!uint(line[2..5], 16);
            auto datas = line[7..27].strip;
            for(uint i=0; i < datas.length; i += 2) {
                __memory[address+(i>>1)] = to!ubyte(datas[i..i+2],16);
            }
        }
    }

    void dumpstate() {
        writefln("| RAX: % 16x   RCX: % 16x   RDX: % 16x |", __regfile[0], __regfile[1], __regfile[2]);
        writefln("| RBX: % 16x   RSP: % 16x   RBP: % 16x |", __regfile[3], __regfile[4], __regfile[5]);
        writefln("| RSI: % 16x   RDI: % 16x   R8:  % 16x |", __regfile[6], __regfile[7], __regfile[8]);
        writefln("| R9:  % 16x   R10: % 16x   R11: % 16x |", __regfile[9], __regfile[10], __regfile[11]);
        writefln("| R12: % 16x   R13: % 16x   R14: % 16x |", __regfile[12], __regfile[13], __regfile[14]);

	write(`| register xF(`,(_HCL_bubble_F?'B':_HCL_stall_F?'S':'N'));
		writefln(`) { pc=%016x }                                |`, _HCL_F_pc);


	write(`| register fD(`,(_HCL_bubble_D?'B':_HCL_stall_D?'S':'N'));
		writefln(`) { icode=%01x rA=%01x rB=%01x stat=%01x valC=%016x }     |`, _HCL_D_icode, _HCL_D_rA, _HCL_D_rB, _HCL_D_stat, _HCL_D_valC);


	write(`| register dE(`,(_HCL_bubble_E?'B':_HCL_stall_E?'S':'N'));
		writefln(`) { dstM=%01x icode=%01x stat=%01x valA=%016x          |`, _HCL_E_dstM, _HCL_E_icode, _HCL_E_stat, _HCL_E_valA);
		writefln(`|  valB=%016x valC=%016x }                        |`, _HCL_E_valB, _HCL_E_valC);


	write(`| register eM(`,(_HCL_bubble_M?'B':_HCL_stall_M?'S':'N'));
		writefln(`) { dstM=%01x icode=%01x stat=%01x valA=%016x          |`, _HCL_M_dstM, _HCL_M_icode, _HCL_M_stat, _HCL_M_valA);
		writefln(`|  valE=%016x }                                              |`, _HCL_M_valE);


	write(`| register mW(`,(_HCL_bubble_W?'B':_HCL_stall_W?'S':'N'));
		writefln(`) { dstM=%01x icode=%01x stat=%01x valM=%016x }        |`, _HCL_W_dstM, _HCL_W_icode, _HCL_W_stat, _HCL_W_valM);

        auto set = __memory.keys; sort(set);
        writeln("| used memory:   _0 _1 _2 _3  _4 _5 _6 _7   _8 _9 _a _b  _c _d _e _f    |");
        ulong last = 0;
        foreach(a; set) {
            if (a >= last) {
                last = ((a>>4)<<4);
                writef("|  0x%07x_:  ", last>>4);
                foreach(j; 0..16) {
                    if (last+j in __memory) { writef(" %02x", __memory[last+j]); }
                    else write("   ");
                    if (j == 7) write("  ");
                    if (j == 3 || j == 11) write(" ");
                }
                writeln("    |");
                if (last + 16 < last) break;
                last += 16;
            }
        }
    }
    
    // loop, possibly pausing
    foreach(i; 0..maxsteps) {
        if (verbose) {
            writefln("+------------------- between cycles %4d and %4d ----------------------+", i, i+1);
            dumpstate();
            writeln("+-----------------------------------------------------------------------+");
            if (pause) {
                write("(press enter to continue)");
                stdin.readln();
            }
        }
        auto code = tick(verbose, showall);
        if (code == 2) {
            writeln("+----------------------- halted in state: ------------------------------+");
            dumpstate();
            writeln("+--------------------- (end of halted state) ---------------------------+");
            writeln("Cycles run: ",i+1);
            writeln("Time used: ", (i+1)*tpt);
            return 0;
        }
        if (code > 2) {
            writeln("+------------------- error caused in state: ----------------------------+");
            dumpstate();
            writeln("+-------------------- (end of error state) -----------------------------+");
            writeln("Cycles run: ",i+1);
            writeln("Time used: ", (i+1)*tpt);
            write("Error code: ", code);
            if (code < 6) writeln(" (", ["Bubble","OK","Halt","Invalid Address", "Invalid Instruction", "Pipeline Error"][code],")");
            else writeln(" (user-defined status code)");
            return 0;
        }
    }
    writefln("+------------ timed out after %5d cycles in state: -------------------+", maxsteps);
    dumpstate();
    writeln("+-----------------------------------------------------------------------+");
    
    return 0;
}
