# Creates the Tranix database (one time) using the DB_* settings in backend\.env (defaults: tranix/tranix@localhost:5432).
# The backend then creates all tables itself on start (Flyway).
$dotenv = Join-Path $PSScriptRoot '..\backend\.env'
$cfg = @{ DB_HOST = 'localhost'; DB_PORT = '5432'; DB_NAME = 'tranixdb'; DB_USERNAME = 'tranix'; DB_PASSWORD = 'tranix' }
if (Test-Path $dotenv) {
    foreach ($line in Get-Content $dotenv) {
        $t = $line.Trim()
        if (-not $t -or $t.StartsWith('#') -or -not $t.Contains('=')) { continue }
        $i = $t.IndexOf('=')
        $k = $t.Substring(0, $i).Trim()
        if ($cfg.ContainsKey($k)) { $cfg[$k] = $t.Substring($i + 1).Trim().Trim('"').Trim("'") }
    }
}
$bin = Get-ChildItem 'C:\Program Files\PostgreSQL' -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending |
    ForEach-Object { Join-Path $_.FullName 'bin' } | Where-Object { Test-Path (Join-Path $_ 'createdb.exe') } | Select-Object -First 1
if (-not $bin) { Write-Host 'PostgreSQL tools not found under C:\Program Files\PostgreSQL'; exit 1 }
$env:PGPASSWORD = $cfg.DB_PASSWORD
& (Join-Path $bin 'createdb.exe') -h $cfg.DB_HOST -p $cfg.DB_PORT -U $cfg.DB_USERNAME -O $cfg.DB_USERNAME $cfg.DB_NAME
if ($LASTEXITCODE -eq 0) { Write-Host "Database $($cfg.DB_NAME) created (owner $($cfg.DB_USERNAME))." }
else { Write-Host "Could not create $($cfg.DB_NAME) as $($cfg.DB_USERNAME). If it says permission denied, create it as the postgres user (see docs/dev-testing.md)." }
Remove-Item Env:PGPASSWORD
