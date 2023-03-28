[xml]$plugin =  get-content -path .\_src\plugin.xml

# specify the path to the folder you want to monitor:
$Path = ".\_src"

# specify which files you want to monitor
$FileFilter = '*'  

# specify whether you want to monitor subfolders as well:
$IncludeSubfolders = $true

# specify the file or folder properties you want to monitor:
$AttributeFilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite 

# specify the type of changes you want to monitor:
$ChangeTypes = [System.IO.WatcherChangeTypes]::Created, [System.IO.WatcherChangeTypes]::Deleted, [System.IO.WatcherChangeTypes]::Changed

# specify the maximum time (in milliseconds) you want to wait for changes:
$Timeout = 1000 

# define a function that gets called for every change:
function Invoke-Build
{
  param
  (
    [Parameter(Mandatory)]
    [System.Object]
    $ChangeInformation
  )
    # Write the change
    Write-Host "[$(Get-Date -Format "HH:mm:ss")][$($ChangeInformation.ChangeType)] $($ChangeInformation.Name)" -ForegroundColor Yellow
    
    $srcPath = ".\_src"
    $buildPath = ".\_build"
    # Create the zip file
    $zipFileName = "$($plugin.plugin.name) v$($plugin.plugin.version).zip"
    $zipFilePath = Join-Path $buildPath $zipFileName
    Compress-Archive -path $($srcPath+"\*")  -DestinationPath $zipFilePath -Force
    Write-Host "[$(Get-Date -Format "HH:mm:ss")][Create] build\$zipFileName" -ForegroundColor Yellow



}

# use a try...finally construct to release the
# filesystemwatcher once the loop is aborted
# by pressing CTRL+C

Clear-Host
try
{
  Write-Host "[$($plugin.plugin.name)] Monitoring $Path, Press CTRL+C to exit." -ForegroundColor Green
  $onBoot = @{
    ChangeType = "Boot"
    Name = "Performing an initial build as part of the startup process."
  }
  Invoke-Build -ChangeInformation $onBoot
  # create a filesystemwatcher object
  $watcher = New-Object -TypeName IO.FileSystemWatcher -ArgumentList $Path, $FileFilter -Property @{
    IncludeSubdirectories = $IncludeSubfolders
    NotifyFilter = $AttributeFilter
  }

  # start monitoring manually in a loop:
  do
  {
    # wait for changes for the specified timeout
    # IMPORTANT: while the watcher is active, PowerShell cannot be stopped
    # so it is recommended to use a timeout of 1000ms and repeat the
    # monitoring in a loop. This way, you have the chance to abort the
    # script every second.
    $result = $watcher.WaitForChanged($ChangeTypes, $Timeout)
    # if there was a timeout, continue monitoring:
    if ($result.TimedOut) { continue }
    
    Invoke-Build -Change $result
    # the loop runs forever until you hit CTRL+C    
  } while ($true)
}
finally
{
  # release the watcher and free its memory:
  $watcher.Dispose()
  Write-Host "[$(Get-Date -Format "HH:mm:ss")][Cleanup] FileSystemWatcher removed." -ForegroundColor Cyan
}