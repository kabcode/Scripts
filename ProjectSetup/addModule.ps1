# This file adds a module to an existing project from directory 
# A CMake File is generated and added to the src directory CMakeLists.txt

Function Main($currentPath) {
	"Available Projects:"
	$directories = Get-ChildItem -Path $currentPath -Directory
	$res = $directories | Where-Object { $_ -NotLike "*-bin" } 
	Write-Host $res | Select-Object Name
	
	$projectname = Read-Host -Prompt "`nTo which project do you want to add a module (type 'x' to cancel)"
	if($projectname -eq "x")
	{
		Write-Host "MakeProject script stopped by user."
		return
	}
	$srcDirectory = Join-Path $currentPath $projectname
	Set-Location (Join-Path $srcDirectory "src")
	
	# get new module name
	$modulename = Read-Host -Prompt "`nName for new module? "
	New-Item $modulename -Type directory
}

#########################################################################
# run the script by calling the main function
$script:currentPath = Split-Path -parent $MyInvocation.MyCommand.Definition
Main($currentPath)

Set-Location $currentPath