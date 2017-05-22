# This file removes a CMAKE project from the project dorectory with all files and information
# For well-known reasons there will be single assurance question
Function Main($currentPath){
	
$script:projectExist = $TRUE
do {
		# ask for project name
	$projectname = Read-Host -Prompt "What project is going to be removed? (type 'x' to cancel)"
	if($projectname -eq "x"){
		Write-Host "removeProject script stopped by user."
		return
	}
	# dont try to remove current directory
	if($projectname -eq ""){
		Write-Host "Cannot remove current directory."
		return
	}
	$fullprojectpath = Join-Path $currentPath $projectname
	# check if project exist
	if((Test-Path $fullprojectpath) -eq 1){
		$projectExist = $TRUE
		"No Project with name $projectname in $currentPath."
	}
	else{
		$projectExist = $FALSE
	}	
} while(!$projectExist)

	try{
		Remove-Item $fullprojectpath
		"Project $projectname was removed from $currentPath."
	}
	catch{
		"Error."
		return
	}
}

# simplify the choice prompts
Function New-Choice {
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
	
# run the script
$currentPath = Split-Path -parent $MyInvocation.MyCommand.Definition
Main $currentPath