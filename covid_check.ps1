cd $HOME\repo\covid_check
$URL="http://www.chp.gov.hk/files/misc/enhanced_sur_covid_19_eng.csv"
$FILE=$URL.Split("/")[5]
$URL2="http://www.chp.gov.hk/files/misc/building_list_eng.csv"
$FILE2=$URL2.Split("/")[5]

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
$BLDG=curl -uri $URL2|ConvertFrom-Csv|select District,
    @{Name="BLDG";Expression = {$_."Building name"}},
    @{Name="Last_Visit";Expression = {$_."Last date of residence of the case(s)" -as [datetime]}},
    @{Name="Related";Expression = {$_."Related probable/confirmed cases" -as [datetime]}}
$B14=$BLDG|where Last_Visit -GE (Get-Date).AddDays(-14)

$CSV|gm
$TOT=($CSV2).Count
$AG_MIN=($CSV2 | ForEach-Object {$_.AG}|measure -min).Minimum
$AG_MAX=($CSV2 | ForEach-Object {$_.AG}|measure -max).Maximum

$CSV2|select -Last 10|ft

"Last 2 Days:",
    (($CSV2|where Class -EQ "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-2)).Count),"(Imported) /",
    (($CSV2|where "D_Report" -GE (Get-Date).AddDays(-2)).Count) -join ' '
"Last 7 Days:",
    (($CSV2|where Class -EQ "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-7)).Count),"(Imported) /",
    (($CSV2|where "D_Report" -GE (Get-Date).AddDays(-7)).Count) -join ' '
"Status: ",
    (($CSV2|where "Status" -EQ "To be provided").Count),"(To be provided) | ",
    (($CSV2|where "Status" -EQ "Pending admission").Count),"(Pending admission) | ",
    (($CSV2|where "Status" -EQ "Hospitalised").Count),"(Hospitalised) | ",
    (($CSV2|where "Status" -EQ "Discharged").Count),"(Discharged) | ",
    (($CSV2|where "Status" -EQ "Deceased").Count),"(Deceased) / ",
    $TOT -join ' '
"Hospitalized:",
    (($CSV2|where Class -EQ "Imported case"|where "Status" -EQ "Hospitalised").Count),"(Imported) /",
    (($CSV2|where "Status" -EQ "Hospitalised").Count) -join ' '
"Gender: ",
    (($CSV2|where Gender -EQ "M").Count),"(M) | ",
    (($CSV2|where Gender -EQ "F").Count),"(F)" -join ' '
"Residency: ",
    (($CSV2|where Residency -EQ "HK resident").Count),"(Local) | ",
    (($CSV2|where Residency -EQ "Non-HK resident").Count),"(Non-HK)" -join ' '
"Class: ",
    (($CSV2|where Class -EQ "Imported case").Count),"(Imported) | ",
    (($CSV2|where Class -EQ "Local case").Count),"(Local) | ",
    (($CSV2|where Class -EQ "Epidemiologically linked with local case").Count),"(Linked) " -join ' '
$AG_Str="Age Group: "
$AGP_Str="Age Group: "
for ($num = $AG_MIN ; $num -le $AG_MAX ; $num+=10)
{
    if (($CSV2|where AG -eq $num) -ne $null) {
	    if (($CSV2|where AG -eq $num).count -EQ $null) { $COUNTER = 1 }
	    else { $COUNTER = ($CSV2|where AG -eq $num).count }

	    $AG_Str += $COUNTER," (",$num,"s)| " -join ''
	    $AGP_Str += ($COUNTER/$TOT).tostring("P")," (",$num,"s) | " -join ''

#		$num,$COUNTER,($COUNTER/$TOT).tostring("P") -join ":"
    }
}
$AG_Str
$AGP_Str


#Stats for all Cases within last 14 days
$D14=$CSV2|where "D_Report" -GE (Get-Date).AddDays(-14)
$T14=$D14.Count
$D14_MIN=($D14 | ForEach-Object {$_.AG}|measure -min).Minimum
$D14_MAX=($D14 | ForEach-Object {$_.AG}|measure -max).Maximum
$D14A_Str="D14 AG: "
$D14A_HEADER=@()
$D14A_DATA=@()
for ($num = $D14_MIN ; $num -le $D14_MAX ; $num+=10)
{
    if (($D14|where AG -eq $num) -ne $null) {
	    if (($D14|where AG -eq $num).count -EQ $null) { $COUNTER = 1 }
	    else { $COUNTER = ($D14|where AG -eq $num).count }

	    $D14A_Str += ($COUNTER/$T14).tostring("P")," (",$num,"s)| " -join ''
	    $D14A_HEADER += $num,"s" -join ""
	    $D14A_DATA += $COUNTER
    }
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
$T30=$D30.Count
"D-30 Status: ",
    ((($D30|where "Status" -EQ "To be provided").Count)/$T30).tostring("P"),"(To be provided) | ",
    ((($D30|where "Status" -EQ "Pending admission").Count)/$T30).tostring("P"),"(Pending admission) | ",
    ((($D30|where "Status" -EQ "Hospitalised").Count)/$T30).tostring("P"),"(Hospitalised) | ",
    ((($D30|where "Status" -EQ "Discharged").Count)/$T30).tostring("P"),"(Discharged) | ",
    ((($D30|where "Status" -EQ "Deceased").Count)/$T30).tostring("P"),"(Deceased) / ",
    $T30 -join ' '

$D30D = ($D30|where Status -eq "Deceased"|select "Case","AG")
$D30D_MIN = ($D30D|ForEach-Object {$_.AG}|measure -min).Minimum
$D30D_MAX = ($D30D|ForEach-Object {$_.AG}|measure -max).Maximum

$D30A_Str="D30 AG Death Rate: "
$D30A_HEADER=@()
$D30A_DATA=@()
for ($num = $D30D_MIN ; $num -le $D30D_MAX ; $num+=10)
{
	if (($D30D|where AG -eq $num) -ne $null) {
		if (($D30D|where AG -eq $num).count -EQ $null) { $COUNTER = 1 }
		else { $COUNTER = ($D30D|where AG -eq $num).count }

		$D30A_HEADER += $num,"s" -join ""
		$D30A_DATA += ($COUNTER/(($D30|where AG -EQ $num).Count)).tostring("P")
		$D30A_Str += ($COUNTER/(($D30|where AG -EQ $num).Count)).tostring("P"),"(",$num,"s) |" -join ''

#		$num,$COUNTER,($D30|where AG -EQ $num).Count,($COUNTER/($D30|where AG -EQ $num).Count).tostring("P") -join ":"
	}
}
$D30A_Str
