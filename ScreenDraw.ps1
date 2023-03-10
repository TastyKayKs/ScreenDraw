Try{
    Add-Type -Namespace "User" -Name "Keys" -MemberDefinition '
        [DllImport("user32.dll")]
        public static extern short GetKeyState(UInt16 virtualKeyCode);
    '
}Catch{}

$ControllerTable = [hashtable]::Synchronized(@{})
$ControllerTable.Kill = $false
$ControllerTable.Count = 0
$ControllerTable.FreeDrawCoords = $null
$ControllerTable.UserKeys = [User.Keys]
$ControllerTable.LeftClick = $false
$ControllerTable.RightClick = $false

$ControllerForm = [System.Windows.Forms.Form]::new()
$ControllerForm.Text = "Screen Draw"
$ControllerForm.TopMost = $True
$ControllerForm.MaximizeBox = $false
$ControllerForm.FormBorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$ControllerForm.Height = 579
$ControllerForm.Width = 306

$ActiveList = [System.Windows.Forms.ListBox]::new()
$ActiveList.Location = [System.Drawing.Size]::new(5,10)
$ActiveList.Width = 160
$ActiveList.Height = 189
$ActiveList.ScrollAlwaysVisible = $true
$ActiveList.Parent = $ControllerForm

$Remove = [System.Windows.Forms.Button]::new()
$Remove.Text = "Remove"
$Remove.Width = 87
$Remove.Left = 7
$Remove.Top = $ActiveList.Top+$ActiveList.Height+1
$Remove.Add_Click({
    Try{
        $ActiveList.Items.RemoveAt($ActiveList.SelectedIndex)

        $ActiveList.Items | %{$DrawingForm.Refresh()}{
            $ObjId = [String]$_
            $InputArgs = $ControllerTable.$ObjId
            $Cmd = $InputArgs | %{$Count = 0}{'$InputArgs['+$Count+'],';$Count++}
            $Cmd = $Cmd -join ''
            $Cmd = $Cmd.TrimEnd(',')+')'
            $Cmd = '$Jraphics.'+($ObjId.Split()[-1]).Replace("FreeHand","DrawLines")+'('+$Cmd
            [Void][ScriptBlock]::Create($Cmd).Invoke()
        }
    }Catch{}
})
$Remove.Parent = $ControllerForm

$ClearAll = [System.Windows.Forms.Button]::new()
$ClearAll.Text = "Clear All"
$ClearAll.Width = $Remove.Width
$ClearAll.Left = $Remove.Left
$ClearAll.Top = $Remove.Top+$Remove.Height+1
$ClearAll.Add_Click({
    Try{
        $ActiveList.Items.Clear()
        $DrawingForm.Refresh()
    }Catch{}
})
$ClearAll.Parent = $ControllerForm

$FreeHand = [System.Windows.Forms.Button]::new()
$FreeHand.Text = "Pencil"
$FreeHand.Size = $ClearAll.Size
$FreeHand.Width = $ClearAll.Width/2
$FreeHand.Left = $ClearAll.Location.X
$FreeHand.Top = $ClearAll.Top+$ClearAll.Height+1
$FreeHand.Add_Click({
    $This.Parent.Opacity = 0.25

    $FreeDrawRunspace = [RunspaceFactory]::CreateRunspace()
    $FreeDrawRunspace.Open()
    $FreeDrawPosh = [Powershell]::Create()
    $FreeDrawPosh.Runspace = $FreeDrawRunspace
    [Void]$FreeDrawPosh.AddScript({
        param($CT)

        $CT.RightClick = $false
        While($CT.UserKeys::GetKeyState(0x02) -ge 0){
            Sleep -Milliseconds 25
            $CT.LeftClick = $CT.UserKeys::GetKeyState(0x01) -lt 0
        }
        $CT.RightClick = $true
        $CT.LeftClick = $false
    })
    [Void]$FreeDrawPosh.AddParameter('CT',$ControllerTable)
    $FreeDrawJob=$FreeDrawPosh.BeginInvoke()

    $Pen = [System.Drawing.Pen]::new($FreeHandColor.BackColor)
    $Pen.Width = 5

    While(!$ControllerTable.RightClick){
        $Points = [System.Drawing.Point[]]@()
        Sleep -Milliseconds 50
        $LastPos = [System.Windows.Forms.Cursor]::Position
        While($ControllerTable.LeftClick){
            $CurrPos = [System.Windows.Forms.Cursor]::Position
            $Jraphics.DrawLine($Pen, $LastPos.X, $LastPos.Y, $CurrPos.X, $CurrPos.Y)
            $Points+=($LastPos)
            $Points+=($CurrPos)
            $LastPos = [System.Windows.Forms.Cursor]::Position
            $Jraphics.DrawLine($Pen, $CurrPos.X, $CurrPos.Y, $LastPos.X, $LastPos.Y)
            $Points+=($CurrPos)
            $Points+=($LastPos)
        }
        If($Points.Count){
            $ObjId = "$($ControllerTable.Count) FreeHand"
            $ControllerTable.$ObjId = @($Pen,$Points)

            $ActiveList.Items.Add($ObjId)
            $ControllerTable.Count++
        }
    }

    $ControllerTable.RightClick = $false
    $ControllerTable.LeftClick = $false

    [Void]$FreeDrawPosh.EndInvoke($FreeDrawJob)
    $FreeDrawRunspace.Close()

    $This.Parent.Opacity = 1
})
$FreeHand.Parent = $ControllerForm

$FreeHandColor = [System.windows.Forms.Button]::new()
$FreeHandColor.Text = "Color"
$FreeHandColor.Width = $Remove.Width/2
$FreeHandColor.Left = $Remove.Left+$FreeHand.Width-1
$FreeHandColor.Top = $FreeHand.Top
$FreeHandColor.BackColor = [System.Drawing.Color]::Black
$FreeHandColor.ForeColor = [System.Drawing.Color]::White
$FreeHandColor.Add_Click({
    $ColorDialog = [System.Windows.Forms.ColorDialog]::new()
    $ColorDialog.ShowDialog()
    $This.BackColor = $ColorDialog.Color
    $Lum = [Math]::Sqrt(
        $This.BackColor.R * $This.BackColor.R * 0.299 +
        $This.BackColor.G * $This.BackColor.G * 0.587 +
        $This.BackColor.B * $This.BackColor.B * 0.114
    )
    If($Lum -gt 130){
        $This.ForeColor = [System.Drawing.Color]::Black
    }Else{
        $This.ForeColor = [System.Drawing.Color]::White
    }
    $This.Parent.Focus()
})
$FreeHandColor.Parent = $ControllerForm

$Draw = [System.Windows.Forms.Button]::new()
$Draw.Text = "Draw --->"
$Draw.Width = $Remove.Width
$Draw.Left = $Remove.Left
$Draw.Top = $FreeHand.Top+$FreeHand.Height+1
$Draw.Add_Click({
    Try{
        $Points = $false
        $Split = $false
        $Prev = $null
        $InputArgs = $(ForEach($Control in $BigPanel.Controls){
            Switch($Control.GetType()){
                ([System.Windows.Forms.TextBox]){
                    $Control.Text
                }
                ([System.Windows.Forms.NumericUpDown]){
                    If($Points -and $Prev.GetType() -eq [System.Windows.Forms.NumericUpDown]){
                        [System.Drawing.Point]::new($Prev.Value,$Control.Value)
                        $Prev = $null
                    }ElseIf(!$Points){
                        $Control.Value
                    }
                }
                ([System.Windows.Forms.Button]){
                    If($Control.Text -match "Font"){
                        $Control.Font
                    }ElseIf($Control.Text -match "(Pen|Brush)"){
                        $Color = $Control.BackColor
                        If($Control.Text -match 'Pen'){
                            [System.Drawing.Pen]::new($Color)
                        }Else{
                            [System.Drawing.SolidBrush]::new($Color)
                        }
                    }ElseIf($Control.Text -match ','){
                        If($Control.Text -match 'loc'){$Split = $true}
                        $TempCoords = ($Control.Text.Split('=')[-1].Split(',')|%{[Int]$_})
                        [System.Drawing.Point]::new($TempCoords[0],$TempCoords[1])
                    }ElseIf($Control.Text -notmatch '\+'){
                        [System.Drawing.Image]::FromFile($Control.Text)
                    }Else{
                        $Points = $true
                    }
                }
            }
            $Prev = $Control
        })
        If($Points){
            $PointArray = [System.Drawing.Point[]]::new(($InputArgs.Count-1))
            For($i = 1; $i -lt $InputArgs.Count; $i++){
                $PointArray[($i-1)] = $InputArgs[$i]
            }
            $InputArgs = @($InputArgs[0],$PointArray)
        }

        If($Split){
            $TempPoint = $null
            $InputArgsStart = ($InputArgs | %{$Found = $false}{If($_.GetType() -eq [System.Drawing.Point]){$TempPoint = $_; $Found = $true}; If(!$Found){$_}})
            $InputArgsEnd = ($InputArgs | %{$Found = $false}{If($Found){$_}; If($_.GetType() -eq [System.Drawing.Point]){$Found = $true}})

            $InputArgs = @()
            $InputArgsStart | %{$InputArgs+=$_}
            $InputArgs+=[Int]$TempPoint.X
            $InputArgs+=[Int]$TempPoint.Y
            $InputArgsEnd | %{$InputArgs+=$_}
        }

        $Cmd = $InputArgs | %{$Count = 0}{'$InputArgs['+$Count+'],';$Count++}
        $Cmd = $Cmd -join ''
        $Cmd = $Cmd.TrimEnd(',')+')'
        $Cmd = '$Jraphics.'+$PassiveList.SelectedItem+'('+$Cmd
        [Void][ScriptBlock]::Create($Cmd).Invoke()

        $ObjId = "$($ControllerTable.Count) $($PassiveList.SelectedItem)"
        $ActiveList.Items.Add($ObjId)

        $ControllerTable.$ObjId = $InputArgs
        $ControllerTable.Count++
    }Catch{
        Write-Host "BAD ARGS"
        Write-Host $Error[0]
    }
})
$Draw.Parent = $ControllerForm

$ZoomBoxSize = 120
$ZoomBoxSize+=2

$ZoomBox = [System.Windows.Forms.GroupBox]::new()
$ZoomBox.Size = [System.Drawing.Size]::new($ZoomBoxSize,($ZoomBoxSize+7))
$ZoomBox.Location = [System.Drawing.Point]::new(175,5)
$ZoomBox.Parent = $ControllerForm

$CenterDot = [System.Windows.Forms.Panel]::new()
$CenterDot.Size = [System.Drawing.Size]::new(8,8)
$CenterDot.Location = $ZoomBox.Location
$CenterDot.Left+=57
$CenterDot.Top+=63
$CenterDot.BackColor = [System.Drawing.Color]::Black
$CenterDot.Parent = $ControllerForm
$CenterDot.BringToFront()

$XCoord = [System.Windows.Forms.NumericUpDown]::new()
$XCoord.Size = [System.Drawing.Size]::new(100,25)
$XCoord.Left = $ZoomBox.Location.X+20
$XCoord.Top = $ZoomBox.Location.Y+$ZoomBox.Height+5
$XCoord.Maximum = 99999
$XCoord.Minimum = -99999
$XCoord.Add_ValueChanged({
    [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new($XCoord.Value,$YCoord.Value)
    $PH = [System.Windows.Forms.Cursor]::Position

    $Bounds = [System.Drawing.Rectangle]::new($PH.X-7,$PH.Y-7,15,15)
    $BMP = [System.Drawing.Bitmap]::new($Bounds.Width, $Bounds.Height)
    ([System.Drawing.Graphics]::FromImage($BMP)).CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)

    $BMPBig = [System.Drawing.Bitmap]::new(128, 128)
    $GraphicsBig = [System.Drawing.Graphics]::FromImage($BMPBig)
    $GraphicsBig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $GraphicsBig.DrawImage($BMP,1,7,128,128)
    $ZoomBox.BackgroundImage = $BMPBig
    $ControllerForm.Refresh()
})
$XCoord.Parent = $ControllerForm

$XCoordLabel = [System.Windows.Forms.Label]::new()
$XCoordLabel.Text = "X:"
$XCoordLabel.Width = ($XCoordLabel.Text.Length*6)+10
$XCoordLabel.Height = 15
$XCoordLabel.Location = $XCoord.Location
$XCoordLabel.Left-=20
$XCoordLabel.Top+=3
$XCoordLabel.Parent = $ControllerForm

$YCoord = [System.Windows.Forms.NumericUpDown]::new()
$YCoord.Size = [System.Drawing.Size]::new(100,25)
$YCoord.Location = $XCoord.Location
$YCoord.Top+=$XCoord.Height+5
$YCoord.Maximum = 99999
$YCoord.Minimum = -99999
$YCoord.Add_ValueChanged({
    [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new($XCoord.Value,$YCoord.Value)
    $PH = [System.Windows.Forms.Cursor]::Position

    $Bounds = [System.Drawing.Rectangle]::new($PH.X-7,$PH.Y-7,15,15)
    $BMP = [System.Drawing.Bitmap]::new($Bounds.Width, $Bounds.Height)
    ([System.Drawing.Graphics]::FromImage($BMP)).CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)

    $BMPBig = [System.Drawing.Bitmap]::new(128, 128)
    $GraphicsBig = [System.Drawing.Graphics]::FromImage($BMPBig)
    $GraphicsBig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $GraphicsBig.DrawImage($BMP,1,7,128,128)
    $ZoomBox.BackgroundImage = $BMPBig
    $ControllerForm.Refresh()
})
$YCoord.Parent = $ControllerForm

$YCoordLabel = [System.Windows.Forms.Label]::new()
$YCoordLabel.Text = "Y:"
$YCoordLabel.Width = ($XCoordLabel.Text.Length*6)+10
$YCoordLabel.Height = 15
$YCoordLabel.Location = $YCoord.Location
$YCoordLabel.Left-=20
$YCoordLabel.Top+=3
$YCoordLabel.Parent = $ControllerForm

$MouseTrack = [System.Windows.Forms.Button]::new()
$MouseTrack.Text = "Click n' Drag"
$MouseTrack.Width = 120
$MouseTrack.Height = 30
$MouseTrack.Left = $ZoomBox.Left+1
$MouseTrack.Top = $YCoord.Top+$YCoord.Height+7
$MouseTrack.Add_MouseMove({
    If([System.Windows.Forms.UserControl]::MouseButtons.ToString() -match 'Left'){
        $PH = [System.Windows.Forms.Cursor]::Position

        $XCoord.Value = $PH.X
        $YCoord.Value = $PH.Y

        $Bounds = [System.Drawing.Rectangle]::new($PH.X-7,$PH.Y-7,15,15)
        $BMP = [System.Drawing.Bitmap]::new($Bounds.Width, $Bounds.Height)
        ([System.Drawing.Graphics]::FromImage($BMP)).CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)

        $BMPBig = [System.Drawing.Bitmap]::new(128, 128)
        $GraphicsBig = [System.Drawing.Graphics]::FromImage($BMPBig)
        $GraphicsBig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $GraphicsBig.DrawImage($BMP,1,7,128,128)
        $ZoomBox.BackgroundImage = $BMPBig

        $PixelColor = $BMPBig.GetPixel(64,64)

        $Lum = [Math]::Sqrt(
            $PixelColor.R * $PixelColor.R * 0.299 +
            $PixelColor.G * $PixelColor.G * 0.587 +
            $PixelColor.B * $PixelColor.B * 0.114
        )
        If($Lum -gt 130){
            $CenterDot.BackColor = [System.Drawing.Color]::Black
        }Else{
            $CenterDot.BackColor = [System.Drawing.Color]::White
        }

        $ControllerForm.Refresh()
    }
})
$MouseTrack.Parent = $ControllerForm

$PassiveList = [System.Windows.Forms.ListBox]::new()
$PassiveList.Left = 100
$PassiveList.Top = 225
$PassiveList.Height = 70
$PassiveList.Width = 195
$PassiveList.ScrollAlwaysVisible = $true
$PassiveList.Add_SelectedIndexChanged({
    Try{$BigPanel.Controls.Clear()}Catch{}

    $DrawlingCapes[$This.SelectedIndex] | %{
        $Split = $_.Split(',')
        $Method = $Split[0]
        $Params = $Split[1..($Split.Length - 1)]

        $OffSetX = 10
        $OffSetY = 10

        $Params | %{
            $Type = $_.Split()[0].Split('.')[-1]
            $Type = $Type.Replace('float','int')
            $Label = $_.Split()[-1]

            Switch($Type){
                'Pen'{
                    $Color = [System.Windows.Forms.Button]::new()
                    $Color.BackColor = [System.Drawing.Color]::Black
                    $Color.ForeColor = [System.Drawing.Color]::White
                    $Color.Text = $Label
                    $Color.Left = $OffSetX
                    $Color.Top+=$OffSetY
                    $Color.Add_Click({
                        $ColorDialog = [System.Windows.Forms.ColorDialog]::new()
                        $ColorDialog.ShowDialog()
                        $This.BackColor = $ColorDialog.Color
                        $Lum = [Math]::Sqrt(
                            $This.BackColor.R * $This.BackColor.R * 0.299 +
                            $This.BackColor.G * $This.BackColor.G * 0.587 +
                            $This.BackColor.B * $This.BackColor.B * 0.114
                        )
                        If($Lum -gt 130){
                            $This.ForeColor = [System.Drawing.Color]::Black
                        }Else{
                            $This.ForeColor = [System.Drawing.Color]::White
                        }
                        $This.Parent.Select()
                    })
                    $Color.Parent = $BigPanel
                }
                'Brush'{
                    $Color = [System.Windows.Forms.Button]::new()
                    $Color.BackColor = [System.Drawing.Color]::Black
                    $Color.ForeColor = [System.Drawing.Color]::White
                    $Color.Text = $Label
                    $Color.Left = $OffSetX
                    $Color.Top+=$OffSetY
                    $Color.Add_Click({
                        $ColorDialog = [System.Windows.Forms.ColorDialog]::new()
                        $ColorDialog.ShowDialog()
                        $This.BackColor = $ColorDialog.Color
                        $Lum = [Math]::Sqrt(
                            $This.BackColor.R * $This.BackColor.R * 0.299 +
                            $This.BackColor.G * $This.BackColor.G * 0.587 +
                            $This.BackColor.B * $This.BackColor.B * 0.114
                        )
                        If($Lum -gt 130){
                            $This.ForeColor = [System.Drawing.Color]::Black
                        }Else{
                            $This.ForeColor = [System.Drawing.Color]::White
                        }
                        $This.Parent.Select()
                    })
                    $Color.Parent = $BigPanel
                }
                'Font'{
                    $Font = [System.Windows.Forms.Button]::new()
                    $Font.Text = $Label
                    $Font.Left = $OffSetX
                    $Font.Top+=$OffSetY
                    $Font.Add_Click({
                        $FontDialog = [System.Windows.Forms.FontDialog]::new()
                        $FontDialog.ShowDialog()
                        $This.Font = $FontDialog.Font
                        $This.Parent.Select()
                    })
                    $Font.Parent = $BigPanel
                }
                'Icon'{
                    $File = [System.Windows.Forms.Button]::new()
                    $File.Text = $Label
                    $File.Left = $OffSetX
                    $File.Top+=$OffSetY
                    $File.Add_Click({
                        $FileDialog = [System.Windows.Forms.OpenFileDialog]::new()
                        $FileDialog.ShowDialog()
                        $This.Text = $FileDialog.FileName
                        $This.Parent.Select()
                    })
                    $File.Parent = $BigPanel
                }
                'Image'{
                    $File = [System.Windows.Forms.Button]::new()
                    $File.Text = $Label
                    $File.Left = $OffSetX
                    $File.Top+=$OffSetY
                    $File.Add_Click({
                        $FileDialog = [System.Windows.Forms.OpenFileDialog]::new()
                        $FileDialog.ShowDialog()
                        $This.Text = $FileDialog.FileName
                        $This.Parent.Select()
                    })
                    $File.Parent = $BigPanel
                }
                'String'{
                    $String = [System.Windows.Forms.TextBox]::new()
                    $String.Text = $Label
                    $String.Left = $OffSetX
                    $String.Top = $OffsetY
                    $String.Parent = $BigPanel
                }
                'Point'{
                    $Point = [System.Windows.Forms.Button]::new()
                    $Point.Text = $Label
                    $Point.Left = $OffSetX
                    $Point.Top+=$OffSetY
                    $Point.Add_MouseUp({
                        $This.Text = ($This.Text -replace "\d","" -replace ",","" -replace "=","")+"="+[System.Windows.Forms.Cursor]::Position.ToString().Trim("{}").Replace("X=","").Replace("Y=","")
                    })
                    $Point.Add_MouseMove({
                        If([System.Windows.Forms.UserControl]::MouseButtons.ToString() -match 'Left'){
                            $PH = [System.Windows.Forms.Cursor]::Position

                            $XCoord.Value = $PH.X
                            $YCoord.Value = $PH.Y

                            $Bounds = [System.Drawing.Rectangle]::new($PH.X-7,$PH.Y-7,15,15)
                            $BMP = [System.Drawing.Bitmap]::new($Bounds.Width, $Bounds.Height)
                            ([System.Drawing.Graphics]::FromImage($BMP)).CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)

                            $BMPBig = [System.Drawing.Bitmap]::new(128, 128)
                            $GraphicsBig = [System.Drawing.Graphics]::FromImage($BMPBig)
                            $GraphicsBig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                            $GraphicsBig.DrawImage($BMP,1,7,128,128)
                            $ZoomBox.BackgroundImage = $BMPBig

                            $PixelColor = $BMPBig.GetPixel(64,64)

                            $Lum = [Math]::Sqrt(
                                $PixelColor.R * $PixelColor.R * 0.299 +
                                $PixelColor.G * $PixelColor.G * 0.587 +
                                $PixelColor.B * $PixelColor.B * 0.114
                            )
                            If($Lum -gt 130){
                                $CenterDot.BackColor = [System.Drawing.Color]::Black
                            }Else{
                                $CenterDot.BackColor = [System.Drawing.Color]::White
                            }

                            $ControllerForm.Refresh()
                        }
                    })
                    $Point.Parent = $BigPanel

                    <#$Lab = [System.Windows.Forms.Label]::new()
                    $Lab.Text = $Label
                    $Lab.Width = ($Lab.Text.Length*6)+10
                    $Lab.Left = $OffSetX
                    $Lab.Top+=$OffSetY
                    $Lab.Parent = $BigPanel

                    #$OffSetX+=$Lab.Width+20

                    $Number1 = [System.Windows.Forms.NumericUpDown]::new()
                    $Number1.Maximum = 99999
                    $Number1.Minimum = -99999
                    $Number1.Width = 75
                    $Number1.Left = $Lab.Location.X+$Lab.Width+15
                    $Number1.Top+=$OffSetY
                    $Number1.Text='Array'
                    $Number1.Parent = $BigPanel

                    $Number2 = [System.Windows.Forms.NumericUpDown]::new()
                    $Number2.Maximum = 99999
                    $Number2.Minimum = -99999
                    $Number2.Width = 75
                    $Number2.Left = $Number1.Location.X+$Number1.Width+15
                    $Number2.Top+=$OffSetY
                    $Number2.Text='Array'
                    $Number2.Parent = $BigPanel#>
                }
                'Point[]'{
                    $Add = [system.Windows.Forms.Button]::new()
                    $Add.Text = '+'
                    $Add.Left = $OffsetX
                    $Add.Top = $OffsetY
                    $Add.Add_Click({
                        $TempOffsetY = 0
                        $Parent = $This.Parent
                        ForEach($Child in $Parent.Controls){
                            If($Child.Top -gt $TempOffsetY){
                                $TempOffsetY = $Child.Top
                            }
                        }
                        $TempOffsetY+=30

                        $Point = [System.Windows.Forms.Button]::new()
                        $Point.Text = "pt"
                        $Point.Left = $This.Left
                        $Point.Top+=$TempOffsetY
                        $Point.Add_MouseUp({
                            $This.Text = ($This.Text -replace "\d","" -replace ",","" -replace "=","")+"="+[System.Windows.Forms.Cursor]::Position.ToString().Trim("{}").Replace("X=","").Replace("Y=","")
                        })
                        $Point.Add_MouseMove({
                            If([System.Windows.Forms.UserControl]::MouseButtons.ToString() -match 'Left'){
                                $PH = [System.Windows.Forms.Cursor]::Position

                                $XCoord.Value = $PH.X
                                $YCoord.Value = $PH.Y

                                $Bounds = [System.Drawing.Rectangle]::new($PH.X-7,$PH.Y-7,15,15)
                                $BMP = [System.Drawing.Bitmap]::new($Bounds.Width, $Bounds.Height)
                                ([System.Drawing.Graphics]::FromImage($BMP)).CopyFromScreen($Bounds.Location, [System.Drawing.Point]::Empty, $Bounds.Size)

                                $BMPBig = [System.Drawing.Bitmap]::new(128, 128)
                                $GraphicsBig = [System.Drawing.Graphics]::FromImage($BMPBig)
                                $GraphicsBig.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
                                $GraphicsBig.DrawImage($BMP,1,7,128,128)
                                $ZoomBox.BackgroundImage = $BMPBig

                                $PixelColor = $BMPBig.GetPixel(64,64)

                                $Lum = [Math]::Sqrt(
                                    $PixelColor.R * $PixelColor.R * 0.299 +
                                    $PixelColor.G * $PixelColor.G * 0.587 +
                                    $PixelColor.B * $PixelColor.B * 0.114
                                )
                                If($Lum -gt 130){
                                    $CenterDot.BackColor = [System.Drawing.Color]::Black
                                }Else{
                                    $CenterDot.BackColor = [System.Drawing.Color]::White
                                }

                                $ControllerForm.Refresh()
                            }
                        })
                        $Point.Parent = $BigPanel
                    })
                    $Add.Parent = $BigPanel

                    $OffsetY+=30
                }
                'int'{
                    $Lab = [System.Windows.Forms.Label]::new()
                    $Lab.Text = $Label
                    $Lab.Width = ($Lab.Text.Length*6)+10
                    $Lab.Left+=$OffSetX
                    $Lab.Top+=$OffSetY
                    $Lab.Parent = $BigPanel

                    #$OffSetX+=$Lab.Width+20

                    $Number = [System.Windows.Forms.NumericUpDown]::new()
                    $Number.Maximum = 99999
                    $Number.Minimum = -99999
                    $Number.Width = 75
                    $Number.Left+=$OffSetX+$Lab.Width+15
                    $Number.Top+=$OffSetY
                    $Number.Value = 100
                    $Number.Parent = $BigPanel
                }
            }

            $OffSetY+=30
        }
    }
})
$PassiveList.Parent = $ControllerForm

$BigPanel = [System.Windows.Forms.Panel]::new()
$BigPanel.Top = 300
$BigPanel.Width = 300
$BigPanel.Height = 250
$BigPanel.AutoScroll = $true
$BigPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$BigPanel.Parent = $ControllerForm

$DrawlingCapes = "
DrawLine,System.Drawing.Pen pen,point pt1,point pt2
DrawEllipse,System.Drawing.Pen pen,point loc,int width,int height
DrawRectangle,System.Drawing.Pen pen,point loc,int width,int height
FillEllipse,System.Drawing.Brush brush,point loc,int width,int height
FillRectangle,System.Drawing.Brush brush,point loc,int width,int height
DrawArc,System.Drawing.Pen pen,point loc,int width,int height,int startAngle,int sweepAngle
DrawPie,System.Drawing.Pen pen,point loc,int width,int height,int startAngle,int sweepAngle
FillPie,System.Drawing.Brush brush,point loc,int width,int height,int startAngle,int sweepAngle
DrawBezier,System.Drawing.Pen pen,System.Drawing.Point pt1,System.Drawing.Point pt2,System.Drawing.Point pt3,System.Drawing.Point pt4
DrawCurve,System.Drawing.Pen pen,System.Drawing.Point[] points
DrawClosedCurve,System.Drawing.Pen pen,System.Drawing.Point[] points
DrawPolygon,System.Drawing.Pen pen,System.Drawing.Point[] points
FillClosedCurve,System.Drawing.Brush brush,System.Drawing.Point[] points
FillPolygon,System.Drawing.Brush brush,System.Drawing.Point[] points
DrawString,string s,System.Drawing.Font font,System.Drawing.Brush brush,point loc
DrawIcon,System.Drawing.Icon icon,point loc
DrawImage,System.Drawing.Image image,point loc,int width,int height
DrawImageUnscaled,System.Drawing.Image image,point loc,int width,int height
"
$DrawlingCapes = $DrawlingCapes.Split([System.Environment]::NewLine).Where({$_})
$DrawlingCapes.ForEach({[Void]$PassiveList.Items.Add($_.Split(',')[0])})
$PassiveList.SelectedIndex = 0

$DrawingForm = [System.Windows.Forms.Form]::new()
$DrawingForm.FormBorderStyle = [System.Windows.Forms.BorderStyle]::None
$DrawingForm.ShowInTaskbar = $false
$DrawingForm.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$DrawingForm.Size = [System.Drawing.Size]::new(5000,5000)
$DrawingForm.Location = [System.Drawing.Point]::new(0,0)
$DrawingForm.AllowTransparency = $true
$DrawingForm.TransparencyKey = $DrawingForm.BackColor
$DrawingForm.Show()
$DrawingForm.TopMost = $true
$DrawingForm.TopMost = $false
$DrawingForm.TopMost = $true
$DrawingForm.Hide()
$Jraphics = [System.Drawing.Graphics]::FromHwnd($DrawingForm.Handle)
$Run = [RunspaceFactory]::CreateRunspace()
$Run.Open()
$Pow = [Powershell]::Create()
$Pow.Runspace = $Run
[Void]$Pow.AddScript({
    param($DF,$CT)
    $DF = $DF.Value

    $DF.Show()
    While(!$CT.Kill){
        Sleep -Milliseconds 25
    }
    $DF.Close()
})
[Void]$Pow.AddParameter('DF',[ref]$DrawingForm)
[Void]$Pow.AddParameter('CT',$ControllerTable)
$Job=$Pow.BeginInvoke()

$ControllerForm.ShowDialog()
$ControllerTable.Kill = $true

$Pow.EndInvoke($Job)
$Run.Close()

$Pow.Dispose()
$Run.Dispose()
