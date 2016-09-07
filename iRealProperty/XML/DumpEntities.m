<irealpropertySearch>
 
    <SearchGroup title="Common">
        <!-- SearchDefinition marks the beginning of the search -->
        <SearchDefinition title="By Parcel" mode="ByParcel">
            <query entity="RealPropInfo" sortby="parcelNbr" ascending="yes" predicate="parcelNbr IN %@" grid="GridSearchResultForPI" root="RealPropInfo"/>
        </SearchDefinition>
        <SearchDefinition title="By Street" mode="ByStreet">
            <query entity="RealPropInfo" sortby="streetNbr" ascending="yes" predicate="streetId=%d" grid="GridSearchResultForPI"  root="RealPropInfo"/>     
        </SearchDefinition>
        <SearchDefinition  title="Taxpayers Name" description="Enter the name (or a partial name) of the taxpayers">
            <SearchItem reference="$name" title="Names" maxchar="15" required="yes"  help="Help on names. It can be a very long help to describe this item or others" default="" />
            <SearchItem reference="$sqftlot" title="Lot Sq Ft" maxchar="7"  filter="num"/>
            <query entity="Account" sortby="acct" root="RealPropInfo" predicate="acct CONTAINS[c] $name AND realPropInfo.land.sqFtLot >= $sqftlot" grid="GridSearchResultForPI"/>
        </SearchDefinition>
	<SearchDefinition title="Major" description="Lists Pcls in a Major Number (Plat)" defaultmap="yes">
            <SearchItem reference="$major" title="Major" maxchar="6" required="yes"  help="Enter 6-digit major number" default="" />
            <query entity="RealPropInfo" root="RealPropInfo" sortby="parcelNbr" ascending="yes" predicate="major = $major" grid="GridSearchResultForPI"/>
	</SearchDefinition>
	<SearchDefinition title="SubArea" description="Lists Pcls in a ResSubArea" defaultmap="yes">
            <SearchItem reference="$resSubArea" title="SubArea" maxchar="3" required="yes"  help="Enter ResSubArea" default="" />
            <query entity="RealPropInfo" root="RealPropInfo" sortby="parcelNbr" ascending="yes" predicate="resSubArea CONTAINS[c] $resSubArea" grid="GridSearchResultForPI"/>
	</SearchDefinition>
	<SearchDefinition title="Folio" description="Lists Pcls in a Folio" defaultmap="yes">
            <SearchItem reference="$folio" title="Folio" maxchar="7" required="yes"  help="Enter 7-digit Folio" default="" />
            <query entity="RealPropInfo" root="RealPropInfo" sortby="parcelNbr" ascending="yes" predicate="folio CONTAINS[c] $folio" grid="GridSearchResultForPI"/>
	</SearchDefinition>	
        <SearchDefinition title="Mobile home" description="search for mobile home" >
            <query entity="MHAccount" sortby="mobileHomeId" root="realPropInfo" predicate="mobileHomeId!=0" grid="GridSearchResultWithName"/>
        </SearchDefinition>
	
    </SearchGroup>	

    <SearchGroup title="Phys Inspect">
	<SearchDefinition title="All Parcels" description="Lists All Pcls" defaultmap="yes">
            <query entity="RealPropInfo" root="RealPropInfo" sortby="parcelNbr" ascending="yes" predicate="realPropId > 0" grid="GridSearchResultForPI"/>
	</SearchDefinition>
<!--	TODO, Want < 3, but even = 0 does not work for this one.  Mesa SQL shows 0 and 3 values for inspectionTypeItemId  in my database-->
	<SearchDefinition title="Need Phys Inspect" description="Lists pcls needing physical inspection">
             <query entity="RealPropInfo" root="RealPropInfo" sortby="parcelNbr" ascending="yes" predicate="inspection.inspectionTypeItemId = 0" grid="GridSearchResultForPI" />
	</SearchDefinition>
<!--	THIS WORKS JUST FINE WITH = 3-->
	<SearchDefinition title="Phys Inspect Complete" description="Lists pcls where physical inspection is complete">
            <query entity="RealPropInfo" root="RealPropInfo" sortby="parcelNbr" ascending="yes" predicate="inspection.inspectionTypeItemId = 3" grid="GridSearchResultForPI" />   
	</SearchDefinition>	
    </SearchGroup>
    
		 

    <SearchGroup title="Sales">
        <SearchDefinition title="All Sales" description="Search for All Sales">
        <SearchItem reference="$Date" default="1/1/2010" title="minimum sale date" required="yes" filter="date" />
            <query entity="Sale" root="realPropInfo" sortby="saleDate" predicate="salePrice > 0 AND saleDate > $Date" grid="GridSearchResultWithSalesAndBldgs"/>
        </SearchDefinition>
        <SearchDefinition title="Unverified Sales" description="Search for Unverified Sales">
            <SearchItem reference="$Date" default="1/1/2010" title="minimum sale date" required="yes" filter="date" />
            <query entity="Sale" root="realPropInfo" sortby="saleDate" predicate="salePrice > 0 AND saleDate > $Date AND vYVerifiedAtMarket = 0" grid="GridSearchResultWithSalesAndBldgs"/>
        </SearchDefinition>
        <SearchDefinition title="Verified Sales" description="Search for Unverified Sales">
            <SearchItem reference="$Date" default="1/1/2010" title="minimum sale date" required="yes" filter="date" />
            <query entity="Sale" root="realPropInfo" sortby="saleDate" predicate="salePrice > 0 AND saleDate > $Date AND vYVerifiedAtMarket = 1" grid="GridSearchResultWithSalesAndBldgs"/>
        </SearchDefinition>
    </SearchGroup>



    <SearchGroup title="Maint">
	<SearchDefinition title="Compl and Incompl Maint" description="Permits And Segs">
            <SearchItem reference="$permitVal" default="0" title="minimum permit value" required="yes" filter="num" />
	    <query  entity="Permit" root="realPropInfo" sortby="permitVal" ascending="yes" predicate="permitVal >= $permitVal" grid="GridSearchResultWithSegsAndPermits"/>
	    <joinquery entity="ChngHist" root="realPropInfo" sortby="type" predicate="type='Seg Merge' or type='New Plat'" />
	</SearchDefinition>
	<SearchDefinition title="Incompl Maint" description="Permits And Segs">
            <SearchItem reference="$permitVal" default="0" title="minimum permit value" required="yes" filter="num" />
	    <query  entity="Permit" root="realPropInfo" sortby="permitVal" ascending="yes" predicate="permitStatus=0 AND permitVal >= $permitVal" grid="GridSearchResultWithSegsAndPermits"/>
	    <joinquery entity="ChngHist" root="realPropInfo" sortby="type" predicate="PropStatus = 0" />
	</SearchDefinition>
	<SearchDefinition title="Compl Maint" description="Permits And Segs">
            <SearchItem reference="$permitVal" default="0" title="minimum permit value" required="yes" filter="num" />
	    <query  entity="Permit" root="realPropInfo" sortby="permitVal" ascending="yes" predicate="permitStatus>0 AND permitVal >= $permitVal" grid="GridSearchResultWithSegsAndPermits"/>
	    <joinquery entity="ChngHist" root="realPropInfo" sortby="type" predicate="(type='Seg Merge' or type='New Plat') and PropStatus > 0" />
	</SearchDefinition>
	
	
	
	
    <!--<SearchDefinition title="Incomplete Permits" description="Search for Incomplete Permits">
            <SearchItem reference="$permitVal" default="0" title="minimum permit value" required="yes" filter="num" />
            <SearchItem reference="$permitStatus" default="1" title="permit status" required="yes" filter="num" />
            <query entity="Permit" root="RealPropInfo" sortby="realPropInfo.parcelNbr" ascending="yes" predicate="permitStatus = 1  AND permitVal >= $permitVal" grid="GridSearchResultForPermits" />
        </SearchDefinition>-->
	 

    </SearchGroup>
    
    



    
        <!-- DEFAULT SEARCH FROM THE MAP -->
    <GridDefinition name="GridDefaultFromMap" tag="40" height="30" auto="yes">
        <col label=".landId" width="80" path="realPropInfo.landlandId" />
        <col label=".Account" width="250" path="realPropInfo.Account.acct" />
        <col label=".Address" width="80" path="realPropInfo.streetNbr" />
        <col label=".Street " width="120" path="realPropInfo.street" />
        <col label=".Zip" width="100" path="realPropInfo.zipCode" />
        <col label=".City" width="120" path="realPropInfo.city" />
        <col label=".PT" width="50" path="realPropInfo.propType" />
        <col label=".Major" width="80" path="realPropInfo.major" />
        <col label=".Minor" width="60" path="realPropInfo.minor" />
        <col label=".Area" width="60" path="realPropInfo.resArea" />
        <col label=".Sub" width="60" path="realPropInfo.resSubArea" />
        <col label=".QSTR" width="60" path="realPropInfo.quarterSection" />
        <col label=".Section" width="60" path="realPropInfo.section" />
        <col label=".Township" width="60" path="realPropInfo.township" />
        <col label=".Range" width="60" path="realPropInfo.range" />
        <col label=".Levy" width="60" path="realPropInfo.levyCode" />
        <col label=".Block" width="60" path="realPropInfo.platBlock" />
        <col label=".Lot" width="60" path="realPropInfo.platLot" />
    </GridDefinition>
    
    <!-- GridSearchResultWithName: result of the search -->
    <GridDefinition name="GridSearchResultWithName" tag="40" height="30" auto="yes">
        <col label=".landId" width="80" path="realPropInfo.landlandId" />
        <col label=".Account" width="250" path="realPropInfo.Account.acct" />
        <col label=".Address" width="80" path="realPropInfo.streetNbr" />
        <col label=".Street " width="120" path="realPropInfo.street" />
        <col label=".Zip" width="100" path="realPropInfo.zipCode" />
        <col label=".City" width="120" path="realPropInfo.city" />
        <col label=".PT" width="50" path="realPropInfo.propType" />
        <col label=".Major" width="80" path="realPropInfo.major" />
        <col label=".Minor" width="60" path="realPropInfo.minor" />
        <col label=".Area" width="60" path="realPropInfo.resArea" />
        <col label=".Sub" width="60" path="realPropInfo.resSubArea" />
        <col label=".QSTR" width="60" path="realPropInfo.quarterSection" />
        <col label=".Section" width="60" path="realPropInfo.section" />
        <col label=".Township" width="60" path="realPropInfo.township" />
        <col label=".Range" width="60" path="realPropInfo.range" />
        <col label=".Levy" width="60" path="realPropInfo.levyCode" />
        <col label=".Block" width="60" path="realPropInfo.platBlock" />
        <col label=".Lot" width="60" path="realPropInfo.platLot" />
    </GridDefinition>

    <GridDefinition name="GridSearchResultWithParcel" tag="40" height="30" auto="yes">
        <col label="land.landId" width="80" path="realPropInfo.land.landId" />
        <col label=".Account" width="80" path="realPropInfo.account.acct" />
        <col label=".Major" width="80" path="realPropInfo.major" />
        <col label=".Minor" width="60" path="realPropInfo.minor" />
        <col label=".Address" width="80" path="realPropInfo.streetNbr" />
        <col label=".Street " width="120" path="realPropInfo.street" />
        <col label=".Zip" width="100" path="realPropInfo.zipCode" />
        <col label=".city" width="120" path="realPropInfo.city" />
    </GridDefinition>
    
    <GridDefinition name="GridSearchResultForStreet" tag="40" height="30" auto="yes">
        <col label=".Account" width="80" path="realPropInfo.account.acct" />
        <col label=".Address" width="80" path="realPropInfo.streetNbr" />
        <col label=".Street " width="120" path="realPropInfo.street" />
        <col label=".Zip" width="100" path="realPropInfo.zipCode" />
        <col label=".City" width="120" path="realPropInfo.city" />
    </GridDefinition>


     <GridDefinition name="GridSearchResultForPI" tag="40" height="90"  auto="yes"  >  
	<col label="ParcelNbr" width="140" path="realPropInfo.parcelNbr" />
        <col label="Major" width="80" path="realPropInfo.major" />
        <col label="Minor" width="80" path="realPropInfo.minor" />
        <col label="Address" width="80" path="realPropInfo.streetNbr" />
        <col label="Street " width="140" path="realPropInfo.street" />
        <col label="Zip" width="100" path="realPropInfo.zipCode" />
        <col label="City" width="120" path="realPropInfo.city" />
        <col label="SubArea" width="120" path="realPropInfo.resSubArea" />
        <col label="Folio" width="120" path="realPropInfo.folio" />
        <col label="Account" width="250" path="realPropInfo.Account.acct" />
        <col label="UnverSaleCount" width="100" path="realPropInfo.sale[$salePrice > 0 AND $vYVerifiedAtMarket = 0].@count" type="INT"/>	
        <col label="SegOrPlat" width="120" path="realPropInfo.chngHist[($type='Seg Merge' or $type='New Plat' or $type='Unkill') AND $propStatus=1].@count" type="INT"/>
        <col label="IncomplPermit" width="80" path="realPropInfo.permit[$permitStatus=1].@count"  type="INT"/>
        <col label="LandInspect" width="80" path="realPropInfo.inspection[$inspectionTypeItemId=1.@count"  type="INT"/>
        <col label="ImpsInspect" width="80" path="realPropInfo.inspection[$inspectionTypeItemId=2.@count"  type="INT"/>
        <col label="BothInspect" width="80" path="realPropInfo.inspection[$inspectionTypeItemId=3.@count"  type="INT"/>
<!--        <col label="LandInspect" width="80" path="realPropInfo.header.inspection[$inspectionTypeItemId=1.@count"  type="INT"/>
        <col label="ImpsInspect" width="80" path="realPropInfo.header.inspection[$inspectionTypeItemId=2.@count"  type="INT"/>
        <col label="BothInspect" width="80" path="realPropInfo.header.inspection[$inspectionTypeItemId=3.@count"-->  type="INT"/>
        <col label="IncomplBLV" width="80" path="realPropInfo.land[$baseLandValTaxYr=2013].@count"  type="INT"/>
        <col label="IncomplTotVal" width="80" path="realPropInfo.applHist[$rollYr=2013].@count"  type="INT"/>
        <col label="Accy Count" width="90" path="realPropInfo.accy.@count" type= "INT" />
        <col label="ResBldg Count" width="90" path="realPropInfo.land.resBldg.@count" type= "INT" />
        <col label="BldgGrade" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].bldgGrade" type= "INT" />
        <col label="YrBuilt" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].yrBuilt" type= "INT" />	
        <col label="YrRenovated" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].yrRenovated" type= "INT" />	
        <col label="Condition" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].condition" type= "INT" />
        <col label="Stories" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].stories" type= "INT" />	
        <col label="SqFtTotLiving" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtTotLiving" type= "INT" />
        <col label="SqFt1stFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFt1stFloor" type= "INT" />	
        <col label="SqFtHalfFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtHalfFloor" type= "INT" />
	<col label="SqFt2ndFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFt2ndFloor" type= "INT" />
        <col label="SqFtUpperFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtUpperFloor" type= "INT" />
        <col label="SqFtFinBasement" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtFinBasement" type= "INT" />		
        <col label="SqFtTotBasement" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtTotBasement" type= "INT" />
        <col label="Bedrooms" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].bedrooms" type= "INT" />
        <col label="NbrLivingUnits" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].nbrLivingUnits" type= "INT" />
    </GridDefinition>


    
    
    <GridDefinition name="GridSearchResultWithSalesAndBldgs" tag="40" height="30" auto="yes">
	<col label="ParcelNbr" width="140" path="realPropInfo.parcelNbr" />
        <col label="Major" width="80" path="realPropInfo.major" />
        <col label="Minor" width="80" path="realPropInfo.minor" />
<!--        <col label="PT" width="50" path="realPropInfo.propType" />-->
        <col label="Address" width="80" path="realPropInfo.streetNbr" />
        <col label="Street " width="140" path="realPropInfo.street" />
        <col label="Zip" width="80" path="realPropInfo.zipCode" />
        <col label="City" width="120" path="realPropInfo.city" />
        <col label="UnverSaleCount" width="100" path="realPropInfo.sale[$salePrice > 0 AND $vYVerifiedAtMarket = 0].@count" type="INT"/>
        <col label="SalePrice" width="100" path="sale.salePrice" />
        <col label="SaleDate" width="100" path="sale.saleDate" />
        <col label="exciseTaxNbr" width="100" path="sale.exciseTaxNbr" type= "INT" />
        <col label="VerifAtMkt" width="80" path="sale.vYVerifiedAtMarket" />	
        <col label="VerifBy" width="80" path="sale.vYVerifiedBy" />
        <col label="PropCnt" width="80" path="sale.propCnt" />
        <col label="BuyerName" width="120" path="sale.buyerName" />
        <col label="SellerName" width="120" path="sale.sellerName" />
        <col label="Bldg Count" width="90" path="realPropInfo.land.resBldg.@count" type= "INT"/>
        <col label="BldgGrade" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].bldgGrade" type= "INT" />
        <col label="YrBuilt" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].yrBuilt" type= "INT" />	
        <col label="YrRenovated" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].yrRenovated" type= "INT" />	
        <col label="Condition" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].condition" type= "INT" />
        <col label="Stories" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].stories" type= "INT" />	
        <col label="SqFtTotLiving" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtTotLiving" type= "INT" />
        <col label="SqFt1stFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFt1stFloor" type= "INT" />	
        <col label="SqFtHalfFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtHalfFloor" type= "INT" />
	<col label="SqFt2ndFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFt2ndFloor" type= "INT" />
        <col label="SqFtUpperFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtUpperFloor" type= "INT" />
        <col label="SqFtFinBasement" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtFinBasement" type= "INT" />		
        <col label="SqFtTotBasement" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtTotBasement" type= "INT" />
        <col label="Bedrooms" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].bedrooms" type= "INT" />
        <col label="NbrLivingUnits" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].nbrLivingUnits" type= "INT" />
    </GridDefinition>

     <GridDefinition name="GridSearchResultWithSegsAndPermits" tag="40" height="90" auto="yes" sort="ParcelNbr"  >  
	<col label="ParcelNbr" width="140" path="realPropInfo.parcelNbr" />
	<col label="Pcl" width="140" path="{realPropInfo.major}-{realPropInfo.minor}" />
        <col label="PT" width="50" path="realPropInfo.propType" />
        <col label="Address" width="80" path="realPropInfo.streetNbr" />
        <col label="Street " width="140" path="realPropInfo.street" />
        <col label="Zip" width="100" path="realPropInfo.zipCode" />
        <col label="City" width="120" path="realPropInfo.city" />
        <col label="Type" width="120" path="chngHist.type" />
        <col label="PropStatus" width="120" path="chngHist.propStatus" />	
        <col label="Event Date" width="140" path="chngHist.eventDate" />
        <col label="Permit Description" width="450" path="permit.permitDescr" />  
        <col label="Permitting Jurisdiction" width="120" path="permit.issuingJurisdiction" />  
        <col label="Issue Date" width="100" path="permit.issueDate" />  
        <col label="Permit Nbr" width="80" path="permit.permitNbr" />
        <col label="Permit Status" width="80" path="permit.permitStatus" /> 
        <col label="Permit Type" width="80" path="permit.permitType" />  
        <col label="Permit Val" width="80" path="permit.permitVal" /> 
        <col label="Reviewed By" width="80" path="permit.reviewedBy" />  
        <col label="Reviewed Date" width="90" path="permit.reviewedDate" type="DATE"/>  
        <col label="Bldg Count" width="90" path="realPropInfo.land.resBldg.@count" type= "INT" />
        <col label="BldgGrade" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].bldgGrade" type= "INT" />
        <col label="YrBuilt" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].yrBuilt" type= "INT" />	
        <col label="YrRenovated" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].yrRenovated" type= "INT" />	
        <col label="Condition" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].condition" type= "INT" />
        <col label="Stories" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].stories" type= "INT" />	
        <col label="SqFtTotLiving" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtTotLiving" type= "INT" />
        <col label="SqFt1stFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFt1stFloor" type= "INT" />	
        <col label="SqFtHalfFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtHalfFloor" type= "INT" />
	<col label="SqFt2ndFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFt2ndFloor" type= "INT" />
        <col label="SqFtUpperFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtUpperFloor" type= "INT" />
        <col label="SqFtFinBasement" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtFinBasement" type= "INT" />		
        <col label="SqFtTotBasement" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtTotBasement" type= "INT" />
        <col label="Bedrooms" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].bedrooms" type= "INT" />
        <col label="NbrLivingUnits" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].nbrLivingUnits" type= "INT" />
    </GridDefinition>

<!--    <GridDefinition name="RegisTest" tag="40" height="90" auto="yes" sort= "ParcelNbr" ascending = "Yes"  >  
	<col label="ParcelNbr" width="140" path="realPropInfo.parcelNbr" />
	<col label="Pcl" width="140" path="{realPropInfo.major}-{realPropInfo.minor}" />
        <col label="Rooms" width="100" path="ResBldg.bedrooms" />
        <col label="Permit info" width="100" path="permit.permitVal" />
         <col label="Rooms (full path)" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].bedrooms" />
         <col label="Permit (full path)" width="100" path="realPropInfo.permit[$permitStatus=1].permitVal" />
        <col label="Info updatedate" width="100" path="realPropInfo.updateDate" type="date"/>
   </GridDefinition>-->
    
     <GridDefinition name="GridSearchResultForPermits" tag="40" height="90" auto="yes">
	<col label="ParcelNbr" width="140" path="realPropInfo.parcelNbr" />
	<col label="Major" width="80" path="realPropInfo.major" />
	<col label="Minor" width="80" path="realPropInfo.minor" />
        <col label="PT" width="50" path="realPropInfo.propType" />
        <col label="Address" width="80" path="realPropInfo.streetNbr" />
        <col label="Street " width="140" path="realPropInfo.street" />
        <col label="Zip" width="100" path="realPropInfo.zipCode" />
        <col label="City" width="120" path="realPropInfo.city" />
        <col label="Permit Description" width="450" path="permit.permitDescr" />
        <col label="Permitting Jurisdiction" width="120" path="permit.issuingJurisdiction" />
        <col label="Issue Date" width="100" path="permit.issueDate" />
        <col label="Permit Nbr" width="80" path="permit.permitNbr" />
        <col label="Permit Status" width="80" path="permit.permitStatus" />
        <col label="Permit Type" width="80" path="permit.permitType" />
        <col label="Permit Val" width="80" path="permit.permitVal" />
        <col label="Reviewed By" width="80" path="permit.reviewedBy" />
        <col label="Reviewed Date" width="90" path="permit.reviewedDate" />
        <col label="Bldg Count" width="90" path="realPropInfo.land.resBldg.@count" type= "INT"/>
        <col label="BldgGrade" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].bldgGrade" type= "INT" />
        <col label="YrBuilt" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].yrBuilt" type= "INT" />	
        <col label="YrRenovated" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].yrRenovated" type= "INT" />	
        <col label="Condition" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].condition" type= "INT" />
        <col label="Stories" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].stories" type= "INT" />	
        <col label="SqFtTotLiving" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtTotLiving" type= "INT" />
        <col label="SqFt1stFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFt1stFloor" type= "INT" />	
        <col label="SqFtHalfFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtHalfFloor" type= "INT" />
	<col label="SqFt2ndFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFt2ndFloor" type= "INT" />
        <col label="SqFtUpperFloor" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtUpperFloor" type= "INT" />
        <col label="SqFtFinBasement" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtFinBasement" type= "INT" />		
        <col label="SqFtTotBasement" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].sqFtTotBasement" type= "INT" />
        <col label="Bedrooms" width="80" path="realPropInfo.land.resBldg[$bldgNbr=1].bedrooms" type= "INT" />
        <col label="NbrLivingUnits" width="100" path="realPropInfo.land.resBldg[$bldgNbr=1].nbrLivingUnits" type= "INT" />
	<!-- example of counts <col label="Bldg Count" width="75" path="realPropInfo.land.resBldg.@count" /> -->
    </GridDefinition>


   

    
    




    

</irealpropertySearch>

