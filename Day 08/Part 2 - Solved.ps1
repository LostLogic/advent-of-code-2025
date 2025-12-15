$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

function Get-EuclideanDistance([pscustomobject]$boxA, [pscustomobject]$boxB)
{
    $x = [math]::Pow($boxA.PosX-$boxB.PosX, 2)
    $y = [math]::Pow($boxA.PosY-$boxB.PosY, 2)
    $z = [math]::Pow($boxA.PosZ-$boxB.PosZ, 2)

    return [math]::Sqrt($x+$y+$z)
}

# Build junctionBoxes array
$junctionBoxes = @()
$index = 0

foreach($entry in $puzzleInput)
{
    $parts = $entry.Split(',')
    $junctionBoxes += [pscustomobject]@{
        Id  = $index
        PosX   = [int]$parts[0]
        PosY   = [int]$parts[1]
        PosZ   = [int]$parts[2]
        ConnectedTo = @($index)
        CircuitId = $index
    }
    $index++
}

# Should be uneccesary... Isn't
$junctionBoxes = $junctionBoxes | Sort-Object -Property Id

$connections = 0

# Find Global Edge Pairs
# Precompute edges
Write-Host "Precomputing edges. This might take a few..." -ForegroundColor Cyan
$edges = New-Object System.Collections.Generic.List[pscustomobject]
for($i = 0; $i -lt $junctionBoxes.Count; $i++)
{
    for($j = $i + 1; $j -lt $junctionBoxes.Count; $j++)
    {
        $edges.Add([PSCustomObject]@{
            A=$i
            B=$j
            Distance=Get-EuclideanDistance -boxA $junctionBoxes[$i] -boxB $junctionBoxes[$j]
        })

        if($edges.Count % 1000 -eq 0)
        {
            Write-Host "Edges so far: $($edges.Count)" -ForegroundColor DarkCyan
        }
    }
}
Write-Host "Total Edges: $($edges.Count)" -ForegroundColor Cyan
Write-Host "Sorting edges by distance" -ForegroundColor Cyan
$edges = $edges | Sort-Object -Property Distance

Write-Host "Finding pairs" -ForegroundColor Cyan
foreach($edge in $edges)
{
    if(!$junctionBoxes[$edge.A].ConnectedTo.Contains($edge.B))
    {
        $junctionBoxes[$edge.A].ConnectedTo = @($junctionBoxes[$edge.A].ConnectedTo + @($edge.B) | Sort-Object -Unique)
        $junctionBoxes[$edge.B].ConnectedTo = @($junctionBoxes[$edge.B].ConnectedTo + @($edge.A) | Sort-Object -Unique)
        $connections++
        Write-Host "Finding Pairs - Made $connections" -ForegroundColor Cyan

        # Add to circuit - Merge left
        if(($junctionBoxes | Group-Object -Property CircuitId).Count -eq 2)
        {
            if($junctionBoxes[$edge.A].CircuitId -ne $junctionBoxes[$edge.B].CircuitId)
            {
                Write-Host "Edge A vs Edge B" -ForegroundColor Cyan
                Write-Host "Solution? $($junctionBoxes[$edge.A].PosX * $junctionBoxes[$edge.B].PosX)" -ForegroundColor Magenta
                return
            }
        }
        else
        {
            if($junctionBoxes[$edge.A].CircuitId -ne $junctionBoxes[$edge.B].CircuitId)
            {
                $junctionBoxes | Where-Object -Property CircuitId -eq $junctionBoxes[$edge.B].CircuitId | ForEach-Object {$_.CircuitId = $junctionBoxes[$edge.A].CircuitId}    
            }
        }
    }
}

# Solution: 1474050600