        #add password to encrypt to secure string
        $userid = Read-Host -Prompt "Enter Username"
        $securestring = Read-Host -Prompt "Enter Password" -AsSecureString
        #$securestring = 'passwordgoeshere' | ConvertTo-SecureString -AsPlainText -Force
        $key = New-Object byte[](32)
        $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::Create()
        $rng.GetBytes($key)
        $encryptedstring = ConvertFrom-SecureString -SecureString $securestring -Key $key
        "-----------------------------------"
        "STRING ENCRYPTED"
        "$encryptedstring"
        "KEY ENCRYPTED"
        "$key"
        "-----------------------------------"
        "EXPORTING STRING AND KEY"
        $key | Out-File 'key'
        Get-ChildItem key
        $encryptedstring | Out-File 'secure'
        Get-ChildItem secure
        "-----------------------------------"
        "IMPORTING STRING AND KEY"
        $importkey = Get-Content 'key'
        $importsecure = Get-Content 'secure'
        "KEY = $importkey"
        "STRING = $importsecure"
        "-----------------------------------"
        "CREATING PSCREDENTIAL OBJECT"
        $secure = $encryptedstring | ConvertTo-SecureString -Key $key
        $cred = New-Object System.Management.Automation.PSCredential($userid, $secure)
        $cred
        "-----------------------------------"
        "TESTING DECRYPTION"
        $pw = $cred.GetNetworkCredential().Password
        "PASSWORD = $pw"
