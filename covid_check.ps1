cd C:\users\ckska\repo\covid_check
Invoke-WebRequest -uri http://www.chp.gov.hk/files/misc/enhanced_sur_covid_19_eng.csv -OutFile enhanced_sur_covid_19_eng.csv
$CSV = (gc enhanced_sur_covid_19_eng.csv)|ConvertFrom-Csv|select
$CSV2=$CSV|select @{Name="Case";Expression = {[int]$_."Case no."}},@{Name="D_Report";Expression = {$_."Report date" -as [datetime]}},@{Name="D_Onset";Expression = {$_."Date of onset" -as [datetime]}},Gender,@{Name="Age";Expression = {[int]$_.Age}},@{Name="Hospitalised";Expression = {$_."Hospitalised/Discharged/Deceased"}},@{Name="Residency";Expression = {$_."HK/Non-HK resident"}},@{Name="Class";Expression = {$_."Case classification*"}},@{Name="Confirmed";Expression = {$_."Confirmed/probable"}}

$CSV|gm
$CSV[0]|ft
$CSV2[0]|ft

"Last 7 Days:",(($CSV2|where Class -match "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-7)).count),"(Imported) /",(($CSV2|where "D_Report" -GE (Get-Date).AddDays(-7)).count) -join ' '
"Last 2 Days:",(($CSV2|where Class -match "Imported case"|where "D_Report" -GE (Get-Date).AddDays(-2)).count),"(Imported) /",(($CSV2|where "D_Report" -GE (Get-Date).AddDays(-2)).count) -join ' '
"Hospitalized:",(($CSV2|where Class -match "Imported case"|where "Hospitalised" -Match "Hospitalised").count),"(Imported) /",(($CSV2|where "Hospitalised" -Match "Hospitalised").count) -join ' '
"Hospitalized: ",(($CSV2|where "Hospitalised" -Match "Hospitalised").count)," | Discharged: ",(($CSV2|where "Hospitalised" -Match "Discharged").count),"| Deceased: ",(($CSV2|where "Hospitalised" -Match "Deceased").count) -join ' '
"Gender: ",(($CSV2|where Gender -match "M").count),"(M) | ",(($CSV2|where Gender -match "F").count),"(F)" -join ' '
"Total: ",(($CSV2|where Class -match "Imported case").count),"(Imported) /",(($CSV2).count) -join ' '
