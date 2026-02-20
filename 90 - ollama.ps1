# 90 - ai-ollama.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------

Write-MastHead "Ollama AI - Locally Hosted AI Models"

# ------------------------------------------------------------------------------------------------

Write-Header "Install Ollama"

if (Test-Command -Name $Ollama.CommandName) {
    Write-Ok "Ollama is already installed. Skipping install."
    ollama --version
} else {
    Write-Status "Ollama not found! Installing Ollama from: $($Ollama.InstallUrl)"

    # irm $Ollama.InstallUrl | iex
    Invoke-RestMethod $Ollama.InstallUrl | Invoke-Expression 
}

# ------------------------------------------------------------------------------------------------

Write-Header "Pull Ollama Models"
Write-Status ".shared\variables\ollama.ps1"

$enabledModels = $Ollama.Models | Where-Object { $_.Enabled -eq $true }

if ($enabledModels.Count -eq 0) {
    Write-StatusMessage "No models are enabled. Update `$Ollama.Models` in .shared\variables\ollama.ps1 to enable models." -NoIcon
} else {

    # list models to be pulled
    Write-StatusMessage -Title "Ollama Models" -Message "The following models are enabled and will be pulled:" -NoIcon
    Write-NewLine
    $enabledModels | ForEach-Object { [pscustomobject]$_ } | Format-Table -AutoSize -Property Name, Id, Provider, Url | Out-Host
        
    # human in loop
    $choice = Write-Choice "Are you ready to install Ollama models?"
    switch ($choice) {
        'No'   { Write-Warn "Aborting Ollama model install."; return }
        'Skip' { Write-Warn "Skipping Ollama model install." -NoIcon; return }
    }

    # pull models
    foreach ($model in $enabledModels) {
        Write-NewLine
        Write-Host "Pulling $($model.Name) [$($model.Id)]..." -ForegroundColor Cyan
        Write-Host "   + Provider: $($model.Provider)"
        Write-Host "   + Url: $($model.Url)"
        
        Write-Command "ollama pull $($model.Id)"
        ollama pull $model.Id
    }
}

# ------------------------------------------------------------------------------------------------

# display summary
Write-Header "Ollama Model Summary"
Write-NewLine
Write-Host "Models configured in `$Ollama.Models:" -ForegroundColor Cyan
Write-NewLine
Write-Host ("  {0,-30} {1,-10} {2,-8} {3,-10} {4}" -f "Name", "Size", "Enabled", "MinRAM", "Best For") -ForegroundColor White
Write-Host ("  {0}" -f ("-" * 100)) -ForegroundColor DarkGray

foreach ($model in $Ollama.Models) {
    $enabledText = if ($model.Enabled) { "Yes" } else { "No" }
    $color = if ($model.Enabled) { "Green" } else { "DarkGray" }
    Write-Host ("  {0,-30} {1,-10} {2,-8} {3,-10} {4}" -f $model.Name, $model.Size, $enabledText, "$($model.MinRamGB) GB", $model.BestFor) -ForegroundColor $color
}

Write-NewLine
Write-Host "To run a model interactively:" -ForegroundColor Cyan
Write-Host "    ollama run mistral" -ForegroundColor White
Write-Host "    ollama run llama2" -ForegroundColor White
Write-Host "    ollama run codellama" -ForegroundColor White
Write-NewLine
Write-Host "Ollama API: $($Ollama.ApiBaseUrl)" -ForegroundColor Cyan
Write-Host "  Models    : $($Ollama.ModelsUrl)" -ForegroundColor Cyan