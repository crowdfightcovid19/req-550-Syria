# Contact_matrix.R
# This is simply a supporting file to test some strategies with ad-hoc contact matrices
# Contact matrix for model "age3_gender2_com2_FC" see README in /data/fake_models for details
Cont["age3_M_vulner",]=0
Cont["age3_F_vulner",]=0
Cont[,"age3_M_vulner"]=0
Cont[,"age3_F_vulner"]=0
Cont["age3_F_vulner","age3_F_vulner"]=1
Cont["age3_M_vulner","age3_M_vulner"]=1
Cont["age3_F_vulner","age3_M_vulner"]=1
Cont["age3_M_vulner","age3_F_vulner"]=1
Cont["age3_F_vulner","age2_F_healthy"]=1/20
Cont["age2_F_healthy","age3_F_vulner"]=1/20
Cont["age3_M_vulner","age2_F_healthy"]=1/20
Cont["age2_F_healthy","age3_M_vulner"]=1/20
Cont["age2_F_healthy","age2_M_healthy"]=1/20
Cont["age2_M_healthy","age2_F_healthy"]=1/20
