# win-create-user.ps1 - 设置固定用户名 BOOMDEE + 密码 123456

$UserName = "BOOMDEE"
$Password = "123456"

# 将密码转换为 SecureString
$securePass = ConvertTo-SecureString $Password -AsPlainText -Force

# 如果用户已存在，先删除
if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
    Write-Host "User $UserName already exists, removing..."
    Remove-LocalUser -Name $UserName -ErrorAction SilentlyContinue
}

# 创建用户
New-LocalUser -Name $UserName -Password $securePass -AccountNeverExpires -Description "Created by GitHub Actions"

# 加入远程桌面用户组
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $UserName

# 如果需要管理员权限，可取消下面一行注释
# Add-LocalGroupMember -Group "Administrators" -Member $UserName

# 写入 workflow 环境变量
"RDP_USERNAME=$UserName" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
"RDP_PASSWORD=$Password" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

# 验证
if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
    throw "User creation failed"
} else {
    Write-Host "User $UserName created successfully."
}
