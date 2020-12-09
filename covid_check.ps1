cd C:\users\ckska\repo\covid_check
Invoke-WebRequest -uri http://www.chp.gov.hk/files/misc/enhanced_sur_covid_19_eng.csv -OutFile enhanced_sur_covid_19_eng.csv
$CSV = (gc enhanced_sur_covid_19_eng.csv)|ConvertFrom-Csv|select
$CSV2=$CSV|select @{Name="Case";Expression = {[int]$_."Case no."}},
	@{Name="D_Report";Expression = {$_."Report date" -as [datetime]}},
	@{Name="D_Onset";Expression = {$_."Date of onset" -as [datetime]}},
	Gender,
	@{Name="Age";Expression = {[int]$_.Age}},
	@{Name="AG";Expression = {[int][Math]::Floor($_.Age/10)*10}},
	@{Name="Hospitalised";Expression = {$_."Hospitalised/Discharged/Deceased"}},
	@{Name="Residency";Expression = {$_."HK/Non-HK resident"}},
	@{Name="Class";Expression = {$_."Case classification*"}},
	@{Name="Confirmed";Expression = {$_."Confirmed/probable"}}



$CSV|gm
$TOT=($CSV2).count

$CSV2|select -Last 10|ft

"Last 7 Days:",
    (($CSV2|where Class -match "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-7)).count),"(Imported) /",
    (($CSV2|where "D_Report" -GE (Get-Date).AddDays(-7)).count) -join ' '
"Last 2 Days:",
    (($CSV2|where Class -match "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-2)).count),"(Imported) /",
    (($CSV2|where "D_Report" -GE (Get-Date).AddDays(-2)).count) -join ' '
"Hospitalized:",
    (($CSV2|where Class -match "Imported case"|where "Hospitalised" -Match "Hospitalised").count),"(Imported) /",
    (($CSV2|where "Hospitalised" -Match "Hospitalised").count) -join ' '
"Status: ",
    (($CSV2|where "Hospitalised" -Match "Hospitalised").count)," | Discharged: ",
    (($CSV2|where "Hospitalised" -Match "Discharged").count),"| Deceased: ",
    (($CSV2|where "Hospitalised" -Match "Deceased").count) -join ' '
"Gender: ",
    (($CSV2|where Gender -match "M").count),"(M) | ",
    (($CSV2|where Gender -match "F").count),"(F)" -join ' '
"Age Group: ",
	(($CSV2|where AG -eq 0).count),"(0s)| ",
	(($CSV2|where AG -eq 10).count),"(10s)| ",
	(($CSV2|where AG -eq 20).count),"(20s)| ",
	(($CSV2|where AG -eq 30).count),"(30s)| ",
	(($CSV2|where AG -eq 40).count),"(40s)| ",
	(($CSV2|where AG -eq 50).count),"(50s)| ",
	(($CSV2|where AG -eq 60).count),"(60s)| ",
	(($CSV2|where AG -eq 70).count),"(70s)| ",
	(($CSV2|where AG -eq 80).count),"(80s)| ",
	(($CSV2|where AG -eq 90).count),"(90s)| ",
	(($CSV2|where AG -eq 100).count),"(100s)" -join ' '
"Age Group: ",
	(($CSV2|where AG -eq 0).count/$TOT).tostring("P"),"(0s)| ",
	(($CSV2|where AG -eq 10).count/$TOT).tostring("P"),"(10s)| ",
	(($CSV2|where AG -eq 20).count/$TOT).tostring("P"),"(20s)| ",
	(($CSV2|where AG -eq 30).count/$TOT).tostring("P"),"(30s)| ",
	(($CSV2|where AG -eq 40).count/$TOT).tostring("P"),"(40s)| ",
	(($CSV2|where AG -eq 50).count/$TOT).tostring("P"),"(50s)| ",
	(($CSV2|where AG -eq 60).count/$TOT).tostring("P"),"(60s)| ",
	(($CSV2|where AG -eq 70).count/$TOT).tostring("P"),"(70s)| ",
	(($CSV2|where AG -eq 80).count/$TOT).tostring("P"),"(80s)| ",
	(($CSV2|where AG -eq 90).count/$TOT).tostring("P"),"(90s)| ",
	(($CSV2|where AG -eq 100).count/$TOT).tostring("P"),"(100s)" -join ' '
"Residency: ",
    (($CSV2|where Residency -match "HK resident").count),"(Local) | ",
    (($CSV2|where Residency -match "Non-HK resident").count),"(Non-HK)" -join ' '
"Total: ",
    (($CSV2|where Class -match "Imported case").count),"(Imported) /",
    (($CSV2).count) -join ' '
