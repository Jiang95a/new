param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $MavenArguments
)

$ErrorActionPreference = 'Stop'

$serverRoot = $PSScriptRoot
$mavenRepo = Join-Path $serverRoot '.maven-repo'

function Resolve-Jdk21 {
  $candidates = @()
  $candidates += 'D:\2025\java\IntelliJ IDEA 2025.1\jbr'
  if ($env:JAVA_HOME) { $candidates += $env:JAVA_HOME }

  $searchRoots = @('C:\Program Files\Eclipse Adoptium', 'C:\Program Files\Microsoft', 'C:\Program Files\Java')
  foreach ($root in $searchRoots) {
    if (Test-Path $root) {
      $candidates += @(
        Get-ChildItem $root -Directory -Filter 'jdk*21*' -ErrorAction SilentlyContinue |
          Select-Object -ExpandProperty FullName
      )
    }
  }

  foreach ($candidate in $candidates) {
    if (!$candidate) { continue }
    $java = Join-Path $candidate 'bin\java.exe'
    $javac = Join-Path $candidate 'bin\javac.exe'
    if (!(Test-Path $java) -or !(Test-Path $javac)) { continue }
    $version = (& $javac -version 2>&1 | Out-String)
    if ($version -match '^javac\s+21\.') { return $candidate }
  }

  throw '未找到 JDK 21。请安装 JDK 21，或把 JAVA_HOME 指向 JDK 21。'
}

function Resolve-Maven {
  $mavenCommand = Get-Command mvn.cmd -ErrorAction SilentlyContinue
  $candidates = @()
  $candidates += 'D:\2025\java\IntelliJ IDEA 2025.1\plugins\maven\lib\maven3\bin\mvn.cmd'
  if ($mavenCommand -and $mavenCommand.Source) { $candidates += $mavenCommand.Source }
  if ($env:MAVEN_HOME) {
    $candidates += (Join-Path $env:MAVEN_HOME 'bin\mvn.cmd')
  }

  if (Test-Path 'C:\Program Files\Apache') {
    $candidates += @(
      Get-ChildItem 'C:\Program Files\Apache' -Recurse -Filter mvn.cmd -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty FullName
    )
  }

  foreach ($candidate in $candidates) {
    if ($candidate -and (Test-Path $candidate)) { return $candidate }
  }
  throw '未找到 Maven。请安装 Maven，或把 MAVEN_HOME 指向 Maven 安装目录。'
}

$env:JAVA_HOME = Resolve-Jdk21
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
$maven = Resolve-Maven
$repoArg = "-Dmaven.repo.local=$($mavenRepo.Replace('\', '/'))"
$mavenArgs = if ($MavenArguments.Count -gt 0) { $MavenArguments } else { @('spring-boot:run') }

Write-Host "JAVA_HOME: $env:JAVA_HOME"
Write-Host "Maven: $maven"
Write-Host "Maven repository: $mavenRepo"
Write-Host "Maven args: $($mavenArgs -join ' ')"

Push-Location $serverRoot
try {
  & $maven $repoArg ($mavenArgs -join ' ')
  exit $LASTEXITCODE
} finally {
  Pop-Location
}
