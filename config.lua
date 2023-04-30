Config = {
    Use_ESX = false,
    Use_QBCore = true,
    RoleList = {
        {"Bronze-Tier", 1, 
            {"$1,000,000 voucher", {'Money', 1000000}} 
        }, -- Bronze Tier 
        {"Silver-Tier", 1, 
            {"$5,000,000 voucher",{'Money', 5000000}} 
        }, -- Silver Tier 
        {"Gold-Tier", 1, 
            {"$15,000,000 voucher",{'Money', 15000000}}, 
            {"Invitation to Mafia [Gang]", {'Job', 'mafia', 0}},
            {"Invitation to LS Kings [Gang]", {'Job', 'woodyguns', 0}},
            {"Invitation to Sons of Anarchy [Gang]", {'Job', 'lazy', 0}},
            {"Invitation to Black Diamond Cartel [Gang]", {'Job', 'stevestacos', 0}}
        }, -- Gold Tier 
    },
}