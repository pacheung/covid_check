cd C:\users\ckska\repo\covid_check
Invoke-WebRequest -uri http://www.chp.gov.hk/files/misc/enhanced_sur_covid_19_eng.csv -OutFile enhanced_sur_covid_19_eng.csv
$CSV = (gc enhanced_sur_covid_19_eng.csv)|ConvertFrom-Csv
$CSV| format-table|Measure-Object -line

$CSV[0]
