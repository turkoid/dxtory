$dxtoryIgnoreList = "C:\Program Files (x86)\ExKode\Dxtory2.0\ignore_module_list.txt"
$ignoreList = new-object System.Collections.ArrayList

function AddWildcardFilename($path, $filename) {
    $props = @{
        static = $path -eq ""
        path = $path
        regex = $filename
        match = ""
        found = $false
    }
    if ($props.static) {
        $props.match = $filename
        $props.regex = $props.regex -replace "[[+*?()\\.]", "\$&"
    }
    
    $ignore = new-object psobject -Property $props
    [void] $ignoreList.Add($ignore)
}

function AddStaticFilename($filename) {
    AddWildcardFilename "" $filename
}

#wildcard filenames
AddWildcardFilename "C:\Windows\SysWOW64\Macromed\Flash\" "FlashPlayerPlugin.*\.exe"

#static filenames
AddStaticFilename "Discord.exe"
AddStaticFilename "DiscordPTB.exe"
AddStaticFilename "slack.exe"
AddStaticFilename "Google Play Music Desktop Player.exe"
AddStaticFilename "Google%20Play%20Music%20Desktop%20Player.exe"
AddStaticFilename "zune.exe"
AddStaticFilename "BodySlide x64.exe"
AddStaticFilename "ReShade Assistant Preview.exe"
AddStaticFilename "TeamViewer.exe"
AddStaticFilename "Battle.net.exe"
AddStaticFilename "HD-Frontend.exe"

foreach ($ignore in $ignoreList) {
    if (!($ignore.static)) {
        $regex = "^" + $ignore.regex
        $ignoreMatch = gci $ignore.path | ? {$_.name -match $regex} | select -first 1
        $ignore.match = $ignoreMatch.name
    } 
    if ($ignore.match -ne "") {
        $ignore.match = "*\" + $ignore.match
    }
}

(gc $dxtoryIgnoreList) | `
    foreach {        
        $replace = ""
        foreach ($ignore in $ignoreList) { 
            $regex = "^\*?\\?" + $ignore.regex
            $match = ($_ -match $regex)
            $ignore.found = $ignore.found -or $match
            if ($match) {
                $replace = $ignore.match
                break
            }        
        }    
        if ($replace -eq "") {
            $replace = $_
        }
        $_ -replace ".+", $replace
    } | `
    sc ($dxtoryIgnoreList)

foreach ($ignore in $ignoreList) {
    if ($ignore.match -ne "" -and !($ignore.found)) {
        ac $dxtoryIgnoreList ("`n" + $ignore.match)
    }
}    

(gc $dxtoryIgnoreList) | ? {$_.trim() -ne ""} | sc $dxtoryIgnoreList

start -filepath "C:\Program Files (x86)\ExKode\Dxtory2.0\Dxtory.exe"