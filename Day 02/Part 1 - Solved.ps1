$puzzleInput= Get-Content -Path "Input.txt"

function IsRepeatPattern([long]$number)
{
    $numStr = $number.ToString()
    $length = $numStr.Length

    if($length % 2 -ne 0)
    {
        return $false
    }

    $stringA = $numStr.Substring(0, $length/2)
    $stringB = $numStr.Substring($length/2)

    if($stringA -eq $stringB)
    {
        return $true
    }

    return $false
}

$matchBag = 0

foreach($entry in $puzzleInput.Split(','))
{
    $rangeStart = [long]$entry.Split('-')[0]
    $rangeEnd = [long]$entry.Split('-')[1]

    if($rangeStart -gt $rangeEnd)
    {
        $rangeStart = [long]$entry.Split('-')[1]
        $rangeEnd = [long]$entry.Split('-')[0]
    }

    Write-Host "Checking range $entry" -ForegroundColor Gray

    for($i = $rangeStart; $i -le $rangeEnd; $i++)
    {
        if(IsRepeatPattern -number $i)
        {
            Write-Host "Bad ID: $i" -ForegroundColor Magenta
            $matchBag += $i
        }
    }

    Write-Host
}

Write-Host "Bad ID Sum: $matchBag" -ForegroundColor Green