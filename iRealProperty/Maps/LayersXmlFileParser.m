#import "LayersXmlFileParser.h"
#import "Helper.h"
#import "AxDataManager.h"
#import "MapLayerConfig.h"
#import "RealPropertyApp.h"
#import "MapLegend.h"

@implementation LayersXmlFileParser

#pragma mark - check the configuration file data
-(BOOL) checkConfigurationFile
{
    NSManagedObjectContext *context = [AxDataManager configContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area like[c] %@", [RealPropertyApp getWorkingArea]];
                              
    MapLayerConfig *layerConfig = [AxDataManager getEntityObject:@"MapLayerConfig" andPredicate:predicate andContext:context];
    
    if(layerConfig==nil)
        return NO;
    
    // Check the date of the existing xml file
    NSTimeInterval updateDate = [Helper updateTimeForFile:[NSString stringWithFormat:@"%@.layers.xml", [RealPropertyApp getWorkingPath]]];
    
    
    if(updateDate <= layerConfig.updateDate)
        return YES; // Can stop now...
    
    // Remove all the layer config information
    NSArray *array = [AxDataManager dataListEntity:@"MapLayerConfig" andSortBy:@"updateDate" andPredicate:predicate withContext:context];
    
    for(MapLayerConfig *config in array)
        [context deleteObject:config];
    
    [context save:nil];
    
    return NO;
}

#pragma mark -- Init with file
-(id)initWithXMLFile:(NSString *)xmlFile
{
    self = [super init];
    if(self)
    {
        if([self checkConfigurationFile])
            return self;
        timeNow =  [[Helper localDate] timeIntervalSinceReferenceDate];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        
        NSString *fileName = [documentDirectory stringByAppendingPathComponent:xmlFile];
        // Get it from the existing bundle
        NSString *filePath = [[NSBundle mainBundle] pathForResource:xmlFile ofType:@"xml"];
        NSURL *url;        
        if(filePath!=nil)
            url = [[NSURL alloc]initFileURLWithPath:filePath];
        else
            url = [[NSURL alloc]initFileURLWithPath:fileName];
        
        xmlParser = [[NSXMLParser alloc]initWithContentsOfURL:url];
        [xmlParser setDelegate:self];
        [xmlParser setShouldProcessNamespaces:NO];
        [xmlParser setShouldReportNamespacePrefixes:NO];
        [xmlParser setShouldResolveExternalEntities:NO];
        
        [xmlParser parse];
        currentElement = nil;
    }
    return self;
}
-(void)abortWithMsg:(NSString *)message
{
    [Helper alertWithOk:@"Invalid LayersDefinition.xml" message:message];
    
    [xmlParser abortParsing];
}
//
// get color from a string either as ARGB 255,255,255,255 or using heaxdecimal as #ffffffff
-(NSString *)getColorFrom:(NSString *)string
{
    if([string characterAtIndex:0] == '#')
    {
        NSString *hexString = [string substringFromIndex:1];
        NSScanner *scan = [NSScanner scannerWithString:hexString];
        unsigned int dec;
        if([scan scanHexInt:&dec])
            return [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", ((dec & 0xff000000)>>24)/255.0, ((dec & 0x00ff0000)>>16)/255.0, ((dec & 0x0000ff00)>>8)/255.0, (dec & 0xff)/255.0];
        else
            return @"{0.0,0.0,0.0,0.0}";
    }
    else
    {
        // expect four integers
        NSArray *array = [string componentsSeparatedByString:@","];
        if([array count]!=4)
        {
            [self abortWithMsg:[NSString stringWithFormat:@"Color '%@' must have 4 components!", string]];
            return 0;
        }
        return [NSString stringWithFormat:@"{%0.3f, %0.3f, %0.3f, %0.3f}", [[array objectAtIndex:0]intValue]/255.0, [[array objectAtIndex:1]intValue]/255.0, [[array objectAtIndex:2]intValue]/255.0, [[array objectAtIndex:3]intValue]/255.0];

    }
}
#pragma mark NSXMLParserDelegate methods
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [self abortWithMsg:[parseError localizedDescription]];
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if(currentElement==nil)
    {
        if([elementName caseInsensitiveCompare:@"PhysicalLayers"]==NSOrderedSame)
        {
            currentElement = @"PhysicalLayers";
        }
        else
        {
            [self abortWithMsg:@"Expected PhsyicalLayers"];
        }
    }
    else if([currentElement caseInsensitiveCompare: @"PhysicalLayers"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"layer"]==NSOrderedSame)
        {
            // Extract the tableName/current config
            NSString *tableName = [attributeDict valueForKey:@"tableName"];
            NSString *fileName = [attributeDict valueForKey:@"fileName"];
            NSManagedObjectContext *context = [AxDataManager configContext];
            mapLayerConfig = nil;            
            if(tableName!=nil)
            {
                // Handle case of the table name
                MapLayerConfig *layerConfig = [AxDataManager getEntityObject:@"MapLayerConfig" andPredicate:[NSPredicate predicateWithFormat:@"tableName==[uc] %@ AND area==[uc] %@", tableName, [RealPropertyApp getWorkingArea]] andContext:context];

                if(layerConfig == nil)
                {
                    // Does not exist
                    mapLayerConfig = [AxDataManager getNewEntityObject:@"MapLayerConfig" andContext:context];
                    mapLayerConfig.uid = _uid++;
                    mapLayerConfig.area = [RealPropertyApp getWorkingArea];
                    mapLayerConfig.tableName = tableName;
                    mapLayerConfig.isSID = NO;
                    if([attributeDict valueForKey:@"isParcel"]!=nil && [[attributeDict valueForKey:@"isParcel"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                        mapLayerConfig.isParcel = YES;
                    if([attributeDict valueForKey:@"isStreet"]!=nil && [[attributeDict valueForKey:@"isStreet"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                        mapLayerConfig.isStreet = YES;
                    if([attributeDict valueForKey:@"isWaterBody"]!=nil && [[attributeDict valueForKey:@"isWaterBody"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                        mapLayerConfig.isWtrBdy = YES;
                    if([attributeDict valueForKey:@"visible"]!=nil && [[attributeDict valueForKey:@"visible"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                        mapLayerConfig.isVisible = YES;
                    if([attributeDict valueForKey:@"visible"]!=nil && [[attributeDict valueForKey:@"isPolygon"] caseInsensitiveCompare:@"yes"]==NSOrderedSame)
                        mapLayerConfig.isPolygon = YES;
                    else
                        mapLayerConfig.isPolygon = NO;
                    mapLayerConfig.showShapes = [self getAttributeYes:attributeDict key:@"showShapes"];
                    mapLayerConfig.clipping = [self getAttributeYes:attributeDict key:@"clipping"];
                    mapLayerConfig.friendlyName = [attributeDict valueForKey:@"friendlyName"];
                    mapLayerConfig.updateDate = timeNow;
                }
            }
            else if(fileName!=nil)
            {
                // Handle case of the file name
                MapLayerConfig *layerConfig = [AxDataManager getEntityObject:@"MapLayerConfig" andPredicate:[NSPredicate predicateWithFormat:@"tableName==[uc] %@ AND area==[uc] %@", fileName, [RealPropertyApp getWorkingArea]] andContext:context];
                if(layerConfig==nil)
                {
                    mapLayerConfig = [AxDataManager getNewEntityObject:@"MapLayerConfig" andContext:context];
                    mapLayerConfig.uid = _uid++;
                    mapLayerConfig.area = [RealPropertyApp getWorkingArea];
                    mapLayerConfig.tableName = fileName;
                    mapLayerConfig.isSID = YES;
                    mapLayerConfig.isVisible = YES;
                    mapLayerConfig.friendlyName = [attributeDict valueForKey:@"friendlyName"];
                    mapLayerConfig.updateDate = timeNow;
                }
            }
            else
            {
                [self abortWithMsg:@"Expected to find tableName or FileName"];                
            }
            currentElement = @"layer";
        }
        else
        {
            [self abortWithMsg:@"Expected element layer"];
        }    
    }
    else if([currentElement caseInsensitiveCompare:@"layer"]==NSOrderedSame)
    {
        if([elementName caseInsensitiveCompare:@"shape"]==NSOrderedSame)
        {
            mapLayerConfig.fillColor = [self getColorFrom:[attributeDict valueForKey:@"fillColor"]];
            mapLayerConfig.lineColor = [self getColorFrom:[attributeDict valueForKey:@"lineColor"]];
            mapLayerConfig.fillStyle = [attributeDict valueForKey:@"style"];
            mapLayerConfig.lineWidth = [[attributeDict valueForKey:@"lineWidth"]doubleValue];
            if(mapLayerConfig.lineWidth==0)
                mapLayerConfig.lineWidth = 1.0;
        }
        else if([elementName caseInsensitiveCompare:@"label"]==NSOrderedSame)
        {
            mapLayerConfig.removeLabelDuplicates = [self getAttributeYes:attributeDict key:@"removeDuplicate"];
            mapLayerConfig.scaleLabel = [self getAttributeYes:attributeDict key:@"scale"];
            mapLayerConfig.showLabels = [self getAttributeYes:attributeDict key:@"showLabel"];
            mapLayerConfig.bold = [self getAttributeYes:attributeDict key:@"bold"];
            mapLayerConfig.italic = [self getAttributeYes:attributeDict key:@"italic"];

            

            mapLayerConfig.labelFontSize = [[attributeDict valueForKey:@"fontSize"] doubleValue];
            mapLayerConfig.labelFontSizeColumnName = [attributeDict valueForKey:@"fontSizeColumnName"];
            mapLayerConfig.labelAngle = [[attributeDict valueForKey:@"labelAngle"] doubleValue];
            mapLayerConfig.labelAngleColumnName = [attributeDict valueForKey:@"labelAngleName"];
            mapLayerConfig.labelColor = [self getColorFrom:[attributeDict valueForKey:@"color"]];
            mapLayerConfig.labelColorColumnName = [attributeDict valueForKey:@"colorColumnName"];
            mapLayerConfig.columnLabel = [attributeDict valueForKey:@"columnName"];
            mapLayerConfig.labelAngleColumnName = [attributeDict valueForKey:@"labelAngleColumnName"];
            mapLayerConfig.bolColumnName = [attributeDict valueForKey:@"boldColumnName"];
        }
        else if([elementName caseInsensitiveCompare:@"cutoff"]==NSOrderedSame)
        {
            currentElement = @"cutoff";
            mapLayerConfig.minScale = [[attributeDict valueForKey:@"minScale"] doubleValue];
            mapLayerConfig.maxScale = [[attributeDict valueForKey:@"maxScale"] doubleValue];
            
        }
        else
        {
            [self abortWithMsg:[NSString stringWithFormat:@"Wrong element in layer. Unexpected '%@'", elementName]];
        }
    }
}
-(NSString *)getAttribute:(NSDictionary *)dict key:(NSString *)key
{
    NSString *result = [dict valueForKey:key];
    if(result==nil)
        return @"";
    return result;
}
-(BOOL)getAttributeYes:(NSDictionary *)dict key:(NSString *)key
{
    return [[self getAttribute:dict key:key] caseInsensitiveCompare:@"yes"]==NSOrderedSame? YES: NO;
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName caseInsensitiveCompare:@"layer"]==NSOrderedSame)
    {
        currentElement = @"PhysicalLayers";
        // Add the layer information (assuming that it does not exist)
        if(mapLayerConfig!=nil)
        {
            NSError *error;
            NSManagedObjectContext *context = [AxDataManager configContext];
            if (![context save:&error]) 
            {
                NSLog(@"Context save error: %@", [error localizedDescription]);
            }
            mapLayerConfig = nil;
        }
    }
    else if([elementName caseInsensitiveCompare:@"shape"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"label"]==NSOrderedSame ||
       [elementName caseInsensitiveCompare:@"cutoff"]==NSOrderedSame )
    {
        currentElement = @"layer";
    }
    else if([elementName caseInsensitiveCompare:@"PhysicalLayers"]==NSOrderedSame)
    {
        NSManagedObjectContext *context = [AxDataManager configContext];
        [context reset];
    }
    else
    {
        [self abortWithMsg:[NSString stringWithFormat:@"Wrong closing element. Unexpected '%@'", elementName]];
    }
    
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{

}
@end
