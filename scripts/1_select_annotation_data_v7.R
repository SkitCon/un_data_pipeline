#####################################################################
# UN Multilingual Corpus
# Select annotationss
# Javier Osorio 
# 2-13-2024
#####################################################################



# SETUP --------------------------------------------------
  
# Load all packages here
  
if (!require("pacman")) install.packages("pacman")
pacman::p_load(here, glue, openxlsx, tidyverse, readxl, dplyr, stringr)




# GET THE DATA --------------------------------------------------


# Get the data
data.1994 <- read_csv("data/UNv1.0-linked/1994.csv")
data.1996 <- read_csv("data/UNv1.0-linked/1996.csv")
data.1997 <- read_csv("data/UNv1.0-linked/1997.csv")
data.1998 <- read_csv("data/UNv1.0-linked/1998.csv")
data.1999 <- read_csv("data/UNv1.0-linked/1999.csv")
data.2000 <- read_csv("data/UNv1.0-linked/2000.csv")
data.2001 <- read_csv("data/UNv1.0-linked/2001.csv")
data.2002 <- read_csv("data/UNv1.0-linked/2002.csv")
data.2003 <- read_csv("data/UNv1.0-linked/2003.csv")
data.2004 <- read_csv("data/UNv1.0-linked/2004.csv")
data.2005 <- read_csv("data/UNv1.0-linked/2005.csv")
data.2006 <- read_csv("data/UNv1.0-linked/2006.csv")
data.2007 <- read_csv("data/UNv1.0-linked/2007.csv")
data.2008 <- read_csv("data/UNv1.0-linked/2008.csv")
data.2009 <- read_csv("data/UNv1.0-linked/2009.csv")
data.2010 <- read_csv("data/UNv1.0-linked/2010.csv")
data.2011 <- read_csv("data/UNv1.0-linked/2011.csv")
data.2012 <- read_csv("data/UNv1.0-linked/2012.csv")
data.2013 <- read_csv("data/UNv1.0-linked/2013.csv")
data.2014 <- read_csv("data/UNv1.0-linked/2014.csv")


# Append the data
data.full <- rbind(data.1994, data.1996, data.1997, data.1998, data.1999, data.2000, data.2001, data.2002, data.2003, data.2004, data.2005, data.2006, data.2007, data.2008, data.2009, data.2010, data.2011, data.2012, data.2013, data.2014)

# Drop yearly data
rm(data.1994, data.1996, data.1997, data.1998, data.1999, data.2000, data.2001, data.2002, data.2003, data.2004, data.2005, data.2006, data.2007, data.2008, data.2009, data.2010, data.2011, data.2012, data.2013, data.2014)



# RANDOMIZATION --------------------------------------------------


# Set seed
set.seed(2709)

# Randomize data
data.full <- data.full %>%
  mutate(row.num = row_number())

# Randomize data
data.full <- data.full %>%
  mutate(random = runif(nrow(data.full), min = 0, max = 1)) %>%
  arrange(random)

# Count words per row
data.full <- data.full %>%
  mutate(word.count = str_count(en, '\\w+'))

# Eliminate rows with 5 or fewer words
data.full <- data.full %>%
  filter(word.count>5) %>%
  select(-word.count)

# Eliminate signatures
data.full <- data.full %>%
  mutate(eliminate = str_detect(en, "(Signed)|Ambassador and Permanent Representative|Decides to remain actively seized of the matter")) %>%
  filter(eliminate=="FALSE")%>%
  select(-eliminate)



# SELECT TOPICS  --------------------------------------------------

# UN thematic issues https://www.securitycouncilreport.org/thematic-general-issues
# Select topic
#   Key UN documents
#     Selected Security Council Resolutions
#     Selected Security Council Presidential Statements
#     Selected Secretary General's Reports
#     Selected Security Council Press statements


data.select <- data.full %>%
  mutate(human.rights = str_detect(id, "s/res/2217|a/hrc/54/61|s/2006/822|s/2014/928|s/2014/872|s/2014/501|s/2014/276|s/2012/359|s/2012/24|s/2011/525|s/2009/193|a/62/913|s/2007/471|s/2006/822|s/2006/742|s/2005/490|s/2005/489|s/2005/485|s/2005/60|s/2005/6|s/2004/1038|s/2004/614|s/2004/567|s/2004/384|s/2003/216|s/2003/90|s/2002/937|s/2002/764|s/2002/685|s/2000/786|s/2000/59|s/1999/389|s/1998/581|s/1996/927|s/1996/931")) %>% 
  mutate(protect.civilians = str_detect(id, "s/res/2175|s/res/2150|s/res/1894|s/res/1738|s/res/1674|s/res/1502|s/res/1296|s/res/1265|s/res/1208|s/res/1080|s/res/918|s/prst/2014/3|s/prst/2013/2|s/prst/2010/25|s/prst/2010/10|s/prst/2010/8|s/prst/2010/2|s/prst/2009/1|s/prst/2008/18|s/prst/2006/4|s/prst/2005/30|s/prst/2005/25|s/prst/2004/46|s/prst/2004/30|s/prst/2004/24|s/prst/2004/21|s/prst/2004/19|s/prst/2004/3|s/prst/2003/27|s/prst/2002/41|s/prst/2002/17|s/prst/2002/6|s/prst/1999/6|s/prst/1998/20|s/prst/1998/18|s/prst/1997/34|s/prst/1997/13|s/2014/571|s/2014/74|s/2013/447|s/2012/373|s/2011/701|s/2010/129|s/2008/402|s/2001/614|s/2000/298|s/2000/119|s/1998/581")) %>%
  mutate(terrorism = str_detect(id, "s/res/2253|s/res/2250|s/res/2249|s/res/2199|s/res/2195|s/res/2178|s/res/2170|s/res/2161|s/res/2160|s/res/2133|s/res/2129|s/res/2083|s/res/2082|s/res/2055|s/res/1989|s/res/1988|s/res/1977|s/res/1963|s/res/1904|s/res/1887|s/res/1822|s/res/1810|s/res/1805|s/res/1787|s/res/1735|s/res/1730|s/res/1624|s/res/1617|s/res/1566|s/res/1540|s/res/1535|s/res/1526|s/res/1456|s/res/1455|s/res/1452|s/res/1390|s/res/1388|s/res/1377|s/res/1373|s/res/1368|s/res/1363|s/res/1333|s/res/1269|s/res/1267|s/prst/2014/23|s/prst/2013/5|s/prst/2013/1|s/prst/2012/17|s/prst/2012/2|s/prst/2011/9|s/prst/2011/5|s/prst/2010/19|s/prst/2009/22|s/prst/2008/35|s/prst/2008/32|s/prst/2008/31|s/prst/2008/19|s/prst/2008/45|s/prst/2007/50|s/prst/2007/47|s/prst/2007/45|s/prst/2007/39|s/prst/2007/32|s/prst/2007/26|s/prst/2007/11|s/prst/2007/10|s/prst/2007/4|s/prst/2006/64|s/prst/2006/56|s/prst/2006/28|s/prst/2005/64|s/prst/2005/55|s/prst/2005/34|s/prst/1999/29|s/prst/1995/3|s/2014/9|s/2003/191|s/2001/1086|s/2001/695|s/2001/241|s/2001/1215|s/2014/869|s/2014/787|s/2014/648|s/2014/369|s/2014/233|s/2014/73|s/2014/41|s/2013/792|s/2013/769|s/2013/722|s/2013/467|s/2013/452|s/2013/364|s/2013/327|s/2013/264|s/2012/79|s/2012/16|s/2011/689|s/2011/463|s/2011/245|s/2011/223|s/2011/37|s/2011/29|s/2010/569|s/2010/497|s/2010/462|s/2010/366|s/2010/282|s/2010/125|s/2010/112|s/2010/89|s/2010/52|s/2009/502|s/2009/432|s/2009/389|s/2009/289|s/2009/171|s/2009/170|s/2009/124|s/2009/71|s/2009/67|s/2008/848|s/2008/821|s/2008/738|s/2008/471|s/2008/428|s/2008/379|s/2008/324|s/2008/187|s/2008/80|s/2008/25|s/2008/16|s/2007/677|s/2007/229|s/2007/254|s/2006/989|s/2006/1002|s/2006/154|s/2005/800|s/2005/817|s/2005/761|s/2005/760|s/2005/663|s/2005/672|s/2005/572|s/2004/758|s/2004/642|s/2004/124|s/1999/1021")) %>%
  # mutate(small.arms = str_detect(id, "s/res/1467|s/prst/2012/16|s/prst/2010/6|s/prst/2009/20|s/prst/2008/43|s/prst/2007/42|s/prst/2007/24|s/prst/2006/38|s/prst/2005/7|s/prst/2004/1|s/prst/2002/30|s/prst/2002/31|s/prst/2001/21|s/prst/2000/10|s/prst/1999/28|s/prst/1999/21|s/2013/503|s/2011/255|s/2008/258|s/2006/109|s/2005/86|s/2005/69|s/2003/1217|s/2002/1053|s/2000/1092|s/2000/101|s/1998/318|s/2013/536|s/2010/143|s/2008/697|s/2001/732")) %>%
  # mutate(justice = str_detect(id, "")) %>%
  # mutate(women = str_detect(id, "")) %>%
  # mutate(youth = str_detect(id, "")) %>%
  # mutate(children = str_detect(id, "")) %>%
  # mutate(arms.control = str_detect(id, "")) %>%
  # mutate(drugs = str_detect(id, "")) %>%
  # mutate(piracy = str_detect(id, "")) %>%
  # mutate(non.proliferation = str_detect(id, ""))  %>%
  filter(human.rights=="TRUE" | protect.civilians=="TRUE"| terrorism=="TRUE") %>%
  arrange(random) %>%
  select(-random)



# Label topic
data.select <- data.select %>%
  mutate(topic = case_when(
    human.rights=="TRUE" ~ "Human Rights",
    protect.civilians=="TRUE" ~ "Protect Civilians", 
    terrorism=="TRUE" ~ "Terrorism"
  )) %>%
  select(-c(human.rights,protect.civilians,terrorism))






# SELECT SPECIALIZED CONTENT  --------------------------------------------------




# Select Sample containing human rights violation terms
data.select <- data.select %>%
  mutate(humanrights = str_detect(en, 'attack|torture|waterboard|abus|kill|
                                  murder|execute|execution|death|dead|disembow|dismember|
                                  genocide|democide|brutal|purge|decapitat|stab|hang|
                                  mutilat|indiscriminat|lethal|injur|wound|harm|discrim|
                                  displac|interven|kidnap|bomb|drone|airplane|raid|
                                  strike|terror|refug|mutila|arrest|detain|detent|shot|shoot|
                                  prison|imprison|repress|riot|punish|disob|surrend|
                                  violen|conflict|target|minorit|polic|offensive|
                                  fire|firearm|gun|weapon|rifle|gun|machinegun|mine|
                                  tank|militar|offens|rape|arbitrary|battle|airstrike|
                                  clash|piracy|pirate|battalion|soldier|fight|combat|
                                  combatant|militia|lynch|cleans|crime|squad|militant|
                                  dehumaniz|war|armed|extort|racket|force|inhuman|
                                  segrega|discrimina|slave|surveil|explo|blast|misile|rocket|
                                  involuntary|trouble|extrajudicial|enfoce|injust|
                                  radical|cruel|ransom|surrender|rendition|spy|missing|surrender|
                                  protest|sabotag|march|boycott|barricad|hostage|
                                  rebel|insurgen|radical|ambush|recruit|harass|defens|extremis|
                                  resist|noncombat|excombat|nonmilitant|attroc|risk|threat|victim|
                                  counterterror|counterinsurg|unlawful|unjustif|
                                  paramilitar|impun|impune|restrict|criminaliz|starv|hunger|
                                  integrity|deprivation|interrogat|
                                  overcrowd|ill-treat|inmate|extermin|prepetra|
                                  unrest|disorder|rival|surviv|suffer|scar|burn|
                                  inflict|smuggl|deplor|decease|
                                  retain|retention|abduct|inappropiat|destroy|destruction')) 

# Report number of relevant
table(data.select$humanrights)


# Split database into relevant and no relevant

data.select.relevant <- data.select %>%
  filter(humanrights=="TRUE") 


data.select.notrelevant <- data.select %>%
  filter(humanrights=="FALSE") 




# # EXTRACT NOT RELEVANT SENTENCES  --------------------------------------------------

# Set seed
set.seed(2709) #2709

# Filter likely irrelevant sentences
data.select.notrelevant.sample <- data.full %>%  #data.full data.select.notrelevant
  mutate(exclude = str_detect(en, '17N|AAA|AAD|AAH|AAI|AAMB|ANF|AOI|AQAP|AQIS|ASG|AUC|AUM|Abdallah Azzam Brigades|Abu Nidal Organization|Abu Sayyaf Group|Abu Sayyaf|Abu-Sayyaf|
Al-Aqsa Martyrs Brigade|Ansar Bayt al-Maqdis|Ansar al-Dine|Ansar al-Islam|
Ansar al-Islam|Ansar al-Shari’a in Benghazi|Ansar al-Shari’a in Darnah|Ansar al-Shari’a in Tunisia|Ansarallah|Armed Islamic Group|Army of Islam|Army
|Asa’ib Ahl al-Haq|Asbat al-Ansar|Asnaru|Attacks|Attack|Aum Shinrikyo|Authority|Basque Fatherland and Liberty|Blocks|Boko Haram|Boko-Haram|
Boosting|CIRA|CPP|Chemical|Commanders|Commander|Commissioner|Commission|
Communist Party of the Philippines |Continues|Continue|Continuity Irish Republican Army|Cooperate|Cooperation|Counter Piracy|
Counter-Piracy|Counter-Terrorism|DHKP|Delegates|Delegation|
Democratic Front for the Liberation of Palestine|Deployment|Developing|Develop|Dialogue|Directing|Directs|Direct|Discrimination|ELN|ETA|Electoral|
Encourage|Endorsed|Endorsed|Endorsement|Endorses|Endorses|Endorse|Endorsing|Engagement|Enhance|Exempt|FARC|FARC|Freedoms|Freedom|
GICM|Gama’a al-Islamiyya|HAMAS|HAMAS|HASM|HQN|HTS|HUJI|HUJI|HUM|Hamas|Haqqani Network|Haqqani|Harakat Sawa’d Misr|
Harakat ul-Jihad-i-Islami|Harakat ul-Jihad-i-Islami|Harakat ul-Mujahidin|Hawatmeh Faction|Hay’at Tahrir al-Sham|Headquarters|Headquarter|
Hezballah|Hezbollah|Hizballah|Hizbollah|Hizbul Mujahideen|Hostages|Hostage|IJU|IMU|INTERPOL|IRGC|
ISIS in the Greater Sahara|ISIS-Bangladesh|ISIS-DRC|ISIS-GS|ISIS-K|ISIS-Libya|ISIS-Mozambique|ISIS-Philippines|ISIS-Sinai Province|ISIS-West Africa|
ISIS|Incidents|Incident|Indian Mujahedeen|Interpol|Islamic Jihad Union|Islamic Movement of Uzbekistan|Islamic Revolutionary Guard Corps|Islamic State|
Islamic State’s Khorasan Province|Islamic State’s Khorasan|JAT|JEM|JI|JNIM|JRTN|Jaish-e-Mohammed|Jama’at Nusrat al-Islam wal-Muslimin|
Janjaweed|Japanese Red Army|Jaysh Rijal al-Tariq al Naqshabandi|Jaysh al-Adl|Jemaah Anshorut Tauhid|Jemaah Islamiya|Jihad|Jundallah|Kach|
Kahane Chai|Kata’ib Hizballah|Khmer Rouge|Kurdistan Workers Party|LIFG|LJ|LTTE|Lacks|Lack|Lashkar i Jhangvi|Lashkar-e-Tayyiba|Leaders|Leader|
Letter|Liberation Tigers of Tamil Eelam|Libyan Islamic Fighting Group|Lieutenant|MEK|MSC|Manuel Rodriguez Patriotic Front Dissidents|
Missing|Mitigation|Moroccan Islamic Combatant Group|Mujahedin-e Khalq Organization|Mujahidin Shura Council|NPA|National Liberation Army|
New Irish Republican Army|New People’s Army|Osama|PFLP General Command|PFLP-GC|PFLP-General Command|PFLP|PIJ|PKK|PLF|Palestine Islamic Jihad|
Palestine Liberation Front|Peace|Piracy|Pirates|Pirate|Popular Front for the Liberation of Palestine|Prohibition|Prohibits|Prosecutors|
Prosecutor|Reaffirming|Reaffirms|Real IRA|Recalled|Recalling|Recalls|Recall|Recognising|Recommendations|Recommendation|
Reiterates|Reiterate|Revolutionary Armed Forces of Colombia|Revolutionary Armed Forces of Colombia|
Revolutionary Nuclei|Revolutionary Organization 17 November|Revolutionary People’s Liberation Front|
Revolutionary People’s Liberation Party|Revolutionary Struggle|Salafist Group for Call and Combat|Sayyaf|Segunda Marquetalia|Sendero Luminoso|
Shining Path|Strenghten|Strengthened|Strengthening|Strengthens|Strengthen|Strength|Supported|Supporting|Supports|Support|TTP|Taliban|
Talks|Talk|Tehrik-e Taliban Pakistan|Terrorism|Terrorism|Terrorists|Terrorist|Terror|
Tupac Amaru Revolution Movement|United Self Defense Forces of Colombia|United Self-Defense Forces of Colombia|United Selfdefense Forces of Colombia|
Usama|Violence|Warning|Wavering|Weapons|Weapon|abduct|ablaze|abus|abus|acceptabe|accepted|accepting|accepts|accept|accompanied|accompaning|
accompany|accusation|accusation|accused|accused|accuses|accuses|accuse|accuse|accusing|accusing|acknowledged|acknowledges|acknowledge|acknowledging|acted|acting|
acting|action|acts|acts|act|adequated|adequate|adhered|adheres|adhering|admits|admitted|admitting|adopted|adopt|advancements|
advancement|advances|advance|affected|affecting|affects|against|agent|agreed|agree|aid|airplane|airstrike|al-Ashtar Brigades|al-Mulathamun Battalion|
al-Murabitoun|al-Nusrah Front|al-Qaeda|al-Qaida|al-Qa’ida in Iraq|al-Qa’ida in the Arabian Peninsula|al-Qa’ida in the Indian Subcontinent|
al-Qa’ida in the Islamic Maghreb|al-Qa’ida|al-Shabaab|allowed|allowes|allowing|ambush|ameliorated|ameliorate|ameliorating|ameliorats|appealed|appealing|
appeals|appeal|application|applied|applies|appointed|appointing|appoints|appoint|appreciated|appreciates|appreciate|appreciating|
appreciation|approved|approve|approving|arbitrary|armed|armed|arms|army|arrested|arrest|arrest|ascertained|ascertaining|
ascertains|ascertain|assailants|assailant|assaluring|assaulted|assaulted|assaults|assault|assessed|assesses|assessing|assessment|
assistance|assisted|assisting|assist|assurances|assurance|asylum|attack|attack|attended|attending|attend|attrocities|attrocity|attroc|
auspices|auspice|authorities|authority|banned|banning|banns|ban|barracks|barrack|barricad|baseless|battalion|battle|beaten|beliefs|
belief|believes|believe|beneficial|benefit|blast|blockade|blocked|blocking|blocl|bodies|bodyguards|bodyguard|body|bomb|boosting|
boosts|boos|border crossing|border-crossing|border|boycotted|boycotting|boycotts|boycott|bridged|bridges|bridge|bridging|briefed|brief|brigade|
broadcasting|broadcast|broadening|broadens|broader|broad|brutal|building|burdening|burdens|burden|burial|burn|call|
campaign|capacity-building|captive|carried|carrying|carry|challenges|challenge|challenging|circumvented|circumvent|ckashes|claimed|claim|clash|
cleans|collaborated|collaborate|collaborating|collaboration|combatant|combat|commanders|commander|command|comment|
commissioner|commission|commiting|commitments|commitment|commit|communicate|communications|communication|compatibility|compatible|complaining|
complains|complaints|complaint|complain|completed|complete|compliance|compliant|concerned|concerns|concern|conducted|
conducting|conduct|conflict|conflict|confrontation|confronted|confronting|confronts|confused|confusing|confusion|consultation|consult|contacted|
contacting|contacts|contact|contested|contesting|contest|continuation|continued|continues|continue|continuing|controlled|
controlling|controlls|control|convicted|convicting|convicts|cooperated|cooperate|cooperating|cooperation|coordinated|coordinate|
coordinating|coordination|correctional|corrections|correction|counter piracy|counter-piracy|counterinsurg|counterterror|created|create|
creating|creation|crime|crime|criminaliz|criminal|crisis|
critical|cross-border|cruel|damaged|damages|damage|damaging|dangerous|danger|dead|death|debate|decapitat|decease|decided|decides|
decide|deciding|decision|defendants|defendant|defense|defens|dehumaniz|delegated|delegates|delegate|delegation|demanded|demanding|
demands|demand|democide|demonstrations|demonstration|demonstrators|demonstrator|demoted|demoting|denied|denies|deny|deplor|
deployed|deploying|deployment|deploys|deploy|deported|deport|deprivation|derogatory|deserted|deserting|designate|designed|designing|
design|destroy|destructiondetain|detent|detonations|detonation|developed|developing|develops|develop|dialogue|dialogue|died|
dignifying|dignity|directing|directs|direct|disappearances|disappeared|disappearing|discourages|discourage|discouraging|discriminated|
discriminates|discriminating|discrimination|discriminatory|discrimina|discrim|discuragement|discussed|discussing|discussion|discuss|
disembow|dismantled|dismantles|dismantle|dismantling|dismember|disob|disorder|dispersed|dispersing|displaced|displace|
displac|dispose|disputed|disputes|dispute|disputing|disregarded|disregarding|disregard|distrusted|distrusting|distrust|divergent|diverging|
drawing|drawn|draws|draw|drone|elections|election|embargo|emergency|emphasize|encanced|encouragement|encourages|encourage|
encourage|endorsed|endorsement|endorses|endorse|endorsing|enfoce|enforced|enforcement|enforces|enforce|enforcing|engaged|engagement|
engages|engage|engaging|enhanced|enhances|enhance|enhancing|ensure|escorting|escorts|escort|escroted|ethnic|excluded|excludes|
exclude|excluding|excombat|execute|execution|exempted|exempting|exempt|expanded|expanding|expands|expand|explo|expressed|expressing|
express|extended|extended|extending|extends|extend|extend|extension|extermin|extort|extrajudicial|extremis|fact-finding|failed|
failing|fails|failure|fail|fatalities|fatality|feedback|fight|findings|finding|finds|firearm|fire|fleding|fled|forbiden|forbides|
forbids|forced|forces|force|force|forcing|found|fraudulent|fraud|freedoms|freedom|freeze|freezing|frozen|gender|genocide|granted|
granting|grant|grateful|graves|grave|greater|guarding|guards|guard|gun|gun|hang|harass|harm|headquarters|headquarter|heard|hearing|
hears|honoring|honor|honouring|honour|hostages|hostage|human rights|human right|humanitarian|human|hunger|huring|hurt|ignores|ignore|ignoring|
ill-treat|illegal|illicit|impeded|impede|impede|
impediments|impediment|impeding|implementation|implemented|implemented|implementing|implements|implement|imposed|imposes|impose|imposing|
imprison|improved|improved|improve|improve|improving|impune|impun|inappropiat|incidents|incident|inclination|inclined|inclines|
incompatibility|incompatible|incorporated|incorporate|incorporation|increased|increases|increase|increasingly|increasing|
independently|independent|indiscriminat|inflamatory|inflict|informed|informing|inform|ingored|inhuman|initiated|initiates|initiate|
initiate|initiatives|initiative|injured|injure|injuring|injur|injust|inmate|installations|installation|instructed|instructing|
instructs|insufficiently|insufficient|insurgen|integrated|integrate|integration|integrity|intelligence|intended|intends|intention|
interrogated|interrogates|interrogate|interrogating|interrogation|interrogat|interven|interviewed|interview|intolerance|intolerant|
investigations|investigation|invitation|invited|invites|inviting|involuntary|irricated|irritates|irritating|irritation|justice|keeping|
Janjaweed|janjaweed|keep|kept|kidnapped|kidnapping|kidnap|kill|kill|lacking|lacks|lack|launched|launches|launching|launch|laws|law|leaders|leader|legal|
legal|lethal|letters|letter|licit|lieutenant|looted|looting|loot|lynch|machinegun|manipulated|manipulates|manipulate|manipulating|
manipulation|march|measures|measure|meet with|meeting with|meeting with|meeting|meet|message|met with|met with|militants|militant|militant|
militar|militias|militia|mines|mine|minorities|minority|minorit|misile|missing|missing|
mitigated|mitigates|mitigate|mitigating|mitigation|murder|must|mutilat|mutila|necessary|needed|needs|need|negative|negotiated|
negotiate|negotiations|negotiation|noncombat|nonmilitant|noted|notes|note|notified|notifies|notifying|notify|nuclear|objected|objecting|
objection|objects|obligated|obligates|obligate|obligating|obligations|obligation|oblitages|offensive|offens|officers|officer|
operational|opposed|oppose|opposing|opposition|overcrowd|paramilitary|paramilitar|participated|participates|participate|participating|
participation|peacekeeping|peace|permited|permits|permitting|permit|perpetrated|perpetrates|perpetrating|perpetrators|
perpetrator|personnel|piracy|piracy|piracy|pirates|pirate|pirate|pirat|platoon|pledged|pledges|pledge|police|polic|positive|powerful|
power|power|prepared|prepare|preparing|prepetra|presence|presented|present|prison|problematic|problems|problem|proclamation|
proclamed|proclaming|progress|promoted|promotes|promote|prompting|propelled|proposes|propose|proposing|prosecuted|prosecutes|prosecute|
prosecuting|prosecution|prosecutors|prosecutor|protected|protection|protect|protested|protesting|protest|punish|purge|racket|
radicalization|radicalized|radicalizes|radical|radiological|radlicalizes|raid|raised|raise|ransom|raped|rapes|rape|raping|reaffirming|
ratified|ratifies|ratifying|reaffirms|rebels|rebel|recalles|recalling|recalls|recall|recognising|recognized|recognizes|recognize|
retaliatory|recommendations|recommendation|recommended|recommending|recommends|recommend|reconciliation|reconciliatory|recotnizing|recruited|
recruiting|recruitment|recruit|reduced|reduces|reduce|reducing|referendum|refugees|refugee|refug|rehabilitated|rehabilitates|
rehabilitate|rehabilitating|reiterated|reiterates|reiterate|reiterating|rejecs|rejected|rejecting|rejection|reject|released|release|
reluctantly|reluctant|remained|remains|removal|removed|removes|remove|remove|removing|rendition|repair|reparations|reparations|
reparation|reported|reporting|report|representatives|representative|repress|requested|requesting|requests|request|required|required|
requirements|requirement|requires|require|require|requiring|resisted|resisting|resist|resist|responded|response|restoration|restored|
restores|restore|restoring|restrict|retain|retaliated|retaliate|retaliating|retaliation|retention|reviewed|reviewing|reviews|
review|rhetorics|rhetoric|rifle|riot|risk|rival|rocket|sabotag|safely|safety|sanctions|santion|scar|scepticism|sceptic|security|
segrega|seminars|seminar|sentenced|sentence|settlements|settlement|shared|shares|share|sharing|shoot|shot|should|signed|signing|slave|
smuggl|soldiers|soldier|spy|squads|squad|squad|stab|started|starting|starts|starv|stated|statement|state|strength,|strengthening|
strengthen|strength|stresses|stressing|stress|strike|stronger|strong|strong|struggled|struggles|struggle|struggling|submitted|
submitting|submitts|suffer|sufficiency|sufficiently|sufficient|suggested|suggesting|suggests|suggest|suit|supervised|suppervision|
support|surrender|surrendered|surrendering|surrenders|surrend|surveil|surviv|taken away|taken|talks|talk|tanks|tank|target|terrorism|terrorists|terrorist|terror|
terror|theft|threathening|threathen|threats|threat|tolerance|tolerant|tolerates|tolerate|took away|tools|tool|tortured|tortures|torture|
torturing|trafficking|traffick|trained|training|train|tributes|tribute|troops|
troop|troubled|troublesome|trouble|trouble|troubling|true|trusted|trusting|trusts|trust|truth|unacceptable|unaccepted|undertakes|
undertake|undertaking|undignifying|undisposed|unjustif|unlawful|unrest|unsupervised|untrue|urged|urgent|urge|veiries|veracity|
verification|verified|verify|victimizer|victimizing|victims|victim|violate|violating|violations|violation|violence|violent|violen|visited|
visiting|visits|visit|vulnerable|warned|warnes|warning|warn|war|waterboard|wavering|weapons|weapon|welcomed|welcomes|whereabouts|
whereabout|wiretapped|wiretapping|wiretap|withdrawal|withdrawn|withdraw|withdrew|witnesses|witnessing|witness|women|worked|working|
workshops|workshop|works|work|wounded|wound|rocket|rocketlauncher|rocket launcher|
refurbishment|refurbish|refurbished|refurbishing|ongoing|escalation|escalates|escalated|escalating|
patrol|patrols|patrolling|patrolled|transparent|transparency|accountable|accounted|accountability|
terribly|terrible|events|unprecedented|solidarity|compassionate|compassion|defend|defense|defended|defending|
seized|seizure|seizures|confiscate|confiscated|confiscation|confiscating|seizing|
limit|limiting|limits|limitation|limitations|pressure|pressures|pressing|pressuring|pressured|
facilitate|facilitates|facilitated|facilitating|Selfdefense|selfdefense|vigilante|vigilantes|vigilantism|
return|returned|returns|returning|divided|division|dividing|divides|homeland|Homeland|execute|executing|execution|executed|
Armed|Arms|Conflict|conflicting|conflicted|Tribunal|Tribunals|tribunal|tribunals|jury|Jury|
Amendment|amendment|amended|amends|amending|unreliable|difficult|difficulties|reliable|
helicopter|helicopters|crowd|crows|tear gas|gassed|
contribute|contributes|contributed|contributing|contribution|contributions|troop-contributing|
Humanitarian|setback|setbacks|delay|delays|delayed|delaying|fugitive|fugitives|decree|decrees|ruled|rules|principle|principles|
able|unable|disabled|jurisdiction|Security|Police|Intelligence|Military|Defence|
resettlement|voluntary|mandatory|punish|Punish|Trafficking|Traffic|punishment|punished|punishing|
cooperative|uncooperative|cooperate|uncooperate|enlarge|enlarges|enlarged|enlarging|Explosive|Explosives|landmine|landmines|
allegedly|alleged|repatriated|repatriates|repatriating|repatriation|facilitate|facilitated|facilitates|facilitating|
presumed|presumably|battle|battlefield|battles|compensation|compensated|compensates|compensating|
restitute|restitutes|restituted|restituting|restitution|ballistic|balistic|missile|missiles|Safety|safeguard|safegards|
appropriate|appropriates|appropriated|appropriating|appropriation|appropriations|Referendum|referendum|Plebiscite|plebiscite|
detained|detains|detaining|detainee|detainees|Crisis|surveillance|surveilled|military|militar|Military|Militar|
suspend|suspended|suspends|suspending|suspension|political|Political|affair|Affair|affairs|affairs|
munition|munitions|ammunition|ammunitions|live round|live rounds|deceased|
refuse|refused|refuses|refusing|refusal|
decline|declines|declined|declining|declination|
invasion|invade|invaded|invades|invading|
anexation|anexated|anexating|Palestinian|Palestine|Kosovo|Afghanistan|Iraq|Uganda|Korea|
Rwanda|Kosovo|Sudan|Israel|Kuwait|Bosnia|Sarajevo|
sorrow|pecuniary|penalties|penalty|offence|offences|offending|offended|offensive|defensive|
reaffirm|reaffirms|reaffirmed|reaffirming|reaffirmation|
evacuation|evacuated|evacuates|evacuating|evacuate|guilty|innocent|
devote|devotes|devoted|devoting|inalienable|tension|tensions|tense|tensed|
Release|release|released|releases|releasing|escape|escapes|escaped|escaping|
invasion|invade|invading|invaded|invader|
occupation|occupaying|occupate|occupated|occupator|compensation|compensate|compensates|compensated|compensating|
Criminal|Court|court|Reconnaissance|Battalion|infantry|Infantry|reconnaissance|carjack|carjacked|carjacking|
deferred|deterring|deterres|deterrance|deterrant|sexual|
impute|impunity|poisson|poissoning|poissoned|poissons|
inquired|inquire|inquires|inquiring|inquiry|Brigadier|Congo|Major|gratitude|unquestionably|questionably|
unquestionable|questionable|destruction|CWPF|CWPFs|regret|regrets|regreted|regrettable|regretting|
renew|renewed|renews|achieve|achieves|achieved|
advise|advised|advises|advising|advice|shelter|shelling|fleeing|flee|poppy|opium|opiouds|dramatic|
returnees|returnee|weak|weakened|weakens|weakening|promotion|promoted|promoting|promotes|robbed|robbing|robbery|
stalemate|confiscating|confiscate|confiscates|confiscated|confiscating|
mass destruction|massive destruction|disarming|disarmed|desarmes|disarmed|disarmament|
supervision|supervise|supervised|supervising|
relocate|relocates|relocated|relocating|relocation|eviction|evicted|evicting|
extradition|extradited|extraditing|extradite|
compromise|compromises|compromised|compromising
')) %>%
  filter(exclude=="FALSE") %>%
  filter(id %in% sample(unique(id),5000)) %>%
  select(c("id","ar","en","es","row.num")) 
  
head(data.select.notrelevant.sample$en)
#

# Add Relevant column
data.select.notrelevant.sample <- data.select.notrelevant.sample %>%
  mutate(Relevant=0)%>%
  select(c("id","ar","en","es","Relevant")) 
names(data.select.notrelevant.sample)

# Export data 
write.csv(data.select.notrelevant.sample,"annotations/data/not_relevant.csv", row.names=FALSE)
write.table(data.select.notrelevant.sample, file='annotations/data/not_relevant.tsv', quote=FALSE, sep='\t', row.names=FALSE)






# # SELECT SAMPLES  --------------------------------------------------


# # Proportion 3/4 relevant &  1/4 not relevant
# Not using this one
# 
# data.1  <- as.data.frame(rbind(data.select.relevant[1:150,],data.select.notrelevant[1:50,]))  %>% arrange(row.num)
# data.2  <- as.data.frame(rbind(data.select.relevant[151:300,],data.select.notrelevant[51:100,]))  %>% arrange(row.num)
# data.3  <- as.data.frame(rbind(data.select.relevant[301:450,],data.select.notrelevant[101:150,]))  %>% arrange(row.num)
# data.4  <- as.data.frame(rbind(data.select.relevant[451:600,],data.select.notrelevant[151:200,]))  %>% arrange(row.num)
# data.5  <- as.data.frame(rbind(data.select.relevant[601:750,],data.select.notrelevant[201:250,]))  %>% arrange(row.num)
# data.6  <- as.data.frame(rbind(data.select.relevant[751:900,],data.select.notrelevant[251:300,]))  %>% arrange(row.num)
# data.7  <- as.data.frame(rbind(data.select.relevant[901:1050,],data.select.notrelevant[301:350,]))  %>% arrange(row.num)
# data.8  <- as.data.frame(rbind(data.select.relevant[1051:1200,],data.select.notrelevant[351:400,]))  %>% arrange(row.num)
# data.9  <- as.data.frame(rbind(data.select.relevant[1201:1350,],data.select.notrelevant[401:450,]))  %>% arrange(row.num)
# data.10  <- as.data.frame(rbind(data.select.relevant[1351:1500,],data.select.notrelevant[451:500,]))  %>% arrange(row.num)
# data.11  <- as.data.frame(rbind(data.select.relevant[1501:1650,],data.select.notrelevant[501:550,]))  %>% arrange(row.num)
# data.12  <- as.data.frame(rbind(data.select.relevant[1651:1800,],data.select.notrelevant[551:600,]))  %>% arrange(row.num)
# data.13  <- as.data.frame(rbind(data.select.relevant[1801:1950,],data.select.notrelevant[601:650,]))  %>% arrange(row.num)
# data.14  <- as.data.frame(rbind(data.select.relevant[1951:2100,],data.select.notrelevant[651:700,]))  %>% arrange(row.num)
# data.15  <- as.data.frame(rbind(data.select.relevant[2101:2250,],data.select.notrelevant[701:750,]))  %>% arrange(row.num)
# 


# Generate 30 datasets
data.1 <- as.data.frame(data.select.relevant[1:400,]) 
data.2 <- as.data.frame(data.select.relevant[401:800,]) 
data.3 <- as.data.frame(data.select.relevant[801:1200,]) 
data.4 <- as.data.frame(data.select.relevant[1201:1600,]) 
data.5 <- as.data.frame(data.select.relevant[1601:2000,]) 
data.6 <- as.data.frame(data.select.relevant[2001:2400,]) 
data.7 <- as.data.frame(data.select.relevant[2401:2800,]) 
data.8 <- as.data.frame(data.select.relevant[2801:3200,]) 
data.9 <- as.data.frame(data.select.relevant[3201:3600,]) 
data.10 <- as.data.frame(data.select.relevant[3601:4000,]) 
data.11 <- as.data.frame(data.select.relevant[4001:4400,]) 
data.12 <- as.data.frame(data.select.relevant[4401:4800,]) 
data.13 <- as.data.frame(data.select.relevant[4801:5200,]) 
data.14 <- as.data.frame(data.select.relevant[5201:5600,]) 
data.15 <- as.data.frame(data.select.relevant[5601:6000,])
data.16 <- as.data.frame(data.select.relevant[6001:6400,]) 
data.17 <- as.data.frame(data.select.relevant[6401:6800,]) 
data.18 <- as.data.frame(data.select.relevant[6801:7200,]) 
data.19 <- as.data.frame(data.select.relevant[7201:7600,]) 
data.20 <- as.data.frame(data.select.relevant[7601:8000,]) 
data.21 <- as.data.frame(data.select.relevant[8001:8400,]) 
data.22 <- as.data.frame(data.select.relevant[8401:8800,]) 
data.23 <- as.data.frame(data.select.relevant[8801:9200,]) 
data.24 <- as.data.frame(data.select.relevant[9201:9600,])
data.25 <- as.data.frame(data.select.relevant[9601:10000,])
data.26 <- as.data.frame(data.select.relevant[10001:10400,]) 
data.27 <- as.data.frame(data.select.relevant[10401:10800,])
data.28 <- as.data.frame(data.select.relevant[10801:11200,]) 
data.29 <- as.data.frame(data.select.relevant[11201:11600,]) 
data.30 <- as.data.frame(data.select.relevant[11601:12000,])



# Export
write.csv(data.1,"annotations/data/data_1.csv", row.names=FALSE)
write.csv(data.2,"annotations/data/data_2.csv", row.names=FALSE)
write.csv(data.3,"annotations/data/data_3.csv", row.names=FALSE)
write.csv(data.4,"annotations/data/data_4.csv", row.names=FALSE)
write.csv(data.5,"annotations/data/data_5.csv", row.names=FALSE)
write.csv(data.6,"annotations/data/data_6.csv", row.names=FALSE)
write.csv(data.7,"annotations/data/data_7.csv", row.names=FALSE)
write.csv(data.8,"annotations/data/data_8.csv", row.names=FALSE)
write.csv(data.9,"annotations/data/data_9.csv", row.names=FALSE)
write.csv(data.10,"annotations/data/data_10.csv", row.names=FALSE)
write.csv(data.11,"annotations/data/data_11.csv", row.names=FALSE)
write.csv(data.12,"annotations/data/data_12.csv", row.names=FALSE)
write.csv(data.13,"annotations/data/data_13.csv", row.names=FALSE)
write.csv(data.14,"annotations/data/data_14.csv", row.names=FALSE)
write.csv(data.15,"annotations/data/data_15.csv", row.names=FALSE)
write.csv(data.16,"annotations/data/data_16.csv", row.names=FALSE)
write.csv(data.17,"annotations/data/data_17.csv", row.names=FALSE)
write.csv(data.18,"annotations/data/data_18.csv", row.names=FALSE)
write.csv(data.19,"annotations/data/data_19.csv", row.names=FALSE)
write.csv(data.20,"annotations/data/data_20.csv", row.names=FALSE)
write.csv(data.21,"annotations/data/data_21.csv", row.names=FALSE)
write.csv(data.22,"annotations/data/data_22.csv", row.names=FALSE)
write.csv(data.23,"annotations/data/data_23.csv", row.names=FALSE)
write.csv(data.24,"annotations/data/data_24.csv", row.names=FALSE)
write.csv(data.25,"annotations/data/data_25.csv", row.names=FALSE)
write.csv(data.26,"annotations/data/data_26.csv", row.names=FALSE)
write.csv(data.27,"annotations/data/data_27.csv", row.names=FALSE)
write.csv(data.28,"annotations/data/data_28.csv", row.names=FALSE)
write.csv(data.29,"annotations/data/data_29.csv", row.names=FALSE)
write.csv(data.30,"annotations/data/data_30.csv", row.names=FALSE)



# 
# # SPLIT SAMPLES AR/SP  --------------------------------------------------
# 
# # Generate Arabic datasets
# 
# data.ar.1 <-data.1 %>% select(-es)
# data.ar.2 <-data.2 %>% select(-es)
# data.ar.3 <-data.3 %>% select(-es)
# data.ar.4 <-data.4 %>% select(-es)
# data.ar.5 <-data.5 %>% select(-es)
# data.ar.6 <-data.6 %>% select(-es)
# data.ar.7 <-data.7 %>% select(-es)
# data.ar.8 <-data.8 %>% select(-es)
# data.ar.9 <-data.9 %>% select(-es)
# data.ar.10 <-data.10 %>% select(-es)
# data.ar.11 <-data.11 %>% select(-es)
# data.ar.12 <-data.12 %>% select(-es)
# data.ar.13 <-data.13 %>% select(-es)
# data.ar.14 <-data.14 %>% select(-es)
# data.ar.15 <-data.15 %>% select(-es)
# 
# 
# write.csv(data.ar.1,"annotations/data/data_ar_1.csv", row.names=FALSE)
# write.csv(data.ar.2,"annotations/data/data_ar_2.csv", row.names=FALSE)
# write.csv(data.ar.3,"annotations/data/data_ar_3.csv", row.names=FALSE)
# write.csv(data.ar.4,"annotations/data/data_ar_4.csv", row.names=FALSE)
# write.csv(data.ar.5,"annotations/data/data_ar_5.csv", row.names=FALSE)
# write.csv(data.ar.6,"annotations/data/data_ar_6.csv", row.names=FALSE)
# write.csv(data.ar.7,"annotations/data/data_ar_7.csv", row.names=FALSE)
# write.csv(data.ar.8,"annotations/data/data_ar_8.csv", row.names=FALSE)
# write.csv(data.ar.9,"annotations/data/data_ar_9.csv", row.names=FALSE)
# write.csv(data.ar.10,"annotations/data/data_ar_10.csv", row.names=FALSE)
# write.csv(data.ar.11,"annotations/data/data_ar_11.csv", row.names=FALSE)
# write.csv(data.ar.12,"annotations/data/data_ar_12.csv", row.names=FALSE)
# write.csv(data.ar.13,"annotations/data/data_ar_13.csv", row.names=FALSE)
# write.csv(data.ar.14,"annotations/data/data_ar_14.csv", row.names=FALSE)
# write.csv(data.ar.15,"annotations/data/data_ar_15.csv", row.names=FALSE)
# 
# 
# 
# # Generate Spanish datasets
# 
# data.sp.1 <-data.1 %>% select(-ar)
# data.sp.2 <-data.2 %>% select(-ar)
# data.sp.3 <-data.3 %>% select(-ar)
# data.sp.4 <-data.4 %>% select(-ar)
# data.sp.5 <-data.5 %>% select(-ar)
# data.sp.6 <-data.6 %>% select(-ar)
# data.sp.7 <-data.7 %>% select(-ar)
# data.sp.8 <-data.8 %>% select(-ar)
# data.sp.9 <-data.9 %>% select(-ar)
# data.sp.10 <-data.10 %>% select(-ar)
# data.sp.11 <-data.11 %>% select(-ar)
# data.sp.12 <-data.12 %>% select(-ar)
# data.sp.13 <-data.13 %>% select(-ar)
# data.sp.14 <-data.14 %>% select(-ar)
# data.sp.15 <-data.15 %>% select(-ar)
# 
# 
# write.csv(data.sp.1,"annotations/data/data_sp_1.csv", row.names=FALSE)
# write.csv(data.sp.2,"annotations/data/data_sp_2.csv", row.names=FALSE)
# write.csv(data.sp.3,"annotations/data/data_sp_3.csv", row.names=FALSE)
# write.csv(data.sp.4,"annotations/data/data_sp_4.csv", row.names=FALSE)
# write.csv(data.sp.5,"annotations/data/data_sp_5.csv", row.names=FALSE)
# write.csv(data.sp.6,"annotations/data/data_sp_6.csv", row.names=FALSE)
# write.csv(data.sp.7,"annotations/data/data_sp_7.csv", row.names=FALSE)
# write.csv(data.sp.8,"annotations/data/data_sp_8.csv", row.names=FALSE)
# write.csv(data.sp.9,"annotations/data/data_sp_9.csv", row.names=FALSE)
# write.csv(data.sp.10,"annotations/data/data_sp_10.csv", row.names=FALSE)
# write.csv(data.sp.11,"annotations/data/data_sp_11.csv", row.names=FALSE)
# write.csv(data.sp.12,"annotations/data/data_sp_12.csv", row.names=FALSE)
# write.csv(data.sp.13,"annotations/data/data_sp_13.csv", row.names=FALSE)
# write.csv(data.sp.14,"annotations/data/data_sp_14.csv", row.names=FALSE)
# write.csv(data.sp.15,"annotations/data/data_sp_15.csv", row.names=FALSE)
# 
# 


# End of script