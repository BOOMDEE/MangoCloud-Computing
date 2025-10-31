# win-create-user.ps1
# 创建本地 RDP 用户，并写入 RDP_CREDS 环境变量

$UserName = "BOOMDEE"
$Password = "123456"

# 将密码转换为 SecureString
$securePass = ConvertTo-SecureString $Password -AsPlainText -Force

# 如果用户已存在，先删除
if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
    Write-Host "User $UserName already exists, removing..."
    Remove-LocalUser -Name $UserName -ErrorAction SilentlyContinue
}

# 创建本地用户
New-LocalUser -Name $UserName -Password $securePass -AccountNeverExpires -Description "Created by GitHub Actions"

# 加入远程桌面用户组
Add-LocalGroupMember -Group "Remote Desktop Users" -Member $UserName

# 如果需要管理员权限，请取消下面一行
# Add-LocalGroupMember -Group "Administrators" -Member $UserName

# 写入 workflow 环境变量 RDP_CREDS
echo "RDP_CREDS=User: $UserName | Password: $Password" >> $env:GITHUB_ENV

# 验证
if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
    throw "User creation failed"
} else {
    Write-Host "User $UserName created successfully."
}
