cd $HOME\repo\covid_check
$URL="http://www.chp.gov.hk/files/misc/enhanced_sur_covid_19_eng.csv" #Confirmed/Suspected Cases
$URL2="http://www.chp.gov.hk/files/misc/building_list_eng.csv" #Building List
$URL3="http://www.chp.gov.hk/files/misc/large_clusters_eng.csv" #Top Cluster 10+
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
#Building involved
$BLDG=curl -uri $URL2|ConvertFrom-Csv|select District,
    @{Name="BLDG";Expression = {$_."Building name"}},
    @{Name="Last_Visit";Expression = {$_."Last date of residence of the case(s)" -as [datetime]}},
    @{Name="Related";Expression = {$_."Related probable/confirmed cases"}}
$B14=$BLDG|where Last_Visit -GE (Get-Date).AddDays(-14)
#Top cluster
$CLU=curl -uri $URL3|ConvertFrom-Csv|select Cluster,@{Name="NUM";Expression = {[int]$_."Number of cases"}},@{Name="Involved";Expression = {$_."Involved case number"}}|sort NUM -Descending

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
    (($CSV2|where Status -EQ "To be provided").Count),"(",(($CSV2|where Status -EQ "To be provided").Count/$TOT).tostring("P"),") (To be provided) | ",
    (($CSV2|where Status -EQ "Pending admission").Count),"(",(($CSV2|where Status -EQ "Pending admission").Count/$TOT).tostring("P"),") (Pending admission) | ",
    (($CSV2|where Status -EQ "Hospitalised").Count),"(",(($CSV2|where Status -EQ "Hospitalised").Count/$TOT).tostring("P"),") (Hospitalised) | ",
    (($CSV2|where Status -EQ "Discharged").Count),"(",(($CSV2|where Status -EQ "Discharged").Count/$TOT).tostring("P"),") (Discharged) | ",
    (($CSV2|where Status -EQ "Deceased").Count),"(",(($CSV2|where Status -EQ "Deceased").Count/$TOT).tostring("P"),") (Deceased) / ",
    $TOT -join ' '
#"Hospitalized:",
#    (($CSV2|where Class -EQ "Imported case"|where "Status" -EQ "Hospitalised").Count),"(Imported) /",
#    (($CSV2|where "Status" -EQ "Hospitalised").Count) -join ' '
"Gender: ",
    (($CSV2|where Gender -EQ "M").Count),"(",(($CSV2|where Gender -EQ "M").Count/$TOT).tostring("P"),") (M) | ",
    (($CSV2|where Gender -EQ "F").Count),"(",(($CSV2|where Gender -EQ "F").Count/$TOT).tostring("P"),") (F)" -join ' '
"Residency: ",
    (($CSV2|where Residency -EQ "HK resident").Count),"(",(($CSV2|where Residency -EQ "HK resident").Count/$TOT).tostring("P"),") (Local) | ",
    (($CSV2|where Residency -EQ "Non-HK resident").Count),"(",(($CSV2|where Residency -EQ "Non-HK resident").Count/$TOT).tostring("P"),") (Non-HK)" -join ' '
"Class: ",
    (($CSV2|where Class -EQ "Imported case").Count),"(",(($CSV2|where Class -EQ "Imported case").Count/$TOT).tostring("P"),") (Imported) | ",
    (($CSV2|where Class -EQ "Local case").Count),"(",(($CSV2|where Class -EQ "Local case").Count/$TOT).tostring("P"),") (Local) | ",
    (($CSV2|where Class -EQ "Possibly Local case").Count),"(",(($CSV2|where Class -EQ "Possibly Local case").Count/$TOT).tostring("P"),") (P-Local) | ",
    (($CSV2|where Class -EQ "Epidemiologically linked with local case").Count),"(",(($CSV2|where Class -EQ "Epidemiologically linked with local case").Count/$TOT).tostring("P"),") (Linked-L) | ",
    (($CSV2|where Class -EQ "Epidemiologically linked with possibly local case").Count),"(",(($CSV2|where Class -EQ "Epidemiologically linked with possibly local case").Count/$TOT).tostring("P"),") (Linked-PL) | ",
    (($CSV2|where Class -EQ "Epidemiologically linked with imported case").Count),"(",(($CSV2|where Class -EQ "Epidemiologically linked with imported case").Count/$TOT).tostring("P"),") (Linked-I) " -join ' '

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
$D14D=$D14|where Status -eq "Deceased"|select "Case","AG"

$T14=$D14.Count
$T14D=$D14D.Count
$D14_MIN=($D14 | ForEach-Object {$_.AG}|measure -min).Minimum
$D14_MAX=($D14 | ForEach-Object {$_.AG}|measure -max).Maximum
$D14D_MIN=($D14D| ForEach-Object {$_.AG}|measure -min).Minimum
$D14D_MAX=($D14D| ForEach-Object {$_.AG}|measure -max).Maximum

$D14A_Str="D14 AG: "
$D14D_Str="D14 AG Death: "
$D14A_HEADER=@()
$D14A_DATA=@()
for ($num = $D14_MIN ; $num -le $D14_MAX ; $num+=10)
{
    if (($D14|where AG -eq $num) -ne $null) {
	    if (($D14|where AG -eq $num).count -EQ $null) { $COUNTER = 1 }
	    else { $COUNTER = ($D14|where AG -eq $num).count }

	    $D14A_Str += $COUNTER,"(",($COUNTER/$T14).tostring("P"),") (",$num,"s)| " -join ''
	    $D14A_HEADER += $num,"s" -join ""
	    $D14A_DATA += $COUNTER
    }
    if (($D14D|where AG -eq $num) -ne $null) {
	    if (($D14D|where AG -eq $num).count -EQ $null) { $COUNTER_D = 1 }
	    else { $COUNTER_D = ($D14D|where AG -eq $num).count }

	    $D14D_Str += $COUNTER_D,"(",($COUNTER_D/$COUNTER).tostring("P"),") (",$num,"s)| " -join ''
    }
}
$D14A_Str += $T14," [TOTAL]" -join ''
$D14D_Str += $T14D," [TOTAL]" -join ''
$D14A_Str
$D14D_Str

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
#start "$PWD\D14_AG_Chart.png"

date
$D14B=$D14|select Case,D_Report,D_Onset,
    @{Name="District";Expression = {($BLDG|where Related -Contains $_."Case").District}},
    @{Name="BLDG";Expression = {if ($_.Class -NE "Imported case") {($BLDG|where Related -Contains $_.Case).BLDG}}},
    Gender,Age,AG,Status,Residency,Class
$D14B|where BLDG -Like "*Shun Tin Estate*"|ft
date

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

#Top 5 Clusters
$CLU|select -First 5|ft