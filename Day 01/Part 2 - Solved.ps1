$puzzleInput = Get-Content -Path "Input.txt"

$safeValue = 50
$password = 0

foreach($line in $puzzleInput)
{
    $safeRotation = [int]$line.Substring(1)

    Write-Host "$safeValue - Rotating $line" -ForegroundColor Cyan

    if($line[0] -eq "L")
    {
        for($i = $safeRotation; $i -gt 0; $i--)
        {
            $safeValue--

            if($safeValue -eq 0)
            {
                $password++
            }

            if($safeValue -eq -1)
            {
                $safeValue = 99
            }
        }
    }
    else
    {
        for($i = 0; $i -lt $safeRotation; $i++)
        {
            $safeValue++

            if($safeValue -eq 100)
            {
                $safeValue = 0
            }

            if($safeValue -eq 0)
            {
                $password++
            }
        }
    }
}

Write-Host "Your 0x434C49434B 'CLICK' password is: $($password)" -ForegroundColor Green