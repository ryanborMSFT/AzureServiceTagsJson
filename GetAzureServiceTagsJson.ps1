$startDate = (get-date).DateTime
Write-Output "Script started at: $startDate"

$rootDirectory = $Env:BUILD_REPOSITORY_LOCALPATH
$rootDirectoryWithTrailingSlash = $($rootDirectory+"\")

Write-Output "Root Directory: $($rootDirectory)"
Write-Output "Root Directory (with trailing slash): $($rootDirectoryWithTrailingSlash)"

[hashtable] $DownloadIds = @{
    AzurePublic = 56519
    AzureGovernment = 57063
    AzureGermany = 57064
    AzureChina = 57062
}

foreach ($id in $DownloadIds.GetEnumerator())
{
    "Checking file: $($id.Name.ToString())"
    $DetailsPage = Invoke-WebRequest -Uri "https://www.microsoft.com/en-us/download/details.aspx?id=$($id.Value)" -Method Get -UseBasicParsing
    $directDownloadUri = $null
    $directDownloadUri = ($DetailsPage.Links |where-object {$_.outerhtml -like "*ServiceTags_*"})[0].href
    if ($directDownloadUri)
    {
        $fileName = $directDownloadUri.Split("/")[-1]
        $outFile = ".attachments\AzureServiceTagsJson\$fileName"
        "- JSON found: $directDownloadUri"
        "- Downloading and saving to $outFile"
        $download = Invoke-WebRequest -Uri $directDownloadUri -OutFile $outFile
    }
    else 
    { 
        "- ERROR: No JSON file found for file: $($id.Name.ToString())"
    }
}

$endDate = (get-date).DateTime
Write-Output "Script finished at: $endDate"
