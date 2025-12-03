$puzzleInput = Get-Content -Path "Input.txt"

function MaxIntIndex ([string]$IntString, [int]$StartPos = 0, [int]$EndPos = 0)
{
    $maxVal = 0
    $maxValIndex = 0

    for($i = $StartPos; $i -lt $EndPos; $i++)
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

[long]$maxJoltTotal = 0
$batteryTotal = 12

foreach($line in $puzzleInput)
{
    $startPos = 0
    $battCells = ""

    for($i = 0; $i -lt $batteryTotal; $i++)
    {
        $maxEndPos = $line.Length - ($batteryTotal - ($i+1))
        $startPos = MaxIntIndex -IntString $line -StartPos $startPos -EndPos $maxEndPos
        $battCells += $line[$startPos]
        $startPos++
    }

    Write-Host "Cell: $line - Jolt: $battCells" -ForegroundColor Cyan
    $maxJoltTotal += [long]$battCells
}

Write-Host "Max Total Joltage: $($maxJoltTotal)" -ForegroundColor Green