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
    }
    $index++
}

# Should be uneccesary... Isn't
$junctionBoxes = $junctionBoxes | Sort-Object -Property Id

$connections = 0
$maxConnections = 1000

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
    
$edges = $edges | Sort-Object -Property Distance
Write-Host "Finding pairs" -ForegroundColor Cyan
foreach($edge in $edges)
{
    if(!$junctionBoxes[$edge.A].ConnectedTo.Contains($edge.B))
    {
        $junctionBoxes[$edge.A].ConnectedTo = @($junctionBoxes[$edge.A].ConnectedTo + @($edge.B) | Sort-Object -Unique)
        $junctionBoxes[$edge.B].ConnectedTo = @($junctionBoxes[$edge.B].ConnectedTo + @($edge.A) | Sort-Object -Unique)
        $connections++
    }

    if($connections -eq $maxConnections)
    {
        return
    }

    Write-Host "Finding Pairs - Made $connections of $maxConnections connections" -ForegroundColor Cyan
}


# Build circuits
$circuits = New-Object System.Collections.ArrayList

Write-Host "Building circuits" -ForegroundColor Cyan
foreach($box in $junctionBoxes)
{
    $boxCircuit = @($box.Id)
    
    $newCircuit = $true

    while($newCircuit)
    {
        $boxCircuitNow = @($boxCircuit)

        foreach($connection in $boxCircuitNow)
        {
            $connectionBox = $junctionBoxes[$connection]
        
            $boxCircuit = @($boxCircuit + $connectionBox.ConnectedTo + @($connectionBox.Id) | Sort-Object -Unique)
        }

        if($boxCircuit.Count -eq $boxCircuitNow.Count)
        {
            $newCircuit = $false
        }
    }
 
    $merged = $false
    for($i = 0; $i -lt $circuits.Count; $i++)
    {
        foreach($entry in $boxCircuit)
        {
            if($circuits[$i].Contains($entry))
            {
                $circuits[$i] = @($circuits[$i] + $boxCircuit | Sort-Object -Unique)
                $merged = $true
                break
            }
        }

        if($merged)
        {
            break
        }
    }

    if(!$merged)
    {
        $circuits.Add($boxCircuit) | Out-Null
    }
}

Write-Host "Merging circuits" -ForegroundColor Cyan
$changed = $true
while($changed)
{
    # We'll do one pass regardless. We could do some group select, but hammer, nail
    $changed = $false
    for($i = 0; $i -lt $circuits.Count; $i++)
    {
        for($j = $i+1; $j -lt $circuits.Count; $j++)
        {
            if($circuits[$i] | Where-Object { $circuits[$j] -contains $_ })
            {
                # Merge the sucker
                $merged = ($circuits[$i] + $circuits[$j]) | Sort-Object -Unique
                $circuits[$i] = $merged
                $circuits.RemoveAt($j)
                $changed = $true
                break;
            }
        }

        if($changed)
        {
            break;
        }
    }
}

Write-Host
Write-Host "Count - Junction Box IDs" -ForegroundColor Cyan
foreach($circuit in $circuits | Sort-Object -Property Count -Descending)
{
    Write-Host "[$($circuit.Count)] - $circuit" -ForegroundColor Cyan
}

Write-Host "Total circuits: $($circuits.Count)" -ForegroundColor Green

$circuits = $circuits | Sort-Object -Property Count -Descending
$solution = 0

$solution = $circuits[0].Count
for($i = 1; $i -lt 3; $i++)
{
    $solution = $solution * $circuits[$i].Count
}

# First try : 1100 - Too low
# Second try: 52668 - Just right
Write-Host
Write-Host "If my that is right, and it seldom is - the solution should be $solution" -ForegroundColor Magenta