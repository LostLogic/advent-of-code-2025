$puzzleInput= Get-Content -Path "Input.txt"

function IsMonoSequence([long]$number)
{
    $numStr = $number.ToString()

    if($numStr.Length -eq 1)
    {
        return $false
    }

    for($i = 1; $i -lt $numStr.Length; $i++)
    {
        if($numStr[$i - 1] -ne $numStr[$i])
        {
            return $false
        }
    }

    return $true
}

function IsRepeatPattern([long]$number)
{
    $numStr = $number.ToString()
    $length = $numStr.Length

    # Handled by IsMonoSequence
    if($length -eq 2)
    {
        return $false
    }

    $validMods = @()

    for($i = 2; $i -lt $length; $i++)
    {
        if($length % $i -eq 0)
        {
            $validMods += $length / $i
        }
    }

    foreach($mod in $validMods)
    {
        $match = $true
        $modLen = $length / $mod

        for($i = 1; $i -lt $mod; $i++)
        {
            $strPart1 = $numStr.Substring(($i-1) * $modLen, $modLen)
            $strPart2 = $numStr.Substring($i * $modLen, $modLen)

            if($strPart1 -ne $strPart2)
            {
                $match = $false
                break
            }
        }

        if($match)
        {
            return $true
        }
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
        if(IsMonoSequence -number $i)
        {
            Write-Host "Mono Sequence ID: $i" -ForegroundColor Cyan
            $matchBag += $i
        }
        elseif(IsRepeatPattern -number $i)
        {
            Write-Host "Repeat Pattern ID: $i" -ForegroundColor Magenta
            $matchBag += $i
        }
    }

    Write-Host
}

Write-Host "Bad ID Sum: $matchBag" -ForegroundColor Green