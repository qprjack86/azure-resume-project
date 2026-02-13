using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $InputDoc, $TriggerMetadata)

# Initialize visitor count if document doesn't exist
$count = 1
if ($InputDoc) {
    $count = $InputDoc.count + 1
}

# Create the object to save to Cosmos DB
$visitorObject = @{
    "id" = "1"
    "count" = $count
}

# Prepare Response
$body = @{
    "count" = $count
}

# Output bindings
Push-OutputBinding -Name OutputDoc -Value $visitorObject
Push-OutputBinding -Name Response -Value @{
    body = $body
    status = [HttpStatusCode]::OK
}