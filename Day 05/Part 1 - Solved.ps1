$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

$freshIngredients = New-Object System.Collections.ArrayList

$freshIdRanges = New-Object System.Collections.ArrayList

function Get-IsLongInRange([long]$longNumber, [System.Collections.ArrayList]$rangeArray)
{
    foreach($entry in $rangeArray)
    {
        
        if($longNumber -ge $entry[0] -and $longNumber -le $entry[1])
        {
            return $true
        }
    }

    return $false
}

foreach($line in $puzzleInput)
{
    if($line.Contains('-'))
    {
        $rangeSplit = $line.Split('-')
        $rangeStart = [long]$rangeSplit[0]
        $rangeEnd = [long]$rangeSplit[1]

        if($rangeStart -gt $rangeEnd)
        {
            $rangeStart = [long]$rangeSplit[1]
            $rangeEnd = [long]$rangeSplit[0]
        }

        $freshIdRanges.Add(@($rangeStart, $rangeEnd)) | Out-Null
    }
    elseif($line.Length -ge 1)
    {
        if((Get-IsLongInRange -longNumber ([long]$line) -rangeArray $freshIdRanges) -and !$freshIngredients.Contains([long]$line))
        {
            $freshIngredients.Add([long]$line) | Out-Null
        }
    }
}

Write-Host "Total fresh ingredients: $($freshIngredients.Count)" -ForegroundColor Cyan