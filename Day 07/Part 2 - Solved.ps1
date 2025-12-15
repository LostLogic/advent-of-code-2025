$puzzleInput = Get-Content -Path "Input.txt"
#$puzzleInput = Get-Content -Path "SourceOfTruth.txt"

$startSymbol = 'S'
$nothingSymbol = '.'
$splitSymbol = '^'

$tachyPath = $null

foreach($line in $puzzleInput)
{
    # First line - Find start
    if($null -eq $tachyPath)
    {
        $rowVal = $line.Replace($startSymbol, 1).Replace($nothingSymbol, 0)
        $rowVal = $rowVal.Trim(' ').ToCharArray()

        $tachyPath = [long[]]::new($rowVal.Length)

        for($i = 0; $i -lt $rowVal.Length; $i++)
        {
            $tachyPath[$i] = [long]$rowVal[$i].ToString()
        }

        continue
    }
    
    # Nothing to do?
    if($line.IndexOf($splitSymbol) -lt 0)
    {
        continue
    }
    
    $splitIndex = 0

    while($splitIndex -lt $line.Length -and $line.IndexOf($splitSymbol, $splitIndex) -ge 0)
    {
        $splitIndex = $line.IndexOf($splitSymbol, $splitIndex)

        $tachyPath[$splitIndex - 1] = $tachyPath[$splitIndex - 1] + $tachyPath[$splitIndex]
        $tachyPath[$splitIndex + 1] = $tachyPath[$splitIndex + 1] + $tachyPath[$splitIndex]
        $tachyPath[$splitIndex] = 0

        $splitIndex++
    }
}

[long]$worldPotential = 0

foreach($entry in $tachyPath)
{
    $worldPotential += $entry
}

Write-Host "Tachyon beam world Potential: $worldPotential" -ForegroundColor Green