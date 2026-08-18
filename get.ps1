#Requires -Version 5.1
<#
.SYNOPSIS
    Fetch a LeetCode problem into problems/ as a drill file plus DuckDB sample data.
.EXAMPLE
    .\get.ps1 recyclable-and-low-fat-products
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Slug
)

$ErrorActionPreference = 'Stop'

$script = Join-Path $PSScriptRoot 'get.py'
if (-not (Test-Path $script)) {
    Write-Error "get.py not found next to get.ps1 at $script"
    exit 1
}

& py $script $Slug
exit $LASTEXITCODE
