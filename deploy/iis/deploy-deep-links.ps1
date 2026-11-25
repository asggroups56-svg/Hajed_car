<#
.SYNOPSIS
    Copies the App Links / Universal Links files and the car fallback page to
    the delta-asg.com:443 IIS site, and merges the required rewrite rules into
    the existing web.config.

.DESCRIPTION
    Run this on the web server (elevated PowerShell) or on a machine that can
    write to the site's physical path.

    - Copies: wwwroot/deep-links/assetlinks.json
              wwwroot/deep-links/apple-app-site-association.json
              wwwroot/car/index.html
    - Merges the <rewrite> rules from web.config.merge.xml into the existing
      <system.webServer> node, keeping every other node intact, and writes a
      timestamped backup first. Use -SkipWebConfig to only copy the files.

.EXAMPLE
    .\deploy-deep-links.ps1 -SiteRoot 'C:\inetpub\wwwroot' -RepoRoot 'C:\src\Hajed_car'

.EXAMPLE
    .\deploy-deep-links.ps1 -SiteRoot 'C:\inetpub\wwwroot' -RepoRoot 'C:\src\Hajed_car' -SkipWebConfig
#>
param(
    [Parameter(Mandatory = $true)]
    [string] $SiteRoot,

    [Parameter(Mandatory = $true)]
    [string] $RepoRoot,

    [switch] $SkipWebConfig
)

$ErrorActionPreference = 'Stop'

$wwwroot = Join-Path $SiteRoot 'wwwroot'
$repoWeb = Join-Path $RepoRoot 'web'

if (-not (Test-Path $repoWeb)) {
    throw "Repo web folder not found: $repoWeb"
}

if (-not (Test-Path $wwwroot)) {
    throw "wwwroot not found: $wwwroot (check -SiteRoot)"
}

New-Item -ItemType Directory -Force `
    (Join-Path $wwwroot 'deep-links'), `
    (Join-Path $wwwroot 'car') | Out-Null

$copies = @(
    @{
        Source = Join-Path $repoWeb '.well-known\assetlinks.json'
        Target = Join-Path $wwwroot 'deep-links\assetlinks.json'
    },
    @{
        Source = Join-Path $repoWeb '.well-known\apple-app-site-association'
        Target = Join-Path $wwwroot 'deep-links\apple-app-site-association.json'
    },
    @{
        Source = Join-Path $repoWeb 'car\index.html'
        Target = Join-Path $wwwroot 'car\index.html'
    }
)

foreach ($copy in $copies) {
    if (-not (Test-Path $copy.Source)) {
        throw "Missing source file: $($copy.Source)"
    }
    Copy-Item $copy.Source $copy.Target -Force
    Write-Host "Copied $($copy.Source) -> $($copy.Target)"
}

# ---------------------------------------------------------------------------
# Merge the rewrite rules into web.config (never replace the file)
# ---------------------------------------------------------------------------
$webConfig = Join-Path $SiteRoot 'web.config'
$recycleNeeded = $false

if ($SkipWebConfig) {
    Write-Host 'Skipped web.config (use web.config.merge.xml manually).'
} elseif (-not (Test-Path $webConfig)) {
    Write-Warning "web.config not found at $webConfig. Merge web.config.merge.xml manually."
} else {
    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $false
    $xml.Load($webConfig)

    $root = $xml.DocumentElement
    if ($null -eq $root) {
        throw "web.config has no root element: $webConfig"
    }

    $systemWebServer = $root.SelectSingleNode('system.webServer')
    if ($null -eq $systemWebServer) {
        $systemWebServer = $xml.CreateElement('system.webServer')
        [void] $root.AppendChild($systemWebServer)
    }

    $rewrite = $systemWebServer.SelectSingleNode('rewrite')
    if ($null -eq $rewrite) {
        $rewrite = $xml.CreateElement('rewrite')
        [void] $systemWebServer.AppendChild($rewrite)
    }

    $rules = $rewrite.SelectSingleNode('rules')
    if ($null -eq $rules) {
        $rules = $xml.CreateElement('rules')
        [void] $rewrite.AppendChild($rules)
    }

    # Definitions must match deploy/iis/web.config.merge.xml
    $definitions = @(
        @{
            Name  = 'DeepLink-AssetLinks'
            Match = '^\.well-known/assetlinks\.json$'
            Url   = '/deep-links/assetlinks.json'
            Blank = $false
        },
        @{
            Name  = 'DeepLink-AASA'
            Match = '^\.well-known/apple-app-site-association$'
            Url   = '/deep-links/apple-app-site-association.json'
            Blank = $false
        },
        @{
            Name  = 'DeepLink-CarRoot'
            Match = '^car/?$'
            Url   = '/car/index.html'
            Blank = $false
        },
        @{
            Name  = 'DeepLink-CarDetails'
            Match = '^car/(.+)$'
            Url   = '/car/index.html'
            Blank = $true
        }
    )

    $changed = $false
    foreach ($definition in $definitions) {
        $existing = $rules.SelectSingleNode("add[@name='$($definition.Name)']")
        if ($null -ne $existing) {
            [void] $rules.RemoveChild($existing)
        }

        $rule = $xml.CreateElement('add')
        $rule.SetAttribute('name', $definition.Name)
        $rule.SetAttribute('stopProcessing', 'true')
        $rule.SetAttribute('match', $definition.Match)

        if ($definition.Blank) {
            $conditions = $xml.CreateElement('conditions')
            $condition = $xml.CreateElement('add')
            $condition.SetAttribute('input', '{URL}')
            $condition.SetAttribute('pattern', '^car/index\.html$')
            $condition.SetAttribute('negate', 'true')
            [void] $conditions.AppendChild($condition)
            [void] $rule.AppendChild($conditions)
        }

        $action = $xml.CreateElement('action')
        $action.SetAttribute('type', 'Rewrite')
        $action.SetAttribute('url', $definition.Url)
        [void] $rule.AppendChild($action)

        # Keep our rules first so a later catch-all/SPA rule cannot swallow them,
        # but stay after a leading <clear /> (otherwise IIS would drop them).
        $anchor = $null
        foreach ($child in $rules.ChildNodes) {
            if ($child.NodeType -eq [System.Xml.XmlNodeType]::Element -and $child.Name -ne 'clear') {
                $anchor = $child
                break
            }
        }

        if ($null -ne $anchor) {
            [void] $rules.InsertBefore($rule, $anchor)
        } else {
            [void] $rules.AppendChild($rule)
        }
        $changed = $true
    }

    if ($changed) {
        $backup = "$webConfig.$(Get-Date -Format 'yyyyMMdd-HHmmss').bak"
        Copy-Item $webConfig $backup -Force
        Write-Host "Backup: $backup"

        $settings = New-Object System.Xml.XmlWriterSettings
        $settings.Indent = $true
        $settings.IndentChars = '  '
        $settings.NewLineChars = "`r`n"

        $writer = [System.Xml.XmlWriter]::Create($webConfig, $settings)
        try {
            $xml.Save($writer)
        } finally {
            $writer.Close()
        }

        Write-Host "Merged the DeepLink rewrite rules into $webConfig"
        $recycleNeeded = $true
    }
}

if ($recycleNeeded) {
    Write-Host ''
    Write-Host 'Recycle the application pool so IIS reloads web.config:'
    Write-Host '  Restart-WebAppPool -Name (Get-Website -Name "<site name>").applicationPool'
}

Write-Host ''
Write-Host 'Verify from a machine with internet access (all must be 200, no Location header):'
Write-Host '  curl -sSI https://delta-asg.com/.well-known/assetlinks.json'
Write-Host '  curl -sSI https://delta-asg.com/.well-known/apple-app-site-association'
Write-Host '  curl -sSI https://delta-asg.com/car/2531'
Write-Host ''
Write-Host 'If URL Rewrite is not installed on the server, use deploy/aspnet/DeepLinkEndpoints.cs instead.'
