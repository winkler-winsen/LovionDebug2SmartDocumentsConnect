<#
    .SYNOPSIS
    Konvertiert Lovion EXPLORE Debug Ausgaben (Strg+Umsch.+Alt+F11) in einer Textdatei $infile zu Einträgen für Lovion SmartDocumentsConnect ExportConfigs-XML-Dateien

    .NOTES
    Author:     Lars Winkler 
    Date:       08.03.2023
    Version:    1.1

    .LINK
    None.

    .INPUTS
    None.

    .OUTPUTS
    None.
#>

$infile = 'EE.txt'  # Input Datei mit der Lovion EXPLORE Debug Ausgabe (Strg+Umsch.+Alt+F11) 

$content = Get-Content $infile -Encoding UTF8
$table = @{}
$position=0
$output=@()

$RwoTypeNameInt = $content[1].Substring( $content[1].LastIndexOf('(')+1, ($content[1].LastIndexOf(')') - $content[1].LastIndexOf('('))-1 ).Trim().Replace('?','').Replace('%','').Replace('[','').Replace(']','').Replace('²','2').Replace('³','2').Replace(':','')
$RwoTypeNameExt = $content[1].Substring( $content[1].IndexOf('"')+1, ($content[1].LastIndexOf('"') - $content[1].IndexOf('"'))-1 ).Trim().Replace('?','').Replace('%','').Replace('[','').Replace(']','').Replace('²','2').Replace('³','2').Replace(':','')

# Ermittle die Position, wo am häufigsten der ':' als Trenner steht. Dort wird später getrennt
foreach ($c in $content) {
    #$c
    $semis = ($c.ToCharArray() | Where-Object {$_ -eq ':'} | Measure-Object).Count
    if ($semis -gt 0) {
        # Write-Host $semis $c
        $start=0
        for ($i=1; $i -le $semis; $i++){
            $start=$c.IndexOf(':',$start+1)

             if ($table[$start] =  $table[$start]+1) {
            }

        }
        
        foreach ($i in $table.keys) {
            if ($table[$i] -gt $position) { $position=$i }
        }
    }

}

# Parsing 
foreach ($c in $content) {
    if ($c[$position] -match ':') {
        $d=$c.Substring(0,$position)
        $Feld = (($d | Select-String "(?<=\()(.*?)(?=\))" -AllMatches).Matches.Value | Select-Object -Last 1)
        $Name = $d.Substring(0,$d.IndexOf($Feld)-1).Trim().Replace('?','').Replace('%','').Replace('[','').Replace(']','').Replace('²','2').Replace('³','2').Replace(':','')
        $Feld = "@$Feld"
        $Placeholder = $Name.Replace(' ','_').Replace('(','').Replace(')','')

        # Referenzen auf Objek(e), Punkt(e) und Flächen aussortieren
        if ($c.Substring($position, $c.Length - $position) -like "* Objekt*" -or
            $c.Substring($position, $c.Length - $position) -like "* Punkt*" -or
            $c.Substring($position, $c.Length - $position) -like "* Fläche*" -or
            $c.Substring($position, $c.Length - $position) -like "* Geometrie*") {
           continue
        }
        if ($Placeholder -match "^\d") {
            $Placeholder = '_'+$Placeholder
        }
    
        $output+="				<FieldMapping description=`"{0}`" placeholder=`"{1}`" xPath=`"{3}/{2}`"/>" -f $Name,$Placeholder,$Feld,$RwoTypeNameInt
        
    }
}

$output | Out-File -FilePath "$infile.xml" -Encoding utf8