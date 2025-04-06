# What command should be run to compile each file extension
# Uses substituions:
# 	%  -> the filename
# 	%< -> the "name part" of the filename, i.e. the filename without extension
# 	%+ -> the "name part" + the extension .yonax
declare -A COMPILERS=(
	[c]="gcc -o %+ %"
	[cpp]="g++ -o %+ %"
	[go]="go build -o %+ %"
	[hs]="ghc -Wno-tabs %"
	[java]="javac %"
	[ml]="ocamlc -o %+ %"
	[rs]="rustc -A dead-code -o %+ %"
	[tex]="pdflatex -output-directory='tex-logs' % && mv tex-logs/%<.pdf ."
	[ts]="tsc --target esnext %"
)
