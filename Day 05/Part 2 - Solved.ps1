$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

$freshIdRanges = New-Object System.Collections.ArrayList

foreach($line in $puzzleInput)
{
    if($line.Contains('-'))
    {
        $rangeSplit = $line.Split('-')
        
        $min = [long]$rangeSplit[0]
        $max = [long]$rangeSplit[1]

        if($min -gt $max)
        {
            $min = [long]$rangeSplit[1]
            $max = [long]$rangeSplit[0]
        }

        $freshIdRanges.Add(@($min, $max)) | Out-Null
    }
}

$freshIdRanges = $freshIdRanges | Sort-Object {$_[0]}
$freshIdRanges = {$freshIdRanges}.Invoke()

for($i = 0; $i -lt $freshIdRanges.Count -1; $i++)
{
    if($freshIdRanges[$i][1]+1 -ge $freshIdRanges[$i+1][0])
    {
        Write-Host "Merging ranges" -ForegroundColor Cyan
        Write-Host "A: $($freshIdRanges[$i][0]) - $($freshIdRanges[$i][1])"
        Write-Host "B: $($freshIdRanges[$i+1][0]) - $($freshIdRanges[$i+1][1])"

        if($freshIdRanges[$i+1][1] -ge $freshIdRanges[$i][1])
        {
            $freshIdRanges[$i][1] = $freshIdRanges[$i+1][1]
        }
        
        $freshIdRanges.RemoveAt($i+1)
        Write-Host "N: $($freshIdRanges[$i][0]) - $($freshIdRanges[$i][1])"
        $i--
    }
}

$freshIds = 0

foreach($entry in $freshIdRanges)
{
    Write-Host "Adding range count : $($entry[0]) to $($entry[1]) - Total: $(($entry[1] - $entry[0]) + 1)"
    $freshIds += ($entry[1] - $entry[0]) + 1
}

# First  try: 336495597913122 - Too high
# Second try: 316061716527909 - Too low
# Third  try: 336495597913099 - Too high
# Fourth try: 336495597913098 - Just right


Write-Host "Total fresh ingredients: $freshIds" -ForegroundColor Cyan