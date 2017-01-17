#!/usr/bin/env python3

#
# Reifier class 
# reifies a ground normal logic program to be used as an update program in moviola
# format is a bit different than the gringo's
#

import sys
import clingo
import clingo.ast

class Reifier:
    def __init__(self, prgid=0, out=sys.stdout):
        self.prgid = prgid          # step or id of the program in a DLP
        self.ruleid = 0
        self.out = out

    def reify(self, ast):
        if ast.type == clingo.ast.ASTType.Rule:
            self.ruleid = self.ruleid + 1
            self.reifyRule(ast)
        elif ast.type == clingo.ast.ASTType.Program:
            self.prgid = self.prgid + 1
        else:
            sys.stderr.write('Type: %s\n' %(ast.type))
            sys.stderr.write('%s\n' %(ast))

    def reifyRule(self, ast):
        if ast.type != clingo.ast.ASTType.Rule:
            raise Error('Expecting a Rule type AST')
        if str(ast['head']) != '#false':  self.reifyHeadLiteral(ast['head']) 
        for b in ast['body']:
            self.reifyBodyLiteral(b)
        self.out.write('rule(head(%d),body(%d),%d).\n' %(self.ruleid,self.ruleid,self.prgid))
        
    def reifyBodyLiteral(self, ast, onlyone=False):
        if ast.type != clingo.ast.ASTType.Literal:
            raise Error('Expecting a Literal type AST')
        if str(ast.sign) == '':
            self.out.write('literal_tuple(body(%d),%s,%d).\n' %(self.ruleid,ast,self.prgid))
        elif ast.sign == clingo.ast.Sign.Negation:
            self.out.write('literal_tuple(body(%d),_n(%s),%d).\n' %(self.ruleid,ast['atom'],self.prgid))

    def reifyHeadLiteral(self, ast):
        if ast.type != clingo.ast.ASTType.Literal:
            raise Error('Expecting a Literal type AST')
        if str(ast.sign) == '':
            self.out.write('literal_tuple(head(%d),%s,%d).\n' %(self.ruleid,ast,self.prgid))
        elif ast.sign == clingo.ast.Sign.Negation:
            self.out.write('literal_tuple(head(%d),_n(%s),%d).\n' %(self.ruleid,ast['atom'],self.prgid))


def main():
    if len(sys.argv) <= 1:
        raise Exception('Usage: reifier.py prgid# (reads from stdin)')
   
    prgid = int(sys.argv[1])
    reifier = Reifier(prgid=prgid-1)

    clingo.parse_program(sys.stdin.read(), lambda n: reifier.reify(n) )
    for p in range(prgid,reifier.prgid+1):
        sys.stdout.write('pids(%d,0).\n' %(p))


if __name__ == "__main__":
    main()
