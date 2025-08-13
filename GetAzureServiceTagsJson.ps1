$startDate = (get-date).DateTime
Write-Output "Script started at: $startDate"

[hashtable] $DownloadIds = @{
    Public = 56519
    AzureGovernment = 57063
    AzureGermany = 57064
    China = 57062
}

foreach ($id in $DownloadIds.GetEnumerator())
{
    "Checking file: $($id.Name.ToString())"
    $DetailsPage = Invoke-WebRequest -Uri "https://www.microsoft.com/en-us/download/details.aspx?id=$($id.Value)" -Method Get -UseBasicParsing
    $directDownloadUri = $null
    $directDownloadUris = ($detailsPage.Content | select-string "https:\/\/download\.microsoft\.com\/download[^`"]+ServiceTags_$($id.name)[^`"]+\.json" -AllMatches).Matches.Value | Sort-Object | Get-Unique

    foreach ($uri in $directDownloadUris)
    {
        "- JSON found: $uri"
        $newDir = New-Item -ItemType Directory -Name $id.Name.ToString() -Force
        $fileName = $uri.Split("/")[-1]
        $outFile = "$($newDir.PSPath)/$fileName"
        "- Downloading and saving to $outFile"

        try {
            # Invoke the request and capture the full response
            $download = Invoke-WebRequest -Uri $uri `
                                        -OutFile $outFile `
                                        -ErrorAction Stop
            # If the request succeeds, you can still inspect the status code
            $statusCode = $download.StatusCode
        }
        catch {
            # When an HTTP error occurs, the exception contains the response
            $response   = $_.Exception.Response
            $statusCode = $response.StatusCode

            # Handle the error as needed (e.g., log, retry, etc.)
            Write-Warning "::error ::HTTP $statusCode returned for $uri"
        }
    }
}

$endDate = (get-date).DateTime
Write-Output "Script finished at: $endDate"

