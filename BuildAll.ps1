#
# Build all solutions in directory
#

Write-Progress -Activity "Gathering solutions..." -Status 0 -PercentComplete 0
    
$solutions = Get-ChildItem -Path . -Filter *.sln -ErrorAction SilentlyContinue -Force -Recurse -Depth 1

$count = 0

Clear-Host
for($i=0; $i -le 6; $i++)
{
    Write-Output ""
}

foreach ($solution in $solutions) 
{
    $complete = [math]::Round(($count / $solutions.Count) * 100)
    
	Write-Progress -Activity "Building $solution" -Status "$complete%" -PercentComplete $complete
    
	$proc = Start-Process -Wait -PassThru -NoNewWindow -FilePath "msbuild.exe" -WorkingDirectory $solution.DirectoryName -ArgumentList $solution.Name, "/verbosity:quiet", "/nologo" #,"/p:Configuration=Debug"

    if($proc.ExitCode -ne 0)
    {
        Write-Output "Failed: $($solution.Name)"
    }
    $count++
}

Write-Progress -Completed "Done"

