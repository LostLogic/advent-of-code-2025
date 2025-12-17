$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

function Print-Tiles([bool[,]] $TileArray, [bool] $PrintToScreen = $false)
{
    # Prepare the output list
    $printList = [System.Collections.Generic.List[string]]::new()

    # Dimensions
    $rows = $TileArray.GetLength(0) # Y
    $cols = $TileArray.GetLength(1) # X

    for ($y = 0; $y -lt $rows; $y++)
    {
        $printString = ""

        for ($x = 0; $x -lt $cols; $x++)
        {
            if($TileArray[$y, $x])
            {
                $printString += "#"
            }
            else
            {
                $printString += "."
            }
        }

        $printList.Add($printString)

        if ($PrintToScreen) {
            Write-Host $printString -ForegroundColor Cyan
        }
    }

    return $printList
}

function Get-HasValue([bool[,]]$array, [int]$xStart, [int]$xEnd, [int]$yStart, [int]$yEnd, [bool]$testValue)
{
    $height = $yEnd - $yStart + 1
    $width = $xEnd - $xStart + 1
    
    for($y = 0; $y -lt $height; $y++)
    {
        for($x = 0; $x -lt $width; $x++)
        {
            if($array[($yStart + $y), ($xStart + $x)] -eq $testValue)
            {
                return $true
            }
        }
    }

    return $false
}


$tiles = New-Object System.Collections.Generic.List[PSCustomObject]

$index = 0
foreach($entry in $puzzleInput)
{
    $tiles.Add([PSCustomObject]@{
        X = [int]$entry.Split(',')[0]
        Y = [int]$entry.Split(',')[1]
    })
}

$xMin = $tiles | Sort-Object -Property X -Unique | Select-Object -First 1 -ExpandProperty X
$xMax = $tiles | Sort-Object -Property X -Unique -Descending | Select-Object -First 1 -ExpandProperty X

$yMin = $tiles | Sort-Object -Property Y -Unique | Select-Object -First 1 -ExpandProperty Y
$yMax = $tiles | Sort-Object -Property Y -Unique -Descending | Select-Object -First 1 -ExpandProperty Y

$tileAreaPreCalc = New-Object System.Collections.Generic.List[PSCustomObject]

# Pre-Calculate the area between two red tiles
for($i = 0; $i -lt $tiles.Count; $i++)
{
    for($j = $i + 1; $j -lt $tiles.Count; $j++)
    {
        $dX = [math]::Abs($tiles[$i].X - $tiles[$j].X) + 1
        $dY = [math]::Abs($tiles[$i].Y - $tiles[$j].Y) + 1

        $area = $dX * $dY

        $tileAreaPreCalc.Add([PSCustomObject]@{
            A = $tiles[$i]
            B = $tiles[$j]
            Area = $area
        })
    }
}

# Since the y and x Max is around 100k, creating a bool array
# would still allocate 10gb of ram. Not fun, not efficient.
# Time for some napkin compression - as in - something I can 
# write on a napkin - not a nasa napkin algorithm in other words

$xArray = $tiles | Sort-Object -Property X -Unique | Select-Object -ExpandProperty X
$yArray = $tiles | Sort-Object -Property Y -Unique | Select-Object -ExpandProperty Y

# Build Red-Green Tile Grid
# We don't care if either point is red or green
# just if it has a true or false value (Colored, Not Colored)
# We will always just test valid squares from the
# pre-calculated tile array
$tileArray = [bool[,]]::new($yArray.Count, $xArray.Count)

# Connect first and last entry
$col = ($tiles[0].X -eq $tiles[-1].X)

if(!$col)
{
    # Fill between X and X+1
    $xStart = [math]::Min($tiles[0].X, $tiles[-1].X)
    $xEnd = [math]::Max($tiles[0].X, $tiles[-1].X)

    $xCompressedStart = $xArray.IndexOf($xStart)
    $xCompressedEnd  = $xArray.IndexOf($xEnd)

    $yCompressed = $yArray.IndexOf($tiles[0].Y)

    for($j = $xCompressedStart; $j -le $xCompressedEnd; $j++)
    {
        $tileArray[$yCompressed, $j] = $true
    }
}
else
{
    # Fill between Y and Y+1
    $yStart = [math]::Min($tiles[0].Y, $tiles[-1].Y)
    $yEnd = [math]::Max($tiles[0].Y, $tiles[-1].Y)

    $yCompressedStart = $yArray.IndexOf($yStart)
    $yCompressedEnd  = $yArray.IndexOf($yEnd)

    $xCompressed = $xArray.IndexOf($tiles[0].X)

    for($j = $yCompressedStart; $j -le $yCompressedEnd; $j++)
    {
        $tileArray[$j, $xCompressed] = $true
    }
}

for($i = 0; $i -lt $tiles.Count-1; $i++)
{
    $col = ($tiles[0].X -eq $tiles[1].X)
    if(!$col)
    {
        # Fill between X and X+1
        $xStart = [math]::Min($tiles[$i].X, $tiles[$i+1].X)
        $xEnd = [math]::Max($tiles[$i].X, $tiles[$i+1].X)

        $xCompressedStart = $xArray.IndexOf($xStart)
        $xCompressedEnd  = $xArray.IndexOf($xEnd)

        $yCompressed = $yArray.IndexOf($tiles[$i].Y)
                
        for($j = $xCompressedStart; $j -le $xCompressedEnd; $j++)
        {
            $tileArray[$yCompressed, $j] = $true
        }
    }
    else
    {
        # Fill between Y and Y+1
        $yStart = [math]::Min($tiles[$i].Y, $tiles[$i+1].Y)
        $yEnd = [math]::Max($tiles[$i].Y, $tiles[$i+1].Y)

        $yCompressedStart = $yArray.IndexOf($yStart)
        $yCompressedEnd  = $yArray.IndexOf($yEnd)

        $xCompressed = $xArray.IndexOf($tiles[$i].X)

        for($j = $yCompressedStart; $j -le $yCompressedEnd; $j++)
        {
            $tileArray[$j, $xCompressed] = $true
        }
    }
}

# Fill void
for($i = 0; $i -lt $tileArray.GetLength(0); $i++)
{
    $row = for($x = 0; $x -lt $tileArray.GetLength(1); $x++) { $tileArray[$i, $x] }

    $firstTile = $row.IndexOf($true)

    if($firstTile -eq -1)
    {
        continue
    }

    for($j = $firstTile + 1; $j -lt $row.Count; $j++)
    {
        if($tileArray[$i, $j] -and $row[$j..-1].IndexOf($true) -eq -1)
        {
            break
        }

        $tileArray[$i, $j] = $true
    }
}

#$visualTiles = Print-Tiles -tileArray $tileArray -printToScreen $true
#$visualTiles | Out-File "alltheTiles.txt"

# Check the pre calculated tile area and test each
# of the entries from largest toward smallest until
# we find a square that's within the bounds of red
# and green tiles

# Good'ol brute force
foreach($area in $tileAreaPreCalc | Sort-Object -Property Area -Descending)
{
    $startX = $xArray.IndexOf([math]::Min($area.A.X, $area.B.X))
    $endX = $xArray.IndexOf([math]::Max($area.A.X, $area.B.X))

    $startY = $yArray.IndexOf([math]::Min($area.A.Y, $area.B.Y))
    $endY = $yArray.IndexOf([math]::Max($area.A.Y, $area.B.Y))
    
    Write-Host "Testing Area [$($area.Area)] at X: [$startX-$endX] Y: [$startY-$endY]" -ForegroundColor Cyan

    $isInvalid = Get-HasValue -array $tileArray -xStart $startX -xEnd $endX -yStart $startY -yEnd $endY -testValue $false

    if(!$isInvalid)
    {
        Write-Host "Max Area: $($area.Area) [$($area.A.X),$($area.A.Y)] [$($area.B.X),$($area.B.Y)]" -ForegroundColor Green
        return
    }
}

# First attempt: 3083850 - Too low