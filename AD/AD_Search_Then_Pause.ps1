#this is a demonstration to tweak someone's script to add a pause at the end when executed from right click

#retrive the OUs and set the scope
$search = "" #hard code Distinguished path if you want otherwise prompt to select an OU
if($search.length -lt 1){
    $search = Get-ADOrganizationalUnit -Filter * | Out-GridView -Title "Select an OU Scope" -PassThru
}
#capture the search string
$userpartname = Read-Host "type the user name you look for or part of a name and it will show you all matches"
$userpartname += "*"

#capture results in variable
$users = Get-ADUser -SearchBase $search.distinguishedname -Filter {SamaccountName -like $userpartname}

#display output formatted
$users | format-table Name,SamAccountName,Description,SID

#pause
Read-Host -Prompt "Press Enter to Quit"