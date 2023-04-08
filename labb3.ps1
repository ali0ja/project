$header_dir = "C:\Users\jal01ali\Desktop\tmp\ps"

$sigPath = "C:\Users\jal01ali\Desktop\tmp\ps\siglist.txt"

$sigList = Import-Csv -Path "$sigPath" -Delimiter ";" -header "fileExtension", "firstValue", "lastValue"

Get-ChildItem -Path $header_dir -Recurse -Include *.* | ForEach-Object {
    $file = $_.FullName
    $fileLength = $_.Length
    $fileType = [System.IO.Path]::GetExtension($file)
    $fileName = $_.Name
    $firstLine = Get-Content -Path $file -Encoding Byte -TotalCount $fileLength
    $hexValues = $firstLine | ForEach-Object { '{0:X2}' -f $_ }
    $hexValues = $hexValues -join ''
    $lastFour = $hexValues.Substring($hexValues.Length - 4)

    foreach ($sig in $sigList) {
        if ($fileType -eq $sig.fileExtension) {
            if ($sig.lastValue -ne "" -and $hexValues.StartsWith($sig.firstValue) -and $lastFour -eq $sig.lastValue) {
                Write-Output "FileName: $fileName Type: $fileType | SigFirst: $($sig.firstValue) FileFirst: $($hexValues.Substring(0, 4)) | SigLast: $($sig.lastValue) FileLast: $lastFour || VALID 1"
                break
            }
            elseif ($sig.lastValue -eq "" -and $hexValues.StartsWith($sig.firstValue)) {
                Write-Output "FileName: $fileName Type: $fileType | SigFirst: $($sig.firstValue) FileFirst: $($hexValues.Substring(0, 4)) | SigLast: $($sig.lastValue) FileLast: $lastFour || VALID 2"
                break
            }
            else {
                Write-Output "FileName: $fileName Type: $fileType | SigValue: $($sig.firstValue) FileValue: $($hexValues.Substring(0, 4)) | SigLast: $($sig.lastValue) FileLast: $lastFour || ROUGE"
            }
        }
    }
}
