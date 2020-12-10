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
"Age Group: ",
    (($CSV2|where AG -EQ 0).count),"(0s)| ",
    (($CSV2|where AG -EQ 10).count),"(10s)| ",
    (($CSV2|where AG -EQ 20).count),"(20s)| ",
    (($CSV2|where AG -EQ 30).count),"(30s)| ",
    (($CSV2|where AG -EQ 40).count),"(40s)| ",
    (($CSV2|where AG -EQ 50).count),"(50s)| ",
    (($CSV2|where AG -EQ 60).count),"(60s)| ",
    (($CSV2|where AG -EQ 70).count),"(70s)| ",
    (($CSV2|where AG -EQ 80).count),"(80s)| ",
    (($CSV2|where AG -EQ 90).count),"(90s)| ",
    (($CSV2|where AG -EQ 100).count),"(100s)" -join ' '
"Age Group: ",
    (($CSV2|where AG -EQ 0).count/$TOT).tostring("P"),"(0s)| ",
    (($CSV2|where AG -EQ 10).count/$TOT).tostring("P"),"(10s)| ",
    (($CSV2|where AG -EQ 20).count/$TOT).tostring("P"),"(20s)| ",
    (($CSV2|where AG -EQ 30).count/$TOT).tostring("P"),"(30s)| ",
    (($CSV2|where AG -EQ 40).count/$TOT).tostring("P"),"(40s)| ",
    (($CSV2|where AG -EQ 50).count/$TOT).tostring("P"),"(50s)| ",
    (($CSV2|where AG -EQ 60).count/$TOT).tostring("P"),"(60s)| ",
    (($CSV2|where AG -EQ 70).count/$TOT).tostring("P"),"(70s)| ",
    (($CSV2|where AG -EQ 80).count/$TOT).tostring("P"),"(80s)| ",
    (($CSV2|where AG -EQ 90).count/$TOT).tostring("P"),"(90s)| ",
    (($CSV2|where AG -EQ 100).count/$TOT).tostring("P"),"(100s)" -join ' '
"Residency: ",
    (($CSV2|where Residency -EQ "HK resident").count),"(Local) | ",
    (($CSV2|where Residency -EQ "Non-HK resident").count),"(Non-HK)" -join ' '
"Class: ",
    (($CSV2|where Class -EQ "Imported case").count),"(Imported) | ",
    (($CSV2|where Class -EQ "Local case").count),"(Local) | ",
    (($CSV2|where Class -EQ "Epidemiologically linked with local case").count),"(Linked) /",
    $TOT -join ' '

