Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-PSReadLineKeyHandler -Chord "Shift+Tab" -Function ForwardWord
Set-Alias -Name ls -Value lsd
