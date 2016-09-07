#import "SQLSync.h"
#import "SQLEntity.h"
#import "AxDataManager.h"
#import "RealPropertyApp.h"


@implementation SQLSync

    @synthesize destContext;
    @synthesize verbose;

#pragma mark - Init and memory
    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                    // Custom initialization
                }
            return self;
        }



    - (void)didReceiveMemoryWarning
        {
            // Releases the view if it doesn't have a superview.
            [super didReceiveMemoryWarning];

            // Release any cached data, images, etc that aren't in use.
        }

#pragma mark - Utilities
    - (NSManagedObject *)createManagedEntity :(NSString *)objectName
        {
            return [AxDataManager getNewEntityObject:objectName andContext:destContext];
        }



    - (NSString *)cleanPictPath:(NSString *)path
        {
            return path;

            NSString *dependant = @"//shadow/media$/dev/";
            NSString *result    = [path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            // Remove the dependant path
            NSString *clean     = [result stringByReplacingOccurrencesOfString:dependant withString:@""];

            return clean;
        }



//
// Automatically initialize the base entity based on the application information
//
    - (NSManagedObject *)createBaseEntity :(NSString *)objectName
        {
            return [AxDataManager getNewEntityObject:objectName];
        }



    - (BOOL)isValidateForInsert :(NSManagedObject *)object
        {
            NSError *error = nil;
            if (![object validateForInsert:&error])
                {
                    NSLog(@"validateForInsert Errors:");
                    for (id key in [error userInfo])
                        {
                            NSLog(@"key: %@, value:%@", key, [[error userInfo] objectForKey:key]);
                        }
                    return NO;
                }
            return YES;
        }



    - (void)matchName:(NSManagedObject *)source
               sqlRow:(NSArray *)row
        {
            NSString               *entityName = [[source entity] name];
            NSManagedObjectContext *context    = [AxDataManager defaultContext];

            //loop through all attributes and assign then to the clone
            NSDictionary *attributes = [[NSEntityDescription entityForName:entityName inManagedObjectContext:context] attributesByName];

            // First pass: loop through attributes to make sure that they are all there
            for (NSString  *attr in attributes)
                {
                    BOOL found = NO;
                    for (SQLEntity *sql in row)
                        {
                            if ([sql.sqlName caseInsensitiveCompare:attr] == NSOrderedSame)
                                {
                                    found = YES;
                                    break;
                                }
                        }
                    if (!found)
                    NSLog(@"Entity '%@.%@' not found in the SQL table", entityName, attr);
                }
            // Second pass: loop through the SQL rows
            for (SQLEntity *sql in row)
                {
                    BOOL found = NO;
                    for (NSString *attr in attributes)
                        {
                            if ([attr caseInsensitiveCompare:sql.sqlName] == NSOrderedSame)
                                {
                                    found = YES;
                                    break;
                                }
                        }
                    if (!found)
                    NSLog(@"sql field '%@.%@' not found in the entity", entityName, sql.sqlName);
                }
        }



//
// Setup all the properties of a basentity object based on the SQL row values found.
// This method does not fail, but displays message when the property does not exist on the target object
// or when the type is different
//
    extern id objc_getClass(const char *);



    - (void)setupProperties:(NSManagedObject *)object
                     sqlRow:(NSArray *)row
        {
            // [self matchName:object sqlRow:row];

            NSArray *properties = [[object entity] properties];

            // go through the list of SQL Objects
            for (int index = 0; index < [row count]; index++)
                {
                    @try
                        {
                            SQLEntity *sqlEntity = [row objectAtIndex:index];
                            if (sqlEntity.sqlValue == kSqlNull)
                                continue;

                            // Loop through the entities of the object now
                            BOOL found = NO;


                            for (NSPropertyDescription *property in properties)
                                {
                                    if (![property isKindOfClass:(id) objc_getClass("NSAttributeDescription")])
                                        continue;
                                    NSString *entityName = [property name];

                                    if ([entityName compare:sqlEntity.sqlName options:NSCaseInsensitiveSearch] == NSOrderedSame)
                                        {
                                            // Found the class entity matching the SQL entry
                                            found = YES;

                                            // Setup the value...
                                            NSAttributeDescription *attribute = (NSAttributeDescription *) property;
                                            if ([attribute attributeType] == NSDateAttributeType)
                                                {
                                                    // Setup a date
                                                    if (sqlEntity.sqlValue != kSqlDate)
                                                        {
                                                            NSLog(@"Wrong Type: '%@'.'%@' is NSDateAttribute, SQL is %@",
                                                            [NSString stringWithUTF8String:object_getClassName(object)], sqlEntity.sqlName, [sqlEntity getTypeName]);
                                                            continue;
                                                        }

                                                    [object setValue:sqlEntity.valueDate forKey:entityName];
                                                    // NSLog(@"'%@' '%@'",entityName, sqlEntity.valueDate);

                                                }


                                            else if ([attribute attributeType] == NSBooleanAttributeType)
                                                {
                                                    // Setup a boolean
                                                    if (sqlEntity.sqlValue == kSqlInt)
                                                        [object setValue:[[NSNumber alloc] initWithBool:(BOOL) sqlEntity.valueInt] forKey:entityName];
                                                    else if (sqlEntity.sqlValue == kSqlString)
                                                        {
                                                            BOOL boolean;
                                                            if ([sqlEntity.valueString compare:@"Y"] == NSOrderedSame)
                                                                boolean = YES;
                                                            else
                                                                boolean = NO;
                                                            [object setValue:[[NSNumber alloc] initWithBool:(BOOL) boolean] forKey:entityName];
                                                        }

                                                }
                                            else if ([attribute attributeType] == NSStringAttributeType)
                                                {
                                                    // Setup as a string
                                                    if (sqlEntity.sqlValue != kSqlString)
                                                        {
                                                            NSLog(@"Wrong Type: '%@'.'%@' is String, SQL is %@",
                                                            [NSString stringWithUTF8String:object_getClassName(object)], sqlEntity.sqlName, [sqlEntity getTypeName]);
                                                        }

                                                    [object setValue:sqlEntity.valueString forKey:entityName];
                                                    //NSLog(@"'%@' '%@'",entityName, sqlEntity.valueString);
                                                }
                                            else if ([attribute attributeType] == NSInteger32AttributeType || [attribute attributeType] == NSInteger16AttributeType)
                                                {
                                                    // Setup as an INT
                                                    if (sqlEntity.sqlValue != kSqlInt)
                                                        {
                                                            NSLog(@"Wrong Type: '%@'.'%@' is INT, SQL is %@",
                                                            [NSString stringWithUTF8String:object_getClassName(object)], sqlEntity.sqlName, [sqlEntity getTypeName]);
                                                            continue;
                                                        }

                                                    [object setValue:[[NSNumber alloc] initWithInt:sqlEntity.valueInt] forKey:entityName];
                                                }
                                            else if ([attribute attributeType] == NSFloatAttributeType || [attribute attributeType] == NSDecimalAttributeType ||
                                                    [attribute attributeType] == NSDoubleAttributeType)
                                                {
                                                    // Setup as a float
                                                    if (sqlEntity.sqlValue != kSqlFloat)
                                                        {
                                                            NSLog(@"Wrong Type: '%@'.'%@' is FLOAT, SQL is %@",
                                                            [NSString stringWithUTF8String:object_getClassName(object)], sqlEntity.sqlName, [sqlEntity getTypeName]);
                                                            continue;
                                                        }

                                                    [object setValue:[[NSNumber alloc] initWithFloat:sqlEntity.valueFloat] forKey:entityName];
                                                    //NSLog(@"'%@' '%f'",entityName, sqlEntity.valueFloat);
                                                }
                                            else
                                                {
                                                    NSLog(@"'%@' Unrecognized type", entityName);
                                                }
                                            break;
                                        }
                                }
                            if (!found)
                                {
                                    //  NSLog(@"Entity '%@' does not have a SQL property '%@'", [NSString  stringWithUTF8String:object_getClassName(object)], sqlEntityName);
                                }

                        }
                    @catch (NSException *exception)
                        {
                            NSLog(@"Setup properties exception: %@", exception);
                        }
                }
        }



    - (void)insertMobileHome:(NSArray *)sqlItems
                realPropInfo:(RealPropInfo *)realPropInfo
        {
            // Look for MobileHomeId
            SQLEntity *sqlEntity;
            for (sqlEntity in sqlItems)
                {
                    if ([sqlEntity.sqlName compare:@"MobileHomeId"] == NSOrderedSame)
                        break;
                }
            if (sqlEntity == nil)
                {
                    NSLog(@"Can't find MobileHomeId");
                }

            // ok, now access the real table
            MHAccount *mhAccount = (MHAccount *) [self createBaseEntity:@"MHAccount"];
            NSArray   *array     = [SQLEntity SQLitemsFromTable:@"MobileAccount" withFilter:[NSString stringWithFormat:@"_MobileHomeId=%d", sqlEntity.valueInt]];

            if (array == nil || [array count] == 0)
                {
                    NSLog(@"Can't read Account Mobile home id='%d'", sqlEntity.valueInt);
                    return;
                }
            [self setupProperties:(NSManagedObject *) mhAccount sqlRow:[array objectAtIndex:0]];
            [realPropInfo addMHAccountObject:mhAccount];

            // Read the characteristics
            MHCharacteristic *mhChar = (MHCharacteristic *) [self createBaseEntity:@"MHCharacteristic"];
            array = [SQLEntity SQLitemsFromTable:@"MobileChar" withFilter:[NSString stringWithFormat:@"_MobileHomeId=%d", sqlEntity.valueInt]];

            if (array == nil || [array count] == 0)
                {
                    NSLog(@"Can't read Mobile Char id='%d'", sqlEntity.valueInt);
                    return;
                }
            [self setupProperties:(NSManagedObject *) mhChar sqlRow:[array objectAtIndex:0]];
            mhAccount.mHCharacteristic = mhChar;

            // Location
            MHLocation *mhLocation = (MHLocation *) [self createBaseEntity:@"MHLocation"];
            array = [SQLEntity SQLitemsFromTable:@"MobileLocAddr" withFilter:[NSString stringWithFormat:@"_MobileHomeId=%d", sqlEntity.valueInt]];

            if (array == nil || [array count] == 0)
                {
                    NSLog(@"Can't read RPMH_P_LocAddrByParcel='%d'", sqlEntity.valueInt);
                    return;
                }
            [self setupProperties:(NSManagedObject *) mhLocation sqlRow:[array objectAtIndex:0]];
            mhAccount.mHLocation = mhLocation;

            // Add the mobile pictures
            // Mobile meda - Multiple Entries ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"MediaMobile" withFilter:[NSString stringWithFormat:@"_MobileHomeId=%d", sqlEntity.valueInt]];
            for (int count = 0; count < [array count]; count++)
                {
                    MediaMobile *mediaMobile = (MediaMobile *) [self createBaseEntity:@"MediaMobile"];
                    [self setupProperties:(NSManagedObject *) mediaMobile sqlRow:[array objectAtIndex:count]];
                    mediaMobile.mediaLoc = [self cleanPictPath:mediaMobile.mediaLoc];

                    [mhAccount addMediaMobileObject:mediaMobile];
                }
        }



//
// Return the notes based on a specific noteId type and realPropInfo value
//
    - (NSSet *)getNotes:(NSString *)noteName
             realPropId:(int)realPropId
                 noteId:(int)noteId
        {
            NSMutableSet *set          = [[NSMutableSet alloc] init];
            NSArray      *noteIntances = [SQLEntity SQLitemsFromTable:@"NoteInstance" withFilter:[NSString stringWithFormat:@"_NoteId=%d AND _RealPropId=%d", noteId, realPropId]];

            for (int index = 0; index < [noteIntances count]; index++)
                {
                    NoteInstance *noteInstance = (NoteInstance *) [self createBaseEntity:noteName];
                    [self setupProperties:(NSManagedObject *) noteInstance sqlRow:[noteIntances objectAtIndex:index]];
                    [set addObject:noteInstance];

                    // Check if there is a media attached
                    NSArray *medias = [SQLEntity SQLitemsFromTable:@"MediaNote" withFilter:[NSString stringWithFormat:@"_NoteId=%d AND _InstanceId=%d", noteInstance.noteId, noteInstance.noteInstance]];

                    if ([medias count] > 0)
                        {
                            MediaNote *mediaNote = (MediaNote *) [self createBaseEntity:@"MediaNote"];
                            [self setupProperties:(NSManagedObject *) mediaNote sqlRow:[medias objectAtIndex:0]];
                            mediaNote.mediaLoc     = mediaNote.mediaLoc;
                            noteInstance.mediaNote = mediaNote;
                        }
                    medias = nil;
                }
            noteIntances   = nil;

            return set;
        }



//
// Create one entry into the CoreData based on the SQL value
//
    - (void)createRealProperty:(int)parcelNbr
        {
            // RealPropInfo ---------------------------------------------------------------------------------------------------
            if (verbose)
            NSLog(@"Add parcelNbr:'%d'", parcelNbr);
            RealPropInfo   *realPropInfo = (RealPropInfo *) [self createBaseEntity:@"RealPropInfo"];
            NSMutableArray *array        = [SQLEntity SQLitemsFromTable:@"RealPropInfo" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", parcelNbr]];
            if (array == nil || [array count] == 0)
                {
                    NSLog(@"Can't read ParcelNbr='%d'", parcelNbr);
                    return;
                }
            [self setupProperties:(NSManagedObject *) realPropInfo sqlRow:[array objectAtIndex:0]];
            realPropInfo.parcelNbr     = [NSString stringWithFormat:@"%@%@", realPropInfo.major, realPropInfo.minor];
            if (realPropInfo.noteId != 0)
                {
                    NSSet *set = [self getNotes:@"NoteRealPropInfo" realPropId:realPropInfo.realPropId noteId:realPropInfo.noteId];
                    [realPropInfo addNoteRealPropInfo:set];
                }
            // Inspection ---------------------------------------------------------------------------------------------------
            Inspection     *inspection = (Inspection *) [self createBaseEntity:@"Inspection"];
            array = [SQLEntity SQLitemsFromTable:@"INSPECTION" withFilter:[NSString stringWithFormat:@"_realPropId=%d", realPropInfo.realPropId]];
            if ([array count] > 0)
                {
                    [self setupProperties:inspection sqlRow:[array objectAtIndex:0]];
                    realPropInfo.inspection = inspection;
                }

            // Land ---------------------------------------------------------------------------------------------------
            if (verbose > 1)
            NSLog(@"'%d' - Land", parcelNbr);
            Land *land = (Land *) [self createBaseEntity:@"Land"];
            array = [SQLEntity SQLitemsFromTable:@"LAND" withFilter:[NSString stringWithFormat:@"_landId=%d", realPropInfo.landId]];
            if (array == nil || [array count] == 0)
                {
                    NSLog(@"Land: Can't read LanbdId='%d'", realPropInfo.landId);
                    return;
                }
            [self setupProperties:(NSManagedObject *) land sqlRow:[array objectAtIndex:0]];

            realPropInfo.land = land;
            array = nil;

            // XLand ---------------------------------------------------------------------------------------------------
            if (verbose > 1)
            NSLog(@"'%d' - XLand", parcelNbr);
            XLand *xland = (XLand *) [self createBaseEntity:@"XLand"];
            array = [SQLEntity SQLitemsFromTable:@"XLAND" withFilter:[NSString stringWithFormat:@"_landId=%d", realPropInfo.landId]];
            if (array == nil || [array count] == 0)
                {
                    NSLog(@"XLand: Can't read LanddId='%d'", realPropInfo.landId);
                }
            else
                [self setupProperties:(NSManagedObject *) xland sqlRow:[array objectAtIndex:0]];

            realPropInfo.xland = xland;
            array = nil;

            // Account ---------------------------------------------------------------------------------------------------
            if (verbose > 1)
            NSLog(@"'%d' - Account", parcelNbr);
            Account *account = (Account *) [self createBaseEntity:@"Account"];
            array = [SQLEntity SQLitemsFromTable:@"Accounts" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (array == nil || [array count] == 0)
                {
                    NSLog(@"Header: Can't read account='%d'", realPropInfo.realPropId);
                }
            else
                [self setupProperties:(NSManagedObject *) account sqlRow:[array objectAtIndex:0]];

            realPropInfo.account = account;
            array = nil;

            // Current Zoning -- Multiple entries -----------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"CurrentZoning" withFilter:[NSString stringWithFormat:@"_LandId=%d", realPropInfo.landId]];
            if (verbose > 1)
            NSLog(@"'%d' - Zoning:%d", parcelNbr, [array count]);

            for (int count = 0; count < [array count]; count++)
                {
                    CurrentZoning *currZoning = (CurrentZoning *) [self createBaseEntity:@"CurrZoning"];
                    [self setupProperties:(NSManagedObject *) currZoning sqlRow:[array objectAtIndex:count]];
                    [land addCurrZoningObject:currZoning];
                }
            // EnvRes - Multiple Entries ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"ENVRES" withFilter:[NSString stringWithFormat:@"_LandId=%d", realPropInfo.landId]];
            if (verbose > 1)
            NSLog(@"'%d' - EnvRes:%d", parcelNbr, [array count]);

            for (int count = 0; count < [array count]; count++)
                {
                    EnvRes *envRes = (EnvRes *) [self createBaseEntity:@"EnvRes"];
                    [self setupProperties:(NSManagedObject *) envRes sqlRow:[array objectAtIndex:count]];
                    [land addEnvResObject:envRes];
                }
            array = nil;
            // Building -- Multiple entries ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"ResBldg" withFilter:[NSString stringWithFormat:@"_LandId=%d", realPropInfo.landId]];

            if (verbose > 1)
            NSLog(@"'%d' - Add Building:%d", parcelNbr, [array count]);
            for (int count = 0; count < [array count]; count++)
                {
                    ResBldg *resBldg = (ResBldg *) [self createBaseEntity:@"ResBldg"];
                    [self setupProperties:(NSManagedObject *) resBldg sqlRow:[array objectAtIndex:count]];
                    [land addResBldgObject:resBldg];
                }
            array = nil;
            // Accessory - Multiple Entries ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"Accy" withFilter:[NSString stringWithFormat:@"_LandId=%d", realPropInfo.landId]];
            if (verbose > 1)
            NSLog(@"'%d' - Accy:%d", parcelNbr, [array count]);

            for (int count = 0; count < [array count]; count++)
                {
                    Accy *accy = (Accy *) [self createBaseEntity:@"Accy"];
                    [self setupProperties:(NSManagedObject *) accy sqlRow:[array objectAtIndex:count]];
                    [realPropInfo addAccyObject:accy];
                }
            array = nil;

            // Mobile - Multiple Entries ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"Mobile" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - Add Mobile:%d", parcelNbr, [array count]);

            for (NSArray *a in array)
                {
                    [self insertMobileHome:a realPropInfo:realPropInfo];
                }
            array = nil;
            // Accy Media - Multiple Entries ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"MediaAccy" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - Add Accy Media:%d", parcelNbr, [array count]);

            for (int count = 0; count < [array count]; count++)
                {
                    MediaAccy *mediaAccy = (MediaAccy *) [self createBaseEntity:@"MediaAccy"];
                    [self setupProperties:(NSManagedObject *) mediaAccy sqlRow:[array objectAtIndex:count]];
                    for (Accy *accy in realPropInfo.accy)
                        {
                            // look for the appropriate ACCY media
                            if (accy.lineNbr == mediaAccy.lineNbr)
                                {
                                    mediaAccy.mediaLoc = [self cleanPictPath:mediaAccy.mediaLoc];
                                    [accy addMediaAccyObject:mediaAccy];
                                    break;
                                }
                        }
                }
            array = nil;
            // ResBldg Media - Multiple Entries ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"MediaBldg" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - Building Media:%d", parcelNbr, [array count]);

            for (int count = 0; count < [array count]; count++)
                {
                    MediaBldg *mediaBldg = (MediaBldg *) [self createBaseEntity:@"MediaBldg"];
                    [self setupProperties:(NSManagedObject *) mediaBldg sqlRow:[array objectAtIndex:count]];
                    Land *land = realPropInfo.land;

                    for (ResBldg *resBldg in land.resBldg)
                        {
                            // look for the appropriate building media
                            if (mediaBldg.bldgId == resBldg.bldgId)
                                {
                                    mediaBldg.mediaLoc = [self cleanPictPath:mediaBldg.mediaLoc];

                                    [resBldg addMediaBldgObject:mediaBldg];
                                    break;
                                }
                        }
                }
            array = nil;
            // Land Media - Multiple Entries ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"MediaLand" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - Land Media:%d", parcelNbr, [array count]);

            for (int count = 0; count < [array count]; count++)
                {
                    MediaLand *mediaLand = (MediaLand *) [self createBaseEntity:@"MediaLand"];

                    [self setupProperties:(NSManagedObject *) mediaLand sqlRow:[array objectAtIndex:count]];
                    Land *land = realPropInfo.land;
                    mediaLand.mediaLoc = [self cleanPictPath:mediaLand.mediaLoc];

                    [land addMediaLandObject:mediaLand];
                }
            array = nil;

            // Permits - Multiple entries  ------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"Permit" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - Permits:%d", parcelNbr, [array count]);
            for (int count = 0; count < [array count]; count++)
                {
                    Permit *permit = (Permit *) [self createBaseEntity:@"Permit"];
                    [self setupProperties:(NSManagedObject *) permit sqlRow:[array objectAtIndex:count]];

                    // Find the permit details for that permit
                    NSArray *subArray = [SQLEntity SQLitemsFromTable:@"PermitDtl" withFilter:[NSString stringWithFormat:@"_RealPropId=%d AND _PermitNbr='%@'", realPropInfo.realPropId, permit.permitNbr]];
                    for (int subcount = 0; subcount < [subArray count]; subcount++)
                        {
                            PermitDtl *permitDtl = (PermitDtl *) [self createBaseEntity:@"PermitDtl"];
                            [self setupProperties:(NSManagedObject *) permitDtl sqlRow:[subArray objectAtIndex:subcount]];
                            [permit addPermitDtlObject:permitDtl];
                        }
                    [realPropInfo addPermitObject:permit];
                }
            array = nil;


            // Sale - Multiple entries  ------------------------------------------------------------------------------------------
            if (verbose > 1)
            NSLog(@"'%d' - Sales:%d", parcelNbr, [array count]);
            array = [SQLEntity SQLitemsFromTable:@"Sale" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            for (int count = 0; count < [array count]; count++)
                {
                    Sale *sale = (Sale *) [self createBaseEntity:@"Sale"];
                    [self setupProperties:(NSManagedObject *) sale sqlRow:[array objectAtIndex:count]];

#warning sale field missing
#if 0
        [realPropInfo addSaleObject:sale];
#endif
                    // For each sale, look for list of parcels associated
                    NSArray *saleParcels = [SQLEntity SQLitemsFromTable:@"SaleParcel" withFilter:[NSString stringWithFormat:@"_SaleId=%d", sale.saleId]];

                    for (int index = 0; index < [saleParcels count]; index++)
                        {
                            SaleParcels * parcel = (SaleParcels *)
                            [self createBaseEntity:@"SaleParcels"];
                            [self setupProperties:(NSManagedObject *) parcel sqlRow:[saleParcels objectAtIndex:index]];
                            [sale addSaleParcelObject:parcel];
                        }
                    saleParcels = nil;

                    // For each sale, add the warnings
                    NSArray *saleWarnings = [SQLEntity SQLitemsFromTable:@"SaleWarning" withFilter:[NSString stringWithFormat:@"_SaleId=%d", sale.saleId]];

                    for (int index = 0; index < [saleWarnings count]; index++)
                        {
                            SaleWarning *warning = (SaleWarning *) [self createBaseEntity:@"SaleWarning"];
                            [self setupProperties:(NSManagedObject *) warning sqlRow:[saleWarnings objectAtIndex:index]];
                            [sale addSaleWarningObject:warning];
                        }
                    saleWarnings = nil;

                    // Add the notes for this particular sale -- referenced through NoteId
                    if (sale.noteId != 0)
                        {
                            NSSet *set = [self getNotes:@"NoteSale" realPropId:realPropInfo.realPropId noteId:sale.noteId];
                            [sale addNoteSale:set];
                        }
                }
            array = nil;
            // Reviews - Multiple Entries ---------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"Review" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - Reviews:%d", parcelNbr, [array count]);
            for (int count = 0; count < [array count]; count++)
                {
                    Review *review = (Review *) [self createBaseEntity:@"Review"];
                    [self setupProperties:(NSManagedObject *) review sqlRow:[array objectAtIndex:count]];

                    [realPropInfo addReviewObject:review];

                    // For each review, get the list of ReviewJrnl
                    NSArray *arrayJournal = [SQLEntity SQLitemsFromTable:@"ReviewJrnl" withFilter:[NSString stringWithFormat:@"_AssmtReviewId=%d", review.assmtReviewId]];
                    for (int index = 0; index < [arrayJournal count]; index++)
                        {
                            ReviewJrnl *reviewJrnl = (ReviewJrnl *) [self createBaseEntity:@"ReviewJrnl"];
                            [self setupProperties:(NSManagedObject *) reviewJrnl sqlRow:[arrayJournal objectAtIndex:index]];

                            [review addReviewJrnlObject:reviewJrnl];
                        }
                    // Add the notes (if any)
                    if (review.noteId != 0)
                        {
                            NSSet *set = [self getNotes:@"NoteReview" realPropId:realPropInfo.realPropId noteId:review.noteId];
                            [review addNoteReview:set];
                        }
                }
            array = nil;
            // Value Hist - Multiple entries ------------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"ValHist" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - Values Hist:%d", parcelNbr, [array count]);
            for (int count = 0; count < [array count]; count++)
                {
                    ValHist *values = (ValHist *) [self createBaseEntity:@"ValHist"];
                    [self setupProperties:(NSManagedObject *) values sqlRow:[array objectAtIndex:count]];

                    [realPropInfo addValHistObject:values];
                }
            array = nil;
            // ChngHist - Multiple entries ------------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"ChngHist" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - ChngHist:%d", parcelNbr, [array count]);
            for (int count = 0; count < [array count]; count++)
                {
                    ChngHist *chngHist = (ChngHist *) [self createBaseEntity:@"ChngHist"];
                    [self setupProperties:(NSManagedObject *) chngHist sqlRow:[array objectAtIndex:count]];

                    [realPropInfo addChngHistObject:chngHist];
                    // Now loop for all the chngHistList

                    NSArray *subArray = [SQLEntity SQLitemsFromTable:@"ChngHistDtl" withFilter:[NSString stringWithFormat:@"_EventId=%d", chngHist.eventId]];
                    if (verbose > 2)
                    NSLog(@"'%d' - ChngHistDtl:%d %d", parcelNbr, count, [subArray count]);

                    for (int index = 0; index < [subArray count]; index++)
                        {
                            ChngHistDtl *chngHistDtl = (ChngHistDtl *) [self createBaseEntity:@"ChngHistDtl"];
                            [self setupProperties:(NSManagedObject *) chngHistDtl sqlRow:[subArray objectAtIndex:index]];
                            [chngHist addChngHistDtlObject:chngHistDtl];
                        }
                }
            array = nil;
            // HIExmpt.h - Multiple entries ------------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"HIExmpt" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - HIE:%d", parcelNbr, [array count]);
            for (int count = 0; count < [array count]; count++)
                {
                    HIExmpt *values = (HIExmpt *) [self createBaseEntity:@"HIExmpt"];
                    [self setupProperties:(NSManagedObject *) values sqlRow:[array objectAtIndex:count]];

                    [realPropInfo addHIExemptObject:values];

                    // Add notes (if they exist)
                    if (values.noteId != 0)
                        {
                            NSSet *set = [self getNotes:@"NoteHIExmpt" realPropId:realPropInfo.realPropId noteId:values.noteId];
                            [values addNoteHIExmpt:set];
                        }
                }
            array = nil;
            // UndividedInt - Multiple entries ------------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"UndInt" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];

            if (verbose > 1)
            NSLog(@"'%d' - Undivided Int:%d", parcelNbr, [array count]);
            for (int count = 0; count < [array count]; count++)
                {
                    UndividedInt *value = (UndividedInt *) [self createBaseEntity:@"UndividedInt"];
                    [self setupProperties:(NSManagedObject *) value sqlRow:[array objectAtIndex:count]];

                    [realPropInfo addUndividedIntObject:value];
                }
            array = nil;
            // Tax roll ------------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"TaxRoll" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];

            if (verbose > 1)
            NSLog(@"'%d' - TaxRoll:%d", parcelNbr, [array count]);
            for (int count = 0; count < [array count]; count++)
                {
                    TaxRoll *value = (TaxRoll *) [self createBaseEntity:@"TaxRoll"];
                    [self setupProperties:(NSManagedObject *) value sqlRow:[array objectAtIndex:count]];

                    [realPropInfo addTaxRollObject:value];
                }
            array = nil;
            // Val Est ------------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"ValEst" withFilter:[NSString stringWithFormat:@"_LandId='%d'", realPropInfo.landId, realPropInfo.propType, realPropInfo.killed]];
            if (verbose > 1)
            NSLog(@"'%d' - Val Est:%d", parcelNbr, [array count]);

            for (int count = 0; count < [array count]; count++)
                {
                    ValEst *value = (ValEst *) [self createBaseEntity:@"ValEst"];
                    [self setupProperties:(NSManagedObject *) value sqlRow:[array objectAtIndex:count]];

                    [realPropInfo addValEstObject:value];
                }
            array = nil;
            // Appraisal History  ------------------------------------------------------------------------------------------------
            array = [SQLEntity SQLitemsFromTable:@"ApplHist" withFilter:[NSString stringWithFormat:@"_RealPropId=%d", realPropInfo.realPropId]];
            if (verbose > 1)
            NSLog(@"'%d' - Appraisal:%d", parcelNbr, [array count]);

            for (int count = 0; count < [array count]; count++)
                {
                    ApplHist *value = (ApplHist *) [self createBaseEntity:@"ApplHist"];
                    [self setupProperties:(NSManagedObject *) value sqlRow:[array objectAtIndex:count]];

                    [realPropInfo addApplHistObject:value];
                }
            array = nil;
            //////////////////////////////////////////////////////////////////////////////////////////
            // Save the form
            //////////////////////////////////////////////////////////////////////////////////////////

            NSManagedObjectContext *context = [AxDataManager getContext:@"default"];

            NSError *error;
            if (![context save:&error])
                {
                    NSLog(@"Context save error: %@", [error localizedDescription]);
                }
            [context reset];
            realPropInfo = nil;
        }



    - (void)createAllRealProperty
        {
            [SQLEntity prepareIndexes];
            self.verbose = 0;
            NSArray *rows = [SQLEntity SQLItemsFromTable:@"RealPropInfo"];
            int count = 1;
            self.verbose = 1;
            for (NSArray *row in rows)
                {
                    NSLog(@"%d/%d", count++, [rows count]);
                    //  if(count<623)
                    //     continue;
                    for (SQLEntity *sqlEntity in row)
                        {
                            NSString *name = sqlEntity.sqlName;
                            if ([name compare:@"RealPropId"] == NSOrderedSame)
                                {

                                    [self createRealProperty:sqlEntity.valueInt];
                                }
                        }
                }
        }

#pragma mark - View lifecycle

    - (void)viewDidLoad
        {
            [super viewDidLoad];
        }



    - (void)viewDidUnload
        {
            [super viewDidUnload];
            // Release any retained subviews of the main view.
            // e.g. self.myOutlet = nil;
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;

        }

@end
