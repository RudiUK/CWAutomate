# Define the registry key path
$keyPath = "HKLM:\SOFTWARE\LabTech\Service\VirusScanners"

# Get all subkeys under the specified registry key
$subKeys = Get-ChildItem -Path $keyPath

# Iterate through each subkey
foreach ($subKey in $subKeys) {
    # Get the OsType value
    $osType = (Get-ItemProperty -Path $subKey.PSPath -Name "OsType" -ErrorAction SilentlyContinue).OsType

    # Check if OsType value exists and is either 0, 1, 4, or 5
    if ($osType -eq 0 -or $osType -eq 1 -or $osType -eq 4 -or $osType -eq 5) {
        # Get the ProgLocation value
        $progLocation = (Get-ItemProperty -Path $subKey.PSPath -Name "ProgLocation" -ErrorAction SilentlyContinue).ProgLocation
        Write-Output "TESTING: $progLocation"
        # Check if ProgLocation value exists
        if ($progLocation) {
            # Check if ProgLocation points to a registry key and value pair
            if ($progLocation -match '{%-([^:]+):([^%-]+)-%}(.+)') {
                # Extract registry key, value, and remaining path
                $registryKey = $matches[1]
                $registryValue = $matches[2]
                $remainingPath = $matches[3]

                # Get the value from the specified registry key
                $resolvedPath = (Get-ItemProperty -Path "Registry::$registryKey" -Name $registryValue -ErrorAction SilentlyContinue).$registryValue

                # Append the remaining path
                $fullPath = Join-Path -Path $resolvedPath -ChildPath $remainingPath
            } else {
                # Set fullPath to ProgLocation
                $fullPath = $progLocation
            }

            # Check if fullPath is not empty and points to a valid location
            if ($fullPath -and (Test-Path $fullPath -PathType 'Leaf' -ErrorAction SilentlyContinue)) {
                Write-Output "Resolved path found for subkey $($subKey.Name): $fullPath"
                # Output the ID field if it exists
                $idField = (Get-ItemProperty -Path $subKey.PSPath -Name "ID" -ErrorAction SilentlyContinue).ID
                if ($idField) {
                    Write-Output "ID: $idField"
                }
            }
        }
    }
}
