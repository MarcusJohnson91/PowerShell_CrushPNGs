<# if you get an error about "Execution Policies" run this: Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
   We need NuGet for SplitPipeline, which we need for multithreading, so you have to install that, do so with: Install-Module SplitPipeline
#>

<#
if (!(Find-PackageProvider -Name NuGet -Force -MinimumVersion 2.8.5.201)) {
    Get-PackageProvider -Name NuGet -Force -MinimumVersion 2.8.5.201
}

if (!(Get-Module -ListAvailable -Name SplitPipeline)) {
    Install-Module -Name SplitPipeline -Scope AllUsers
}

Import-Module SplitPipeline
#>

<# $NumCores = Get-WmiObject –class Win32_processor | ft NumberOfLogicalProcessors #>

<# When looping, use Get-Random to generate a random fileID so PNGCrush doesn't step on PNGCrush's toes #>
$PNGExtension = ".png"
$Folder = "C:\Users\Marcus\Desktop\TestCrushPNGs"
cd $Folder

workflow CrushPNGs() {
    <#
    Once we have a PNG file from our list of PNGs to compress, all we need to do is loop over them all depending on the number of cores available,
    and run PNGCrush on them with the TempPNG name, then switch it back to the original file name.
    #>
    $PNGFiles = Get-ChildItem -Path $Folder -File -Filter "*.png"
    ForEach -Parallel ($OriginalPNG in $PNGFiles) {
        $Temp          = Get-Random
        $TempPNG       = [string]$Temp + ".png"
        Invoke-Expression -Command "C:\Program Files\PNGCrush\pngcrush.exe -l 9 -max 10485760 -reduce -brute $OriginalPNG $TempPNG"
        Rename-Item -LiteralPath $TempPNG -NewName $OriginalPNG
    }
    
    <# Get-ChildItem where {$_.extension -eq $PNGExtension} #>
}

