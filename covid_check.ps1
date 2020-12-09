[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Ssl3
[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"

cd C:\users\ckska\repo\covid_check
Invoke-WebRequest -uri http://www.chp.gov.hk/files/misc/enhanced_sur_covid_19_eng.csv -OutFile C:\users\ckska\repo\covid_check\enhanced_sur_covid_19_eng.csv
$CSV = (gc enhanced_sur_covid_19_eng.csv)|ConvertFrom-Csv
$CSV| format-table|Measure-Object -line

$CSV[0]
