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
	
	# add module in src CMakeLists.txt
	Add-Content "CMakeLists.txt" "ADD_SUBDIRECTORY($modulename)"
	
	# change to module file and setup module directory
	$modulePath = Join-Path $srcDirectory $modulename 
	Set-Location $modulePath
	New-Item "include" -Type directory
	New-Item "source" -Type directory
	
	# setup CMakeLists.txt for the module
	$cmakeListModule = New-Item (Join-Path $modulePath "CMakeLists.txt") -Type File
	Add-Content $cmakeListModule "###############################################"
	Add-Content $cmakeListModule "# CMAKELISTS FOR $modulename"
	Add-Content $cmakeListModule "###############################################"
	Add-Content $cmakeListModule "`n`n# add source files"
	Add-Content $cmakeListModule "SET(${CMAKE_CURRENT_LIST_DIR}/source/*.cpp)"
	Add-Content $cmakeListModule "`n`n# add module as library"
	Add-Content $cmakeListModule "ADD_LIBRARY ($modulename $SOURCES)"
	Add-Content $cmakeListModule "`n`n# add include files to global and local include set"
	Add-Content $cmakeListModule "target_include_directories($modulename PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include> PRIVATE source)"
	
}

#########################################################################
# run the script by calling the main function
$script:currentPath = Split-Path -parent $MyInvocation.MyCommand.Definition
Main($currentPath)

Set-Location $currentPath