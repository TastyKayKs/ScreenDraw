$ControllerTable = [hashtable]::Synchronized(@{})
$ControllerTable.Kill = $false
$ControllerTable.Count = 0

$ControllerForm = [System.Windows.Forms.Form]::new()
$ControllerForm.Text = "Screen Draw"
$ControllerForm.Size = [System.Drawing.Size]::new(500,500)

$ActiveList = [System.Windows.Forms.ListBox]::new()
$ActiveList.ScrollAlwaysVisible = $true
$ActiveList.Parent = $ControllerForm

$PassiveList = [System.Windows.Forms.ListBox]::new()
$PassiveList.Location = [System.Drawing.Size]::new(100,150)
$PassiveList.ScrollAlwaysVisible = $true
$PassiveList.Add_SelectedIndexChanged({
    $BigPanel.Controls.Clear()

    $OffSetX = 0
    $OffSetY = 0

    $DrawlingCapes[$This.SelectedIndex] | %{
        $Split = $_.Split(',')
        $Method = $Split[0]
        $Params = $Split[1..($Split.Length - 1)]

        $OffSetX = 30
        $OffSetY = 30

        $Params | %{
            $Type = $_.Split()[0].Split('.')[-1]
            $Type = $Type.Replace('float','int')
            $Label = $_.Split()[-1]

            Switch($Type){
                'Pen'{
                    $Color = [System.Windows.Forms.Button]::new()
                    $Color.Text = $Label
                    $Color.Left = $OffSetX
                    $Color.Top+=$OffSetY
                    $Color.Add_Click({
                        $ColorDialog = [System.Windows.Forms.ColorDialog]::new()
                        $ColorDialog.ShowDialog()
                        $This.BackColor = $ColorDialog.Color
                        $This.Parent.Select()
                    })
                    $Color.Parent = $BigPanel
                }
                'Brush'{
                    $Color = [System.Windows.Forms.Button]::new()
                    $Color.Text = $Label
                    $Color.Left = $OffSetX
                    $Color.Top+=$OffSetY
                    $Color.Add_Click({
                        $ColorDialog = [System.Windows.Forms.ColorDialog]::new()
                        $ColorDialog.ShowDialog()
                        $This.BackColor = $ColorDialog.Color
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
                    $Lab = [System.Windows.Forms.Label]::new()
                    $Lab.Text = $Label
                    $Lab.Width = ($Label.Length*5)+10
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
                    $Number2.Parent = $BigPanel
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

                        $Lab = [System.Windows.Forms.Label]::new()
                        $Lab.Text = "points"
                        $Lab.Width = ($Lab.Text.Length*5)+10
                        $Lab.Left = $This.Location.X
                        $Lab.Top = $TempOffsetY
                        $Lab.Parent = $BigPanel

                        #$OffSetX+=$Lab.Width+20

                        $Number1 = [System.Windows.Forms.NumericUpDown]::new()
                        $Number1.Maximum = 99999
                        $Number1.Minimum = -99999
                        $Number1.Width = 75
                        $Number1.Left = $Lab.Location.X+$Lab.Width+15
                        $Number1.Top = $TempOffsetY
                        $Number1.Parent = $BigPanel

                        $Number2 = [System.Windows.Forms.NumericUpDown]::new()
                        $Number2.Maximum = 99999
                        $Number2.Minimum = -99999
                        $Number2.Width = 75
                        $Number2.Left = $Number1.Location.X+$Number1.Width+15
                        $Number2.Top = $TempOffsetY
                        $Number2.Parent = $BigPanel
                    })
                    $Add.Parent = $BigPanel

                    $OffsetY+=30

                    $Lab = [System.Windows.Forms.Label]::new()
                    $Lab.Text = $Label
                    $Lab.Width = ($Lab.Text.Length*5)+10
                    $Lab.Left = $OffSetX
                    $Lab.Top = $OffSetY
                    $Lab.Parent = $BigPanel

                    #$OffSetX+=$Lab.Width+20

                    $Number1 = [System.Windows.Forms.NumericUpDown]::new()
                    $Number1.Maximum = 99999
                    $Number1.Minimum = -99999
                    $Number1.Width = 75
                    $Number1.Left = $Lab.Location.X+$Lab.Width+15
                    $Number1.Top = $OffSetY
                    $Number1.Parent = $BigPanel

                    $Number2 = [System.Windows.Forms.NumericUpDown]::new()
                    $Number2.Maximum = 99999
                    $Number2.Minimum = -99999
                    $Number2.Width = 75
                    $Number2.Left = $Number1.Location.X+$Number1.Width+15
                    $Number2.Top = $OffSetY
                    $Number2.Parent = $BigPanel
                }
                'int'{
                    $Lab = [System.Windows.Forms.Label]::new()
                    $Lab.Text = $Label
                    $Lab.Width = ($Label.Length*5)+10
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

                    $Number.Parent = $BigPanel
                }
            }

            $OffSetY+=30
        }
    }
})
$PassiveList.Parent = $ControllerForm

$DrawlingCapes = "
DrawLine,System.Drawing.Pen pen,int x1,int y1,int x2,int y2
DrawEllipse,System.Drawing.Pen pen,int x,int y,int width,int height
DrawRectangle,System.Drawing.Pen pen,int x,int y,int width,int height
FillEllipse,System.Drawing.Brush brush,int x,int y,int width,int height
FillRectangle,System.Drawing.Brush brush,int x,int y,int width,int height
DrawArc,System.Drawing.Pen pen,int x,int y,int width,int height,int startAngle,int sweepAngle
DrawPie,System.Drawing.Pen pen,int x,int y,int width,int height,int startAngle,int sweepAngle
FillPie,System.Drawing.Brush brush,int x,int y,int width,int height,int startAngle,int sweepAngle
DrawBezier,System.Drawing.Pen pen,System.Drawing.Point pt1,System.Drawing.Point pt2,System.Drawing.Point pt3,System.Drawing.Point pt4
DrawCurve,System.Drawing.Pen pen,System.Drawing.Point[] points
DrawClosedCurve,System.Drawing.Pen pen,System.Drawing.Point[] points
DrawPolygon,System.Drawing.Pen pen,System.Drawing.Point[] points
FillClosedCurve,System.Drawing.Brush brush,System.Drawing.Point[] points
FillPolygon,System.Drawing.Brush brush,System.Drawing.Point[] points
DrawString,string s,System.Drawing.Font font,System.Drawing.Brush brush,float x,float y
DrawIcon,System.Drawing.Icon icon,int x,int y
DrawImage,System.Drawing.Image image,int x,int y,int width,int height
DrawImageUnscaled,System.Drawing.Image image,int x,int y,int width,int height
"
$DrawlingCapes = $DrawlingCapes.Split([System.Environment]::NewLine).Where({$_})
$DrawlingCapes.ForEach({[Void]$PassiveList.Items.Add($_.Split(',')[0])})
$PassiveList.SelectedIndex = 0

$Draw = [System.Windows.Forms.Button]::new()
$Draw.Text = "Draw"
$Draw.Location = [System.Drawing.Point]::new(0,200)
$Draw.Add_Click({
    Try{
        $Points = $false
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

$Remove = [System.Windows.Forms.Button]::new()
$Remove.Text = "Remove"
$Remove.Location = [System.Drawing.Point]::new(0,150)
$Remove.Add_Click({
    Try{
        $ActiveList.Items.RemoveAt($ActiveList.SelectedIndex)

        $ActiveList.Items | %{$DrawingForm.Refresh()}{
            $ObjId = [String]$_
            $InputArgs = $ControllerTable.$ObjId
            #$Jraphics.DrawLine($InputArgs[0],$InputArgs[1],$InputArgs[2])
            $Cmd = $InputArgs | %{$Count = 0}{'$InputArgs['+$Count+'],';$Count++}
            $Cmd = $Cmd -join ''
            $Cmd = $Cmd.TrimEnd(',')+')'
            $Cmd = '$Jraphics.'+$ObjId.Split()[-1]+'('+$Cmd
            [Void][ScriptBlock]::Create($Cmd).Invoke()
        }
    }Catch{}
})
$Remove.Parent = $ControllerForm

$ZoomBoxSize = 120
$ZoomBoxSize+=2

$ZoomBox = [System.Windows.Forms.GroupBox]::new()
$ZoomBox.Size = [System.Drawing.Size]::new($ZoomBoxSize,($ZoomBoxSize+7))
$ZoomBox.Location = [System.Drawing.Point]::new(150,5)
$ZoomBox.Parent = $ControllerForm

$CenterDot = [System.Windows.Forms.Panel]::new()
$CenterDot.Size = [System.Drawing.Size]::new(8,8)
$CenterDot.Location = $ZoomBox.Location
$CenterDot.Left+=57
$CenterDot.Top+=63
$CenterDot.BackColor = [System.Drawing.Color]::Black
$CenterDot.Parent = $ControllerForm
$CenterDot.BringToFront()

$MouseTrack = [System.Windows.Forms.Button]::new()
$MouseTrack.Text = "Mouse Inf"
$MouseTrack.Location = [System.Drawing.Point]::new(0,175)
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
        $ControllerForm.Refresh()
    }
})
$MouseTrack.Parent = $ControllerForm


$XCoord = [System.Windows.Forms.NumericUpDown]::new()
$XCoord.Size = [System.Drawing.Size]::new(50,25)
$XCoord.Location = [System.Drawing.Point]::new(300,150)
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
$XCoordLabel.Location = $XCoord.Location
$XCoordLabel.Left-=20
$XCoordLabel.Top+=3
$XCoordLabel.Parent = $ControllerForm

$YCoord = [System.Windows.Forms.NumericUpDown]::new()
$YCoord.Size = [System.Drawing.Size]::new(50,25)
$YCoord.Location = $XCoord.Location
$YCoord.Top+=30
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
$YCoordLabel.Location = $YCoord.Location
$YCoordLabel.Left-=20
$YCoordLabel.Top+=3
$YCoordLabel.Parent = $ControllerForm

$BigPanel = [System.Windows.Forms.Panel]::new()
$BigPanel.Top = 250
$BigPanel.Width = 300
$BigPanel.Height = 300
$BigPanel.AutoScroll = $true
$BigPanel.Parent = $ControllerForm

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
        Sleep 1
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


#$GroupBoxColorSizeSize = [System.Windows.Forms.GroupBox]::new()
