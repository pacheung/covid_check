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
$TOT=($CSV2).count

$CSV2|select -Last 10|ft

"Last 7 Days:",
    (($CSV2|where Class -EQ "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-7)).count),"(Imported) /",
    (($CSV2|where "D_Report" -GE (Get-Date).AddDays(-7)).count) -join ' '
"Last 2 Days:",
    (($CSV2|where Class -EQ "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-2)).count),"(Imported) /",
    (($CSV2|where "D_Report" -GE (Get-Date).AddDays(-2)).count) -join ' '
"Hospitalized:",
    (($CSV2|where Class -EQ "Imported case"|where "Status" -EQ "Hospitalised").count),"(Imported) /",
    (($CSV2|where "Status" -EQ "Hospitalised").count) -join ' '
"Status: ",
    (($CSV2|where "Status" -EQ "To be provided").count),"(To be provided) | ",
    (($CSV2|where "Status" -EQ "Hospitalised").count),"(Hospitalised) | ",
    (($CSV2|where "Status" -EQ "Discharged").count),"(Discharged) | ",
    (($CSV2|where "Status" -EQ "Deceased").count),"(Deceased)" -join ' '
"Gender: ",
    (($CSV2|where Gender -EQ "M").count),"(M) | ",
    (($CSV2|where Gender -EQ "F").count),"(F)" -join ' '
$AG_Str="Age Group: "
for ($num = 0 ; $num -le 100 ; $num+=10)
{
	$AG_Str += (($CSV2|where AG -EQ $num).count)," (",$num,"s)| " -join ''
}
$AG_Str
$AGP_Str="Age Group: "
for ($num = 0 ; $num -le 100 ; $num+=10)
{
	$AGP_Str += (($CSV2|where AG -EQ $num).count/$TOT).tostring("P")," (",$num,"s) | " -join ''
}
$AGP_Str
"Residency: ",
    (($CSV2|where Residency -EQ "HK resident").count),"(Local) | ",
    (($CSV2|where Residency -EQ "Non-HK resident").count),"(Non-HK)" -join ' '
"Class: ",
    (($CSV2|where Class -EQ "Imported case").count),"(Imported) | ",
    (($CSV2|where Class -EQ "Local case").count),"(Local) | ",
    (($CSV2|where Class -EQ "Epidemiologically linked with local case").count),"(Linked) /",
    $TOT -join ' '


$D_30=$CSV2|where "D_Report" -LT (Get-Date).AddDays(-30)
$T30=$D_30.count
"D-30 Status: ",
    (($D_30|where "Status" -EQ "To be provided").count/$T30).tostring("P"),"(To be provided) | ",
    (($D_30|where "Status" -EQ "Hospitalised").count/$T30).tostring("P"),"(Hospitalised) | ",
    (($D_30|where "Status" -EQ "Discharged").count/$T30).tostring("P"),"(Discharged) | ",
    (($D_30|where "Status" -EQ "Deceased").count/$T30).tostring("P"),"(Deceased) / ",
    $T30 -join ' '

$D14=$CSV2|where "D_Report" -GE (Get-Date).AddDays(-14)
$T14=$D14.count
$D14A_Str="D14 AgeGroup: "
$D14A_HEADER=@()
$D14A_DATA=@()
for ($num = 0 ; $num -le 100 ; $num+=10)
{
	$D14A_Str += (($D14|where AG -EQ $num).count/$T14).tostring("P")," (",$num,"s)| " -join ''
	$D14A_HEADER += $num,"s" -join ""
	$D14A_DATA += (($D14|where AG -EQ $num).count)
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