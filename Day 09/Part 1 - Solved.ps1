$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

$tiles = New-Object System.Collections.Generic.List[PSCustomObject]

foreach($entry in $puzzleInput)
{
    $tiles.Add([PSCustomObject]@{
        X = [int]$entry.Split(',')[0]
        Y = [int]$entry.Split(',')[1]
    })
}

$tileA = $tileB = $null
$tileArea = 0

for($i = 0; $i -lt $tiles.Count; $i++)
{
    for($j = $i+1; $j -lt $tiles.Count; $j++)
    {
        $dX = [math]::Abs($tiles[$i].X - $tiles[$j].X) + 1
        $dY = [math]::Abs($tiles[$i].Y - $tiles[$j].Y) + 1

        $area = $dX * $dY

        if($tileArea -lt $area)
        {
            $tileArea = $area
            $tileA = $tiles[$i]
            $tileB = $tiles[$j]
        }
    }
}

Write-Host "Max Area: $tileArea"