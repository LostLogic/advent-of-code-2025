$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

$splitCount = 0

$startSymbol = 'S'
$splitSymbol = '^'

$splitIndexes = @()

foreach($line in $puzzleInput)
{
    # First line - Find start
    if($splitIndexes.Count -eq 0)
    {
        $splitIndexes = @($line.IndexOf($startSymbol))
        continue
    }

    $splitString = ""
    foreach($index in $splitIndexes)
    {
        if($line[[int]$index] -eq $splitSymbol)
        {
            $splitString = $splitString + "$([int]$index-1),$([int]$index+1),"
            $splitCount++
        }
        else
        {
            $splitString = $splitString + "$($index),"
        }
    }

    $splitString = $splitString.Trim(',')

    $splitIndexes = $splitString.Split(',') | Select-Object -Unique

    #Write-Host $line
    #Write-Host $splitIndexes
}

Write-Host "Tachyon beam split $($splitCount) times" -ForegroundColor Green