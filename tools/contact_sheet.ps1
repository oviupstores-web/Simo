# Planche de contrôle : vignettes 360 px avec leur libellé, 5 par ligne.
# Usage : contact_sheet.ps1 <sortie.jpg> "<image>|<libellé>" ...
param([string]$Out, [Parameter(ValueFromRemainingArguments = $true)][string[]]$Entries)
Add-Type -AssemblyName System.Drawing
$cell = 360; $label = 44; $gap = 16; $cols = 5
$rows = [Math]::Ceiling($Entries.Count / $cols)
$W = $cols * $cell + ($cols + 1) * $gap
$H = $rows * ($cell + $label) + ($rows + 1) * $gap
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'
$g.TextRenderingHint = 'AntiAliasGridFit'
$g.Clear([System.Drawing.Color]::FromArgb(250, 251, 248))
$font = New-Object System.Drawing.Font 'Segoe UI', 13
$brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(31, 41, 35))
for ($i = 0; $i -lt $Entries.Count; $i++) {
  $path, $text = $Entries[$i].Split('|', 2)
  $x = $gap + ($i % $cols) * ($cell + $gap)
  $y = $gap + [Math]::Floor($i / $cols) * ($cell + $label + $gap)
  $img = [System.Drawing.Image]::FromFile($path)
  # Ajuste l'image dans la case carrée sans la déformer.
  $s = [Math]::Min($cell / $img.Width, $cell / $img.Height)
  $w = [int]($img.Width * $s); $h = [int]($img.Height * $s)
  $g.DrawImage($img, $x + [int](($cell - $w) / 2), $y + [int](($cell - $h) / 2), $w, $h)
  $img.Dispose()
  $g.DrawString($text, $font, $brush, [single]$x, [single]($y + $cell + 8))
}
New-Item -ItemType Directory -Force (Split-Path $Out) | Out-Null
$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$p = New-Object System.Drawing.Imaging.EncoderParameters 1
$p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 88L
$bmp.Save($Out, $codec, $p)
$g.Dispose(); $bmp.Dispose()
