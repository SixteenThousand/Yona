START_MSG="Preparing to run...\n\n"
END_MSG="\n\nProgram might have run!"

declare -A RUNNERS
RUNNERS=(
	[go]="go run %"
	[hs]="runghc %"
	[js]="node %"
	[lisp]="sbcl --script %"
	[lua]="lua %"
	[mjs]="node %"
	[ml]="ocaml %"
	[php]="php %"
	[ps1]="pwsh %"
	[py]="python %"
	[rb]="ruby %"
	[sql]="psql -f %"
	[sh]="bash %"
	[bash]="bash %"
	[fish]="fish %"
	[pl]="perl %"
	[java]="java %<"
	[ts]="node %+.js"
)
