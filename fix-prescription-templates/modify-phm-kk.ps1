$connectionString = "DSN=PROD_scripts_dsn"

function Read-Scalar {
    param(
        [System.Data.Odbc.OdbcConnection]$Connection,
        [string]$Sql,
        [string]$Id
    )

    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = $Sql

    $p = $cmd.Parameters.Add("@id", [System.Data.Odbc.OdbcType]::VarChar)
    $p.Value = $Id

    return $cmd.ExecuteScalar()
}

function Update-Verordnung {
    param(
        [System.Data.Odbc.OdbcConnection]$Connection,
        [string]$Id,
        [string]$Blob
    )

    $cmd = $Connection.CreateCommand()
    $cmd.CommandText = @"
UPDATE RW_EREZEPT_Verordnung
SET Blob = ?
WHERE ERezeptID = ?
"@

    $pBlob = $cmd.Parameters.Add("@blob", [System.Data.Odbc.OdbcType]::Text)
    $pBlob.Value = $Blob

    $p = $cmd.Parameters.Add("@id", [System.Data.Odbc.OdbcType]::VarChar)
    $p.Value = $Id

    [void]$cmd.ExecuteNonQuery()
}

$connection = New-Object System.Data.Odbc.OdbcConnection($connectionString)
$connection.Open()

try {
    while ($true) {
        Write-Host ""
        Write-Host "----------------------------------------"
        $id = Read-Host "E-Rezept-ID eingeben oder ENTER zum Beenden"

        if ([string]::IsNullOrWhiteSpace($id)) {
            break
        }

        if ($id -notlike "980*") {
            Write-Host "Abbruch: Die E-Rezept-ID beginnt nicht mit 980."
            continue
        }

        $exists = Read-Scalar `
            -Connection $connection `
            -Sql "SELECT COUNT(*) FROM RW_EREZEPT_Verordnung WHERE ERezeptID = ?" `
            -Id $id

        if ([int]$exists -eq 0) {
            Write-Host "Abbruch: E-Rezept-ID wurde nicht gefunden."
            continue
        }

        $blob = Read-Scalar `
            -Connection $connection `
            -Sql "SELECT Blob FROM RW_EREZEPT_Verordnung WHERE ERezeptID = ?" `
            -Id $id

        if ([string]::IsNullOrWhiteSpace($blob)) {
            Write-Host "Abbruch: Keine Verordnung gefunden."
            continue
        }

        try {
            $decoded = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($blob))
            $bundleMatch = [regex]::Match($decoded, '(?s)<Bundle.*?</Bundle>')

            if (-not $bundleMatch.Success) {
                Write-Host "Abbruch: Kein Bundle in der Verordnung gefunden."
                continue
            }

            $originalBundle = $bundleMatch.Value

            $doc = New-Object System.Xml.XmlDocument
            $doc.PreserveWhitespace = $true
            $doc.LoadXml($originalBundle)

            $nsmgr = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
            $nsmgr.AddNamespace("f", "http://hl7.org/fhir")

            $ikNode = $doc.SelectSingleNode("(//f:entry/f:resource/f:Coverage/f:payor/f:identifier/f:value/@value)[last()]", $nsmgr)
            $displayNode = $doc.SelectSingleNode("(//f:entry/f:resource/f:Coverage/f:payor/f:display/@value)[last()]", $nsmgr)

            if ($null -eq $ikNode -or $null -eq $displayNode) {
                Write-Host "Abbruch: IK-Nummer oder Display wurde nicht gefunden."
                continue
            }

            Write-Host ""
            Write-Host "Aktuelle Werte:"
            Write-Host "IK-Nummer:      $($ikNode.Value)"
            Write-Host "Pflegekasse:    $($displayNode.Value)"
            Write-Host ""

            $newIk = Read-Host "Neue IK-Nummer"
            $newDisplay = Read-Host "Neuer Pflegekassenname"

            if ([string]::IsNullOrWhiteSpace($newIk) -or [string]::IsNullOrWhiteSpace($newDisplay)) {
                Write-Host "Abbruch: Beide Werte müssen gefüllt sein."
                continue
            }

            Write-Host ""
            Write-Host "Neue Werte:"
            Write-Host "IK-Nummer:      $newIk"
            Write-Host "Pflegekasse:    $newDisplay"
            Write-Host ""

            $confirm = Read-Host "Änderung übernehmen? J/N"

            if ($confirm -ne "J" -and $confirm -ne "j") {
                Write-Host "Nicht gespeichert."
                continue
            }

            $ikNode.Value = $newIk
            $displayNode.Value = $newDisplay

            $newBundle = $doc.OuterXml

            $cmd = $connection.CreateCommand()
            $cmd.CommandText = 
@"
UPDATE RW_EREZEPT_Verordnung
SET Blob = ?
WHERE ERezeptID = ?
"@

            $pBlob = $cmd.Parameters.Add("@blob", [System.Data.Odbc.OdbcType]::Text)
            $pBlob.Value = $newBundle

            $p = $cmd.Parameters.Add("@id", [System.Data.Odbc.OdbcType]::VarChar)
            $p.Value = $id

            [void]$cmd.ExecuteNonQuery()

            $cmdDelete = $connection.CreateCommand()
            $cmdDelete.CommandText = 
@"
DELETE FROM RW_EREZEPT_Quittung
WHERE ERezeptID = ?
"@

            $pDeleteId = $cmdDelete.Parameters.Add("@id", [System.Data.Odbc.OdbcType]::VarChar)
            $pDeleteId.Value = $id

            [void]$cmdDelete.ExecuteNonQuery()

            Write-Host "Gespeichert. Quittung wurde gelöscht."
        }
        catch {
            Write-Host "Fehler beim Verarbeiten der Verordnung:"
            Write-Host $_.Exception.Message
        }
    }
}
finally {
    $connection.Close()
}