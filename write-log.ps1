#variables
$verboseLogging = $false

[string] $TargetFolder = "c:\TeamsProject\"
if((test-path $TargetFolder) -ne $true)
{
    new-item -path $TargetFolder -type directory
}

$Filename = "Write-Log"
$Today = get-date -uformat "%y-%m-%d"
$LogFileFullName= $Filename+$Today+".log"
[string] $LogfilePath = $TargetFolder+$LogFileFullName

#region logging function
Function Add-Enum ($name,[string[]]$values,$nameSpace) 
{
if ($nameSpace) 
{
$code = @"
  namespace $NameSpace
  {
      public enum $name : int 
      {
          $($values -join ",`n")
      }
  }
"@

} 
else 
{
$code = @"
  public enum $name : int 
  {
      $($values -join ",`n")
  }
"@
}
Add-Type $code 
}

Add-Enum LogLevel "CriticalError","Error","Warning","Informational"
Add-Enum LogMode "File","Screen","FileScreen","HTML"

function FileLog
{
    param(  [string] $FileLogstr,
            [string] $FileName)

    Add-content -Path $FileName -Value $FileLogstr
}

function ScreenLog
{
    param(  [string] $ScreenLogStr,
            [LogLevel] $LogLevel)
    


    switch($LogLevel)
    {
        CriticalError { write-host $ScreenLogStr -BackgroundColor Red -ForegroundColor White -NoNewline}
        Error { write-host $ScreenLogStr -ForegroundColor Red -NoNewline}
        Warning {write-host $ScreenLogStr -ForegroundColor Yellow -NoNewline}
        Informational { write-host $ScreenLogStr -ForegroundColor Green -NoNewline}
        default {write-host $ScreenLogStr -ForegroundColor Gray -NoNewline}
    }
    write-host 
}

function HTMLLog
{
    param()
}

function AddWhiteSpace
{
    param([int] $NumberofIndents)

    [string]$whitespace =""
    [string]$indent = "     "
    
    if($NumberofIndents -gt 1)
    {
        for($i=1; $i -le $NumberofIndents; $i++)
        {
            $whitespace += $indent
        }
    }
    
    return $whitespace
}

function Write-Log
{
    param ( [string] $FileName,
            [string] $LogStr,
			[boolean] $Verbose,
            [string] $subsystem,
            [LogMode] $LogMode,
			[LogLevel] $LogLevel,
            [int] $IndentLevel)
        
	
    $date = (get-date -uformat "%y-%m-%d-%H-")+(get-date).minute;
    $whitepsace = AddWhiteSpace($IndentLevel)
    $FinalLogStr = "["+$date+ "]:"+"["+$LogLevel+"]"+":["+$subsystem+"]:"+$whitepsace+ $LogStr;  
    
    switch($LogMode){
        File {FileLog -FileLogstr $FinalLogStr -FileName $FileName}
        Screen {ScreenLog -ScreenLogStr $FinalLogStr -LogLevel $LogLevel}
        FileScreen{FileLog -FileLogstr $FinalLogStr -FileName $FileName;ScreenLog -ScreenLogStr $FinalLogStr -LogLevel $LogLevel}
        HTML{HTMLLog}
        default {}
    }
}
#endregion

#region examples
Write-Log -filename $LogfilePath -logstr "Example info" -verbose $verboseLogging -subsystem "Setup" -logmode "FileScreen" -loglevel "Informational" -indentlevel 1
Write-Log -filename $LogfilePath -logstr "Example Log file location: $($LogfilePath)" -verbose $verboseLogging -subsystem "Setup" -logmode "FileScreen" -loglevel "Informational" -indentlevel 2
Write-Log -filename $LogfilePath -logstr "Example warning" -verbose $verboseLogging -subsystem "Setup" -logmode "FileScreen" -loglevel "Warning" -indentlevel 1
Write-Log -filename $LogfilePath -logstr "WarningLog file location: $($LogfilePath)" -verbose $verboseLogging -subsystem "Setup" -logmode "FileScreen" -loglevel "Informational" -indentlevel 2
Write-Log -filename $LogfilePath -logstr "Error" -verbose $verboseLogging -subsystem "Setup" -logmode "FileScreen" -loglevel "Error" -indentlevel 1
Write-Log -filename $LogfilePath -logstr "Error Log file location: $($LogfilePath)" -verbose $verboseLogging -subsystem "Setup" -logmode "FileScreen" -loglevel "Error" -indentlevel 2
Write-Log -filename $LogfilePath -logstr "CriticalError" -verbose $verboseLogging -subsystem "Setup" -logmode "FileScreen" -loglevel "CriticalError" -indentlevel 1
#endregion
