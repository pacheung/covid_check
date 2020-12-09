# covid_check
> .\covid_check.ps1


   TypeName: Selected.System.Management.Automation.PSCustomObject

Name                             MemberType   Definition                                        
----                             ----------   ----------                                        
Equals                           Method       bool Equals(System.Object obj)                    
GetHashCode                      Method       int GetHashCode()                                 
GetType                          Method       type GetType()                                    
ToString                         Method       string ToString()                                 
Age                              NoteProperty string Age=39                                     
Case classification*             NoteProperty string Case classification*=Imported case         
Case no.                         NoteProperty string Case no.=1                                 
Confirmed/probable               NoteProperty string Confirmed/probable=Confirmed               
Date of onset                    NoteProperty string Date of onset=21/01/2020                   
Gender                           NoteProperty string Gender=M                                   
HK/Non-HK resident               NoteProperty string HK/Non-HK resident=Non-HK resident         
Hospitalised/Discharged/Deceased NoteProperty string Hospitalised/Discharged/Deceased=Discharged
Name of hospital admitted        NoteProperty string Name of hospital admitted=                 
Report date                      NoteProperty string Report date=23/01/2020                     



Case no. Report date Date of onset Gender Age Name of hospital admitted Hospitalised/Discharged/Deceased HK/Non-HK resident Case classification* Confirmed/probable
-------- ----------- ------------- ------ --- ------------------------- -------------------------------- ------------------ -------------------- ------------------
1        23/01/2020  21/01/2020    M      39                            Discharged                       Non-HK resident    Imported case        Confirmed         



Case D_Report              D_Onset               Gender Age Hospitalised Residency       Class         Confirmed
---- --------              -------               ------ --- ------------ ---------       -----         ---------
   1 23/1/2020 12:00:00 am 21/1/2020 12:00:00 am M       39 Discharged   Non-HK resident Imported case Confirmed


Last 7 Days: 52 (Imported) / 576
Last 2 Days: 5 (Imported) / 100
Hospitalized: 58 (Imported) / 1135
Hospitalized:  1135  | Discharged:  5696 | Deceased:  112
Gender:  3481 (M) |  3595 (F)
Total:  1733 (Imported) / 7076
