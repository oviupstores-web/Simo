# Redimensionne (recadrage centré au bon ratio) une image générée vers sa taille finale.
# Usage : resize.ps1 <source> <destination> <largeur> <hauteur> [png]
param([string]$Src, [string]$Dst, [int]$W, [int]$H, [string]$Format = "jpg")
Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile($Src)
$ratio = $W / $H
if ($img.Width / $img.Height -gt $ratio) {
  $ch = $img.Height; $cw = [int]($ch * $ratio); $cx = [int](($img.Width - $cw) / 2); $cy = 0
} else {
  $cw = $img.Width; $ch = [int]($cw / $ratio); $cx = 0; $cy = [int](($img.Height - $ch) / 2)
}
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.SmoothingMode = 'HighQuality'
$g.PixelOffsetMode = 'HighQuality'
$g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $W, $H), (New-Object System.Drawing.Rectangle $cx, $cy, $cw, $ch), 'Pixel')
New-Item -ItemType Directory -Force (Split-Path $Dst) | Out-Null
if ($Format -eq "png") {
  $bmp.Save($Dst, [System.Drawing.Imaging.ImageFormat]::Png)
} else {
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
  $p = New-Object System.Drawing.Imaging.EncoderParameters 1
  $p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 85L
  $bmp.Save($Dst, $codec, $p)
}
$g.Dispose(); $bmp.Dispose(); $img.Dispose()
