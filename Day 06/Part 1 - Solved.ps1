$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

$cleanList = New-Object System.Collections.ArrayList

foreach($entry in $puzzleInput)
{
    $cleanString = $entry.Trim().Replace('  ', ' ')

    while($cleanString.Contains('  '))
    {
        $cleanString = $cleanString.Replace('  ', ' ')
    }

    $cleanList.Add($cleanString) | Out-Null
}

$colCount = $cleanList[0].Split(' ').Count

$totalSum = 0

for($i = 0; $i -lt $colCount; $i++)
{
    $operation = $cleanList[-1].Split(' ')[$i]
    $thisSum = [long]$cleanList[0].Split(' ')[$i]
    if($operation -eq '*')
    {
        for($j = 1; $j -lt $cleanList.Count -1; $j++)
        {
            if($thisSum -eq 0)
            {
                $thisSum = [long]$cleanList[$j].Split(' ')[$i]
            }
            else
            {
                $thisSum = [long]$cleanList[$j].Split(' ')[$i] * $thisSum
            }
            
        }
    }
    elseif($operation -eq '+')
    {
        for($j = 1; $j -lt $cleanList.Count -1; $j++)
        {
            $thisSum += [long]$cleanList[$j].Split(' ')[$i]
        }
    }
    else
    {
        Write-Host "Unknown: $operation"
    }

    $totalSum += $thisSum
}

Write-Host "Sum Total: $totalSum"