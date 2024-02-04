Param(
	$action,
	$path,
	$name,
	$extension,
	$token
)


$commandsPath = "./.yona"


Function Invoke-TopLevel {
	cd $(git rev-parse --show-toplevel)
}

Function New-Yona {
	Invoke-TopLevel
	New-Item `
		-Path . `
		-ItemType "file" `
		-Name $commandsPath `
		-Value "show;;ls"
}


Function Invoke-Command {
	Param($commandName)
	Invoke-TopLevel
	$line = Select-String -Path $commandsPath -pattern "$commandName;;(.+)"
	Invoke-Expression $line.matches.groups[1].value
}

Function Get-YonaInfo {
	echo "Yona of the Build - pwsh version"
	$desc = -join (`
		"This tool allows you to run given shell commands ", `
		"of a project from anywhwhere in said project" `
	)
	echo $desc
}

Function Invoke-Grep {
	Invoke-TopLevel
	Invoke-Expression "rg `"$token`""
}

Function Invoke-Run {
	echo "`r`nPreparing to run...`r`n"
	cd $path
	if($extension -eq "java") {
		Invoke-Expression "java $name"
		return
	}
	if(Test-Path "$path\$name`.exe") {
		Invoke-Expression ".\$name"
		return
	}
	$runners = @{
		hs = "runghc";
		js = "node";
		lisp = "sbcl --script";
		php = "php";
		py = "python";
		go = "go run";
	}
	$runner = $runners.$extension
	Invoke-Expression "$runner $name`.$extension"
	echo "`r`nIt might have run!"
}

Function Invoke-Compile {
	echo "`r`nPreparing to compile...`r`n"
	cd $path
	if($extension -eq "c") {
		Invoke-Expression "gcc $name`.$extension -o $name"
		return
	}
	$compilers = @{
		cs = "csc";
		hs = "ghc -Wno-tabs";
		java = "javac -Xlint:unchecked";
		rs = "rustc -A dead-code";
		tex = "pdflatex";
		go = "go build"
	}
	$compiler = $compilers.$extension
	Invoke-Expression "$compiler $name`.$extension"
	echo "`r`nCompiled! Maybe!"
}

$cwd = Get-Location
Switch ($action) {
	"help" {Get-YonaInfo}
	"--help" {Get-YonaInfo}
	"init" {New-Yona}
	"grep" {Invoke-Grep}
	"run" {Invoke-Run}
	"compile" {Invoke-Compile}
	default {Invoke-Command -commandName $action}
}
cd $cwd
