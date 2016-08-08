$dxtoryIgnoreList = "C:\Program Files (x86)\ExKode\Dxtory2.0\ignore_module_list.txt"
$ignoreList = new-object System.Collections.ArrayList

$props = @{
    path = "C:\Windows\SysWOW64\Macromed\Flash\"
    regex = "FlashPlayerPlugin.*\.exe"
    match = ""
    found = $false
}
$ignore = new-object psobject -Property $props
[void] $ignoreList.Add($ignore)

foreach ($ignore in $ignoreList) {
    $ignore.regex = "^" + $ignore.regex
    $ignoreMatch = gci $ignore.path | ? {$_.name -match $ignore.regex} | select -first 1
    $ignore.match = $ignoreMatch.name
}

(gc $dxtoryIgnoreList) | `
    foreach { foreach ($ignore in $ignoreList) { 
        $ignore.found = $ignore.found -or ($_ -match $ignore.regex)
        $_ -replace $ignore.regex, $ignore.match
    }} | `
    sc ($dxtoryIgnoreList)

foreach ($ignore in $ignoreList) {
    if ($ignore.match -ne "" -and !($ignore.found)) {
        ac $dxtoryIgnoreList ("`n" + $ignore.match)
    }
}    

(gc $dxtoryIgnoreList) | ? {$_.trim() -ne ""} | sc $dxtoryIgnoreList

start -filepath "C:\Program Files (x86)\ExKode\Dxtory2.0\Dxtory.exe"