$puzzleInput = Get-Content -Path "Input.txt"

$paperRoll = '@'
$movableRolls = 0

function GetRowValues([string]$rowData, [int]$index, [int]$count)
{
    $start = $index - (($count-1)/2)
    $total = $count

    if($start -lt 0)
    {
        $total += $start
        $start = 0
    }

    if($start + $total -gt $rowData.Length)
    {
        $total = $rowData.Length - ($start)
    }
        
    return $rowData.Substring($start, $total)
}


function CanIMoveThisRoll($data, $row, $col, $count, $valueSymbol)
{
    $values = ""
    if($row -gt 0)
    {
        $values = GetRowValues -rowData $data[$row-1] -index $col -count $count
    }
    

    $values += GetRowValues -rowData $data[$row] -index $col -count $count

    if($row -lt $data.Length -1)
    {
        $values += GetRowValues -rowData $data[$row+1] -index $col -count $count
    }
    
    $valueTotal = ($values.ToCharArray() | Where-Object {$_ -eq $valueSymbol}).Count

    # "Center" will always be "One", so we can check if there is 3+1 or less
    if($valueTotal -le 4)
    {
        return $true
    }

    return $false
}

for($i = 0; $i -lt $puzzleInput.Length; $i++)
{
    for($j = 0; $j -lt $puzzleInput[$i].Length; $j++)
    {
        if($puzzleInput[$i][$j] -eq $paperRoll)
        {
            $movableRolls += CanIMoveThisRoll -data $puzzleInput -row $i -col $j -count 3 -valueSymbol $paperRoll
        }
    }
}

Write-Host "We can move $movableRolls rolls" -ForegroundColor Cyan
