# 01 - system.ps1

. ".shared\index.ps1"

# ------------------------------------------------------------------------------------------------
# System Information
# Get comprehensive system information including hardware, architecture, and specifications
# ------------------------------------------------------------------------------------------------

Write-MastHead "System Information"

# ------------------------------------------------------------------------------
# Basic System Information
# ------------------------------------------------------------------------------
Write-StatusHeader "Basic System Information:"

Write-Var -Name "Computer Name" -Value $env:COMPUTERNAME
Write-Var -Name "Network Name (Hostname)" -Value ([System.Net.Dns]::GetHostName())
Write-Var -Name "Full Computer Name (FQDN)" -Value ([System.Net.Dns]::GetHostEntry([System.Net.Dns]::GetHostName()).HostName)

# ------------------------------------------------------------------------------
# Operating System Information
# ------------------------------------------------------------------------------
Write-StatusHeader "Operating System:"

# Windows Version and Architecture
$os = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Var -Name "OS Name" -Value $os.Caption
Write-Var -Name "OS Version" -Value $os.Version
Write-Var -Name "OS Build" -Value $os.BuildNumber
Write-Var -Name "OS Architecture" -Value $os.OSArchitecture

# System Architecture Detection
if ([Environment]::Is64BitOperatingSystem) {
    Write-Var -Name "OS Bits" -Value "64-bit Operating System"
} else {
    Write-Var -Name "OS Bits" -Value "32-bit Operating System"
}

if ([Environment]::Is64BitProcess) {
    Write-Var -Name "Process Architecture" -Value "64-bit Process"
} else {
    Write-Var -Name "Process Architecture" -Value "32-bit Process"
}

# ------------------------------------------------------------------------------
# Processor (CPU) Information
# ------------------------------------------------------------------------------
Write-StatusHeader "Processor (CPU):"

$cpu = Get-CimInstance -ClassName Win32_Processor
Write-Var -Name "CPU Name" -Value $cpu.Name
Write-Var -Name "CPU Manufacturer" -Value $cpu.Manufacturer
Write-Var -Name "CPU Architecture" -Value $cpu.Architecture
Write-Var -Name "CPU Cores" -Value $cpu.NumberOfCores
Write-Var -Name "CPU Logical Processors" -Value $cpu.NumberOfLogicalProcessors
Write-Var -Name "CPU Max Clock Speed" -Value "$($cpu.MaxClockSpeed) MHz"
Write-Var -Name "CPU Current Clock Speed" -Value "$($cpu.CurrentClockSpeed) MHz"
Write-Var -Name "CPU Address Width" -Value "$($cpu.AddressWidth)-bit"
Write-Var -Name "CPU Data Width" -Value "$($cpu.DataWidth)-bit"

# Architecture Type Detection
switch ($cpu.Architecture) {
    0 {       Write-Var -Name "Architecture Type:" -Value "x86 (32-bit)" }
    1 {       Write-Var -Name "Architecture Type:" -Value "MIPS" }
    2 {       Write-Var -Name "Architecture Type:" -Value "Alpha" }
    3 {       Write-Var -Name "Architecture Type:" -Value "PowerPC" }
    5 {       Write-Var -Name "Architecture Type:" -Value "ARM" }
    6 {       Write-Var -Name "Architecture Type:" -Value "Itanium (ia64)" }
    9 {       Write-Var -Name "Architecture Type:" -Value "x64 (AMD64/Intel64)" }
    12 {      Write-Var -Name "Architecture Type:" -Value "ARM64" }
    default { Write-Var -Name "Architecture Type:" -Value "Unknown Architecture ($($cpu.Architecture))" }
}

# ARM64 Detection
Write-StatusHeader $env:PROCESSOR_ARCHITECTURE
if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64" -or $cpu.Architecture -eq 12) {
    Write-Host "`n*** ARM64 ARCHITECTURE DETECTED ***" -ForegroundColor Magenta -BackgroundColor Black
    Write-Host "Special considerations may be needed for ARM64 compatibility" -ForegroundColor Yellow
}

# Processor Family and Type
Write-Var -Name "Family" -Value $cpu.Family
Write-Var -Name "Level" -Value $cpu.Level

# ------------------------------------------------------------------------------
# Graphics (GPU) Information
# ------------------------------------------------------------------------------
Write-StatusHeader "Graphics (GPU):"

$gpus = Get-CimInstance -ClassName Win32_VideoController
foreach ($gpu in $gpus) {
    Write-Var -Name "GPU Name" -Value $gpu.Name
    Write-Var -Name "GPU Adapter Type" -Value $gpu.AdapterCompatibility
    Write-Var -Name "GPU Driver Version" -Value $gpu.DriverVersion
    Write-Var -Name "GPU Driver Date" -Value $gpu.DriverDate
    
    # VRAM Calculation
    if ($gpu.AdapterRAM) {
        $vramGB = [math]::Round($gpu.AdapterRAM / 1GB, 2)
        $vramMB = [math]::Round($gpu.AdapterRAM / 1MB, 0)
        Write-Var -Name "GPU VRAM" -Value "$vramGB GB ($vramMB MB)"
    } else {
        Write-Var -Name "GPU VRAM" -Value "Not Available"
    }
    
    Write-Var -Name "GPU Video Processor" -Value $gpu.VideoProcessor
    Write-Var -Name "GPU Video Mode" -Value $gpu.VideoModeDescription
    Write-Var -Name "GPU Current Resolution" -Value "$($gpu.CurrentHorizontalResolution) x $($gpu.CurrentVerticalResolution)"
    Write-Var -Name "GPU Current Refresh Rate" -Value "$($gpu.CurrentRefreshRate) Hz"
    Write-Var -Name "GPU Current Bits Per Pixel" -Value $gpu.CurrentBitsPerPixel
    Write-Var -Name "GPU Status" -Value $gpu.Status
}

# ------------------------------------------------------------------------------
# Memory (RAM) Information
# ------------------------------------------------------------------------------
Write-StatusHeader "Memory (RAM):"

$computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
$totalRAM = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
Write-Var -Name "Total Physical Memory" -Value "$totalRAM GB"

# Detailed Memory Information
$memoryModules = Get-CimInstance -ClassName Win32_PhysicalMemory
Write-Var -Name "Memory Modules Installed" -Value $memoryModules.Count

foreach ($module in $memoryModules) {
    $moduleSize = [math]::Round($module.Capacity / 1GB, 2)
    Write-Var -Name "  Module" -Value $module.DeviceLocator
    Write-Var -Name "  Capacity" -Value "$moduleSize GB"
    Write-Var -Name "  Speed" -Value "$($module.Speed) MHz"
    Write-Var -Name "  Manufacturer" -Value $module.Manufacturer
    Write-Var -Name "  Part Number" -Value $module.PartNumber
    Write-Var -Name "  Memory Type" -Value $module.MemoryType
    Write-Var -Name "  Form Factor" -Value $module.FormFactor
}

# Memory Usage
$os = Get-CimInstance -ClassName Win32_OperatingSystem
$freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedRAM = $totalRAM - $freeRAM
$memoryUsagePercent = [math]::Round(($usedRAM / $totalRAM) * 100, 1)

Write-Var -Name "Memory Used" -Value "$usedRAM GB"
Write-Var -Name "Memory Free" -Value "$freeRAM GB"
Write-Var -Name "Memory Usage" -Value "$memoryUsagePercent%"

# ------------------------------------------------------------------------------
# Storage Information
# ------------------------------------------------------------------------------
Write-StatusHeader "Storage Drives:"

$disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
foreach ($disk in $disks) {
    $totalSize = [math]::Round($disk.Size / 1GB, 2)
    $freeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
    $usedSpace = $totalSize - $freeSpace
    $usedPercent = [math]::Round(($usedSpace / $totalSize) * 100, 1)
    
    Write-Var -Name "Drive" -Value $disk.DeviceID
    Write-Var -Name "Volume Name" -Value $disk.VolumeName
    Write-Var -Name "File System" -Value $disk.FileSystem
    Write-Var -Name "Total Size" -Value "$totalSize GB"
    Write-Var -Name "Used" -Value "$usedSpace GB ($usedPercent%)"
    Write-Var -Name "Free" -Value "$freeSpace GB"
}

# ------------------------------------------------------------------------------
# System Board (Motherboard) Information
# ------------------------------------------------------------------------------
Write-StatusHeader "System Board (Motherboard):"

$board = Get-CimInstance -ClassName Win32_BaseBoard
Write-Var -Name "Manufacturer" -Value $board.Manufacturer
Write-Var -Name "Product" -Value $board.Product
Write-Var -Name "Version" -Value $board.Version
Write-Var -Name "Serial Number" -Value $board.SerialNumber

# ------------------------------------------------------------------------------
# BIOS Information
# ------------------------------------------------------------------------------
Write-StatusHeader "BIOS/UEFI:"

$bios = Get-CimInstance -ClassName Win32_BIOS
Write-Var -Name "Manufacturer" -Value $bios.Manufacturer
Write-Var -Name "Version" -Value $bios.Version
Write-Var -Name "SMBIOS Version" -Value $bios.SMBIOSBIOSVersion
Write-Var -Name "Release Date" -Value $bios.ReleaseDate
Write-Var -Name "Serial Number" -Value $bios.SerialNumber

# ------------------------------------------------------------------------------
# System Model Information
# ------------------------------------------------------------------------------
Write-StatusHeader "System Model:"

Write-Var -Name "Manufacturer" -Value $computerSystem.Manufacturer
Write-Var -Name "Model" -Value $computerSystem.Model
Write-Var -Name "System Type" -Value $computerSystem.SystemType
Write-Var -Name "PC System Type" -Value $computerSystem.PCSystemType
Write-Var -Name "Domain Role" -Value $computerSystem.DomainRole

# ------------------------------------------------------------------------------
# Developer-Specific Information
# ------------------------------------------------------------------------------
Write-StatusHeader "Developer Information:"
Write-NewLine

# Hyper-V Detection
$hyperv = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty HypervisorPresent
Write-Status "Hyper-V / Virtualization:"
if ($hyperv) {
    Write-Var -Name "Hypervisor Present" -Value "YES"
    Write-Var -Name "Virtualization Enabled" -Value "YES"
} else {
    Write-Var -Name "Hypervisor Present" -Value "NO"
    Write-Var -Name "Virtualization Enabled" -Value "NO"
}
Write-NewLine

# TPM Information
Write-Status "TPM (Trusted Platform Module):"
try {
    $tpm = Get-CimInstance -Namespace "root\CIMv2\Security\MicrosoftTpm" -ClassName Win32_Tpm -ErrorAction Stop
    Write-Var -Name "TPM Present" -Value "YES"
    Write-Var -Name "TPM Enabled" -Value $tpm.IsEnabled_InitialValue
    Write-Var -Name "TPM Activated" -Value $tpm.IsActivated_InitialValue
    Write-Var -Name "TPM Version" -Value $tpm.SpecVersion
} catch {
    Write-Var -Name "TPM Present" -Value "NO or Not Accessible"
}
Write-NewLine

# Secure Boot Status
Write-Status "Secure Boot:"
try {
    $secureBoot = Confirm-SecureBootUEFI -ErrorAction Stop
    Write-Var -Name "Secure Boot Enabled" -Value $secureBoot
} catch {
    Write-Var -Name "Secure Boot Status" -Value "Not Available (Legacy BIOS or not accessible)"
}
Write-NewLine

# Power Plan
Write-Status "Power Plan:"
$powerPlan = Get-CimInstance -Namespace "root\cimv2\power" -ClassName Win32_PowerPlan -Filter "IsActive=true"
Write-Var -Name "Active Power Plan" -Value $powerPlan.ElementName

# System Uptime
$uptime = (Get-Date) - $os.LastBootUpTime
Write-Var -Name "Last Boot" -Value $os.LastBootUpTime
Write-Var -Name "Uptime" -Value "$($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes"
Write-NewLine

# Windows Features (WSL, Hyper-V, Containers)
Write-Status "Windows Optional Features (Development Related):"
$features = @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform",
    "Microsoft-Hyper-V-All",
    "Containers",
    "Containers-DisposableClientVM",
    "HypervisorPlatform"
)

foreach ($featureName in $features) {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $featureName -ErrorAction SilentlyContinue
    if ($feature) {
        $status = if ($feature.State -eq "Enabled") { "Enabled" } else { "Disabled" }
        Write-Var -Name $featureName -Value $status
    } else {
        Write-Var -Name $featureName -Value "Not Available"
    }
}
