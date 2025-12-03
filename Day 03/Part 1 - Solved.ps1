$puzzleInput = Get-Content -Path "Input.txt"

function MaxIntIndex ([string]$IntString, [int]$StartPos = 0, [bool]$NotLast = $false)
{
    $maxVal = 0
    $maxValIndex = 0

    $maxEndPos = $IntString.Length

    if($NotLast)
    {
        $maxEndPos--
    }

    for($i = $StartPos; $i -lt $maxEndPos; $i++)
    {
        if([int]$IntString[$i] -gt $maxVal)
        {
            $maxVal = [int]$IntString[$i]
            $maxValIndex = $i
        }

        if($maxVal -eq 9)
        {
            break
        }
    }

    return $maxValIndex
}

$maxJoltTotal = 0

foreach($line in $puzzleInput)
{
    $battPos1 = MaxIntIndex -IntString $line -StartPos 0 -NotLast $true
    $battPos2 = MaxIntIndex -IntString $line -StartPos ($battPos1 + 1) -NotLast $false

    $joltage = [int]"$($line[$battPos1])$($line[$battPos2])"

    Write-Host "Bank $line : Joltage: $joltage" -ForegroundColor Cyan
    $maxJoltTotal += $joltage
}

Write-Host "Max Total Joltage: $($maxJoltTotal)" -ForegroundColor Green