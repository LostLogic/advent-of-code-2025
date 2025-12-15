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
        ConnectedTo = @()
    }
    $index++
}

$connections = 0
$maxConnections = 1000

# Find Global Edge Pairs
while($connections -lt $maxConnections)
{
    Write-Host "Finding Pairs - Made $connections of $maxConnections connections" -ForegroundColor Cyan
    $closestPair = @(-1, -1)
    $distance = -1

    for($i = 0; $i -lt $junctionBoxes.Count; $i++)
    {
        $boxA = $junctionBoxes[$i]

        for($j = $i + 1; $j -lt $junctionBoxes.Count; $j++)
        {
            $boxB = $junctionBoxes[$j]

            if($boxA.Id -eq $boxB.Id)
            {
                continue
            }

            if($boxA.ConnectedTo.Contains($boxB.Id) -or $boxB.ConnectedTo.Contains($boxA.Id))
            {
                # They are already connected. Let's continue to check the nodes
                continue
            }

            $boxDistance = Get-EuclideanDistance -boxA $boxA -boxB $boxB

            if($distance -eq -1 -or $boxDistance -lt $distance)
            {
                # These two nodes should be closer together
                Write-Host "A [$($boxA.Id)] - B [$($boxB.Id)] - Distance [$boxDistance]" -ForegroundColor Cyan
                $distance = $boxDistance
                $closestPair[0] = $boxA.Id
                $closestPair[1] = $boxB.Id
            }
        }
    }

    Write-Host
    Write-Host "Closest pair:" -ForegroundColor Cyan

    $node1 = $junctionBoxes | Where-Object -Property Id -EQ -Value $closestPair[0]
    $node2 = $junctionBoxes | Where-Object -Property Id -EQ -Value $closestPair[1]
    
    Write-Host "[$($node1.PosX),$($node1.PosY),$($node1.PosZ)] : [$($node2.PosX),$($node2.PosY),$($node2.PosZ)]" -ForegroundColor Green
    Write-Host "Distance: $distance" -ForegroundColor Green
    Write-Host

    $node1.ConnectedTo = $node1.ConnectedTo + $($node2.Id)
    $node2.ConnectedTo = $node2.ConnectedTo + $($node1.Id)
    
    $connections++
}

# Build circuits
$circuits = New-Object System.Collections.ArrayList

foreach($box in $junctionBoxes)
{
    $boxCircuit = @($box.Id)
    
    $newCircuit = $true

    while($newCircuit)
    {
        $boxCircuitNow = @($boxCircuit)

        foreach($connection in $boxCircuitNow)
        {
            $connectionBox = $junctionBoxes | Where-Object -Property Id -EQ $connection
        
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
Write-Host
Write-Host "If my that is right, and it seldom is - the solution should be $solution" -ForegroundColor Magenta