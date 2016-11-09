import pegged.grammar;

/// HCL2 uses the following PEG grammar with pegged 0.1 extensions.
enum hcl_grammar = `
HCL:
	DefList < ((ConstDef / WireDef / Initialize / RegDef / ';')* eoi) { flatten }
	
	Comment1 <- '#' (!eol .)* eol
	Comment2 <- '//' (!eol .)* eol
	Comment3 <- '/*' (!'*' . / '*' !'/')* '*/'
	Spacing <- ((blank / Comment1 / Comment2 / Comment3)*)
	
	Math <- SetMembership / Math1 / MuxExp
	Math1 < (Math2 (BinOp Math2)*)
	Math2 < UnOp* Math3
	Math3 <- WireCat / Slice
	WireCat < '(' Slice ('..' Slice)+ ')'
	Slice < Value ('[' DecLit '..' DecLit ']')?
	Value <- (BinLit / HexLit / DecLit / BoolLit / Variable) ![0-9a-zA-Z] / '(' Math ')'
	BinLit <- "0b" ~([01]+)
	HexLit <- "0x" ~([0-9a-fA-F]+) 
	DecLit <- ~([1-9] [0-9]* / "0" ![0-9])
	BoolLit <- 'true' / 'True' / 'TRUE' / 'false' / 'False' / 'FALSE'
	Variable <- identifier
	BinOp <- 
		/ '<=' / '==' / '>=' / '!=' / '<' / '>'
		/ '||' / '&&' / '|' / '&' / '^'
		/ '+' / '-' / '*' / '/' / '%'
	UnOp <- '~' / '-' / '!'
	
	MuxExp < '[' MuxRow+ ']'
	MuxRow < (SetMembership / Math1) ':' Math ';'
	
	SetMembership < (Math1 'in' '{' Math (',' Math)* '}') { setToOr }
	
	ConstDef < "const" :spacing Variable "=" Math1 (',' Variable '=' Math1)* ';'
	WireDef < "wire" :spacing Variable ':' DecLit (',' Variable ':' DecLit)* ';'
	Initialize < Variable '=' Math (',' Variable '=' Math)* ';'
	RegDef < 'register' :spacing ~([a-z]? [A-Z]) '{' RegPart* '}'
	RegPart < Variable ':' DecLit '=' Math ';'
`;

void main() {
	static import std.file, std.array;
	std.file.write("grammar.d", `/**
 * This file was auto-generated by PEGGED, which is available under the Boost
 * license from <https://github.com/PhilippeSigaud/Pegged>.
 * The originating PEGGED grammar follows this comment.
 * 
 * The grammar and this file are both part of the HCL2D project, which is a
 * a hardware description language inspired by the HCL language described in 
 * Computer Systems: A Programmer's Perspective by R. Bryant and D. O'Hallaron.
 * 
 * License:
 * Copyright (c) 2015 Luther Tychonievich. 
 * Released into the public domain.  
 * Attribution is appreciated but not required.
 */
/+
`~hcl_grammar~`
+/
import pegged.grammar;

`~grammar(hcl_grammar)~`

/// A helper function: removes all nodes that are nothing but a single child
ParseTree flatten(ParseTree p) {
	p = HCL.decimateTree(p);
	if (p.children.length == 1 && p.matches == p.children[0].matches) 
		return flatten(p.children[0]);
	auto ans = p;
	foreach(i,c; p.children) {
		ans.children[i] = flatten(c);
	}
	return ans;
}

/// A simplifying function: changes "x in {a,b}" into "x==a||x==b"
ParseTree setToOr(ParseTree p) {
	if (!p.successful) return p;
	p = HCL.decimateTree(p);
	ParseTree ans = {"HCL.Math1", true, p.matches, p.input, p.begin, p.end, []};
	ParseTree eq = {"HCL.BinOp", true, ["=="], p.input, p.children[0].end, p.children[1].begin, []};
	foreach(i, child; p.children[1..$]) {
		if (i > 0) {
			ParseTree or = {"HCL.BinOp", true, ["||"], p.input, p.children[i].end, p.children[i+1].begin, []};
			ans.children ~= or;
		}
		ParseTree term = {"HCL.Math1", true, 
				p.children[0].matches ~ child.matches,
				p.input,
				child.begin, child.end,
				[p.children[0], eq, child] 
			};
		ParseTree wrap = {"HCL.Value", true, 
				"(" ~ term.matches ~ ")",
				p.input,
				term.begin, term.end,
				[term] 
			};
		ans.children ~= wrap;
	}
	return ans;
}
`);
}
