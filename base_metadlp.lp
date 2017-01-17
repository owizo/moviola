#program base.

%
% Update semantics
%

%% #external sem(as).   % Update answer set semantics
%% #external sem(ju).   % Justified update semantics
%% #external sem(ds).   % Dynamic stable model semantics
%% #external sem(rd).   % Refined dynamic stable model semantics

1 { sem(as); sem(ju); sem(ds); sem(rd) } 1.

activedef :- sem(ds).
activedef :- sem(rd).

%% To avoid some annoying warnings
rule(d,d,d) :- 1==0.
rule(head(d),d,d) :- 1==0.
rule(d,body(d),d) :- 1==0.
rule(head(d),body(d),d) :- 1==0.
pids(d,d) :- 1==0.
literal_tuple(d,d,d) :- 1==0.
literal_tuple(head(d),d,d) :- 1==0.
literal_tuple(body(d),d,d) :- 1==0.

