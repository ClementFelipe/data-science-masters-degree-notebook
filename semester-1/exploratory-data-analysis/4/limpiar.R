# cleaning and transformation process

lt_house <- function(houses)
{
  colnames(houses)<- tolower(colnames(houses))
  houses$mssubclass <- factor(houses$mssubclas)
  houses$mszoning <- factor(houses$mszoning)
  houses$street <-factor(houses$street)
  houses$alley <-factor(houses$alley, levels=c("NA","Pave", "Grvl"))
  houses$lotshape <- factor(houses$lotshape, levels=c("IR3","IR2","IR1","Reg"), ordered=TRUE)
  houses$landcontour <- factor(houses$landcontour)
  houses$utilities <- factor(houses$utilities)
  houses$lotconfig <- factor(houses$lotconfig)
  houses$landslope <- factor(houses$landslope)
  houses$neighborhood <-factor(houses$neighborhood)
  houses$condition1 <- factor(houses$condition1)
  houses$condition2 <- factor(houses$condition2)
  houses$bldgtype <-factor(houses$bldgtype)
  houses$housestyle <- factor(houses$housestyle)
  houses$overallqual <- factor(houses$overallqual, levels=c(1,2,3,4,5,6,7,8,9,10), ordered=TRUE)
  houses$overallcond <- factor(houses$overallcond, levels=c(1,2,3,4,5,6,7,8,9,10), ordered=TRUE)
  #houses$yearbuilt <- as.character(houses$yearbuilt)
  #houses$yearremodadd <- as.character(houses$yearremodadd)
  houses$yrsold <- as.character(houses$yrsold)
  houses$mosold <- as.character(houses$mosold)
  houses$roofstyle <- factor(houses$roofstyle)
  houses$roofmatl <- factor(houses$roofmatl)
  houses$exterior1st <- factor(houses$exterior1st)
  houses$exterior2nd <- factor(houses$exterior2nd)
  houses$masvnrtype <- factor(houses$masvnrtype)
  houses$exterqual <- factor(houses$exterqual, levels=c("Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$extercond <- factor(houses$extercond, levels=c("Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$foundation <- factor(houses$foundation)
  houses$bsmtqual <- factor(houses$extercond, levels=c("NA", "Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$bsmtcond <- factor(houses$bsmtcond, levels=c("NA", "Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$bsmtexposure <- factor(houses$bsmtexposure, levels=c("NA", "No","Mn","Av","Gd"), ordered=TRUE)
  houses$bsmtfintype1 <- factor(houses$bsmtfintype1, levels=c("NA","Unf","LwQ","Rec", "BLQ", "ALQ", "GLQ"), ordered=TRUE)
  houses$bsmtfintype2 <- factor(houses$bsmtfintype2, levels=c("NA","Unf","LwQ","Rec", "BLQ", "ALQ", "GLQ"), ordered=TRUE)
  houses$heating <- factor(houses$heating)
  houses$heatingqc <- factor(houses$heatingqc, levels=c("Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$centralair <- factor(houses$centralair, levels=c("N", "Y"))
  houses$electrical <- factor(houses$electrical, levels=c("Mix", "FuseP", "FuseF", "FuseA", "SBrkr"))
  houses$kitchenqual <- factor(houses$kitchenqual, levels=c("Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$functional <- factor(houses$functional)
  houses$fireplacequ <- factor(houses$fireplacequ, levels=c("NA","Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$garagetype <- factor(houses$garagetype, levels=c("NA", "Detchd", "CarPort", "BuiltIn", "Basment", "Attchd", "2Types"))
  houses$garagefinish <- factor(houses$garagefinish, levels=c("NA", "Unf", "RFn", "Fin"))
  houses$garagequal <- factor(houses$fireplacequ, levels=c("NA","Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$garagecond <- factor(houses$garagecond, levels=c("NA","Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$paveddrive <- factor(houses$paveddrive)
  houses$poolqc <- factor(houses$poolqc, levels=c("NA","Po","Fa","TA","Gd", "Ex"), ordered=TRUE)
  houses$fence <- factor(houses$fence, levels=c("NA","MnWw","GdWo","MnPrv","GdPrv"), ordered=TRUE, exclude = "")
  houses$miscfeature <- factor(houses$miscfeature, levels=c("NA", "TenC", "Shed", "Othr", "Gar2", "Elev"))
  houses$saletype <- factor(houses$saletype)
  houses$salecondition <- factor(houses$salecondition)
  houses$garageyrblt <- as.character(houses$garageyrblt)
  
  # years
  houses$yearbuilt <- as.Date(paste0(houses$yearbuilt, '-01-01'))
  houses$yearremodadd <- as.Date(paste0(houses$yearremodadd, '-01-01'))
  
  # diapositiva 23
  houses$datesold <- as.POSIXct(paste0(houses$yrsold,"-", houses$mosold, "-01"), format="%Y-%m-%d")
  
  
  houses <- houses %>% 
    filter(!is.na(lotfrontage)) %>%
    filter(!is.na(masvnrarea)) %>%
    filter(!is.na(electrical)) %>%
    filter(!is.na(garageyrblt))

  houses[is.na(houses$poolqc),]$poolqc <- "NA"
  levels(houses$poolqc)
  houses[is.na(houses$alley),]$alley <- "NA"
  #houses[is.na(houses$bsmtqual),]$bsmtqual <- "NA"
  houses[is.na(houses$bsmtcond),]$bsmtcond <- "NA"
  houses[is.na(houses$bsmtexposure),]$bsmtexposure <- "NA"
  houses[is.na(houses$bsmtfintype1),]$bsmtfintype1 <- "NA"
  houses[is.na(houses$bsmtfintype2),]$bsmtfintype2 <- "NA"
  #houses[is.na(houses$garagetype),]$garagetype <- "NA"
  #houses[is.na(houses$garagefinish),]$garagefinish <- "NA"
  houses[is.na(houses$garagequal),]$garagequal <- "NA"
  #houses[is.na(houses$garagecond),]$garagecond <- "NA"
  houses[is.na(houses$fence),]$fence <- "NA"
  houses[is.na(houses$miscfeature),]$miscfeature <- "NA"
  houses[is.na(houses$fireplacequ),]$fireplacequ <- "NA"
  
  
  houses
}