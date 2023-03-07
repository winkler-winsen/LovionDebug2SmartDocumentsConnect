#
# Autor: Lars Winkler <l.winkler@lkharburg.de>
# Datum: 07.03.2023
#
# Konvertiert Lovion Editor Debug Ausgaben (Strg+Umsch.+Alt+F11) in einer Textdatei $infile zu Einträgen für Lovion Smart Documents Export Config XML Dateien
#

$infile = 'EE.txt'

$content = Get-Content $infile -Encoding UTF8
$table = @{}
$position=0
$output=@()

$RwoTypeNameExt = $content[1].Substring( $content[1].LastIndexOf('(')+1, ($content[1].LastIndexOf(')') - $content[1].LastIndexOf('('))-1 ).Trim().Replace('?','').Replace('%','').Replace('[','').Replace(']','').Replace('²','2').Replace('³','2').Replace(':','')
$RwoTypeNameInt = $content[1].Substring( $content[1].IndexOf('"')+1, ($content[1].LastIndexOf('"') - $content[1].IndexOf('"'))-1 ).Trim().Replace('?','').Replace('%','').Replace('[','').Replace(']','').Replace('²','2').Replace('³','2').Replace(':','')

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
        $Name = $d.Substring(0,$d.IndexOf('(')).Trim().Replace('?','').Replace('%','').Replace('[','').Replace(']','').Replace('²','2').Replace('³','2').Replace(':','')
        $Placeholder = $Name.Replace(' ','_')
        $Feld = '@'+$d.Substring( $d.LastIndexOf('(')+1, ($d.LastIndexOf(')') - $d.LastIndexOf('('))-1 ).Trim().Replace(' ','_')

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
    
        $output+="				<FieldMapping description=`"{0}`" placeholder=`"{1}`" xPath=`"{3}/{2}`"/>" -f $Name,$Placeholder,$Feld,$RwoTypeNameExt
        
    }
}

$output | Out-File -FilePath "$infile.xml" -Encoding utf8