#script (python).

import clingo
import cmd2
import os
import sys
from reifier import Reifier

from IPython.terminal.embed import InteractiveShellEmbed
ipshell = InteractiveShellEmbed()

class DlpInterpreter(cmd2.Cmd):
    SEM_AS = 0
    SEM_JU = 1
    SEM_DS = 2
    SEM_RD = 3
    SEM_ALL = 9

    ASSUM = { SEM_AS: [(clingo.parse_term('sem(as)'),True)],
              SEM_JU: [(clingo.parse_term('sem(ju)'),True)],
              SEM_DS: [(clingo.parse_term('sem(ds)'),True)],
              SEM_RD: [(clingo.parse_term('sem(rd)'),True)],
              SEM_ALL: [] }

    SEMNAME = { SEM_AS: 'sem(as)',
                SEM_JU: 'sem(ju)',
                SEM_DS: 'sem(ds)',
                SEM_RD: 'sem(rd)',
                SEM_ALL: '1{sem(as);sem(ju);sem(ds);sem(rd)}1.' }
    
    def __init__(self, dlpname='u', ctrl=None):
        cmd2.Cmd.__init__(self)
        self.updatePrgName = 'update.lp'
        self.prompt = '>> '
        self.ruler = '-'
        self.dlpname = 'u'
        self.prgid = 0
        self.verbose = 0
        self.inplayback = False
        self.debugplayback = False
        self.reifier = Reifier()
        if ctrl:
            self.ctrl = ctrl
        else:
            self.ctrl = clingo.Control()
        self.ctrl.configuration.solve.project = 1
        self.ctrl.load('base_metadlp.lp')
        self.ctrl.ground([('base',[])])
        self.ctrl.load('ms_metadlp.lp')
        self.do_semantics('rd')
        self.singleshotcmds = []

    def postcmd(self, stop, line):
        if not self.debugplayback and self.inplayback and len(self.cmdqueue) == 0:
            self.inplayback = False
        return stop

    def do_debugplayback(self, args):
        self.debugplayback = True
        self.inplayback = True

    def do_debugnoplayback(self, args):
        self.debugplayback = False
        self.inplayback = False

    def do_debugnoproject(self, args):
        self.ctrl.configuration.solve.project = 0

    def do_record(self, args):
        a = args.split()
        if len(a) != 1:
            self.perror('*** invalid number of arguments')
            return
        f = open(a[0],'w')
        f.write('debugplayback\n')
        for c in self.history[:-1]:
            f.write('%s\n' %(c))
        f.write('debugnoplayback\n')
        f.close()
        self.poutput('Command history written to %s' %(a[0]))

    def do_singleshot(self, args):
        a = args.split()
        if len(a) != 1:
            self.perror('*** invalid number of arguments')
            return
        f = open(a[0],'w')
        f.write('rm %s.ssupd\n' %(self.dlpname))
        for c in self.singleshotcmds:
            f.write('%s\n' %(c))
        f.close()
        self.poutput('Single-shot script prepared: %s' %(a[0]))

    def do_playback(self, args):
        a = args.split()
        if len(a) != 1:
            self.perror('*** invalid number of arguments')
            return
        try :  
            f = open(a[0],'r')
            self.cmdqueue.extend(f.readlines())
            f.close()
            self.inplayback = True
        except Exception as e:
            self.perror(str(e))

    def on_model(self, model):
        if self.verbose > 0:
            self.poutput(', '.join(map(str, model.symbols(atoms=True))))

    def do_verbose(self, args):
        a = args.split()
        if len(a) != 1:
            self.perror('*** invalid number of arguments')
            return
        self.verbose = int(a[0])

    def do_freezesemantics(self, args):
        'Freeze the current update semantics.'
        self.do_semantics('')
        self.poutput('Freezing semantics ...')
        self.ctrl.add('freeze',[],'%s.' %(DlpInterpreter.SEMNAME[self.semantics]))
        self.ctrl.ground([('freeze',[])])
        self.ctrl.solve()
        self.ctrl.cleanup()

    def do_semantics(self, args):
        'Show/change the active update semantics.'
        a = args.split()
        if len(a) == 0:
            if self.semantics == DlpInterpreter.SEM_JU:
                self.poutput('Update semantics: JU')
            elif self.semantics == DlpInterpreter.SEM_DS:
                self.poutput('Update semantics: DS')
            elif self.semantics == DlpInterpreter.SEM_RD:
                self.poutput('Update semantics: RD')
            elif self.semantics == DlpInterpreter.SEM_AS:
                self.poutput('Update semantics: AS')
            elif self.semantics == DlpInterpreter.SEM_ALL:
                self.poutput('Update semantics: ALL')
            return
        elif len(a) != 1:
            self.perror('*** invalid number of arguments')
            return

        if a[0] == 'ju':
            self.semantics = DlpInterpreter.SEM_JU
            self.poutput('Changing semantics: JU')
        elif a[0] == 'ds':
            self.semantics = DlpInterpreter.SEM_DS
            self.poutput('Changing semantics: DS')
        elif a[0] == 'rd':
            self.semantics = DlpInterpreter.SEM_RD
            self.poutput('Changing semantics: RD')
        elif a[0] == 'as':
            self.semantics = DlpInterpreter.SEM_AS
            self.poutput('Changing semantics: AS')
        elif a[0] == 'all':
            self.semantics = DlpInterpreter.SEM_ALL
            self.poutput('Changing semantics: ALL')
        else:
            self.perror('*** invalid update semantics value, use as, ju, ds, rd, or all')
            return

    def do_update(self, args):
        'Enter an update propositional program using the editor.'
        if not self.inplayback:
            os.system('%s %s' %(self.editor, self.updatePrgName))
            self.stdout.write(open(self.updatePrgName).read())

        self.prgid += 1
        currUpdatePrgName = '%s.%d.lp' %(self.dlpname,self.prgid)
        if not self.inplayback:
            os.system('cp %s %s' %(self.updatePrgName, currUpdatePrgName))
        
        self.poutput('Reifying %s ...' %(currUpdatePrgName))
        reifiedOut = open('%s.reified' %(currUpdatePrgName), 'w')
        self.reifier.out =reifiedOut
        self.reifier.prgid = self.prgid-1
        clingo.parse_program(open(currUpdatePrgName).read(), lambda n: self.reifier.reify(n) )
        for p in range(self.prgid, self.reifier.prgid+1):
            reifiedOut.write('pids(%d,%d).\n' % (p,self.prgid))
        reifiedOut.close()
        self.singleshotcmds.append('./reifier.py %d < %s > %s.reified' %(self.prgid,currUpdatePrgName,currUpdatePrgName))
        self.singleshotcmds.append('cat %s.reified >> %s.ssupd' %(currUpdatePrgName,self.dlpname))

        self.poutput('Updating ...')
        # add the update program 
        self.ctrl.add('u_%d'%(self.prgid),[],'#include "%s.%d.lp.reified".' %(self.dlpname,self.prgid))

        # ground
        self.ctrl.ground([('meta',[self.prgid]),('u_%d'%(self.prgid),[])])

        self.prgid = self.reifier.prgid

    def do_name(self, args):
        'Change the of the DLP'
        a = args.split()
        if len(a) != 1:
            self.perror('*** invalid number of arguments')
            return
        self.dlpname = a[0]

    def do_solve(self, args):
        'Solve'
        self.singleshotcmds.append("echo '%s.' | clingo metadlp_singleshot.lp %s.ssupd - -c _uid=0 %d" 
            %(DlpInterpreter.SEMNAME[self.semantics],self.dlpname,
              int(self.ctrl.configuration.solve.models) if self.ctrl.configuration.solve.models!='-1' else 1))
        self.ctrl.solve(on_model = self.on_model, assumptions=DlpInterpreter.ASSUM[self.semantics])

    def do_models(self,args):
        'Set the number of models to be searched for (0:all)'
        a = args.split()
        if len(a) != 1:
            self.perror('*** invalid number of arguments')
            return
        self.ctrl.configuration.solve.models = int(a[0])

    def do_eof(self, args):
        self.poutput('\n')
        return True


def main(prg):
    # clingo is calling ...
    # unfortunately there is no way to differentia whether the script is run directly or via clingo
    d = DlpInterpreter(ctrl=prg)
    d.cmdloop()

#end.
