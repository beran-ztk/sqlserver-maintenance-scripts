function Get-ZusatzattributeXml {
    param(
        [string]$kz,
        [string]$handedOver
    )

$extension = @"
<extension url="http://fhir.abda.de/eRezeptAbgabedaten/StructureDefinition/DAV-EX-ERP-Zusatzattribute">
  <extension url="ZusatzattributZusaetzlicheAbgabeangaben">
    <extension url="DokumentationFreitext">
      <valueString value="Tarifkennzeichen 1100P53; Beihilfe nein" />
    </extension>
    <extension url="Gruppe">
      <valueCodeableConcept>
        <coding>
          <system value="http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-CS-ERP-ZusatzattributGruppe" />
          <code value="12" />
        </coding>
      </valueCodeableConcept>
    </extension>
    <extension url="Schluessel">
      <valueBoolean value="true" />
    </extension>
  </extension>

  <extension url="ZusatzattributGruppeFuerGenehmigung">
    <extension url="DokumentationFreitext">
      <valueString value="$kz" />
    </extension>
    <extension url="Datum">
      <valueDate value="$handedOver" />
    </extension>
    <extension url="Gruppe">
      <valueCodeableConcept>
        <coding>
          <system value="http://fhir.abda.de/eRezeptAbgabedaten/CodeSystem/DAV-CS-ERP-ZusatzattributGruppe" />
          <code value="13" />
        </coding>
      </valueCodeableConcept>
    </extension>
    <extension url="Schluessel">
      <valueBoolean value="true" />
    </extension>
  </extension>
</extension>
"@

    return $extension
}

$connection = New-Object System.Data.Odbc.OdbcConnection("DSN=PROD_scripts_dsn")
$connection.Open()

$unitPriceByHimi = @{
    "54.99.01.0001" = 0.0714
    "54.99.01.1001" = 0.1071
    "54.99.01.2001" = 0.1666
    "54.99.01.5001" = 0.9520
    "54.99.01.3001" = 0.1547
    "54.99.01.3002" = 24.9900
    "54.99.01.4001" = 0.1547
    "54.99.02.0001" = 1.6660
    "54.99.02.0002" = 1.5470
    "54.99.02.0014" = 0.2142
    "54.99.02.0015" = 0.2023
}

$query = @"
;WITH XMLNAMESPACES (DEFAULT 'http://hl7.org/fhir')
SELECT  
    r.ERezeptID      AS id,
    r.diDate         AS date,
    r.iAnzahl        AS anz,
    r.diPzn          AS pzn,
    r.strText        AS name,
    r.ERezeptSecret  AS secret,
    ax.AbrechnungXml.value('(//chargeItemCodeableConcept/coding/code/@value)[1]', 'varchar(50)')    AS himi,
    ax.AbrechnungXml.value('(//priceComponent/factor/@value)[1]', 'int')                            AS faktor,
    ax.AbrechnungXml.value('(//priceComponent/amount/value/@value)[1]', 'decimal(10,4)')            AS preis,
    ax.AbrechnungXml.value('(//whenHandedOver/@value)[1]', 'varchar(10)')                           AS handedOver,
    v.Blob           AS verordnung,
    a.Blob           AS abrechnung
FROM RW_APOBASE_Rezept r
INNER JOIN RW_EREZEPT_Verordnung v 
    ON r.ERezeptID = v.ERezeptID
INNER JOIN RW_EREZEPT_Abrechnung a 
    ON r.ERezeptID = a.ERezeptID
CROSS APPLY (
    SELECT TRY_CAST(a.Blob AS xml) AS AbrechnungXml
) ax
WHERE r.ERezeptID LIKE '980%'
  AND r.cKontrollStatus <> 2
  AND r.bStorno = 0
  AND ax.AbrechnungXml IS NOT NULL;
"@

try {
    $items = @()

    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $command.CommandTimeout = 0
    $reader = $command.ExecuteReader()

    while ($reader.Read()) {
        $items += [pscustomobject]@{
            Id         = [string]$reader["id"]
            Secret     = [string]$reader["secret"]
            Himi       = $reader["himi"]
            Faktor     = $reader["faktor"]
            Abrechnung = [string]$reader["abrechnung"]
            HandedOver = [string]$reader["handedOver"]
            Verordnung = [string]$reader["verordnung"]
        }
    }
}
catch {
    Write-Error $_
}
finally {
    if ($reader) { 
        $reader.Close() 
    }
}

foreach ($item in $items) {

    $changed = $false

    $id     = $item.Id
    $himi   = $item.Himi
    $secret = $item.Secret
    if ($secret -notmatch '^(\d{2}\.\d{2}\.\d{2}\.\d{4})') { continue }
    $targetHimi = $matches[1]

    ########################
    # Abrechnung in Xml-Doc laden
    $doc = New-Object System.Xml.XmlDocument
    $doc.PreserveWhitespace = $true
    $doc.LoadXml($item.Abrechnung)

    $nsmgr = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
    $nsmgr.AddNamespace("f", "http://hl7.org/fhir")

    ########################
    # Preise und Himi neu berechen, wenn default-pzn eingetragen ist
    if ([int64]$himi -eq 18774742) {
        $changed = $true

        if (-not $unitPriceByHimi.ContainsKey($targetHimi)) { continue }
        if ($item.Faktor -eq $null -or $item.Faktor -eq [DBNull]::Value) { continue }

        $faktor    = [int]$item.Faktor
        $unitPrice = [decimal]$unitPriceByHimi[$targetHimi]
        $expected  = [math]::Round($unitPrice * $faktor, 2)
        $format    = $expected.ToString("0.00", [System.Globalization.CultureInfo]::InvariantCulture)

        $systemAttr = $doc.SelectSingleNode("(//f:lineItem/f:chargeItemCodeableConcept/f:coding/f:system/@value)[1]", $nsmgr)
        if ($systemAttr) { $systemAttr.Value = "http://fhir.de/sid/gkv/hmnr" }

        $codeAttr = $doc.SelectSingleNode("(//f:lineItem/f:chargeItemCodeableConcept/f:coding/f:code/@value)[1]", $nsmgr)
        if ($codeAttr) { $codeAttr.Value = $targetHimi.Replace(".", "") }

        $priceAttr = $doc.SelectSingleNode("(//f:lineItem/f:priceComponent/f:amount/f:value/@value)[1]", $nsmgr)
        if ($priceAttr) { $priceAttr.Value = $format }

        $totalGrossAttr = $doc.SelectSingleNode("(//f:Invoice/f:totalGross/f:value/@value)[1]", $nsmgr)
        if ($totalGrossAttr) { $totalGrossAttr.Value = $format }
    }

    ########################
    # XML fertigstellen
    $newXml = $doc.OuterXml

    # Wenn Zusatzattribute fehlen
    if ($newXml -notmatch 'StructureDefinition/DAV-EX-ERP-Zusatzattribute') {
        $changed = $true

        $kz = $secret
        if ($kz.StartsWith($targetHimi)) {
            $kz = $kz.Substring($targetHimi.Length)
        } else {
            continue
        }

        $handedOver = $item.HandedOver
        if ([string]::IsNullOrWhiteSpace($handedOver)) { continue }

        $extension = Get-ZusatzattributeXml $kz $handedOver

        $newXml = $newXml.Replace("<lineItem>", "<lineItem>`n$extension")
    }

    ########################
    # Verordnung
    try {
        # Verordnung auspacken
        $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($item.Verordnung))
        $bundle = [regex]::Match($decoded, '(?s)<Bundle.*?</Bundle>')

        # Cast Verordnung zu XML
        $vDoc = New-Object System.Xml.XmlDocument
        $vDoc.PreserveWhitespace = $true
        $vDoc.LoadXml($bundle)

        $nsmgr = New-Object System.Xml.XmlNamespaceManager($vDoc.NameTable)
        $nsmgr.AddNamespace("f", "http://hl7.org/fhir")
    }
    catch {
        continue
    }
    
    # Prüfe die Länge des Pflegekassennamens
    $systemAttr = $vdoc.SelectSingleNode("(//f:entry/f:resource/f:Coverage/f:payor/f:display/@value)[1]", $nsmgr)

    if ($systemAttr.Value.Length -gt 45) {
        $systemAttr.Value = $systemAttr.Value.Substring(0,45)
    }
    $verordnung = $vDoc.OuterXml

    ########################
    # Update ausführen
    Write-Output "UPDATED Id=$id TargetHimi=$targetHimi Faktor=$faktor Expected=$format"

    $sql = ""
    $sql += "UPDATE RW_APOBASE_Rezept SET cKontrollStatus = 0, cFehlerTyp = 0 WHERE ERezeptID = '$id';"
    $sql += "UPDATE RW_EREZEPT_Verordnung SET Blob = '$verordnung' WHERE ERezeptID = '$id';"
    $sql += "DELETE RW_EREZEPT_Quittung WHERE ERezeptID = '$id';"

    if ($changed) {
        $sql += "UPDATE RW_EREZEPT_Abrechnung SET Blob = '$newXml' WHERE ERezeptID = '$id';"
    }

    $updateCmd = $connection.CreateCommand()
    $updateCmd.CommandText = $sql
    [void]$updateCmd.ExecuteNonQuery()
}

$connection.Close()