$URL="http://www.chp.gov.hk/files/misc/enhanced_sur_covid_19_eng.csv"
$FILE=$URL.Split("/")[5]

Invoke-WebRequest -uri $URL -OutFile $FILE
$CSV = (gc $FILE)|ConvertFrom-Csv
$CSV2=$CSV|select @{Name="Case";Expression = {[int]$_."Case no."}},
    @{Name="D_Report";Expression = {$_."Report date" -as [datetime]}},
    @{Name="D_Onset";Expression = {$_."Date of onset" -as [datetime]}},
    Gender,
    @{Name="Age";Expression = {[int]$_.Age}},
    @{Name="AG";Expression = {[int][Math]::Floor($_.Age/10)*10}},
    @{Name="Status";Expression = {$_."Hospitalised/Discharged/Deceased"}},
    @{Name="Residency";Expression = {$_."HK/Non-HK resident"}},
    @{Name="Class";Expression = {$_."Case classification*"}},
    @{Name="Confirmed";Expression = {$_."Confirmed/probable"}}


$CSV|gm
$TOT=($CSV2).Count+1
$AG_MAX=($CSV2 | ForEach-Object {$_.AG}|measure -max).Maximum

$CSV2|select -Last 10|ft

"Last 2 Days:",
    (($CSV2|where Class -EQ "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-2)).Count+1),"(Imported) /",
    (($CSV2|where "D_Report" -GE (Get-Date).AddDays(-2)).Count+1) -join ' '
"Last 7 Days:",
    (($CSV2|where Class -EQ "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-7)).Count+1),"(Imported) /",
    (($CSV2|where "D_Report" -GE (Get-Date).AddDays(-7)).Count+1) -join ' '
"Status: ",
    (($CSV2|where "Status" -EQ "To be provided").Count+1),"(To be provided) | ",
    (($CSV2|where "Status" -EQ "Hospitalised").Count+1),"(Hospitalised) | ",
    (($CSV2|where "Status" -EQ "Discharged").Count+1),"(Discharged) | ",
    (($CSV2|where "Status" -EQ "Deceased").Count+1),"(Deceased) / ",
    $TOT -join ' '
"Hospitalized:",
    (($CSV2|where Class -EQ "Imported case"|where "Status" -EQ "Hospitalised").Count+1),"(Imported) /",
    (($CSV2|where "Status" -EQ "Hospitalised").Count+1) -join ' '
"Gender: ",
    (($CSV2|where Gender -EQ "M").Count+1),"(M) | ",
    (($CSV2|where Gender -EQ "F").Count+1),"(F)" -join ' '
"Residency: ",
    (($CSV2|where Residency -EQ "HK resident").Count+1),"(Local) | ",
    (($CSV2|where Residency -EQ "Non-HK resident").Count+1),"(Non-HK)" -join ' '
"Class: ",
    (($CSV2|where Class -EQ "Imported case").Count+1),"(Imported) | ",
    (($CSV2|where Class -EQ "Local case").Count+1),"(Local) | ",
    (($CSV2|where Class -EQ "Epidemiologically linked with local case").Count+1),"(Linked) " -join ' '
$AG_Str="Age Group: "
for ($num = 0 ; $num -le $AG_MAX ; $num+=10)
{
	$AG_Str += (($CSV2|where AG -EQ $num).Count+1)," (",$num,"s)| " -join ''
}
$AG_Str

$AGP_Str="Age Group: "
for ($num = 0 ; $num -le $AG_MAX ; $num+=10)
{
	$AGP_Str += ((($CSV2|where AG -EQ $num).Count+1)/$TOT).tostring("P")," (",$num,"s) | " -join ''
}
$AGP_Str



#Stats for all Cases within last 14 days
$D14=$CSV2|where "D_Report" -GE (Get-Date).AddDays(-14)
$T14=$D14.Count+1
$D14_AG_MAX=($D14 | ForEach-Object {$_.AG}|measure -max).Maximum
$D14A_Str="D14 AG: "
$D14A_HEADER=@()
$D14A_DATA=@()
for ($num = 0 ; $num -le $D14_AG_MAX ; $num+=10)
{
	$D14A_Str += ((($D14|where AG -EQ $num).Count+1)/$T14).tostring("P")," (",$num,"s)| " -join ''
	$D14A_HEADER += $num,"s" -join ""
	$D14A_DATA += (($D14|where AG -EQ $num).Count+1)
}
$D14A_Str += $T14," [TOTAL]" -join ''
$D14A_Str

#Testing for creating chart
[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
$D14_AG_Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
$D14_AG_Chart.Width = 800
$D14_AG_Chart.Height = 400
$D14_AG_Chart.BackColor = [System.Drawing.Color]::White
		 
#header 
[void]$D14_AG_Chart.Titles.Add("Age Group Distribution for Recent 14 Days")
$D14_AG_Chart.Titles[0].Font = "segoeuilight,20pt"
$D14_AG_Chart.Titles[0].Alignment = "topLeft"
$chartarea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
$chartarea.Name = "ChartArea1"
$D14_AG_Chart.ChartAreas.Add($chartarea)
			  
[void]$D14_AG_Chart.Series.Add("data1")
$D14_AG_Chart.Series["data1"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Doughnut
$D14_AG_Chart.Series["data1"].Points.DataBindXY($D14A_HEADER, $D14A_DATA)
$D14_AG_Chart.SaveImage("$PWD\D14_AG_Chart.png","png")
start "$PWD\D14_AG_Chart.png"

#Stats for all Cases beyond 30days
$D30=$CSV2|where "D_Report" -LT (Get-Date).AddDays(-30)
$T30=$D30.Count+1
"D-30 Status: ",
    ((($D30|where "Status" -EQ "To be provided").Count+1)/$T30).tostring("P"),"(To be provided) | ",
    ((($D30|where "Status" -EQ "Hospitalised").Count+1)/$T30).tostring("P"),"(Hospitalised) | ",
    ((($D30|where "Status" -EQ "Discharged").Count+1)/$T30).tostring("P"),"(Discharged) | ",
    ((($D30|where "Status" -EQ "Deceased").Count+1)/$T30).tostring("P"),"(Deceased) / ",
    $T30 -join ' '

$D30D = ($D30|where Status -eq "Deceased"|select "Case","AG")
$D30D_MIN = ($D30D|ForEach-Object {$_.AG}|measure -min).Minimum
$D30D_MAX = ($D30D|ForEach-Object {$_.AG}|measure -max).Maximum

$D30A_Str="D30 AG Death Rate: "
$D30A_HEADER=@()
$D30A_DATA=@()
#for ($num = $D30D_MIN ; $num -le $D_30D_MAX ; $num+=10)
for ($num = $D30D_MIN ; $num -le $D30D_MAX ; $num+=10)
{
	$D30A_HEADER += $num,"s" -join ""
	$D30A_DATA += ((($D30D|where AG -EQ $num).Count+1)/(($D30|where AG -EQ $num).Count+1)).tostring("P")
    $D30A_Str += ((($D30D|where AG -EQ $num).Count+1)/(($D30|where AG -EQ $num).Count+1)).tostring("P"),"(",$num,"s) |" -join ''
}
$D30A_HEADER
$D30A_DATA
$D30A_Str

