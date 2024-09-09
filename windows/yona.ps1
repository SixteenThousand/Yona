Param(
	[Parameter(Position=0)]$action,
	# either the absolute path of the file, or the string used by grep
	[Parameter(Position=1)]$object,
	$name,
	$extension
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
	echo "Yona of the Build 0.1 - powershell version"
	$desc = -join (`
		"This tool allows you to run given shell commands ", `
		"of a project from anywhwhere in said project" `
	)
	echo $desc
}

Function Invoke-Grep {
	Invoke-TopLevel
	Invoke-Expression "rg `"$object`""
}

Function Invoke-Run {
	echo "`r`nPreparing to run...`r`n"
	cd $object 
	if(Test-Path "$object\$name`.exe") {
		Invoke-Expression ".\$name"
		return
	}
	$runners = @{
		go = "go run";
		hs = "runghc";
		js = "node";
		lisp = "sbcl --script";
        mjs = "node";
		php = "php";
		ps1 = "pwsh";
		py = "python";
        rb = "ruby";
	}
    # run commands that need the "name part" of the filename, i.e. the filename
    # sans extension. The hash (#) will be replaced by the name part.
    $specialRunners = @{
        java = "java #";
        ts = "node #.js";
    }
    if($runners.Contains($extension)) {
        $runner = $runners.$extension
        Invoke-Expression "$runner $name`.$extension"
    } elseif($specialRunners.Contains($extension)) {
        Invoke-Expression $($specialRunners.$extension -creplace "#",$name)
    }
	echo "`r`nIt might have run!"
}

Function Invoke-Compile {
	echo "`r`nPreparing to compile...`r`n"
	cd $object
	if($extension -eq "c") {
		Invoke-Expression "gcc $name`.$extension -o $name"
		return
	}
	$compilers = @{
		cs = "csc";
		go = "go build"
		hs = "ghc -Wno-tabs";
		java = "javac -Xlint:unchecked";
		rs = "rustc -A dead-code";
		tex = "pdflatex -aux-directory='tex-logs'";
        ts = "tsc --target esnext"
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
