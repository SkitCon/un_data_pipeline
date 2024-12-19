#####################################################################
# UN Multilingual Corpus
# Select annotationss
# Javier Osorio and Amber Converse
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
  arrange(random) %>%
  select(-random)

# Label topic
data.select <- data.select %>%
  mutate(topic = case_when(
    human.rights=="TRUE" ~ "Human Rights",
    protect.civilians=="TRUE" ~ "Protect Civilians", 
    terrorism=="TRUE" ~ "Terrorism"
  ))






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

data.most_relevant <- data.select %>% 
  filter(human.rights=="TRUE" | protect.civilians=="TRUE"| terrorism=="TRUE")
  
data.select <- data.select %>%
  select(-c(human.rights,protect.civilians,terrorism))

data.most_relevant <- data.most_relevant %>%
  select(-c(human.rights,protect.civilians,terrorism))
  
# Report number of relevant
table(data.select$humanrights)

data.1 = as.data.frame(data.select[1:100000,])
data.2 = as.data.frame(data.select[100001:200000,])
data.3 = as.data.frame(data.select[200001:300000,])
data.4 = as.data.frame(data.select[300001:400000,])
data.5 = as.data.frame(data.select[500001:500000,])

write.csv(data.1, "data/new_sentences/new_sentences_1.csv")
write.csv(data.2, "data/new_sentences/new_sentences_2.csv")
write.csv(data.3, "data/new_sentences/new_sentences_3.csv")
write.csv(data.4, "data/new_sentences/new_sentences_4.csv")
write.csv(data.5, "data/new_sentences/new_sentences_5.csv")

write.csv(data.most_relevant, "data/new_sentences/most_relevant.csv")

