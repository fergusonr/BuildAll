#
# Build all solutions in directory
#

param(
    [Parameter(Mandatory=$false)][string]$skip
)

if(    $PSVersionTable.PSVersion.Major -ge 7 `
  -or ($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion.Minor -ge 2))
{
    $PSStyle.Progress.View="Classic" # Backwards compatible
}

if($skip -ne "")
{
  $msg = "skipping $($skip)"
}

Write-Progress -Activity "Gathering solutions...$($msg)" -Status 0 -PercentComplete 0
    
$solutions = Get-ChildItem -Path . -Filter *.sln -ErrorAction SilentlyContinue -Force -Recurse -Depth 1

$count = 0

Clear-Host
for($i=0; $i -le 6; $i++)
{
    Write-Output ""
}

foreach ($solution in $solutions) 
{
    if($PSBoundParameters.ContainsKey('skip') -and $solution.Name.contains($skip))
    {
        $count++;
        continue
    }

    $complete = [math]::Round(($count / $solutions.Count) * 100)
    
	Write-Progress -Activity "Building $($solution.BaseName)" -Status "$complete%" -PercentComplete $complete
    
	$proc = Start-Process -Wait -PassThru -NoNewWindow -FilePath "msbuild.exe" -WorkingDirectory $solution.DirectoryName -ArgumentList "`"$($solution.Name)`"", "/verbosity:quiet", "/nologo", "/t:clean,restore,build",/p:WarningLevel=0 #,"/p:Configuration=Debug"

    if($proc.ExitCode -ne 0)
    {
        Write-Output "Failed: $($solution.Name)"
    }
    $count++
}

Write-Progress -Completed "Done"

