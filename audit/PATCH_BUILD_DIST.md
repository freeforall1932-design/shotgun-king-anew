# Patch Documentation: PowerShell Build & Install Tools
**Target Files:** `tools/build-dist.ps1`, `tools/install-mods.ps1`  

---

## 1. Robocopy Sanitization in build-dist.ps1 (SEC-01)
Robocopy uses exit codes 0-7 for successful operations. Under $ErrorActionPreference = "Stop" or PS 7+, $LASTEXITCODE = 1 causes terminating errors and bleeds into Python invocation checks.

```diff
--- a/tools/build-dist.ps1
+++ b/tools/build-dist.ps1
@@ -111,2 +111,9 @@
 Write-Host "1/3 copying game -> $dest (this copies ~100 MB, be patient)"
-robocopy $GameDir $dest /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
+& robocopy $GameDir $dest /E /NFL /NDL /NJH /NJS /NP /R:1 /W:1 | Out-Null
+if ($LASTEXITCODE -ge 8) {
+    Write-Error "robocopy failed with fatal error code $LASTEXITCODE"
+} else {
+    # Robocopy 0..7 are success codes; reset so it does not affect step 4/4
+    $global:LASTEXITCODE = 0
+}
```

---

## 2. Flat Zip Directory Collision in build-dist.ps1 (SEC-04)

```diff
--- a/tools/build-dist.ps1
+++ b/tools/build-dist.ps1
@@ -143,7 +143,9 @@
-            $stage = Join-Path $env:TEMP ("sk-dist-zip-" + $z.BaseName)
+            $stage = Join-Path $env:TEMP ("sk-dist-zip-" + $z.BaseName + "-" + [guid]::NewGuid().ToString("N"))
+            $extractSub = Join-Path $stage "unpacked"
             if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
+            New-Item -ItemType Directory -Path $extractSub -Force | Out-Null
             try {
-                Expand-Archive -LiteralPath $z.FullName -DestinationPath $stage -Force
-                $info = Get-ChildItem -LiteralPath $stage -Recurse -Filter info.lua -File -ErrorAction SilentlyContinue | Select-Object -First 1
+                Expand-Archive -LiteralPath $z.FullName -DestinationPath $extractSub -Force
+                $info = Get-ChildItem -LiteralPath $extractSub -Recurse -Filter info.lua -File -ErrorAction SilentlyContinue | Select-Object -First 1
                 if ($info) {
                     $infoText = Get-Content -Raw -LiteralPath $info.FullName
                     if ($infoText -match '(?m)^\s*name\s*=\s*"([^"]+)"') {
                         $modName = $Matches[1]
                         $to = Join-Path $modsRoot $modName
                         if (Test-Path -LiteralPath $to) { Remove-Item -LiteralPath $to -Recurse -Force }
-                        Move-Item -LiteralPath $info.Directory.FullName -Destination $to -Force
+                        Copy-Item -LiteralPath (Join-Path $info.Directory.FullName "*") -Destination $to -Recurse -Force
                         Write-Host "  ~ unpacked inherited '$($z.Name)' -> mods/$modName"
                     }
                 }
```
