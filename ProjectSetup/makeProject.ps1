# This file sets up a CMAKE project directory with all useful files and information
# collect some basic information
Function Main($currentPath) {
	"`n"
	"=================================="
	" Welcome to Project Maker for C++ " 
	"=================================="
	"`n"
	
	Write-Host "Some information are needed:"
	$script:projectExist = $FALSE
	do {
		# ask for project name
		$projectname = Read-Host -Prompt "Type in your (main) project name (type 'x' to cancel)"
		if($projectname -eq "x")
		{
			Write-Host "MakeProject script stopped by user."
			return
		}
		$fullprojectpath = Join-Path $currentPath $projectname

		# check if project already exist.
		$projectExist = checkDirectory($fullprojectpath)
		$projectExist
	} while(!$projectExist)
	"The project name is ""$fullprojectpath""."
	
	# create project file set (CMakeLists.txt, ReadMe, License, Doxyfile
	$cmakeListtop = New-Item (Join-Path $fullprojectpath "CMakeLists.txt") -Type File
	## cmakeMinimumVersion
	$cmake_config = @{"cmakeversion" = "3.1"}
	$cmake_config.Set_Item("projectname",$projectname)
	Populate-CMakeLists $cmakeListtop $cmake_config
	
	# create a ReadMe file for instructions
	New-Item (Join-Path $fullprojectpath "ReadMe.md") -Type File

	# create a LICENSE file (with at least the MIT license)
	$licencefile = New-Item (Join-Path $fullprojectpath "LICENSE.txt") -Type File
	$choice = New-Choice "yes","no" -Caption "Do you want a license for your project?"
	if($choice -eq "yes") {
		Invoke-Item $licencefile
		Start-Process -FilePath https://choosealicense.com  
	}
	else {
		$copyrightholder = Read-Host "Who is the copyright holder of your project?"
		Print-MITLicense $licencefile $copyrightholder
	}
	
	# setup doxyfile for documentation and documentation directory
	New-Item (Join-Path $fullprojectpath "Doxyfile") -Type File
	New-Item (Join-Path $fullprojectpath "doc") -Type directory
	
	# create directory structure for project
	<#
	New-Item (Join-Path $fullprojectpath "bin") -Type directory
	New-Item (Join-Path $fullprojectpath "build") -Type directory
	New-Item (Join-Path $fullprojectpath "src") -Type directory
	New-Item (Join-Path $fullprojectpath "include") -Type directory
	New-Item (Join-Path $fullprojectpath "extern") -Type directory
	New-Item (Join-Path $fullprojectpath "test") -Type directory
	# New-Item (Join-Path $fullprojectpath "libs") -Type directory
	New-Item (Join-Path $fullprojectpath "shared") -Type directory
	#>
}

# check if project folder exist, otherwise create the folder and change to it
# if project exists return true (asks for another project name)
Function checkDirectory($fullprojectpath) {
	if((Test-Path $fullprojectpath) -eq 0)
	{
		Write-Host "Create $fullprojectpath and change into this directory..."
		New-Item $fullprojectpath -Type directory
		Set-Location -Path $fullprojectpath
		$projectExist = $FALSE
	}
	else
	{
		Write-Host "This project already exist. Do you want to rename your project?"
		$projectExist = $TRUE
	}
}

# simplify the choice prompts
function New-Choice {
<#
        .SYNOPSIS
                The New-Choice function is used to provide extended control to a script author who writing code
        that will prompt a user for information.
 
        .PARAMETER  Choices
                An Array of Choices, ie Yes, No and Maybe
 
        .PARAMETER  Caption
                Caption to present to end user
 
        .EXAMPLE
                PS C:\> New-Choice -Choices 'Yes','No' -Caption "PowerShell makes choices easy"
               
        .NOTES
                Author: Andy Schneider
                Date: 5/6/2011
#>
 
[CmdletBinding()]
param(
               
        [Parameter(Position=0, Mandatory=$True, ValueFromPipeline=$True)]
        $Choices,
               
        [Parameter(Position=1)]
        $Caption,
   
        [Parameter(Position=2)]
        $Message    
       
)
       
process {
       
        $resulthash += @{}
        for ($i = 0; $i -lt $choices.count; $i++)
            {
                   
               $ChoiceDescriptions += @(New-Object System.Management.Automation.Host.ChoiceDescription ("&" + $choices[$i]))
               $resulthash.$i = $choices[$i]
            }
        $AllChoices = [System.Management.Automation.Host.ChoiceDescription[]]($ChoiceDescriptions)
        $result = $Host.UI.PromptForChoice($Caption,$Message, $AllChoices, 1)
        $resulthash.$result -replace "&", ""
        }        
}

# print MIT-License to file
Function Print-MITLicense($licencefile, $copyrightholder) {
	$currentYear = (Get-Date).Year
	$licencetext = 
"Copyright $currentYear $copyrightholder
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and 
associated documentation files (the ""Software""), to deal in the Software without restriction, 
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or 
substantial portions of the Software.

THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN 
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
	
	$licencetext | Out-File $licencefile
}

# Populate CmakeLists.txt with some base content
Function Populate-CMakeLists($cmakeListtop, $cmake_config){
	Add-Content $cmakeListtop "###############################################"
	Add-Content $cmakeListtop "# TOP CMAKELISTS FOR $($cmake_config.projectname)"
	Add-Content $cmakeListtop "###############################################"
	Add-Content $cmakeListtop "`n# basic setup of the project cmakelists.txt"
	Add-Content $cmakeListtop "CMAKE_MINIMUM_REQUIRED (VERSION $($cmake_config.cmakeversion))"
	Add-Content $cmakeListtop "PROJECT ($($cmake_config.projectname))"
	Add-Content $cmakeListtop "`n# add executable"
	Add-Content $cmakeListtop "ADD_EXECUTABLE ($($cmake_config.projectname) """")"
}

# run the script by calling the main function
$script:currentPath = Split-Path -parent $MyInvocation.MyCommand.Definition
Main($currentPath)

# for test reasons
Set-Location $currentPath



