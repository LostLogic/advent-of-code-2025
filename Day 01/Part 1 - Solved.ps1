$puzzleInput = Get-Content -Path "Input.txt"

$safeValue = 50
$password = 0

foreach($line in $puzzleInput)
{
    $safeRotation = [int]$line.Substring(1)

    Write-Host "$safeValue - Rotating $line" -ForegroundColor Cyan

    if($line[0] -eq "L")
    {
        $safeValue = $safeValue - $safeRotation
    }
    else
    {
        $safeValue = $safeValue + $safeRotation
    }

    while($safeValue -gt 99 -or $safeValue -lt 0)
    {
        if($safeValue -gt 99)
        {
            $safeValue = $safeValue - 100
            
        }
        elseif($safeValue -lt 0)
        {
            $safeValue = $safeValue + 100
        }
    }
    
    if($safeValue -eq 0)
    {
        Write-Host "$safeValue - Storing" -ForegroundColor Green
        $password++
    }
    else
    {
        Write-Host "$safeValue - Next rotation" -ForegroundColor Gray
    }
}

Write-Host "Your password is: $($password)" -ForegroundColor Green