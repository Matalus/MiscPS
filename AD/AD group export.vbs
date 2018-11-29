'Script begins here
Dim objGroup, objUser, objFSO, objFile, strDomain, strGroup, Domain, Group

'Change DomainName to the name of the domain the group is in
strDomain = "DOMAINNAME"

'Change GroupName to the name of the group whose members you want to export
strGroup = InputBox ("Enter the Group name", "Data needed", "Default group name")

'Change strPath to the path of where you'd like your file to save
Set oShell = CreateObject( "WScript.Shell" )
strPath = oShell.ExpandEnvironmentStrings("%UserProfile%\Desktop\")

Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objFile = objFSO.CreateTextFile(strPath & strGroup & " - Members.txt")
Set objGroup = GetObject("WinNT://" & strDomain & "/" & strGroup & ",group")
For Each objUser In objGroup.Members
    objFile.WriteLine objUser.Name
Next
objFile.Close
Set objFile = Nothing
Set objFSO = Nothing
Set objUser = Nothing
Set objGroup = Nothing
Wscript.Echo "Please check your desktop for your output file"
