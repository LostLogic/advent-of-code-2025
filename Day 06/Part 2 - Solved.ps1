$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

# Use operators as split index. Will always appear at the left-most part

$colStart = New-Object System.Collections.ArrayList

$colStart.Add(0) | Out-Null

for($i = 1; $i -lt $puzzleInput[-1].Length; $i++)
{
    if($puzzleInput[-1][$i] -ne ' ')
    {
        $colStart.Add($i) | Out-Null
    }
}

[long]$fullSum = 0

for($i = $colStart.Count-1; $i -ge 0; $i--)
{
    $operation = $puzzleInput[-1][$colStart[$i]]
    $problem = New-Object System.Collections.ArrayList

    for($j = 0; $j -lt $puzzleInput.Count -1; $j++)
    {
        if($i -ge $colStart.Count -1)
        {
            $problem.Add($puzzleInput[$j].Substring($colStart[$i])) | Out-Null
        }
        else
        {
            $problem.Add($puzzleInput[$j].Substring($colStart[$i], $colStart[$i+1] - $colStart[$i] - 1)) | Out-Null
        }
    }
    
    $problemArranged = New-Object System.Collections.ArrayList
    $parr = [string[]]::new($problem[0].ToCharArray().Length)

    for($pRow = 0; $pRow -lt $problem.Count; $pRow++)
    {
        $charProblem = $problem[$pRow].ToCharArray()

        for($cIndex = $charProblem.Length -1; $cIndex -ge 0; $cIndex--)
        {
            $parr[$cIndex] = $parr[$cIndex] + $charProblem[$cIndex]
        }
    }

    $thisSum = [long]$parr[0]
    for($n = 1; $n -lt $parr.Count; $n++)
    {
        if($operation -eq '+')
        {
            $thisSum += [long]$parr[$n]
        }
        elseif($operation -eq '*')
        {
            $thisSum = $thisSum * [long]$parr[$n]
        }

    }

    $fullSum += $thisSum
}

Write-Host "Sum Total: $($fullSum)" -ForegroundColor Green