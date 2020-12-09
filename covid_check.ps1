cd C:\users\ckska\repo\covid_check
Invoke-WebRequest -uri http://www.chp.gov.hk/files/misc/enhanced_sur_covid_19_eng.csv -OutFile enhanced_sur_covid_19_eng.csv
$CSV = (gc enhanced_sur_covid_19_eng.csv)|ConvertFrom-Csv|select

$CSV| format-table|Measure -line
$CSV| where "Report date" -match "8/12/2020"|Format-Table|measure -line

$CSV[0]|format-table
$CSV|gm

$CSV2=$CSV|select @{Name="Case";Expression = {[int]$_."Case no."}},@{Name="D_Report";Expression = {$_."Report date" -as [datetime]}},@{Name="D_Onset";Expression = {$_."Date of onset" -as [datetime]}},Gender,@{Name="Age";Expression = {[int]$_.Age}},@{Name="Hospitalised";Expression = {$_."Hospitalised/Discharged/Deceased"}},@{Name="Residency";Expression = {$_."HK/Non-HK resident"}},@{Name="Class";Expression = {$_."Case classification*"}},@{Name="Confirmed";Expression = {$_."Confirmed/probable"}}
  

$CSV2[0]|format-table
$CSV2|gm

