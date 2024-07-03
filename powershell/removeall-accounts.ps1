# Get the current user's SID
$currentUserSid = (Get-WmiObject -Class Win32_UserAccount | Where-Object { $_.Name -eq $env:USERNAME }).SID

# Get all user profiles
$userProfiles = Get-WmiObject Win32_UserProfile | Where-Object { $_.Special -eq $false }

foreach ($profile in $userProfiles) {
    # If the profile SID does not match the current user's SID, remove it
    if ($profile.SID -ne $currentUserSid) {
        Write-Host "Removing user profile: $($profile.LocalPath)"
        # Remove the user profile
        try {
            $profile.Delete()
            Remove-Item -Path $profile.LocalPath -Recurse -Force
            Write-Host "Successfully removed: $($profile.LocalPath)"
        } catch {
            Write-Host "Failed to remove: $($profile.LocalPath). Error: $_"
        }
    } else {
        Write-Host "Skipping current user profile: $($profile.LocalPath)"
    }
}

Write-Host "Completed removing other user profiles."