import pandas as pd
import numpy as np

#CSV=pd.read_csv("enhanced_sur_covid_19_eng.csv")
CSV=pd.read_csv("enhanced_sur_covid_19_eng.csv",
    usecols=["Case no.",
        "Report date",
        "Gender",
        "Age",
        "Hospitalised/Discharged/Deceased",
        "HK/Non-HK resident",
        "Case classification*"
    ],
)
CSV=CSV.rename(
    columns={'Case no.':'Case',
        "Report date":"D_Report",
        "Hospitalised/Discharged/Deceased":"Status",
        "HK/Non-HK resident":"Residency",
        "Case classification*":"Class"
    },
)

CSV
