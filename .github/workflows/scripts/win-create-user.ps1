# ---------- 自定义用户名和密码 ----------
$UserName = "BOOMDEE"
$Password = "123456"

# ---------- 创建用户 ----------
$securePass = ConvertTo-SecureString $Password -AsPlainText -Force

# 如果用户已存在，先删除
if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
    Write-Host "User $UserName already exists, removing..."
    Try { Remove-LocalUser -Name $UserName -ErrorAction Stop } Catch {
        Write-Warning "Failed to remove existing user: $_"
    }
}

# 创建本地用户
Try {
    New-LocalUser -Name $UserName -Password $securePass -AccountNeverExpires -Description "Created by GitHub Actions"
    Write-Host "User $UserName created."
} Catch {
    Write-Error "Failed to create user $UserName: $_"
    exit 1
}

# 加入远程桌面用户组
Try {
    Add-LocalGroupMember -Group "Remote Desktop Users" -Member $UserName -ErrorAction Stop
    Write-Host "Added $UserName to Remote Desktop Users."
} Catch {
    Write-Warning "Failed to add to Remote Desktop Users: $_"
}

# 如果需要管理员权限，可取消下一行注释
# Add-LocalGroupMember -Group "Administrators" -Member $UserName

# ---------- 输出到 GitHub Actions workflow ----------
"RDP_USERNAME=$UserName" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
"RDP_PASSWORD=$Password" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

# ---------- 验证 ----------
if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
    throw "User creation failed"
} else {
    Write-Host "User check OK."
}
