Param()

# Requiere: Allow scripts to access OAuth token = true
$orgUrl   = "$env:SYSTEM_COLLECTIONURI"
$project  = "$env:SYSTEM_TEAMPROJECT"
$repo     = "$env:BUILD_REPOSITORY_NAME"
$token    = "$env:SYSTEM_ACCESSTOKEN"

$b64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$token"))
$hdr = @{ Authorization = "Basic $b64" }

# 1) Rama por defecto
$repoUrl = "$orgUrl$project/_apis/git/repositories/$repo?api-version=7.0"
$repoInfo = Invoke-RestMethod -Uri $repoUrl -Headers $hdr -Method Get
$defaultBranchRef = $repoInfo.defaultBranch  # ej: refs/heads/main
if (-not $defaultBranchRef) { Write-Error "No se pudo obtener la rama por defecto"; exit 1 }
$main = $defaultBranchRef -replace '^refs/heads/',''
Write-Host "Rama principal: $main"

# Cargar refs para objectId
$refsUrl = "$orgUrl$project/_apis/git/repositories/$repo/refs?api-version=7.0"
$refs = Invoke-RestMethod -Uri $refsUrl -Headers $hdr -Method Get
$srcOid = ($refs.value | Where-Object { $_.name -eq $defaultBranchRef }).objectId
if (-not $srcOid) { Write-Error "No se encontró objectId de $defaultBranchRef"; exit 1 }

function New-Branch([string]$name){
  $exists = $refs.value | Where-Object { $_.name -eq "refs/heads/$name" }
  if ($exists) { Write-Host "Rama $name ya existe"; return }
  $body = @(
    @{ name="refs/heads/$name"; oldObjectId="0000000000000000000000000000000000000000"; newObjectId=$srcOid }
  ) | ConvertTo-Json
  $createUrl = "$orgUrl$project/_apis/git/repositories/$repo/refs?api-version=7.0"
  Invoke-RestMethod -Uri $createUrl -Headers $hdr -Method Post -Body $body -ContentType "application/json"
  Write-Host "Rama $name creada desde $main"
}

New-Branch "developer"
New-Branch "QA"

# 2) Generar YAML FINAL a archivo SEPARADO
$yaml = @"
trigger:
  - $main
  - developer
  - QA

pr:
  - developer
  - QA

pool:
  vmImage: ubuntu-latest

stages:
- stage: Build
  jobs:
  - job: BuildApp
    steps:
    - script: echo Construyendo desde rama \$(Build.SourceBranchName)
      displayName: Build

- stage: DeployDev
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/developer')
  dependsOn: Build
  jobs:
  - job: Deploy
    steps:
    - script: echo Deploy a Desarrollo
      displayName: Deploy Dev

- stage: DeployQA
  condition: eq(variables['Build.SourceBranch'], 'refs/heads/QA')
  dependsOn: Build
  jobs:
  - job: Deploy
    steps:
    - script: echo Deploy a QA
      displayName: Deploy QA
"@

$out = Join-Path $env:BUILD_SOURCESDIRECTORY 'azure-pipelines.generated.yml'
$yaml | Out-File -FilePath $out -Encoding UTF8
Write-Host "Generado: $out"
