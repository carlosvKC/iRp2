
#import <CoreData/CoreData.h>

#import "Synchronizator.h"
#import "AxDataManager.h"
#import "Synchronization.h"
#import "SyncEntity.h"
#import "SyncInformation.h"
#import "LastSynchronization.h"
#import "RealProperty.h"
#import "ReadPictures.h"
#import "SyncValidationError.h"
#import "DatabaseDate.h"
#import "ImageToDownload.h"
#import "OpenEntity.h"
#import "SyncActualStep.h"
#import "TabBookmarkController.h"
#import "TrackChanges.h"

@implementation Synchronizator

@synthesize delegate;
@synthesize requester;
@synthesize securityToken;
@synthesize forceRestart;
@synthesize entitiesToSync;
@synthesize imageDatabasePath;
@synthesize blobServiceURL;
@synthesize area;
@synthesize downloadSyncInProgress;
@synthesize alert;
@synthesize notSyncedEntities;
@synthesize entitiesToSyncCount;

enum MediaTypeConstant
{
    kMediaPict = 1,
    kMediaFplan = 2,
    kMediaMini  = 3
};

-(id)init:(NSString *)serviceURL
{
    self= [super init];
    if (self)
    {
        dataServiceURL = serviceURL;
        downloadSyncInProgress = NO;
    }
    return self;
}

#pragma mark -
#pragma mark public execute requests methods
-(void)dumpChangedEntities
{
    [self loadSyncContext];
    NSArray *resultEntityList = [self createEntityList];
  
    NSLog(@"New dump");
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rowStatus == 'I') OR (rowStatus == 'U') OR (rowStatus == 'D')"];
    for (SyncInformation *syncInf in resultEntityList) 
    {
        NSArray *results = [AxDataManager dataListEntity:syncInf.syncEntityName andSortBy:@"rowStatus" andPredicate:predicate];
        
        for(NSObject *object in results)
        {
            RealPropInfo *prop = (RealPropInfo *)object;
            NSLog(@"0x%lx '%@' '%@'------------------------------", (long)object, NSStringFromClass([object class]), prop.rowStatus); 
            NSLog(@"%@", object);
        }
    }
    
    syncContext = nil;
}


//
// Gets the list of entities to sync.
//
-(void)executeGetEntityListToUpload
{
    @autoreleasepool
    {
        syncStagingGUID = @"";
        actualSyncDirection = syncDirectionUpload;
        [self loadSyncContext];
        //NSArray *resultEntityList;
        NSMutableArray *myresultEntityList;
        
        NSArray *resultEntityList = myresultEntityList;
        if (forceRestart)
        {
            resultEntityList = [self createEntityList];
        }
        else 
        {
            NSString *resumeStagingGuid;
            resultEntityList = [self getArrayOfEntitiesToResumeWithDirection:actualSyncDirection stagingGUID:&resumeStagingGuid ];
            if (resultEntityList == nil)
            {
                resultEntityList = [self createEntityList];
            }
            else 
            {
                syncStagingGUID = resumeStagingGuid;
            }
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rowStatus == 'I') OR (rowStatus == 'U') OR (rowStatus == 'D')"];
        
        for (SyncInformation *syncInf in resultEntityList) 
        {
            // handle the special case for NoteInstance
            if([syncInf.syncEntityName caseInsensitiveCompare:@"NoteInstance"]==NSOrderedSame)
            {
                // Add all the different types of notes
                int count = 0;
                count += [AxDataManager countEntities:@"NoteRealPropInfo" andPredicate:predicate andContext:syncContext];                
                count += [AxDataManager countEntities:@"NoteHIExmpt" andPredicate:predicate andContext:syncContext];                
                count += [AxDataManager countEntities:@"NoteSale" andPredicate:predicate andContext:syncContext];                
                count += [AxDataManager countEntities:@"NoteReview" andPredicate:predicate andContext:syncContext];     
                syncInf.numberOfEntitiesToSync = count;
            }
            else 
                syncInf.numberOfEntitiesToSync = [AxDataManager countEntities:syncInf.syncEntityName andPredicate:predicate andContext:syncContext];
        }
        
        entitiesToSync = resultEntityList;
        [self loadLastSyncDate:actualSyncDirection];
        if ([self.delegate respondsToSelector:@selector(synchronizatorGetEntityListToUploadDone:lastSyncDate:)])
        {
            [self performSelectorOnMainThread:@selector(callGetEntityListToUploadDone:) withObject:resultEntityList waitUntilDone:YES];
        }
        syncContext = nil;
    }
}



// 10/1/14 HNN
// user must be copying from web and pasting because they're were some extended characters in their notes
// and either json or html post did not like it. I'm scrubbing the data here so that the executeUploadNewEntitiesSync
// works. the bad thing was that the executeUploadNewEntitiesSync never returned any errors
//
// used in executeUploadEntitesSynchronous
-(NSString *)scrubAscii:(NSString *)input
{
    NSString *tmp2=[[NSString alloc]init];
    tmp2=@"";
    for (int cntr=0; cntr < [input length]; cntr++) {
        int asciiCode=[input characterAtIndex:cntr];
        if (asciiCode < 127)
            tmp2=[tmp2 stringByAppendingString:[[input substringFromIndex:cntr]substringToIndex:1]];
        else
            tmp2=[tmp2 stringByAppendingString:@" "];
    }
    return tmp2;
}
//
// Starts the synchronization process for the entities in the list synchronous.
//
-(void)executeUploadEntitesSynchronous:(NSMutableArray *)entityKinds
{
    @autoreleasepool
    {
        NSError *error;
        syncInProgress = YES;
        actualEntityKindIndex = 0;
        totalImagesToUpload = 0;
        serverSyncDate = 0;
        actualSyncDirection = syncDirectionUpload;
        if (self.requester == nil) 
        {
            self.requester = [[Requester alloc]init:dataServiceURL];
        }
        self.requester.delegate = self;
        entitiesToSync = entityKinds;
        
        if (forceRestart || [syncStagingGUID compare:@""]  == NSOrderedSame)
        {
            syncStagingGUID = [Synchronizator createNewGuid];
            [self saveInitialSyncTrace:entityKinds withSyncDirection:syncDirectionUpload andStaginGuind:syncStagingGUID andNumbersOfRecordsToDownload:0 error:&error];
        }
        
        if ([self.delegate respondsToSelector:@selector(synchronizatorBeforeStartSync:)])
        {
            [self performSelectorOnMainThread:@selector(callBeforeStartSync:) withObject:entitiesToSync waitUntilDone:YES];
        }
        
        [self loadSyncContext];
        [self saveSyncStep:syncStepUploadingEntities IsStarting:YES withError:&error];
        
        
        NSArray *mediaEntityKinds = [self createMediaEntityList];
        
        self.notSyncedEntities = 0;
        self.entitiesToSyncCount = 0;
        
        for (SyncInformation *actEntKind in entitiesToSync) // records returned in correct dependency order
        {
            actEntKind.syncStatus = syncStatusInProgress;
            if ([self.delegate respondsToSelector:@selector(synchronizatorUploadOneEntityStarts:)])
            {
                EntityStartStatus *newStatus = [[EntityStartStatus alloc]init];
                newStatus.totalEntities = [entitiesToSync count];
                newStatus.actualEntityIndex = actualEntityKindIndex + 1;
                newStatus.entityKind = actEntKind.syncEntityName;
                [self performSelectorOnMainThread:@selector(callUploadOneEntityStarts:) withObject:newStatus waitUntilDone:NO];
            }
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(rowStatus == 'I') OR (rowStatus == 'U') OR (rowStatus == 'D')"]; 
            NSArray *entitiesArray = [AxDataManager dataListEntity:actEntKind.syncEntityName andSortBy:nil andPredicate:predicate withContext:syncContext ];
            
            ///////
            //NSMutableArray *saledependsArray = [[NSMutableArray alloc]init];

          //  NSMutableArray *myresultEntityList = entitiesArray;

            //NSArray *resultEntityList = myresultEntityList;

            ///////////
            
            int count = [entitiesArray count];
            // Remove the entities that shouldn't be synched
            
//            BOOL _syncSaleDepends = '\0' ;
//            if ([actEntKind.syncEntityName isEqualToString:@"Sale"])
//                _syncSaleDepends = TRUE;
//            
            entitiesArray = [self removeBookmarkError:entitiesArray name:actEntKind.syncEntityName withContext:syncContext];
//            //////
//            if (_syncSaleDepends) {
//                                
//                //for(NSManagedObject *object in entitiesArray)
//                //NSObject *obj =
//                //{
//                    // get the realPropInfo
//                    if(![OpenEntity checkBookmarkError:@"SaleVerif" withContext:syncContext])
//                        //[array addObject:object];
//                        [saledependsArray addObject:object];
//                //}
//                
//                //return saledependsArray;
//            }
            ////////////////
            if([entitiesArray count]!=count)
            {
                int delta = (count - [entitiesArray count]);
                self.notSyncedEntities += delta;
            }
            
            NSManagedObject *actualEntity;
            self.entitiesToSyncCount += [entitiesArray count];
            
            BOOL goodRec=NO;
            NSString *rowStatus=@"";
            for (actualEntity in entitiesArray)
            {
                goodRec=NO; // good recs have parent relationship else they are deleted records
                rowStatus = [actualEntity valueForKey:@"rowStatus"];
                
                // 8/22/13 HNN fix key data if missing
                if([actualEntity isKindOfClass:[ResBldg class]])
                {
                    ResBldg *bldg = (ResBldg*)actualEntity;

                    if ([rowStatus isEqualToString:@"I"] || [rowStatus isEqualToString:@"U"]);
                    goodRec=YES;
                    NSString * bldgGuid = [actualEntity valueForKey:@"guid"];
                    
                    // 5/18/16 cv check if rpinfo is set
                    if ([actualEntity valueForKey:@"realPropInfo"] == nil)
                    {
                        goodRec=NO;
                    }

                    
                    if ([bldgGuid length]==0 && goodRec==YES)
                    bldg.guid = [Synchronizator createNewGuid];
                }
                
                else if ([actualEntity isKindOfClass:[Permit class]])
                {
                    Permit *permit = (Permit*)actualEntity;
                    if ([rowStatus isEqualToString:@"I"] || [rowStatus isEqualToString:@"U"]);
                    goodRec=YES;
                    NSString * permitGuid = [actualEntity valueForKey:@"guid"];
                    if ([permitGuid length]==0 && goodRec==YES)
                        permit.guid = [Synchronizator createNewGuid];
              
                }
                
                else if([actualEntity isKindOfClass:[EnvRes class]])
                {
                    EnvRes *envres=(EnvRes *) actualEntity;
                    Land *land = envres.land;
                    if (land!=nil)
                        goodRec=YES;

                    NSString * landGuid = [actualEntity valueForKey:@"lndGuid"];
                    if ([landGuid length]==0 && goodRec==YES)
                        envres.lndGuid=land.guid;
                }

                else if([actualEntity isKindOfClass:[MHAccount class]])
                {
                    MHAccount *mhAcct=(MHAccount *) actualEntity;
                    RealPropInfo *rpinfo = mhAcct.realPropInfo;
                    if (rpinfo !=nil)
                        goodRec=YES;

                    NSString * rpGuid = [actualEntity valueForKey:@"rpGuid"];
                    NSString * mhGuid = [actualEntity valueForKey:@"guid"];
                    if ([rpGuid length] == 0 && goodRec==YES)
                        mhAcct.rpGuid=rpinfo.guid;
                    if ([mhGuid length]==0 && goodRec==YES)
                        mhAcct.guid=[Synchronizator createNewGuid];
                }

                else if([actualEntity isKindOfClass:[SaleWarning class]])
                {
                    SaleWarning *warn=(SaleWarning *) actualEntity;
                    Sale *sale = warn.sale;
                    if (sale!=nil)
                        goodRec=YES;

                    NSString * saleGuid = [actualEntity valueForKey:@"saleGuid"];
                    if ([saleGuid length]==0 && goodRec==YES)
                        warn.saleGuid=sale.guid;
                }
//                else if([actualEntity isKindOfClass:[Sale class]])
//                {
//                    Sale *sale=(Sale *)actualEntity;
//                    //SaleVerif *saleVerif= sale.saleVerif;
//                    NSSet *saleVerif = sale.saleVerif;
////                    SaleVerif *saleVerif=(SaleVerif *) actualEntity;
////                    Sale *sale = saleVerif.sale;
////                    if (sale!=nil)
//                    
//                        goodRec=YES;
//                    
//                    NSString * saleGuid = [actualEntity valueForKey:@"saleGuid"];
//                    if ([saleGuid length]==0 && goodRec==YES)
//                        saleVerif.saleGuid=sale.guid;
//                }

                else if([actualEntity isKindOfClass:[SaleVerif class]])
                {
                    SaleVerif *saleVerif=(SaleVerif *) actualEntity;
                    Sale *sale = saleVerif.sale;
                    if (sale!=nil)
                        goodRec=YES;
                    
                    NSString * saleGuid = [actualEntity valueForKey:@"saleGuid"];
                    if ([saleGuid length]==0 && goodRec==YES)
                        saleVerif.saleGuid=sale.guid;
                }

                else if([actualEntity isKindOfClass:[NoteRealPropInfo class]])
                {
                    NoteRealPropInfo *note=(NoteRealPropInfo *) actualEntity;
                    RealPropInfo *rpInfo=note.realPropInfo;
                    if (rpInfo!=nil)
                        goodRec=YES;

                    NSString *srcGuid = [actualEntity valueForKey:@"srcGuid"];
                    //int key = [[actualEntity valueForKey:@"key"]intValue];
                    if ([srcGuid length]==0 && goodRec==YES)
                    {
                        //if ([rpInfo.noteGuid length]==0)
                        //{
                            // create new noteid
                        note.guid =[Synchronizator createNewGuid];
                        note.src=@"realprop";
                        
                    }
                    //  if (noteInstance==0 && goodRec==YES)
                    //      {
                    //       int max = 1000000;
                    //       NoteInstance *instance;
                    //       for(instance in rpInfo.noteRealPropInfo)
                    //           {
                    //             if(instance.noteInstance > max)
                    //                 max = instance.noteInstance;
                    //           }
                    //           note.noteInstance = max+1;
                    //       }
                    if ([srcGuid length]==0 && goodRec==YES)
                        note.src=@"realprop";
                    
                    if(goodRec==YES)
                        note.note = [self scrubAscii:note.note];

                }
                
                else if([actualEntity isKindOfClass:[NoteSale class]])
                {
                    NoteSale *note=(NoteSale *) actualEntity;
                    Sale *sale=note.sale;
                    if (sale!=nil)
                        goodRec=YES;

                    NSString *srcGuid = [actualEntity valueForKey:@"srcGuid"];
                    if ([srcGuid length]==0 && goodRec==YES)
                    {
                        if ([note.guid length]==0)
                        {
                            // create new noteGuid
                            note.guid = [Synchronizator createNewGuid];
                            note.src =@"sale";
                        }
                        
                    }
                    if ([srcGuid length]==0 && goodRec==YES)
                        note.src=@"sale";
                    if(goodRec==YES)
                        note.note = [self scrubAscii:note.note];

                }
                else if([actualEntity isKindOfClass:[NoteReview class]])
                {
                    NoteReview *note=(NoteReview *) actualEntity;
                    Review *review=note.review;
                    if (review!=nil)
                        goodRec=YES;

                    NSString * srcGuid = [actualEntity valueForKey:@"srcGuid"];
                    if ([srcGuid length]==0 && goodRec==YES)
                    {
                            if ([note.srcGuid length]==0)
                        {
                            // create new noteid
                            note.guid = [Synchronizator createNewGuid];
                            note.src=@"review";
                        }                        
                    }
                    //  if (noteInstance==0 && goodRec==YES)
                    //      {
                    //       int max = 1000000;
                    //       NoteInstance *instance;
                    //       for(instance in rpInfo.noteRealPropInfo)
                    //           {
                    //             if(instance.noteInstance > max)
                    //                 max = instance.noteInstance;
                    //           }
                    //           note.noteInstance = max+1;
                    //       }
                    if ([srcGuid length]==0 && goodRec==YES)
                        note.src=@"review";
                    if(goodRec==YES)
                        note.note = [self scrubAscii:note.note];
                }
                else if([actualEntity isKindOfClass:[NoteHIExmpt class]])
                {
                    NoteHIExmpt *note=(NoteHIExmpt *) actualEntity;
                    HIExmpt *hiExmpt=note.hIExmpt;
                    if (hiExmpt!=nil)
                        goodRec=YES;

                    NSString * srcGuid = [actualEntity valueForKey:@"srcGuid"];
                    //NSString *src = [actualEntity valueForKey:@"src"];
                    if ([srcGuid length]==0 && goodRec==YES)
                    {
                        if ([note.srcGuid length]==0)
                        {
                            // create new noteid
                            note.guid = [Synchronizator createNewGuid];
                            note.src=@"hiExmpt";
                        }
                        
                    }
                    //  if (noteInstance==0 && goodRec==YES)
                    //      {
                    //       int max = 1000000;
                    //       NoteInstance *instance;
                    //       for(instance in rpInfo.noteRealPropInfo)
                    //           {
                    //             if(instance.noteInstance > max)
                    //                 max = instance.noteInstance;
                    //           }
                    //           note.noteInstance = max+1;
                    //       }
                    if ([srcGuid length]&& goodRec==YES)
                        note.src=@"hiexmpt";
                    if(goodRec==YES)
                        note.note = [self scrubAscii:note.note];
                }

                else if([actualEntity isKindOfClass:[Accy class]])
                {
                    Accy *accy=(Accy *) actualEntity;
                    RealPropInfo *rpinfo = accy.realPropInfo;
                    Land *land;
                    if (rpinfo!=nil)
                        land= rpinfo.land;
                    if (land!=nil)
                        goodRec=YES;
                    
//                    NSString * landGuid = [actualEntity valueForKey:@"landGuid"];
                    NSString * rpGuid = [actualEntity valueForKey:@"rpGuid"];
//                    NSString * bldgGuid = [actualEntity valueForKey:@"bldgGuid"];
//                    if ([landGuid length]==0 && goodRec==YES)
                    if ([rpGuid length]==0 && goodRec==YES)
//                        accy.landGuid = land.guid;
                        accy.rpGuid = rpinfo.guid;
//                    if ([bldgGuid length]==0 && goodRec==YES)
//                    {
//                        for(ResBldg *bldg in land.resBldg)
//                        {
//                            if(bldg.bldgNbr == 1)
//                            {
//                                bldgGuid=bldg.guid;
//                                break;
//                            }
//                            else if ([bldgGuid length]==0)
//                                bldgGuid = bldg.guid;  // set bldgid to first bldg record if can't find bldgnbr=1
//                        }
                        
//                        accy.landGuid = landGuid;
//                    }
                }
                
                else if([actualEntity isKindOfClass:[MHCharacteristic class]])
                {
                    MHCharacteristic *mhChar=(MHCharacteristic *) actualEntity;
                    MHAccount *mhAcct = mhChar.mHAccount;
                    if (mhAcct!=nil)
                        goodRec=YES;
                    
                    NSString * mhGuid = [actualEntity valueForKey:@"mhGuid"];
                    if ([mhGuid length]==0 && goodRec==YES)
                        mhChar.mhGuid = mhAcct.guid;
                }
                
                else if([actualEntity isKindOfClass:[MHLocation class]])
                {
                    MHLocation *mhLoc=(MHLocation *) actualEntity;
                    MHAccount *mhAcct = mhLoc.mHAccount;
                    if (mhAcct!=nil)
                        goodRec=YES;
                    
                    NSString * mhGuid = [actualEntity valueForKey:@"mhGuid"];
                    if ([mhGuid length]==0 && goodRec==YES)
                        mhLoc.mhGuid=mhAcct.guid;
                }
                
                else if([actualEntity isKindOfClass:[MediaAccy class]])
                {
                    MediaAccy *media=(MediaAccy *) actualEntity;
                    Accy *accy = media.accy;
                    if (accy!=nil)
                        goodRec=YES;
                    
                    NSString * guid = [actualEntity valueForKey:@"guid"];
                    //int lineNbr = [[actualEntity valueForKey:@"lineNbr"]intValue];
                    if ([guid length]==0 && goodRec==YES)
                        media.accyGuid= accy.guid;
                    //if (lineNbr==0 && goodRec==YES)
                    //    media.lineNbr=accy.lineNbr;
                }
                
                else if([actualEntity isKindOfClass:[MediaBldg class]])
                {
                    MediaBldg *media=(MediaBldg *) actualEntity;
                    ResBldg *bldg = media.resBldg;
                    if (bldg!=nil)
                        goodRec=YES;
                    
                    NSString * bldgGuid = [actualEntity valueForKey:@"bldgGuid"];
                    if ([bldgGuid length] == 0 && goodRec==YES)
                        media.bldgGuid=bldg.guid;
                }
                
                else if([actualEntity isKindOfClass:[MediaLand class]])
                {
                    MediaLand *media=(MediaLand *) actualEntity;
                    Land *land = media.land;
                    if (land!=nil)
                        goodRec=YES;
                    
                    NSString * landGuid = [actualEntity valueForKey:@"guid"];
                    if ([landGuid length]==0 && goodRec==YES)
                        media.lndGuid=land.guid;
                }
                
                else if([actualEntity isKindOfClass:[MediaMobile class]])
                {
                    MediaMobile *media=(MediaMobile *) actualEntity;
                    MHAccount *mhAcct = media.mHAccount;
                    if (mhAcct!=nil)
                        goodRec=YES;
                    
                    NSString * mhGuid = [actualEntity valueForKey:@"mhGuid"];
                    if ([mhGuid length] == 0 && goodRec==YES)
                        media.mhGuid=mhAcct.guid;
                }
                
                else if([actualEntity isKindOfClass:[MediaNote class]])
                {
                    MediaNote *media=(MediaNote *) actualEntity;
                    NoteInstance *note = media.noteInstance;
                    if (note!=nil)
                        goodRec=YES;
                    
                    NSString * noteGuid = [actualEntity valueForKey:@"guid"];
                    //int instanceId = [[actualEntity valueForKey:@"instanceId"]intValue];
                    //if (([noteGuid length]==0 && goodRec==YES) || (instanceId==0 && goodRec==YES))
                    if ([noteGuid length] == 0 && goodRec==YES)
                        media.noteGuid= note.guid;
                        //if (instanceId==0 && goodRec==YES)
                        //media.instanceId=note.noteInstance;
                }
                
                else
                    goodRec=YES;
                
                if (goodRec==YES)
                    [actualEntity setValue:syncStagingGUID forKey:@"stagingGUID"]; // only upload good records
                else if ([rowStatus isEqualToString: @"I"] || [rowStatus isEqualToString: @"U"] || [rowStatus isEqualToString: @"D"])
                    [actualEntity setValue:[@"B" stringByAppendingString:rowStatus] forKey:@"rowStatus"]; // prefix rowstatus with B so we can identify later if we need to. this will remove the record from the change list and counts. these records were probably deleted or there was an error creating them, either way, can't link it to anything.                    
                    
            }

            
            [syncContext save:&error];
            if (error != nil) 
            {
                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                return;
            }
            else 
            {   
                // Call the main thread with the error message (network/malformed)
                error = [self.requester executeUploadNewEntitiesSync:entitiesArray ofKind:actEntKind.syncEntityName withToken:securityToken];
                if (error != nil) 
                {
                    [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                    return;
                }
            }
            for (actualEntity in entitiesArray) 
            {
                if([[actualEntity valueForKey:@"rowStatus"] isEqualToString:@"I"])
                {
                    if ([mediaEntityKinds indexOfObject:actEntKind.syncEntityName] != NSNotFound)
                    {
                        totalImagesToUpload++;
                    }
                }
            }
            [syncContext save:&error];
            if (error != nil)
            {
                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                return;
            }
            
            [self updateSyncTrace:actEntKind.syncEntityName withStatus:syncStatusDone andSyncDirection:syncDirectionUpload error:&error];
            actEntKind.syncStatus = syncStatusDone;
            actualEntityKindIndex++;
        }
        [self closeSyncTraceDirection:actualSyncDirection error:&error];
        
        [self uploadImages:mediaEntityKinds withStagingGuid:syncStagingGUID error:&error];
        if (error != nil) 
        {
            [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
            return;
        }
        else 
        {
            syncInProgress = NO;
            if ([self.delegate respondsToSelector:@selector(synchronizatorUploadEntitiesDone:)])
                [self performSelectorOnMainThread:@selector(callUploadEntitiesDone) withObject:error waitUntilDone:NO];
        }
        [self saveSyncStep:syncStepUploadingEntities IsStarting:NO withError:&error];
    }
}

-(NSArray *)removeBookmarkError:(NSArray *)entitiesArray name:(NSString *)syncEntityName withContext:(NSManagedObjectContext *)aContext
{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    for(NSManagedObject *object in entitiesArray)
    {
        // get the realPropInfo
        if(![OpenEntity checkBookmarkError:object withContext:aContext])
            [array addObject:object];
    }
    return array;
}
//
// Do an upload of entities images and download the new entities.
//
-(void)executeFullSyncCircle:(NSMutableArray *)entityKinds
{
    prefContext = nil;
    [self executeUploadEntitesSynchronous:entityKinds];
    
    //[self executeAfterUploadProcess];
}

-(void)executeAutomaticDownload
{
    //@autoreleasepool
    {
        downloadSyncInProgress = YES;
       [self executeAfterUploadProcess];
        //[self finishAlert];
    }
}

//
// Do an upload of entities and download the ValEst for Calculate Estiamtes.
//
//-(void)executeSyncEntitiesForCalculateEstimates:(CalcEstimationParameter *)paraData
//{
//    @autoreleasepool 
//    {
//        NSError *error;
//        syncInProgress = YES;
//        actualEntityKindIndex = 0;
//        actualSyncDirection = syncDirectionUpload; 
//        syncStagingGUID = [Synchronizator createNewGuid];
//        if (self.requester == nil) 
//        {
//            self.requester = [[Requester alloc]init:dataServiceURL];
//        }
//        self.requester.delegate = self;
        
//        entitiesToSync = [[NSMutableArray alloc]initWithObjects:@"RealPropInfo", @"Land", @"XLand", @"EnvRes", @"Accy", @"ResBldg", @"MHAccount", @"MHCharacteristic", @"MHLocation", nil];

//        [self loadSyncContext];
//        NSMutableArray *landIds = [[NSMutableArray alloc]init];
//        for (NSString *actEntKind in entitiesToSync) 
//        {
//            NSPredicate *predicate;
//            if ([actEntKind isEqualToString:@"EnvRes"]) 
//            {
//                predicate = [NSPredicate predicateWithFormat:@"landId IN %@", landIds]; 
//            } 
//            else 
//            {
//                predicate = [NSPredicate predicateWithFormat:@"realPropId == %d", paraData.RealPropId];
//            }
            
//            NSArray *entitiesArray = [AxDataManager dataListEntity:actEntKind andSortBy:nil andPredicate:predicate withContext:syncContext ];
//            NSManagedObject *actualEntity;
//            BOOL isLand = NO;
//            if ([actEntKind isEqualToString:@"Land"]) 
//            {
//                isLand = YES;
//            }
//            for (actualEntity in entitiesArray) 
//            {
//                if (isLand) 
//                {
//                    NSNumber *val = [actualEntity valueForKey:@"landId"];
//                    [landIds addObject:val];
//                }
//                [actualEntity setValue:syncStagingGUID forKey:@"stagingGUID"];
//            }
//            [syncContext save:&error];
//            if (error != nil) 
//            {
//                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
//                return;
//            }
//            else 
//            {   
                // Call the main thread with the error message (network/malformed)
//                error = [self.requester executeUploadNewEntitiesSync:entitiesArray ofKind:actEntKind withToken:securityToken];
//                if (error != nil) 
//                {
//                    [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
//                    return;
//                }
//            }
//            actualEntityKindIndex++;
//        }
        
        //
        // Now, calls the cal estimates process and get the ValEst with the results.
        //
//        NSArray *valEstArr = [requester executeCalculateEstimatesSync:syncStagingGUID TaxYr:paraData.TaxYr Area:paraData.Area subArea:paraData.SubArea andApplGroup:paraData.ApplGroup withToken:securityToken error:&error];
//        if (error != nil) 
//        {
//            [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
//            return;
//        }
//        else 
//        {
//            NSArray *mediaEntityKinds = [self createMediaEntityList];
//            [self processDownloadedEntitiesFromArray:valEstArr ofKind:@"ValEst" withMediaArray:mediaEntityKinds ManageRowStatus:NO error:&error];
//            if (error != nil) 
//            {
//                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
//                return;
//            }
//            else 
//            {
//                syncInProgress = NO;
//            }
//        }
//        syncContext = nil;
//        if ([self.delegate respondsToSelector:@selector(synchronizatorSyncEntitiesForCalculateEstimatesDone:)])
//            [self performSelectorOnMainThread:@selector(callSyncEntitiesForCalculateEstimatesDone) withObject:error waitUntilDone:NO];
//    }
//}

//
// Excutes the process to finish the synchronization
//
-(void)executeAfterUploadProcess
{
    @try {
        prefContext = nil;
        requester= nil;
        self.requester = [[Requester alloc]init:dataServiceURL];
        self.requester.delegate = self;
        int actualStep = [self getActualSyncStep];
        continueAutomaticSync = YES;
        if (actualStep >= 0) 
        {
            int nextStep = [self getNextSyncStep:actualStep];
            double syncDate = [self getLastSyncDate];
            while (nextStep != -1 && continueAutomaticSync)
            {
                actualStep = nextStep;
                [self downloadDataFromNextStep:actualStep withGuid:syncStagingGUID andLastSyncDate:syncDate];
                nextStep = [self getNextSyncStep:actualStep];
            }
        }
        else
        {
            NSLog(@"Actual Step is wrong: %d", actualStep);
        }
        downloadSyncInProgress= NO;
        //cv it might need a sync complete Alert
        
        // get the time to refresh the cells
        //[_optionsList.tableView reloadData];
        
        //[self cleanUp];
//        UIAlertView *view2 = [[UIAlertView alloc] initWithTitle:@"Sync Complete!" message:@"Synchronization complete!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [view2 show];
        
        ///////////////////////
//        UIAlertView *alertFinish = [[UIAlertView alloc] initWithTitle:@"New Sync Comp" message:@"Sync Comp" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertFinish show];
//        alertFinish = nil;
        
        //[self finishAlert];
        //////////////////////////
        // Reset timer
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
        [self unload];
        //[self finishAlert];

    }
    @catch (NSException *exception)
    {
        downloadSyncInProgress = NO;
        NSLog("Exception in executeAfterUploadProcess: %@", exception);
    }
}

-(void)finishAlert
{
    UIAlertView *view2 = [[UIAlertView alloc]
        initWithTitle:@"Sync Complete!" message:@"Synchronization complete!"
        delegate:self
        cancelButtonTitle:@"Ok"
        otherButtonTitles:nil];
        view2.alertViewStyle = UIAlertViewStyleDefault;
        [view2 show];
    
    //this prevent the ARC to clean up :
        NSRunLoop *rl = [NSRunLoop currentRunLoop];
        NSDate *d;
        d= (NSDate*)[d init];
        while ([view2 isVisible]) {
            [rl runUntilDate:d];
        }
}

#pragma mark -
#pragma mark internal methods

-(int)getActualSyncStep
{
    int resultStep = -1;
    [self loadPrefContext];
    SyncActualStep *actSyncStep = [AxDataManager getEntityObject:@"SyncActualStep" andPredicate:nil andContext:prefContext];
    if (actSyncStep != nil)
    {
        if (actSyncStep.endDate != 0) 
        {
            if (actSyncStep.actualStep == SyncStepProcessingDownloadedEntities)
            {
                resultStep = syncStepGetValidationErrors;
            }
            else
            {
                resultStep = actSyncStep.actualStep;
            }
        }
        else
        {
            // 4/15/16 HNN bug fix: continue updating data from server once the data is downloaded to the preferences table or else
            // the user will lose the changes downloaded from the server because once the data is downloaded, the get changes date is updated.
            // can't go back a step if validating error else it'll jump to synctoprep
//            if (actSyncStep.actualStep == syncStepMovingDataFromSyncToPrep || actSyncStep.actualStep == SyncStepProcessingDownloadedEntities || actSyncStep.
            // 4/21/16 HNN bad fix including SyncStepProcessingDownloadedEntities because the call executeAfterUploadProcess increments the step after this
            // call; we need to subtract 1 here in order for us to stay on the same step
            if (actSyncStep.actualStep == syncStepMovingDataFromSyncToPrep  || actSyncStep.actualStep == syncStepGetValidationErrors)
            {
                resultStep = actSyncStep.actualStep;
            }
            else
            {
                resultStep = --actSyncStep.actualStep;
            }
        }
        
        syncStagingGUID = actSyncStep.stagingGuid;
        serverSyncDate = actSyncStep.serverSyncDate;
    }
    else 
    {
        resultStep = syncStepGetValidationErrors;
        serverSyncDate = 0;
    }
    
    if (resultStep < 0)
    {
        resultStep = 0;
    }

    return resultStep;
}

//
// Returns the next valid sync step or -1 if there is not a next step.
//
-(int)getNextSyncStep:(int)actualStep
{
    if (actualStep >= 0 && actualStep < SyncStepProcessingDownloadedEntities) 
    {
        return actualStep + 1;
    }
    else 
    {
        return -1;
    }
}
//getting & Bookmark
-(void)downloadDataFromNextStep:(int)nextStep withGuid:(NSString *)downloadStagingGuid andLastSyncDate:(double)lastSyncServerDate
{
    NSError *error;
    syncStep actualStep = nextStep;
    switch (actualStep) 
    {
        case syncStepMovingDataFromSyncToPrep:   ////Sync Changes
        {
            if ([self.delegate respondsToSelector:@selector(synchronizatorMoveDataFromSyncToPrepStarts:)])
                [self performSelectorOnMainThread:@selector(callMoveDataFromSyncToPrepStarts) withObject:nil waitUntilDone:NO];
            
            if ([self.delegate respondsToSelector:@selector(indicatorMessage:)])
                [self performSelectorOnMainThread:@selector(indicatorMessage:) withObject:@"Sync to Prep" waitUntilDone:NO];
            
            [self saveSyncStep:syncStepMovingDataFromSyncToPrep IsStarting:YES withError:&error];
            NSMutableArray *validationErrors;
            error = [requester executeMoveDataToPrepTablesWithStagingGuidSync:downloadStagingGuid withToken:securityToken andValidationErrors:&validationErrors];
            if (error != nil ) 
            {
                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                continueAutomaticSync = NO;
                return;
            }
            else 
            {
                syncInProgress = NO;
                if ([self.delegate respondsToSelector:@selector(synchronizatorUploadEntitiesDone:)])
                    [self performSelectorOnMainThread:@selector(callUploadEntitiesDone) withObject:error waitUntilDone:NO];
            }
            [self saveSyncStep:syncStepMovingDataFromSyncToPrep IsStarting:NO withError:&error];
        }
            break;
            
        case syncStepGetValidationErrors:
        {
            [self saveSyncStep:syncStepGetValidationErrors IsStarting:YES withError:&error];
            NSArray *validationErrors = [requester executeGetValidationErrors:downloadStagingGuid withToken:securityToken withError:&error];
            if (validationErrors != nil && [validationErrors count] > 0)
            {
                valErrorSyncGuid = [self saveValidationErrorsInToDB:validationErrors error:nil];
                
                [self performSelectorOnMainThread:@selector(callRequestDidFailByValidationErrors:) withObject:validationErrors waitUntilDone:YES];
            }
            if (error != nil )
            {
                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                continueAutomaticSync = NO;
                return;
            }
            else
            {
                [self updateRowStatus:validationErrors];
            }
            [self saveSyncStep:syncStepGetValidationErrors IsStarting:NO withError:&error];
        }
            break;
            
        case syncStepPopulatingPrepTables:
        {
           
            syncStagingGUID = [Synchronizator createNewGuid];
            serverSyncDate = [self.requester executeGetServerDateWithToken:securityToken withError:&error];
            if (error != nil)
            {
                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                continueAutomaticSync = NO;
                return;
            }
            [self saveSyncStep:syncStepPopulatingPrepTables IsStarting:YES withError:&error];
            if ([self.delegate respondsToSelector:@selector(indicatorMessage:)])
                [self performSelectorOnMainThread:@selector(indicatorMessage:) withObject:@"Populate Tables" waitUntilDone:NO];
            
            [self.requester executePopulatePrepTablesForStagingGuid:syncStagingGUID LastSyncDate:lastSyncServerDate Area:area andToken:securityToken withError:&error];
            
            if (error != nil) 
            {
                
                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                continueAutomaticSync = NO;
                return;
            }
            [self saveSyncStep:syncStepPopulatingPrepTables IsStarting:NO withError:&error];

        }
            break;
            
        case syncStepDownloadingEntites:
        {
            if ([self.delegate respondsToSelector:@selector(indicatorMessage:)])
                [self performSelectorOnMainThread:@selector(indicatorMessage:) withObject:@"Download Data" waitUntilDone:NO];
            
            [self downloadEntities];
        }
            break;
            
        case SyncStepProcessingDownloadedEntities:
        {
            if ([self.delegate respondsToSelector:@selector(indicatorMessage:)])
                [self performSelectorOnMainThread:@selector(indicatorMessage:) withObject:@"Update Data" waitUntilDone:NO];
            [self updateEntities];
        }
            break;
            
        default:
            break;
    }
}

-(void)updateRowStatus:(NSArray *)validationErrors
{
    NSError *error;
    
    [self loadSyncContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"entityGuid CONTAINS[cd] %@", @""];
    NSArray *filteredArray;
    filteredArray = [validationErrors filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] == 0)
    {
        NSArray *syncEntityKinds = [self createEntityList];
        NSManagedObject *actualEntity;
        
        for (SyncInformation *actEntKind in syncEntityKinds)
        {
            
            predicate = [NSPredicate predicateWithFormat:@"(stagingGUID == %@)", syncStagingGUID];
            NSArray *entitiesArray = [AxDataManager dataListEntity:actEntKind.syncEntityName andSortBy:nil andPredicate:predicate withContext:syncContext ];
            for (actualEntity in entitiesArray)
            {
                NSString *entGuid = [actualEntity valueForKey:@"guid"];
                predicate = [NSPredicate predicateWithFormat:@"entityGuid == %@", entGuid];
                
                filteredArray = [validationErrors filteredArrayUsingPredicate:predicate];
                if ([filteredArray count] == 0)
                {
                    if([[actualEntity valueForKey:@"rowStatus"] isEqualToString:@"D"])
                    {
                        // Delete the entity
                        [syncContext deleteObject:actualEntity];
                    }
                    else
                    {
                        [actualEntity setValue:@"" forKey:@"rowStatus"];
                    }
                }
            }
        }
        [syncContext save:&error];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.alert == alertView)
    {
        if (buttonIndex == 0)
        {
            [self updateEntities];
        }
    }
}

-(void)updateEntities
{
    NSError *error = nil;
    
    [self saveSyncStep:SyncStepProcessingDownloadedEntities IsStarting:YES withError:&error];
    [self processDownloadedJsonEntities:&error];
    if (error != nil)
    {
        [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
        return;
    }
    [self saveSyncStep:SyncStepProcessingDownloadedEntities IsStarting:NO withError:&error];
    [self closeSyncTraceDirection:actualSyncDirection error:&error];
    if ([self.delegate respondsToSelector:@selector(synchronizatorDownloadEntitiesDone:)])
        [self performSelectorOnMainThread:@selector(callDownloadEntitiesDone) withObject:nil waitUntilDone:NO];
    downloadSyncInProgress = NO;
    ////////////////////////////////////////////////////
    //[self saveLastSyncDate:serverSyncDate withError:&error];
    ////////////////////////////////////////////////////
    

}

-(void)downloadEntities
{
    NSError *error;
    syncInProgress = YES;
    actualSyncDirection = syncDirectionDownload;
    actualEntityKindIndex = 0;
    [self loadSyncContext];
    if (self.requester == nil) 
    {
        self.requester = [[Requester alloc]init:dataServiceURL];
    }
    self.requester.delegate = self;
    NSMutableArray * entityKinds = [self createEntityList];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    entityKinds = [[entityKinds sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    [self saveSyncStep:syncStepDownloadingEntites IsStarting:YES withError:&error];
    long totalRecordsToDownload = 0;
    
    entitiesToSync = [self.requester executeGetEntitiesToDownload:syncStagingGUID withToken:securityToken withError:&error];
    if (error != nil)
    {
        [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
        return;
    }
    
    if ([entitiesToSync count] > 0)
    {        
        [self saveInitialSyncTrace:[entitiesToSync mutableCopy] withSyncDirection:syncDirectionDownload andStaginGuind:@"" andNumbersOfRecordsToDownload:totalRecordsToDownload error:&error];
        
        if ([self.delegate respondsToSelector:@selector(synchronizatorBeforeStartSync:)])
        {
            [self performSelectorOnMainThread:@selector(callBeforeStartSync:) withObject:entitiesToSync waitUntilDone:YES];
        }
        int numberOfEntitiesToSync = 0;
        for (SyncInformation *actEntKind in entitiesToSync)
            numberOfEntitiesToSync += actEntKind.numberOfEntitiesToSync;
        
        for (SyncInformation *actEntKind in entitiesToSync)
        {
            NSString *display = [NSString stringWithFormat:@"Getting %d %@", actEntKind.numberOfEntitiesToSync, actEntKind.syncEntityName];

            if ([self.delegate respondsToSelector:@selector(indicatorMessage:)])
            {
                [self performSelectorOnMainThread:@selector(indicatorMessage:) withObject:display waitUntilDone:NO];
            }
            
            
            error = nil;
            actEntKind.syncStatus = syncStatusInProgress;
            if ([self.delegate respondsToSelector:@selector(synchronizatorDownloadOneEntityStarts:)])
            {
                EntityStartStatus *newStatus = [[EntityStartStatus alloc]init];
                newStatus.totalEntities = [entitiesToSync count];
                newStatus.actualEntityIndex = actualEntityKindIndex + 1;
                newStatus.entityKind = actEntKind.syncEntityName;
                [self performSelectorOnMainThread:@selector(callDownloadOneEntityStarts:) withObject:newStatus waitUntilDone:NO];
            }
            NSString *jSonEntityList = [self.requester executeGetEntitiySynchronous:actEntKind.syncEntityName usingToken:securityToken withStagingGuid:syncStagingGUID withError:&error];
            if (error == nil) 
            {
                [self saveDownloadedJsonEntitiesString:jSonEntityList ofKind:actEntKind.syncEntityName withError:&error];
                if (error != nil) 
                {
                    [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                    return;
                } 
            }
            else 
            {
                [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
                return;
            }
            actEntKind.syncStatus = syncStatusDone;
            actualEntityKindIndex++;
        }
        ////////////////////////////////////////////////////
        [self saveLastSyncDate:serverSyncDate withError:&error];
        ////////////////////////////////////////////////////
        
        if (error != nil)
        {
            [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
            return;
        }
    }
    [self saveSyncStep:syncStepDownloadingEntites IsStarting:NO withError:&error];
    syncContext = nil;
}

-(double)getLastSyncDate
{
    double resultValue = 0.0;
    [self loadSyncContext];
    NSArray *syncDateArray = [AxDataManager dataListEntity:@"DatabaseDate" andPredicate:nil andSortBy:@"lastUpdateDate" sortAscending:YES withContext:syncContext];
    if ([syncDateArray count] > 0)
    {
        DatabaseDate *syncDate = [syncDateArray objectAtIndex:0];
        resultValue = syncDate.lastUpdateDate;
    }
    return resultValue;
}

-(void)saveLastSyncDate:(double)newSyncDate withError:(NSError **)error
{
    if (error) 
        *error= nil;
    NSError *myError;
    [self loadSyncContext];
    DatabaseDate *syncDate;
    NSArray *syncDateArray = [AxDataManager dataListEntity:@"DatabaseDate" andPredicate:nil andSortBy:@"lastUpdateDate" sortAscending:YES withContext:syncContext];
    if ([syncDateArray count] == 0)
    {
        syncDate = [AxDataManager getNewEntityObject:@"DatabaseDate" andContext:syncContext];
    }
    else 
    {
        syncDate = [syncDateArray objectAtIndex:0];
    }
    syncDate.lastUpdateDate = newSyncDate;
    [syncContext save:&myError];
    if (myError != nil)
    {
        *error = myError;
        return;
    }
}

-(void) processDownloadedJsonEntities:(NSError **)error
{
    if (error) 
        *error= nil;
    NSError *myError;
    [self loadPrefContext];
    Synchronization *sync;
    sync = [AxDataManager getEntityObject:@"Synchronization" andPredicate:[NSPredicate predicateWithFormat:@"syncDirection=%d",syncDirectionDownload] andContext:prefContext];
    if (sync != nil) 
    {
        NSArray *mediaEntityKinds = [self createMediaEntityList];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *syncEntities =  [sync.entities sortedArrayUsingDescriptors:sortDescriptors];
        
        for (SyncEntity *syncEnt in syncEntities)
        {
            //also capture syncEntities to chek difference
            if (syncEnt.syncStatus != syncStatusProcessed)
            {
                NSDictionary *jsonDictionary = [BaseRequest parseDataFromString:syncEnt.jsonEntities];
                NSArray *jsonEntitiesArray = [jsonDictionary valueForKey:@"d"];
                //file x deletion have only guid,rowStatus,sstatus,stagingGuid
                [self processDownloadedEntitiesFromArray:jsonEntitiesArray ofKind:syncEnt.entityKind withMediaArray:mediaEntityKinds ManageRowStatus:YES error:&myError ];
                if (myError != nil)
                {
                    *error = myError;
                    return;
                }
                syncEnt.syncStatus = syncStatusProcessed;
            }
        }
        
        [prefContext save:&myError];
        if (myError != nil)
        {
            *error = myError;
            return;
        }
    }
    [self downloadImages:&myError];
    if (myError != nil)
    {
        *error = myError;
        return;
    }
}

-(void) saveDownloadedJsonEntitiesString:(NSString *)jSonEntities ofKind:entityKind withError:(NSError **)error
{
    if (error) 
        *error= nil;
    NSError *myError;
    [self loadPrefContext];
    Synchronization *sync;
    sync = [AxDataManager getEntityObject:@"Synchronization" andPredicate:[NSPredicate predicateWithFormat:@"syncDirection=%d",syncDirectionDownload] andContext:prefContext];
    if (sync != nil) 
    {
        NSSet *syncEntities = sync.entities;
        
        NSEnumerator * syncEntEnumerator = [syncEntities objectEnumerator];
        SyncEntity *syncEnt;
        BOOL found = NO;
        while (!found && (syncEnt = [syncEntEnumerator nextObject])) 
        {
            // cv 5/13/15 I have to use this case for Landfootage vs LandFootage.... unreal where the object is set lowercase
            //if ([syncEnt.entityKind isEqualToString:entityKind])
            if( [syncEnt.entityKind caseInsensitiveCompare:entityKind] == NSOrderedSame )
            {
                found = YES;
            }
        }
        if (found) 
        {
            syncEnt.syncStatus = syncStatusDownloaded;
            syncEnt.jsonEntities = jSonEntities;
            [prefContext save:&myError];
            if (myError != nil)
            {
                *error = myError;
                return;
            }
        }
    }
}

-(NSString *) saveValidationErrorsInToDB:(NSArray *)errors error:(NSError **)error
{
    [self loadPrefContext];
    SyncErrorInformation *valError;
    NSString *syncGuid = [Synchronizator createNewGuid];
    NSTimeInterval syncDate =  [NSDate timeIntervalSinceReferenceDate];
    for (valError in errors) 
    {
        if([valError.entityKind length]!=0  && (![valError.entityKind isEqualToString:@"iXLand"] ))
        {
            // Create an error bookmark
            // 3/20/2015 cv Remove i from object
            valError.entityKind = [valError.entityKind substringFromIndex:1];

            [self createBookmark:valError];
        }
        else
        {
            // Store it in the database
            SyncValidationError * valErrorToInsert = [AxDataManager getNewEntityObject:@"SyncValidationError" andContext:prefContext];
            valErrorToInsert.entityGuid = valError.entityGuid;
            valErrorToInsert.entityKind = valError.entityKind;
            valErrorToInsert.errorMsg = valError.errorMessage;
            valErrorToInsert.syncGuid = syncGuid;
            valErrorToInsert.date = syncDate;
            valErrorToInsert.area = [RealPropertyApp getWorkingArea];
        }
    }
    NSError *myError;
    [prefContext save:&myError];
    if (error != nil) {
        *error= myError;
    }
    return syncGuid;
}
//
// Create a bookmark of a property that has a sync error
//+(RealPropInfo *)findRealPropInfo:(NSManagedObject *)object withContext:(NSManagedObjectContext *)context

//
-(void)createBookmark:(SyncErrorInformation *)valError
{
    NSManagedObjectContext *defaultContext = [AxDataManager createManagedObjectContextFromContextName:@"default"];
    if ([valError.entityKind isEqualToString:@"SaleVerif"]) {
        
        SaleVerif *saleVerif = [AxDataManager getEntityObject:@"SaleVerif" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((SaleVerif *)valError.entityGuid)] andContext:defaultContext];

        
        Sale *sale = [AxDataManager getEntityObject:@"Sale" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((SaleVerif *)saleVerif).saleGuid] andContext:defaultContext];
        
        SaleParcel *saleParcel = [AxDataManager getEntityObject:@"SaleParcel" andPredicate:[NSPredicate predicateWithFormat:@"saleGuid=%@", ((Sale *)sale).guid] andContext:defaultContext];
        
        
        RealPropInfo *realPropInfo = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", saleParcel.rpGuid] andContext:defaultContext];
        
         
        //[TabBookmarkController createBookmark:[NSString stringWithFormat:@"Sync %@ ,%@", valError.errorMessage,realPropInfo.parcelNbr] withInfo:realPropInfo typeItem:9 withContext:defaultContext];
        //Do not synchronize
        [TabBookmarkController createBookmark:[NSString stringWithFormat:@"Sync %@", valError.errorMessage] withInfo:realPropInfo typeItem:kBookmarkErrorSync withContext:defaultContext];

    }
    else
    {
    
    RealPropInfo *realPropInfo = [OpenEntity findRealPropInfo:valError.entityKind withGuid:valError.entityGuid withContext:defaultContext];
    
    if(realPropInfo==nil)
        return;
                                                                                                                                //Do not synchronize
    [TabBookmarkController createBookmark:[NSString stringWithFormat:@"Sync %@", valError.errorMessage] withInfo:realPropInfo typeItem:9 withContext:defaultContext];
    }
    
    }
//-(NSError *)saveNewImageToDownload:(NSString *)imageName ofEntityKind:(NSString *)entityKid withGuid:(NSString *)entityGuid; //mediaLoc:(NSString *)mediaLoc;
-(NSError *)saveNewImageToDownload:(NSString *)imageName ofEntityKind:(NSString *)entityKid withGuid:(NSString *)entityGuid
                         mediaType:(int16_t)mediaType ext:(NSString *)ext;
{
    
    [self loadPrefContext];
    // 4/26/16 HNN need to check if record already exists in the imagetodownload table because if the user stops the update data process or downloading images part, the next download changes will reprocess the data already the downloaded and try to add images to download again
    ImageToDownload *imageTD  = [AxDataManager getEntityObject:@"ImageToDownload" andPredicate:[NSPredicate predicateWithFormat:@"entityGuid=%@ and mediaType=%d", entityGuid,mediaType] andContext:prefContext];
    
    if(imageTD==nil)
    {
        imageTD = [AxDataManager getNewEntityObject:@"ImageToDownload" andContext:prefContext];
        
        imageTD.fileName = imageName;
        //check which guid get pass (bldgGuid,lndGuid,accyGuid,mhGuid)
        imageTD.entityGuid = entityGuid;
        imageTD.entityKind = entityKid;
        // Fix a format issue
        //mediaLoc = [mediaLoc stringByReplacingOccurrencesOfString:@"/" withString:@"\\"];
        //imageTD.mediaLoc = mediaLoc;
        
        imageTD.mediaType = mediaType;
        imageTD.ext = ext;
        
        NSError *myError;
        [prefContext save:&myError];
        //if error occurr need to fix prefContext(ImageToDownload
        return myError;
    }
    return nil;
}

-(void)processDownloadedEntitiesFromArray:(NSArray *)jSonEntityList ofKind:(NSString *)entityKind withMediaArray:(NSArray *)mediaEntityKinds ManageRowStatus:(BOOL)manageRowStatus error:(NSError **)error
{
    if (error) 
        *error= nil;
    NSError *myError;
    BOOL isNewEntity;
    [self loadSyncContext];
    
    for (NSDictionary* entityData in jSonEntityList) 
    {
        isNewEntity = NO;
        NSString *entGuid = [entityData objectForKey:@"guid"];

        
        if ([entGuid caseInsensitiveCompare:@"E1E6C3C5-DF23-4A0D-820A-D30128650EDE"] == NSOrderedSame) {
            isNewEntity = NO;
        }
        
        
        NSString *rowStatus = @"";
        if (manageRowStatus) 
        {
            rowStatus = [entityData objectForKey:@"rowStatus"];
        }
        NSPredicate *predicate;
        
        NSNumber *number = [entityData objectForKey:@"realPropId"];
        if(number==nil || [number isKindOfClass:[NSNull class]])
            //            predicate = [NSPredicate predicateWithFormat:@"guid LIKE[c] %@", entGuid];
            // 4/15/16 HNN search by like is too slow
            predicate = [NSPredicate predicateWithFormat:@"guid = %@", entGuid];
        else
            //            predicate = [NSPredicate predicateWithFormat:@"realPropId=%d AND guid LIKE[c] %@", [number intValue], entGuid];
            predicate = [NSPredicate predicateWithFormat:@"realPropId=%d AND guid = %@", [number intValue], entGuid];
        
        //check if it is a duplicate object
        NSManagedObject *actualEntity;
        // 4/21/16 HNN there is a bug on the server where the guid's createdate is being updated when the record is updated
        // which causes my getupdserverdata sproc to return the rowstatus as an I on existing buildings
//        if (![rowStatus isEqualToString:@"I"])
//        {
            //4/20/16 HNN skip core data lookup if new entity to save time
            actualEntity = [AxDataManager getEntityObject:entityKind andPredicate:predicate andContext:syncContext];
//        }
        
        //cv 03/16 This type will allow us to know if is a cadxml file == 4
        NSNumber *serverImageType = [entityData objectForKey:@"imageType"];
        NSNumber *cadXmlNumber = [NSNumber numberWithInt:4];
        NSNumber *desiredcadXmlNumber = [NSNumber numberWithInt:2];

        
        //check if this prevents to bring delete records from RP??
        if (![rowStatus isEqualToString:@"D"])
        {
            if (actualEntity==nil)
            {
                actualEntity = [AxDataManager getNewEntityObject:entityKind andContext:syncContext];
                isNewEntity = YES;
            }
            
            if (isNewEntity && ([mediaEntityKinds indexOfObject:entityKind] != NSNotFound))
            {
                //NSString *mediaLoc = [entityData objectForKey:@"mediaLoc"];
                //NSString *fileExt = [NSString stringWithFormat:@".%@", [mediaLoc pathExtension]];
                NSString *fileExt =@"";
                int16_t imageType = [[entityData objectForKey:@"imageType"] intValue];
                if (imageType == kMediaPict || imageType == 0)
                    {fileExt = @"JPG";}  // what about png
                
                else if (imageType ==4)
                    
                {   // 4/21/16 HNN the server passes back imagetype=4 so we can differentiate between wmf and cadxml. if cadxml, we need to download the cadxml and png, but we need to set the mediatype to 1 for the png and 2 for the cadxml.
                    fileExt = @"PNG";}
                //{fileExt = @"CADXML";}


                else
                    
                {fileExt = @"WMF";}
                

                NSString* fileName = [NSString stringWithFormat:@"%@.%@", entGuid, fileExt];
                //NSString *filePath = [directoryPath stringByAppendingPathComponent:fileNameExt];
                
                //check which guid get pass (bldgGuid,lndGuid,accyGuid,mhGuid)
                //guid should be the same as being used from \\asr-nas-dr\media\$Dev\1st\2nd\3rdC
                //[self saveNewImageToDownload:fileName ofEntityKind:entityKind withGuid:entGuid mediaLoc:mediaLoc];
                [self saveNewImageToDownload:fileName ofEntityKind:entityKind withGuid:entGuid
                                            mediaType:kMediaPict ext:fileExt];
                //NSLog(@"%@=%d", fileName, imageType);
                if ([serverImageType intValue] == 4)
                    
                {
                    
                    
                    fileName = [entGuid stringByAppendingString:@".cadxml"];
                    //[self saveNewImageToDownload:fileName ofEntityKind:entityKind withGuid:entGuid mediaLoc:mediaStr];
                    
//                    [self saveNewImageToDownload:fileName ofEntityKind:entityKind withGuid:entGuid
                                      // mediaType:&imageType ext:fileExt];
                    
                    [self saveNewImageToDownload:fileName ofEntityKind:entityKind withGuid:entGuid
                                       mediaType:kMediaFplan ext:@"CADXML"];
                }
            }
            
            NSArray* properties = [[actualEntity entity] properties];

            for (NSPropertyDescription* property in properties)
            {
                if ([property isKindOfClass:[NSAttributeDescription class]])
                {
                    NSAttributeDescription * attribute = (NSAttributeDescription *)property;
                    NSString* propertyName = [property name];
                    
                    id value;
                    
//                    if ([entityKind isEqualToString:@"MediaBldg"])
//                    {
//                        if([propertyName caseInsensitiveCompare:@"mediaType"]==NSOrderedSame)
//                        {
//                            value = [[entityData valueForKey:propertyName] copy];
//                            
//                            [actualEntity setValue:value forKey:propertyName];
//
////                            if (value == 4)
////                            {
////                            
////                            }
//                            
////                        setvalue: 2;
//                        }
//                    }

                    if([propertyName caseInsensitiveCompare:@"rowStatus"]==NSOrderedSame)
                        value = @"";
                    else
                        value = [[entityData valueForKey:propertyName] copy];
                    if (value != nil && (NSNull *)value != [NSNull null])
                    {

                        switch ([attribute attributeType]) {
                            case NSBooleanAttributeType:
                            {
                                [actualEntity setValue:[NSNumber numberWithBool:[(NSNumber*)value boolValue]] forKey:propertyName];
                            }
                                break;
                                
                            case NSDateAttributeType:
                            {
                                [actualEntity setValue:[BaseRequest getDateFromJSON:value] forKey:propertyName];
                            }
                                break;
                                
                            case NSDecimalAttributeType:
                            {
                                NSString* strVal = value;
                                NSDecimalNumber * decNum = [NSDecimalNumber decimalNumberWithString:strVal];
                                [actualEntity setValue:decNum forKey:propertyName];
                            }
                                break;
                                
                                
                            default:
                            {
                                //entityKind,propertyName, value
                                if (([entityKind isEqualToString:@"MediaBldg"] || [entityKind isEqualToString:@"MediaAccy"]) && [propertyName isEqualToString:@"imageType"] && (value == cadXmlNumber))
                                    {
                                        [actualEntity setValue:desiredcadXmlNumber forKey:propertyName];
                                    }
                                else
                                    {
                                        [actualEntity setValue:value forKey:propertyName];
                                    }
                            }
                                break;
                        }
                    }
                }
            }

        }
        else
        {
            if (actualEntity!=nil)
            {
                [syncContext deleteObject:actualEntity];
            }
        }
        if (isNewEntity) 
        {
            [OpenEntity insertObjectIntoContext:actualEntity withContext:syncContext];
        }
    }
    [syncContext save:&myError];        //insert or delete object syncContext
    if (myError != nil)
    {
        *error = myError;
        return;
    }
}

-(void)downloadImages:(NSError **)error
{
    if (error)
        *error = nil;
    NSError *myError;
    self.requester.blobServiceURL = blobServiceURL;
    ReadPictures *picReader = [[ReadPictures alloc]initWithDataBase:imageDatabasePath];
    [self loadPrefContext];
    NSArray *imagesToDownload = [AxDataManager dataListEntity:@"ImageToDownload" andPredicate:nil andSortBy:@"entityGuid" sortAscending:YES withContext:prefContext];
    int count = 0;
    for (ImageToDownload *imageTD in imagesToDownload)
    {
        @autoreleasepool
        {
            count++;
            [self performSelectorOnMainThread:@selector(indicatorMessage:) withObject:[NSString stringWithFormat:@"get %d/%d images",count,imagesToDownload.count] waitUntilDone:NO];
            
            NSLog(@"Image to download '%d'",count);

            NSData *dImage = [self.requester executeDownloadBlobFromWebServiceSynchronous:imageTD.fileName usingToken:securityToken withError:&myError];
            if (myError == nil && dImage != nil && dImage.length > 0)
            {
                // Retrieve the original Medias
                // 3/1/15 cv make sure entityKind brings the right type of class, get rid of src

                //[picReader saveNewData:dImage guid:imageTD.entityGuid  mediaType:(imageTD.mediaType)];
                [picReader saveNewData:dImage guid:imageTD.entityGuid  mediaType:(imageTD.mediaType) ext:(imageTD.ext)];
                
                // 4/26/16 HNN we are going to mark images that we saved to the media.sqlite as saved in the errorMessage field
                // so that we can skip them if the user stops this process in the middle because the process will restart
                // at processDownloadedEntitiesFromArray and will try to add to the imagesToDownload if it doesn't exist in
                // that table, but if the user stops the process while we are downloading the images here,
                // we would have saved some of the downloaded images to media.sqlite and we don't want to add it to the media.sqlite again
                // once all images have been downloaded, we will delete the imagesToDownload records that we marked as saved
                //[prefContext deleteObject:imageTD];
                imageTD.errorMessage=@"saved";
            }
            else 
            {
                imageTD.errorMessage = myError.localizedDescription;
                myError = nil;
            }
            dImage = nil;
            [prefContext save:&myError];
        }
    }

    // 4/26/16 HNN once all the images in the synch batch has been saved, we can delete the ImageToDownload records
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"errorMessage=%@", @"saved"];
    imagesToDownload = [AxDataManager dataListEntity:@"ImageToDownload" andPredicate:predicate andSortBy:@"entityGuid" sortAscending:YES withContext:prefContext];
    count = 0;
    for (ImageToDownload *imageTD in imagesToDownload)
    {
        @autoreleasepool
        {
            count++;
            [self performSelectorOnMainThread:@selector(indicatorMessage:) withObject:[NSString stringWithFormat:@"get %d/%d images",count,imagesToDownload.count] waitUntilDone:NO];
            
            NSLog(@"ImageToDownload to remove '%d'",count);
            
            [prefContext deleteObject:imageTD];
            [prefContext save:&myError];
        }
    }

    
    [self performSelectorOnMainThread:@selector(indicatorMessage:) withObject:@"Download complete" waitUntilDone:NO];
    if (error)
        *error = myError;
}
// this method change the name of an existing image to a new name

-(void)uploadImages:(NSArray *)mediaEntityList withStagingGuid:(NSString *)stagingGuid error:(NSError **)error
{
    Configuration *config = [RealPropertyApp getConfiguration];
    if([RealPropertyApp reachNetworkThrough3G])
    {
        if(!config.syncImageOver3G)
            return;
    }
    if (totalImagesToUpload > 0)
    {
        NSError *myError;
        self.requester.blobServiceURL = blobServiceURL;
        int actualImageCount = 1;
        
        NSString *escapedToken = [self.requester getEscapedToken:securityToken withError:&myError];
        
        if (myError == nil)
        {
            for (NSString *actMedia in mediaEntityList) 
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(stagingGUID == %@) AND (rowStatus == 'I')", stagingGuid]; 
                NSArray *entitiesArray = [AxDataManager dataListEntity:actMedia andSortBy:nil andPredicate:predicate withContext:syncContext ];
                ReadPictures *picReader = [[ReadPictures alloc]initWithDataBase:imageDatabasePath];
                
                NSManagedObject *actualEntity;
                for (actualEntity in entitiesArray)
                {
                    if ([self.delegate respondsToSelector:@selector(synchronizatorUploadingPictureStarts:actualPicture:numberOfPicturesToUpload:)])
                        [self performSelectorOnMainThread:@selector(callUploadPicturesStarts:) withObject:[[NSNumber alloc]initWithInt:actualImageCount] waitUntilDone:YES];
                    //3/1/15 cv There's no longer mediaLoc, instead we use guid,Ext from Media object
                    //NSString *mediaPath = [actualEntity valueForKey:@"mediaLoc"];
                    NSString *guid = [actualEntity valueForKey:@"guid"]; // 4/29/16 HNN changed to lower case guid
                    // 4/1/15 cv we no longer get extention from Mediafile; get it from images
                    //NSString *ext = [actualEntity valueForKey:@"ext"];

                    ///////   First file /////////////////////////////////////////////////////////////////////////////////////
                    //NSString *guid = @"";
                    //NSData * picData = [picReader getFileDataFromDatabase:mediaPath guid:&guid path:nil];
                    // 5/3/16 HNN upload picture/picture of cadxml (PNG)
                    NSData * picData;
                    NSString *picName;
                    NSString *ext = [picReader getExtensionWithGuid:guid];  //// get the png record with mediaType =1  ==> ok in sync
                    if (ext != nil)
                    {
                        picName = [NSString stringWithFormat:@"%@.%@", guid, ext];
                        picData = [picReader getFileDataWithMediaTypeFromDatabase:guid mediaType:kMediaPict];  ///change
                        if (picData != nil)
                        {
                            [self uploadOneFile:picData andName:picName usingEscapedToken:escapedToken withError:&myError];
                            if (myError != nil)
                            {
                                if (error != nil)
                                    *error = myError;
                                return;
                            }
                        }
                    }

                    
                    
                    ///////   Second file /////////////////////////////////////////////////////////////////////////////////////
                    // 5/3/16 HNN upload cadxml if exists
                    picData = [picReader getFileDataWithMediaTypeFromDatabase:guid mediaType:kMediaFplan];
                    if (picData != nil)
                    {
                        picName = [NSString stringWithFormat:@"%@.%@", guid, @"CADXML"];
                        [self uploadOneFile:picData andName:picName usingEscapedToken:escapedToken withError:&myError];
                        if (myError != nil)
                        {
                            if (error != nil)
                                *error = myError;
                            return;
                        }
                    }
                    
                    
                    actualImageCount++;
                }
            }
        }
        else
        {
            if (error != nil)
                *error = myError;
            return;
        }
    }
}

-(void)uploadOneFile:(NSData *)fileData andName:(NSString *)fileName usingEscapedToken:(NSString *)escapedToken withError:(NSError**)error
{
    if (error != nil)
        *error = nil;
    NSError *myError;
    if (fileData != nil) 
    {
        myError = [self.requester executeUploadBlobToWebServiceSynchronous:fileData withFileName:fileName usingToken:securityToken andEscapedToken:escapedToken];
        if (myError != nil)
        {
            if (error != nil)
                *error = myError;
            return;
        }
    }

}

//
// Creates a complete list of entities to be sync.
//
-(NSMutableArray *)createEntityList
{
    NSMutableArray *entityList = [[NSMutableArray alloc]init] ;
    [entityList addObject:[self createNewSyncEntity:@"RealPropInfo" description:@"Property Info" withPosition:1]];
    [entityList addObject:[self createNewSyncEntity:@"Account" description:@"Account" withPosition:2]];
    [entityList addObject:[self createNewSyncEntity:@"ApplHist" description:@"Appeals" withPosition:3]];
    [entityList addObject:[self createNewSyncEntity:@"Inspection" description:@"Inspection" withPosition:4]];
    [entityList addObject:[self createNewSyncEntity:@"Land" description:@"Land" withPosition:5]];
    [entityList addObject:[self createNewSyncEntity:@"XLand" description:@"eXtended Land" withPosition:6]];
    
    [entityList addObject:[self createNewSyncEntity:@"ResBldg" description:@"Residential Building" withPosition:7]];
    [entityList addObject:[self createNewSyncEntity:@"MediaBldg" description:@"Media Building" withPosition:8]];
    [entityList addObject:[self createNewSyncEntity:@"Accy" description:@"Accessory" withPosition:9]];
    [entityList addObject:[self createNewSyncEntity:@"MediaAccy" description:@"Media Accessory" withPosition:10]];
    [entityList addObject:[self createNewSyncEntity:@"Bookmark" description:@"Bookmark" withPosition:11]];

    [entityList addObject:[self createNewSyncEntity:@"EnvRes" description:@"Environmental Res" withPosition:12]];
    [entityList addObject:[self createNewSyncEntity:@"MediaLand" description:@"Media Land" withPosition:13]];
    [entityList addObject:[self createNewSyncEntity:@"SaleParcel" description:@"Sale Parcel" withPosition:14]];
    [entityList addObject:[self createNewSyncEntity:@"Sale" description:@"Sale" withPosition:15]];
    [entityList addObject:[self createNewSyncEntity:@"SaleWarning" description:@"Sale Warning" withPosition:16]];

    [entityList addObject:[self createNewSyncEntity:@"TaxRoll" description:@"Tax Roll" withPosition:17]];
    [entityList addObject:[self createNewSyncEntity:@"UndividedInt" description:@"Undivided Interest" withPosition:18]];
    [entityList addObject:[self createNewSyncEntity:@"ValEst" description:@"Value Estimate" withPosition:19]];
    [entityList addObject:[self createNewSyncEntity:@"ValHist" description:@"Value History" withPosition:20]];
    [entityList addObject:[self createNewSyncEntity:@"ChngHist" description:@"Change History" withPosition:21]];
    [entityList addObject:[self createNewSyncEntity:@"ChngHistDtl" description:@"Change History Details" withPosition:22]];
    [entityList addObject:[self createNewSyncEntity:@"HIExmpt" description:@"HIExempt" withPosition:23]];
    [entityList addObject:[self createNewSyncEntity:@"MHAccount" description:@"Mobile Account" withPosition:24]];
    [entityList addObject:[self createNewSyncEntity:@"MHCharacteristic" description:@"Mobile Characteristic" withPosition:25]];
    [entityList addObject:[self createNewSyncEntity:@"MHLocation" description:@"Mobile Location" withPosition:26]];
    [entityList addObject:[self createNewSyncEntity:@"MediaMobile" description:@"Media Mobile" withPosition:27]];
    [entityList addObject:[self createNewSyncEntity:@"Permit" description:@"Permit" withPosition:28]];
    [entityList addObject:[self createNewSyncEntity:@"PermitDtl" description:@"Permit Detail" withPosition:29]];
    [entityList addObject:[self createNewSyncEntity:@"Review" description:@"Review" withPosition:30]];
    [entityList addObject:[self createNewSyncEntity:@"ReviewJrnl" description:@"Review Journal" withPosition:31]];
    [entityList addObject:[self createNewSyncEntity:@"NoteInstance" description:@"Note" withPosition:32]];
    [entityList addObject:[self createNewSyncEntity:@"MediaNote" description:@"Media Note" withPosition:33]];
    
    [entityList addObject:[self createNewSyncEntity:@"LandFootage" description:@"Land Footage" withPosition:34]];
    //ParcelAssignment    
    [entityList addObject:[self createNewSyncEntity:@"SaleVerif" description:@"Sale Verification" withPosition:35]];

    return entityList;
}

//
// Creates a list of media entities.
//
-(NSArray *)createMediaEntityList
{
    NSMutableArray *entityList = [[NSMutableArray alloc]init] ;
    [entityList addObject:@"MediaAccy"];
    [entityList addObject:@"MediaBldg"];
    [entityList addObject:@"MediaLand"];
    [entityList addObject:@"MediaMobile"];
    [entityList addObject:@"MediaNote"];
    return entityList;
}

//
// Creates a new syncInformation Entity
//
-(SyncInformation *)createNewSyncEntity:(NSString *)entityName description:(NSString *)description withPosition:(int)position
{
    SyncInformation *result = [[SyncInformation alloc]init];
    result.syncEntityName = entityName;
    result.syncStatus = syncStatusPending;
    result.syncDescription = description;
    result.position = position;
    return result;
    
}
//
// Calls the method DownloadEntitiesDone
//
-(void)callGetEntityListToUploadDone:(NSArray *)entitiesToUpload
{
    [self.delegate synchronizatorGetEntityListToUploadDone:entitiesToUpload lastSyncDate:lastSyncDate];
}

//
// Calls the method DownloadEntitiesDone
//
-(void)callBeforeStartSync:(NSArray *)entitiesToDownload
{
    [self.delegate synchronizatorBeforeStartSync:entitiesToDownload];
}

//
// Calls the method DownloadEntitiesDone
//
-(void)callDownloadEntitiesDone
{
    [self.delegate synchronizatorDownloadEntitiesDone:self];
}

//
// Calls the method UploadEntitiesDone
//
-(void)callUploadEntitiesDone
{
    [self.delegate synchronizatorUploadEntitiesDone:self];
}

//
// Calls the method UploadEntitiesDone
//
-(void)callSyncEntitiesForCalculateEstimatesDone
{
    [self.delegate synchronizatorSyncEntitiesForCalculateEstimatesDone:self];
}

//
// Calls the method MoveDataFromSyncToPrepStarts
//
-(void)callMoveDataFromSyncToPrepStarts
{
    [self.delegate synchronizatorMoveDataFromSyncToPrepStarts:self];
}

//
// Calls the method synchronizatorUploadPicturesStarts
//
-(void)callUploadPicturesStarts:(NSNumber *)actualImageIndex
{
    [self.delegate synchronizatorUploadingPictureStarts:self actualPicture:[actualImageIndex intValue] numberOfPicturesToUpload:totalImagesToUpload];
}

//
// Calls the method Request did fail
//
-(void)callRequestDidFail:(NSError *)error
{
    downloadSyncInProgress = NO;
    [self.delegate synchronizatorRequestDidFail:self withError:error];
}

//
// Calls the method Request did fail by validation errors
//
-(void)callRequestDidFailByValidationErrors:(NSArray *)errors
{
    [self.delegate synchronizatorRequestDidFailByValidationErrors:self withSyncGuid:valErrorSyncGuid andErrors:errors];
}

//
// Calls the method to notify the upload entity starts
//
-(void)callUploadOneEntityStarts:(EntityStartStatus *)status
{
    [self.delegate synchronizatorUploadOneEntityStarts:status];
}

//
// Calls the method to notify the download entity starts
//
-(void)callDownloadOneEntityStarts:(EntityStartStatus *)status
{
    [self.delegate synchronizatorDownloadOneEntityStarts:status];
}

-(void)indicatorMessage:(NSString *)message
{
    [self.delegate indicatorMessage:message];
}

-(void)unload
{
    if(prefContext!=nil)
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:NSManagedObjectContextDidSaveNotification
         object:prefContext];
    
    if(syncContext!=nil)
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:NSManagedObjectContextDidSaveNotification
         object:syncContext];
    
    syncContext = nil;
    prefContext = nil;
}
-(void)loadPrefContext
{
    if (prefContext == nil) 
    {
        prefContext = [AxDataManager createManagedObjectContextFromContextName:@"config"];
        
        // register for the notification
        [[NSNotificationCenter defaultCenter] 
         addObserver:self 
         selector:@selector(handleDidSaveNotificationForPrefContext:)
         name:NSManagedObjectContextDidSaveNotification 
         object:prefContext];
    }
}

-(void)loadSyncContext
{
    if (syncContext == nil) 
    {
        syncContext = [AxDataManager createManagedObjectContextFromContextName:@"default"];
        
        // register for the notification
        [[NSNotificationCenter defaultCenter] 
         addObserver:self 
         selector:@selector(handleDidSaveNotificationForSyncContext:)
         name:NSManagedObjectContextDidSaveNotification 
         object:syncContext];
    }
}

- (void)handleDidSaveNotificationForSyncContext:(NSNotification *)note 
{
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    if(selector==nil)
        return;
    [[AxDataManager defaultContext] performSelectorOnMainThread:selector withObject:note waitUntilDone:YES];
}

- (void)handleDidSaveNotificationForPrefContext:(NSNotification *)note 
{
    SEL selector = @selector(mergeChangesFromContextDidSaveNotification:);
    if(selector==nil)
        return;
    [[AxDataManager configContext] performSelectorOnMainThread:selector withObject:note waitUntilDone:YES];
}

//
// Save the initial synchronization trace in to db.
//
-(void)saveInitialSyncTrace:(NSMutableArray *)entityKinds withSyncDirection:(syncDirection)direction andStaginGuind:(NSString *)stagingGuid andNumbersOfRecordsToDownload:(long)recordsToDownload error:(NSError **)error
{
    if (error != nil)
        *error = nil;
    NSError *myError;
    [self loadPrefContext];
    Synchronization *sync; 
    sync = [AxDataManager getEntityObject:@"Synchronization" andPredicate:[NSPredicate predicateWithFormat:@"syncDirection=%d",direction] andContext:prefContext];
    if (sync != nil)
    {
        [prefContext deleteObject:sync];
        [prefContext save:&myError];
        if (myError != nil)
        {
            *error = myError;
            return;
        }
    }
    sync = [AxDataManager getNewEntityObject:@"Synchronization" andContext:prefContext];
    sync.syncDirection = direction;
    sync.syncStagingGUID = stagingGuid;
    sync.pendingSyncToPrep = YES;
    sync.totalRecordsToDownload = recordsToDownload;
    sync.syncDate =  [NSDate timeIntervalSinceReferenceDate];
    
    int pos = 0;
    for (SyncInformation *actEntityKind in entityKinds) 
    {
        SyncEntity *newSyncEntity = [AxDataManager getNewEntityObject:@"SyncEntity" andContext:prefContext];
        newSyncEntity.entityKind = actEntityKind.syncEntityName;
        newSyncEntity.syncStatus = syncStatusPending;
        newSyncEntity.position = pos;
        [sync addEntitiesObject:newSyncEntity];
        pos++;
    }
    
    [prefContext save:&myError];
    if (myError != nil)
    {
        *error = myError;
        return;
    }
}

-(void)saveSyncStep:(int)syncStep IsStarting:(BOOL)isStarting withError:(NSError **)error
{
    NSError *myError;
    if (error != nil)
        *error = nil;
    [self loadPrefContext];
    SyncActualStep *actSyncStep;
    NSMutableArray *syncStepArray = [AxDataManager dataListEntity:@"SyncActualStep" andSortBy:@"actualStep" sortAscending:YES withContext:prefContext];
    if (isStarting) 
    {
        if ([syncStepArray count] > 0) 
        {
            actSyncStep = [syncStepArray objectAtIndex:0];
        }
        else 
        {
            actSyncStep = [AxDataManager getNewEntityObject:@"SyncActualStep" andContext:prefContext];
        }
        actSyncStep.actualStep = syncStep;
        actSyncStep.stagingGuid = syncStagingGUID;
        actSyncStep.serverSyncDate = serverSyncDate;
        actSyncStep.startDate = [NSDate timeIntervalSinceReferenceDate];
        actSyncStep.endDate = 0;
    }
    else
    {
        if ([syncStepArray count] > 0) 
        {
            actSyncStep = [syncStepArray objectAtIndex:0];
            actSyncStep.endDate = [NSDate timeIntervalSinceReferenceDate];
        }
    }
    [prefContext save:&myError];
    if (myError != nil)
    {
        *error = myError;
    }
}

//
// Update a syn trace with the actual sync status.
//
-(void)updateSyncTrace:(NSString *)entityKind withStatus:(syncStatus)status andSyncDirection:(syncDirection)direction error:(NSError **)error
{
    if (error != nil) 
        *error = nil;
    NSError *myError;
    [self loadPrefContext];
    Synchronization *sync;
    sync = [AxDataManager getEntityObject:@"Synchronization" andPredicate:[NSPredicate predicateWithFormat:@"syncDirection=%d",direction] andContext:prefContext];
    if (sync != nil) 
    {
        NSSet *syncEntities = sync.entities;
        
        NSEnumerator * syncEntEnumerator = [syncEntities objectEnumerator];
        SyncEntity *syncEnt;
        BOOL found = NO;
        while (!found && (syncEnt = [syncEntEnumerator nextObject])) 
        {
            if ([syncEnt.entityKind isEqualToString:entityKind]) 
            {
                found = YES;
            }
        }
        if (found) 
        {
            syncEnt.syncStatus = status;
            [prefContext save:&myError];
            if (myError != nil)
            {
                *error = myError;
                return;
            }
        }
    }
}

//
// Gets the entities which needs to resume or nil if there is no entities.
//
-(NSArray *)getArrayOfEntitiesToResumeWithDirection:(syncDirection)direction stagingGUID:(NSString **)staginGuid
{
    NSMutableArray *resultEntities;
    [self loadPrefContext];
    Synchronization *sync; 
    sync = [AxDataManager getEntityObject:@"Synchronization" andPredicate:[NSPredicate predicateWithFormat:@"syncDirection=%d",direction] andContext:prefContext];
    if (sync != nil) 
    {
        *staginGuid = sync.syncStagingGUID;
        NSSet *syncEntities = sync.entities;
        resultEntities = [[NSMutableArray alloc]init];
        NSEnumerator * syncEntEnumerator = [syncEntities objectEnumerator];
        SyncEntity *syncEnt;
        while (syncEnt = [syncEntEnumerator nextObject])
        {
            if (syncEnt.syncStatus == syncStatusPending) 
            {
                SyncInformation *syncInf = [[SyncInformation alloc]init];
                
                syncInf.syncEntityName = syncEnt.entityKind;
                syncInf.syncStatus  = syncStatusPending;
                syncInf.position = syncEnt.position;
                [resultEntities addObject:syncInf];
            }
        }
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray;
        sortedArray = [resultEntities sortedArrayUsingDescriptors:sortDescriptors];
        
        return sortedArray;
    }
    
    return nil;
}

//
// Close the sync trace
//
-(void)loadLastSyncDate:(syncDirection)direction
{
   [self loadPrefContext];
    LastSynchronization *syncHst;
    syncHst = [AxDataManager getEntityObject:@"LastSynchronization" andPredicate:[NSPredicate predicateWithFormat:@"direction=%d",direction] andContext:prefContext];
    if (syncHst != nil) 
    {
        lastSyncDate = [NSDate dateWithTimeIntervalSinceReferenceDate:syncHst.date];
    }
    else 
    {
        lastSyncDate = nil;
    }
}

//
// Close the sync trace
//
-(void)closeSyncTraceDirection:(syncDirection)direction error:(NSError **)error
{
    NSError *myError;
    if (error != nil) 
        *error = nil;
    [self loadPrefContext];
    LastSynchronization *syncHst;
    syncHst = [AxDataManager getEntityObject:@"LastSynchronization" andPredicate:[NSPredicate predicateWithFormat:@"direction=%d",direction] andContext:prefContext];
    if (syncHst == nil) 
    {
        syncHst = [AxDataManager getNewEntityObject:@"LastSynchronization" andContext:prefContext];
        syncHst.direction = direction;
    }
    syncHst.date =  [[Helper localDate] timeIntervalSinceReferenceDate];
    [prefContext save:&myError];
    if (myError != nil)
    {
        *error = myError;
        return;
    }
    
    Synchronization *sync; 
    sync = [AxDataManager getEntityObject:@"Synchronization" andPredicate:[NSPredicate predicateWithFormat:@"syncDirection=%d",direction] andContext:prefContext];
    if (sync != nil) 
    {
        NSSet *syncEntities = sync.entities;
        NSEnumerator * syncEntEnumerator = [syncEntities objectEnumerator];
        SyncEntity *syncEnt;
        while (syncEnt = [syncEntEnumerator nextObject])
        {
            [prefContext deleteObject:syncEnt];
        }        
        [prefContext deleteObject:sync];
        [prefContext save:&myError];
        if (myError != nil)
        {
            *error = myError;
            return;
        }
        
        // unregister from notification
        /*[[NSNotificationCenter defaultCenter] 
         removeObserver:self 
         name:NSManagedObjectContextDidSaveNotification 
         object:prefContext];*/
    }
}

//
// Creates a new guid.
//
+ (NSString *)createNewGuid
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

//
// Manage an error in the request.
//
-(void)requestDidFail:(Requester *)r withError:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(callRequestDidFail:) withObject:error waitUntilDone:YES];
}


@end
