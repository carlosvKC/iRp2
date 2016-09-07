#import "OpenEntity.h"
#import "AxDataManager.h"
#import "SelectedObject.h"
#import "Bookmark.h"

@implementation OpenEntity
//
// Return a real prop info object from an existing object
//
+(RealPropInfo *)findRealPropInfo:(NSString *)entityKind withGuid:(NSString *)guid
{
    return [self findRealPropInfo:entityKind withGuid:guid withContext:[AxDataManager defaultContext]];
}
//
// Return a real prop info object from an existing object
//
+(RealPropInfo *)findRealPropInfo:(NSString *)entityKind withGuid:(NSString *)guid withContext:(NSManagedObjectContext *)context
{
    
    NSManagedObject *object = [AxDataManager getEntityObject:entityKind andPredicate:[NSPredicate predicateWithFormat:@"guid = %@",guid] andContext:context];
    return [OpenEntity findRealPropInfo:object withContext:context];
}

//
// Return a real prop info object from an existing object
//
+(RealPropInfo *)findRealPropInfo:(NSManagedObject *)object
{
    return [OpenEntity findRealPropInfo:object withContext:[AxDataManager defaultContext]];
}
+(BOOL)checkBookmarkError:(NSManagedObject *)object withContext:(NSManagedObjectContext *)context
{
    RealPropInfo *info = [OpenEntity findRealPropInfo:object withContext:context];
    if(info==nil)
        return NO;  // No error since we can't check it...
    NSManagedObjectContext *defaultContext = [AxDataManager createManagedObjectContextFromContextName:@"default"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpGuid=%@", info.guid];
    
    Bookmark *bookmark = [AxDataManager getEntityObject:@"Bookmark" andPredicate:predicate andContext:defaultContext];
    if(bookmark==nil)
        return NO;
    return bookmark.hasError;
}
//
// Return a real prop info object from an existing object
//
+(RealPropInfo *)findRealPropInfo:(NSManagedObject *)object withContext:(NSManagedObjectContext *)context
{
    if(object==nil)
        return nil;
    // If the object is real prop info, not much to do!
    if([object isKindOfClass:[RealPropInfo class]])
        return (RealPropInfo *)object;
    
    NSString *className = NSStringFromClass([object class]);
    
    // The object should contain guid
    NSDictionary *attributes = [[NSEntityDescription entityForName:className inManagedObjectContext:context] attributesByName];
        
        for (NSString *attr in attributes)
        {
            if([attr caseInsensitiveCompare:@"rpGuid"]==NSOrderedSame)
            {
                NSString * rpGuid = [object valueForKey:@"rpGuid"];
                rpGuid=[rpGuid uppercaseString]; // 4/29/16 HNN kludge: irealproperty web service datamodel has the rpguid defined as a guid in the applhist_prep and applhist_sync which converts to a lowercase string here, but we need an uppercase guid to find the realpropinfo record. can remove once i publish a new web service with the correct type
                // Return the realProp guid object
                return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", rpGuid] andContext:context];
            }
        }
    
    //Bookmark
//    if([className caseInsensitiveCompare:@"Bookmark"]==NSOrderedSame)
//    {
//       
//        //NSString * rpGuid = [object valueForKey:@"guid"];
//        //return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", rpGuid] andContext:context];
////       RealPropInfo *info = [OpenEntity findRealPropInfo:object withContext:context];
////        if(info==nil)
////        NSManagedObjectContext *defaultContext = [AxDataManager createManagedObjectContextFromContextName:@"default"];
//        
////       NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rpguid=%@", info.guid];
////
////        Bookmark *bookmark = [AxDataManager getEntityObject:@"Bookmark" andPredicate:predicate andContext:defaultContext];
//
//        
//        // Return the realPropI object
//       //return [AxDataManager getEntityObject:@"Bookmark" andPredicate:[NSPredicate predicateWithFormat@"1==1"] andContext:context];
//        
//        return [AxDataManager getEntityObject:@"Bookmark" andPredicate:[NSPredicate predicateWithFormat:@"1==1"] andContext:context];
//
//        
//        
//    }
    
    // Accessory
//    if([className caseInsensitiveCompare:@"Accy"]==NSOrderedSame)
//    {
//        //Land *land = [AxDataManager getEntityObject:@"Land" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((Accy *)object).landGuid] andContext:context];
//        
//        //cv no need for this one
//        //RealPropInfo *rpInfo = [AxDataManager getEntityObject:@"RealpropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@",((Accy *)object).rpGuid] andContext:context];
//        
//        //return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", land.guid] andContext:context];
//        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@",((Accy *)object).rpGuid] andContext:context];
//
//        
//    }
//    // LandFootage  //cv there is no longer relationship with land.guid
//    if([className caseInsensitiveCompare:@"LandFootage"]==NSOrderedSame)
//    {
//        Land *land = [AxDataManager getEntityObject:@"Land" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((Accy *)object).landGuid] andContext:context];
//        return [AxDataManager getEntityObject:@"LandFootage" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", land.guid] andContext:context];
//    }
    // EnvRes
//    if([className caseInsensitiveCompare:@"envRes"]==NSOrderedSame)
//    {
//        Land *land = [AxDataManager getEntityObject:@"Land" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((EnvRes *)object).lndGuid] andContext:context];
        
//        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", land.rpGuid] andContext:context];

//    }
    // ReviewJrnl
    if([className caseInsensitiveCompare:@"reviewJrnl"]==NSOrderedSame)
    {
        Review *review = [AxDataManager getEntityObject:@"Review" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((ReviewJrnl *)object).guid] andContext:context];
        
        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", review.rpGuid] andContext:context];
    }
    
    // Sale
    if([className caseInsensitiveCompare:@"sale"]==NSOrderedSame)
    {
        SaleParcel *saleParcel = [AxDataManager getEntityObject:@"SaleParcel" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((Sale *)object).guid] andContext:context];
        
        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", saleParcel.rpGuid] andContext:context];

    }
    // Sale Warning
    if([className caseInsensitiveCompare:@"saleWarning"]==NSOrderedSame)
    {
        SaleParcel *saleParcel = [AxDataManager getEntityObject:@"SaleParcel" andPredicate:[NSPredicate predicateWithFormat:@"saleGuid=%@", ((SaleWarning *)object).saleGuid] andContext:context];
        
        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", saleParcel.rpGuid] andContext:context];
    }
    // SaleVerif 
    if([className caseInsensitiveCompare:@"SaleVerif"]==NSOrderedSame)
    {
        //Sale *sale = [AxDataManager getEntityObject:@"Sale" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((SaleVerif *)object).saleGuid] andContext:context];

        SaleParcel *saleParcel = [AxDataManager getEntityObject:@"SaleParcel" andPredicate:[NSPredicate predicateWithFormat:@"saleGuid=%@", ((SaleVerif *)object).saleGuid] andContext:context];

        
        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", saleParcel.rpGuid] andContext:context];
    }
    
    // Media Note
    //MediaNote has noteGuid
    //NoteInstance has guid,src,srcGuid
    //posible source == realprop,sale,hiexmpt,review
    if([className caseInsensitiveCompare:@"MediaNote"]==NSOrderedSame)
    {
        
        //steps getting the source and srcGuid from NoteInstance
        NoteInstance *noteInstance = [AxDataManager getEntityObject:@"NoteInstance" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((MediaNote *)object).noteGuid] andContext:context];
        
        
        //chequea q note guid we're using

          //return accordingly with the source
        if ([noteInstance.src isEqualToString:@"realprop"]) {
            // 4/15/16 changed Guid to guid
              return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", noteInstance.srcGuid] andContext:context];
           //Error in 'Guid == "E7F95FAF-A70C-4B79-AC64-6BB54720A6CB"' on RealPropInfo = keypath Guid not found in entity
            
            //assumption NoteInstance for the media should exist already
            //return [AxDataManager getEntityObject:@"NoteInstance" andPredicate:[NSPredicate predicateWithFormat:@"Guid=%@", noteInstance.guid] andContext:context];

             //Error in 'Guid == "ACFE041E-A7A3-4988-AD85-6176F87E1734"'            
        }
        //this is the case where a parent is not rpInfo
        if ([noteInstance.src isEqualToString:@"sale"]) {
            // 4/15/16 changed Guid to guid
            return [AxDataManager getEntityObject:@"Sale" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", noteInstance.srcGuid] andContext:context];
        }
        if ([noteInstance.src isEqualToString:@"hiexmpt"]) {
            // 4/15/16 changed Guid to guid
            return [AxDataManager getEntityObject:@"Hiexmpt" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", noteInstance.srcGuid] andContext:context];
        }
        if ([noteInstance.src isEqualToString:@"review"]) {
            // 4/15/16 changed Guid to guid
            return [AxDataManager getEntityObject:@"Review" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", noteInstance.srcGuid] andContext:context];
        }
    }
    
    //Media Building
    //MediaBldg has bldgGuid
//    if([className caseInsensitiveCompare:@"MediaNote"]==NSOrderedSame)
//    {
//        
//        //steps getting the source and bldgGuid from Resbldg
//    ResBldg *resbldg = [AxDataManager getEntityObject:@"ResBldg" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@",((MediaBldg *)object).bldgGuid] andContext:context];
//        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"bldgGuid=%@", land.guid] andContext:context];
//
//        
//    }
    

    // MediaAccessory
    if([className caseInsensitiveCompare:@"MediaAccy"]==NSOrderedSame)
    {
        Accy *accy = [AxDataManager getEntityObject:@"Accy" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@",((MediaAccy *)object).accyGuid] andContext:context];
        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", accy.rpGuid] andContext:context];
    }

    // MediaLand
    if([className caseInsensitiveCompare:@"MediaLand"]==NSOrderedSame)
    {
        Land *land = [AxDataManager getEntityObject:@"Land" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@",((MediaLand *)object).lndGuid] andContext:context];
        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"lndGuid=%@", land.guid] andContext:context];
    }

    // XLand
    if([className caseInsensitiveCompare:@"XLand"]==NSOrderedSame)
    {
        Land *land = [AxDataManager getEntityObject:@"Land" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@",((XLand *)object).guid] andContext:context];
        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"lndGuid=%@", land.guid] andContext:context];
    }

    // Land
    if([className caseInsensitiveCompare:@"Land"]==NSOrderedSame)
    {
        Land *land = (Land *)object;
        return [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"lndGuid=%@", land.guid] andContext:context];
    }

    

    // Can't find the parent object
    NSLog(@"Cant find parent object for '%@'",     NSStringFromClass([object class]));
    return nil;
}

//
// Return YES if an object can be inserted into the context
//
+(BOOL)insertObjectIntoContext:(NSManagedObject *)object withContext:(NSManagedObjectContext *)context
{
    NSString *className = NSStringFromClass([object class]);
    // if object is a RealPropInfo, it is inserted "as is"
    if([className caseInsensitiveCompare:@"RealPropInfo"]==NSOrderedSame)
    {
        [context insertObject:object];
        return YES;
    }

    if([className caseInsensitiveCompare:@"NoteInstance"]==NSOrderedSame)
    {
        NoteInstance *note = (NoteInstance *)object;
        
        //NoteRealprop
        if([note.src caseInsensitiveCompare:@"realprop"]==NSOrderedSame)
        {
            
            RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", note.srcGuid] andContext:context ];

            
            NoteRealPropInfo *noteInfo = [AxDataManager getNewEntityObject:@"NoteRealPropInfo" andContext:context ];
            [AxDataManager copyManagedObject:note destination:noteInfo withSets:NO withLinks:NO];
            [info addNoteRealPropInfoObject:noteInfo];
            [context deleteObject:object];  // Avoid duplicate
            return YES;
        }


        // NoteSale
        if([note.src caseInsensitiveCompare:@"sale"]==NSOrderedSame)
        {
            Sale *sale = [AxDataManager getEntityObject:@"Sale" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", note.srcGuid] andContext:context ];
            
            NoteSale *noteSale = [AxDataManager getNewEntityObject:@"NoteSale" andContext:context ];
            [AxDataManager copyManagedObject:note destination:noteSale withSets:NO withLinks:NO];
            [sale addNoteSaleObject:noteSale];
            [context deleteObject:object];  // avoid duplicate
            return YES;
        }
      //        // NoteReview
        if([note.src caseInsensitiveCompare:@"review"]==NSOrderedSame)
        {
            Review *review = [AxDataManager getEntityObject:@"Review" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", note.srcGuid] andContext:context];
                        
            NoteReview *noteReview = [AxDataManager getNewEntityObject:@"NoteReview" andContext:context ];
            RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", review.rpGuid] andContext:context ];

            
            [AxDataManager copyManagedObject:note destination:noteReview withSets:NO withLinks:NO];
            
            for(Review *review in info.review)
            {
                //Is this paren table have a child then load the object
                //if(review.noteGuid IsEqualToString:noteReview.srcGuid)
                if ([noteReview.srcGuid length] > 0)
                {
                    [review addNoteReviewObject:noteReview];
                    return YES;
                }
            }
            NSLog(@"Can't insert NoteReview");
        }
        
        // NoteHIExmpt
        
        if([note.src caseInsensitiveCompare:@"hiexmpt"]==NSOrderedSame)
        {
            HIExmpt *exempt = [AxDataManager getEntityObject:@"HIExempt" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", note.srcGuid] andContext:context];
            
            RealPropInfo *info = [AxDataManager getEntityObject:@"RealPropInfo" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", exempt.rpGuid] andContext:context ];

            
            NoteHIExmpt *noteHIE = [AxDataManager getNewEntityObject:@"NoteHIExmpt" andContext:context ];
            
            
            [AxDataManager copyManagedObject:note destination:noteHIE withSets:NO withLinks:NO];
            
            for(HIExmpt *exempt in info.hIExempt)
            {
                if([noteHIE.srcGuid length] > 0)
                {
                    [exempt addNoteHIExmptObject:noteHIE];
                    return YES;
                }
            }
            NSLog(@"Can't insert NoteHIExempt");
        }        
    }
    
    // mediaBldg
    if([className caseInsensitiveCompare:@"mediaBldg"]==NSOrderedSame)
    {
        MediaBldg *mediaBldg = (MediaBldg *)object;
        
        ResBldg *resBldg = [AxDataManager getEntityObject:@"ResBldg" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", mediaBldg.bldgGuid] andContext:context];
                
        if(resBldg!=nil)
            
        {
            [resBldg addMediaBldgObject:mediaBldg];
            return YES;
        }
    }

    
   // RealPropInfo *info = [OpenEntity findRealPropInfo:object withContext:context];
    
    if([className caseInsensitiveCompare:@"MediaNote"]==NSOrderedSame)
  
    {
        MediaNote *mediaNote = (MediaNote *)object;

        //steps getting the source and srcGuid from NoteInstance
        NoteInstance *noteInstance = [AxDataManager getEntityObject:@"NoteInstance" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", ((MediaNote *)object).noteGuid] andContext:context];

        if(noteInstance!=nil)
        {
            [noteInstance addMediaNoteObject:mediaNote];
            return YES;
        }
    }
    // should be able to add mhChar
    if([className caseInsensitiveCompare:@"MhCharacteristic"]==NSOrderedSame)
        
    {
        MHCharacteristic *mhChar = (MHCharacteristic *)object;
        
        MHAccount *mhAccount = [AxDataManager getEntityObject:@"MHAccount" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", mhChar.mhGuid] andContext:context];
        
        if(mhAccount!=nil)
        {
            // 4/29/16 HNN  From what I've researched the addxxObject method is only added by coredata if the relationship is marked to many relationship; I suspect somebody manually added this method to land.h

            //[mhAccount addMHCharObject:mhChar];
            mhChar.mHAccount = mhAccount;
            return YES;
        }
    }
    
    
    // should be able to add mhLocation
    if([className caseInsensitiveCompare:@"MhLocation"]==NSOrderedSame)
        
    {
        MHLocation *mhLoc = (MHLocation *)object;
        
        MHAccount *mhAccount = [AxDataManager getEntityObject:@"MHAccount" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", mhLoc.mhGuid] andContext:context];
        
        if(mhAccount!=nil)
        {
            // 4/29/16 HNN  From what I've researched the addxxObject method is only added by coredata if the relationship is marked to many relationship; I suspect somebody manually added this method to land.h
                //[mhAccount addMHLocObject:mhLoc];
            mhLoc.mHAccount = mhAccount;
            return YES;
        }
    }
    

    // EnvRes
    if([className caseInsensitiveCompare:@"envRes"]==NSOrderedSame)
    {
        EnvRes *envRes = (EnvRes *)object;
        Land *land = [AxDataManager getEntityObject:@"Land" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", envRes.lndGuid] andContext:context];
        
        if(land!=nil)
        {
            //if([mediaBldg.bldgGuid isEqualToString:resBldg.guid])
            //{
            [land addEnvResObject:envRes];
            return YES;
            //}
        }
    }
    // mediaLand
    if([className caseInsensitiveCompare:@"mediaLand"]==NSOrderedSame)
    {
        MediaLand *mediaLand = (MediaLand *)object;
        Land *land = [AxDataManager getEntityObject:@"Land" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", mediaLand.lndGuid] andContext:context];
        
        if(land!=nil)
        {
            //if([mediaBldg.bldgGuid isEqualToString:resBldg.guid])
            //{
            [land addMediaLandObject:mediaLand];
            return YES;
            //}
        }
    }
    
    if([className caseInsensitiveCompare:@"LandFootage"]==NSOrderedSame)
    {
        LandFootage *lndFootage = (LandFootage *)object;
        
        Land *land = [AxDataManager getEntityObject:@"Land" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", lndFootage.guid] andContext:context];
        
        if(land!=nil)
        {
            //if([mediaBldg.bldgGuid isEqualToString:resBldg.guid])
            //{
            // 4/29/16 HNN doesn't seem like addLandFootageObject method really exists because I got an error. I was wondering land had a addLandFootageObject but sales doesn't have a addSalesVerifObject method. From what I've researched the addxxObject method is only added by coredata if the relationship is marked to many relationship; I suspect somebody manually added this method to land.h
//            [land addLandFootageObject:lndFootage];
            lndFootage.land=land;
            return YES;
            //}
        }
    }
    
    //MediaAccy
    if([className caseInsensitiveCompare:@"MediaAccy"]==NSOrderedSame)
    {
        MediaAccy *mediaAccy = (MediaAccy *)object;
        Accy *accy  = [AxDataManager getEntityObject:@"Accy" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", mediaAccy.accyGuid] andContext:context];
        
        if(accy!=nil)
        {
            //if([mediaBldg.bldgGuid isEqualToString:resBldg.guid])
            //{
            [accy addMediaAccyObject:mediaAccy];
            return YES;
            //}
        }
    }
    
    // mediaMobile
    if([className caseInsensitiveCompare:@"mediaMobile"]==NSOrderedSame)
    {
        MediaMobile *mediaMobile = (MediaMobile *)object;
        MHAccount *mhAccount  = [AxDataManager getEntityObject:@"MHAccount" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", mediaMobile.mhGuid] andContext:context];
        
        if(mhAccount!=nil)
        {
            //if([mediaBldg.bldgGuid isEqualToString:resBldg.guid])
            //{
            [mhAccount addMediaMobileObject:mediaMobile];
            return YES;
            //}
        }
    }
    
    // PermitDtl
    if([className caseInsensitiveCompare:@"permitDtl"]==NSOrderedSame)
    {
        PermitDtl *permitDtl = (PermitDtl *)object;
        Permit *permit  = [AxDataManager getEntityObject:@"Permit" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", permitDtl.permitGuid] andContext:context];
        
        if(permit!=nil)
        {
            //if([mediaBldg.bldgGuid isEqualToString:resBldg.guid])
            //{
            [permit addPermitDtlObject:permitDtl];
            return YES;
            //}
        }
    }
    
    // ReviewJrnl
    if([className caseInsensitiveCompare:@"reviewJrnl"]==NSOrderedSame)
    {
        ReviewJrnl *reviewJrnl = (ReviewJrnl *)object;
        Review *review  = [AxDataManager getEntityObject:@"Review" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", reviewJrnl.rtGuid] andContext:context];
        
        if(review!=nil)
        {
            [review addReviewJrnlObject:reviewJrnl];
            return YES;
        }
    }
    
    // Sale
    if([className caseInsensitiveCompare:@"sale"]==NSOrderedSame)
    {
        Sale *sale = (Sale *)object;
        SaleParcel *saleParcel  = [AxDataManager getEntityObject:@"SaleParcel" andPredicate:[NSPredicate predicateWithFormat:@"saleGuid=%@", sale.guid] andContext:context];
        
        if(saleParcel!=nil)
        {
            saleParcel.sale = sale;
            return YES;
        }
    }

    // Sale Verif
    if([className caseInsensitiveCompare:@"saleVerif"]==NSOrderedSame)
    {
        SaleVerif *saleVerif = (SaleVerif *)object;
        Sale *sale  = [AxDataManager getEntityObject:@"Sale" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", saleVerif.saleGuid] andContext:context];
        
        if(sale!=nil)
        {
            // 4/25/16 HNN not sure why we don't have sale.addsaleverifobject, but setting the saleverif.sale ties the two records together
            //sale.saleVerif=saleVerif; // 4/26/16 HNN doesn't like this either
            saleVerif.sale=sale;
            return YES;
        }
    }

    // Sale Warning
    if([className caseInsensitiveCompare:@"saleWarning"]==NSOrderedSame)
    {
        SaleWarning *saleWarning = (SaleWarning *)object;
        Sale *sale  = [AxDataManager getEntityObject:@"Sale" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", saleWarning.saleGuid] andContext:context];
        
        if(sale!=nil)
        {
            [sale addSaleWarningObject:saleWarning];
            return YES;
        }
    }
    
    if([className caseInsensitiveCompare:@"ChngHistDtl"]==NSOrderedSame)
    {
        ChngHistDtl *detail = (ChngHistDtl *)object;
        ChngHist *hist  = [AxDataManager getEntityObject:@"ChngHist" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", detail.chngGuid] andContext:context];
        
        if(hist!=nil)
        {
            [hist addChngHistDtlObject:detail];
            return YES;
        }
        NSLog(@"no rule for ChngHistDtl");
        return NO;
    }

     RealPropInfo *info = [OpenEntity findRealPropInfo:object withContext:context];
      
    
    if(info==nil)
        return NO;
    // Account
    if([className caseInsensitiveCompare:@"Account"]==NSOrderedSame)
    {
        info.account = (Account *)object;
        return YES;
    }
    // Accessory
    if([className caseInsensitiveCompare:@"Accy"]==NSOrderedSame)
    {
        [info addAccyObject:(Accy *)object];
        return YES;
    }
    // applHist
    if([className caseInsensitiveCompare:@"ApplHist"]==NSOrderedSame)
    {
        [info addApplHistObject:(ApplHist *)object];
        [context save:nil];
        return YES;
    }
    // ChngHist
    if([className caseInsensitiveCompare:@"chngHist"]==NSOrderedSame)
    {
        [info addChngHistObject:(ChngHist *)object];
        return YES;
    }
    // hIExempts
    if([className caseInsensitiveCompare:@"hIExempt"]==NSOrderedSame)
    {
        [info addHIExemptObject:(HIExmpt *)object];
        return YES;
    }
    // Inspection
    if([className caseInsensitiveCompare:@"inspection"]==NSOrderedSame)
    {
        info.inspection = (Inspection *)object;
        return YES;
    }
    // Land
    if([className caseInsensitiveCompare:@"Land"]==NSOrderedSame)
    {
        info.land = (Land *)object;
        return YES;
    }
    // mHAccount
    if([className caseInsensitiveCompare:@"mHAccount"]==NSOrderedSame)
    {
        [info addMHAccountObject:(MHAccount *)object];
        return YES;
    }
    // permit
    if([className caseInsensitiveCompare:@"permit"]==NSOrderedSame)
    {
        [info addPermitObject:(Permit *)object];
        return YES;
    }
    // Review
    if([className caseInsensitiveCompare:@"review"]==NSOrderedSame)
    {
        [info addReviewObject:(Review *)object];
        return YES;
    }
    
    // Bookmark
    if([className caseInsensitiveCompare:@"Bookmark"]==NSOrderedSame)
    {
        //
        [info addBookmarkObject:(Bookmark *)object];
       // [context save:nil];
        return YES;
    }

    // saleParcel
    if([className caseInsensitiveCompare:@"saleParcel"]==NSOrderedSame)
    {
        SaleParcel *newSalePar = (SaleParcel *)object;
        [info addSaleParcelObject:newSalePar];
        
        Sale *currSale = [AxDataManager getEntityObject:@"Sale" andPredicate:[NSPredicate predicateWithFormat:@"guid=%@", newSalePar.saleGuid] andContext:context];
        
        if(currSale!=nil)
        {
            [currSale addSaleParcelObject:newSalePar];
        }
        return YES;
    }
    // taxRoll
    if([className caseInsensitiveCompare:@"taxRoll"]==NSOrderedSame)
    {
        [info addTaxRollObject:(TaxRoll *)object];
        return YES;
    }
    // undivided int
    if([className caseInsensitiveCompare:@"undividedInt"]==NSOrderedSame)
    {
        [info addUndividedIntObject:(UndividedInt *)object];
        return YES;
    }
    // Valest
    if([className caseInsensitiveCompare:@"valEst"]==NSOrderedSame)
    {
        [info addValEstObject:(ValEst *)object];
        return YES;
    }
    // ValHist
    if([className caseInsensitiveCompare:@"valHist"]==NSOrderedSame)
    {
        [info addValHistObject:(ValHist *)object];
        return YES;
    }
    // CurrZoning
//    if([className caseInsensitiveCompare:@"currZoning"]==NSOrderedSame)
//    {
//        Land *land = info.land;
//        [land addCurrZoningObject:(CurrentZoning *)object];
//        return YES;
//    }
    // XLand
    if([className caseInsensitiveCompare:@"XLand"]==NSOrderedSame)
    {
        info.xland = (XLand *)object;
        return YES;
    }

    // Residential building
    if([className caseInsensitiveCompare:@"ResBldg"]==NSOrderedSame)
    {
        [info addResBldgObject:(ResBldg *)object];
        return YES;
    }

   
    // MHAccount
    if([className caseInsensitiveCompare:@"mHAccount"]==NSOrderedSame)
    {
        [info addMHAccountObject:(MHAccount *)object];
        return YES;
    }
//    if([className caseInsensitiveCompare:@"NoteInstance"]==NSOrderedSame)
//    {
//        NoteInstance *note = (NoteInstance *)object;
//         // noteRealPropInfo
//        if([note.src caseInsensitiveCompare:@"realprop"]==NSOrderedSame)
//        {
//            NoteRealPropInfo *noteInfo = [AxDataManager getNewEntityObject:@"NoteRealPropInfo" andContext:context ];
//            [AxDataManager copyManagedObject:note destination:noteInfo withSets:NO withLinks:NO];
//            [info addNoteRealPropInfoObject:noteInfo];
//            [context deleteObject:object];  // Avoid duplicate
//            return YES;
//        }
//        // NoteReview
//        else if([note.src caseInsensitiveCompare:@"review"]==NSOrderedSame)
//        {
//            NoteReview *noteReview = [AxDataManager getNewEntityObject:@"NoteReview" andContext:context ];
//            [AxDataManager copyManagedObject:note destination:noteReview withSets:NO withLinks:NO];
//
//            for(Review *review in info.review)
//            {
//                //Is this paren table have a child then load the object
//                //if(review.noteGuid IsEqualToString:noteReview.srcGuid)
//                if ([noteReview.srcGuid length] > 0)
//                {
//                    [review addNoteReviewObject:noteReview];
//                    return YES;
//                }
//            }
//            NSLog(@"Can't insert NoteReview");
//            return NO;
//        }    
//
//        // NoteHIExmpt
//        else if([note.src caseInsensitiveCompare:@"hiexmpt"]==NSOrderedSame)
//        {
//            NoteHIExmpt *noteHIE = [AxDataManager getNewEntityObject:@"NoteHIExmpt" andContext:context ];
//            [AxDataManager copyManagedObject:note destination:noteHIE withSets:NO withLinks:NO];
//
//            for(HIExmpt *exempt in info.hIExempt)
//            {
//                if([exempt.noteGuid isEqualToString:noteHIE.srcGuid])
//                {
//                    [exempt addNoteHIExmptObject:noteHIE];
//                    return YES;
//                }
//            }
//            NSLog(@"Can't insert NoteHIExempt");
//            return NO;
//        }    
//        // NoteSale
//        else if([note.src caseInsensitiveCompare:@"sale"]==NSOrderedSame)
//        {
//            NoteSale *noteSale = [AxDataManager getNewEntityObject:@"NoteSale" andContext:context ];
//            [AxDataManager copyManagedObject:note destination:noteSale withSets:NO withLinks:NO];
//            for(SaleParcel *parcel in info.saleParcel)
//            {
//                Sale *sale = parcel.sale;
//                
//                if([sale.guid isEqualToString:noteSale.srcGuid])
//                {
//                    [sale addNoteSaleObject:noteSale];
//                    return YES;
//                }
//            }
//            NSLog(@"Can't insert NoteSale");
//            return NO;
//        }
//        NSLog(@"Can't identify sale instance=%@", note.src);
//        return NO;
//    }
//    //////////////////////////////////////////////////////////////////////////////
//    if([className caseInsensitiveCompare:@"mediaAccy"]==NSOrderedSame)
//    {
//        MediaAccy *media = (MediaAccy *)object;
//        for(Accy *accy in info.accy)
//        {
//            //if(media.accyGuid==accy.guid && media.lineNbr==accy.lineNbr)
//            if(media.accyGuid==accy.guid)
//            {
//                [accy addMediaAccyObject:media];
//                return YES;
//            }
//        }
//        NSLog(@"Can't insert MediaAccy");
//        return NO;
//    }
       NSLog(@"--- this class can't be inserted: %@", NSStringFromClass([object class]));
    return NO;
}

//
// Redirect an object to a tab info
//
+(BOOL)Open:(NSString *)className withGuid:(NSString *)guid
{
    // Retrieve the object based on the GUID
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"guid=%@", guid];
    RealPropertyApp *app = (RealPropertyApp *)[[UIApplication sharedApplication] delegate];
    
    id object = [AxDataManager getEntityObject:className andPredicate:predicate];
    if(object==nil)
    {
        NSLog(@"Can't find object '%@' with guid='%@'", className, guid);
        return NO;
    }
    // Object is found. Depending on the object, walk back to find the RealPropInfo class
    if([className caseInsensitiveCompare:@"RealPropInfo"]==NSOrderedSame)
    {
        // Redirect to detail
        RealPropInfo *info = object;
        
        SelectedProperties *selObject = [[SelectedProperties alloc]initWithRealPropInfo:info];
        [RealProperty setSelectedProperties:selObject];

//        [app switchToProperty:[NSNumber numberWithInt:info.realPropId] tabIndex:kTabDetails guid:guid];
        [app switchToPropertyGuid: info.guid tabIndex:kTabDetails guid:guid];
        return YES;
    }
    if([className caseInsensitiveCompare:@"Land"]==NSOrderedSame)
    {
        Land *land = object;
        RealPropInfo *info = land.realPropInfo;

        SelectedProperties *selObject = [[SelectedProperties alloc]initWithRealPropInfo:info];
        [RealProperty setSelectedProperties:selObject];
        
//     [app switchToProperty:[NSNumber numberWithInt:info.realPropId] tabIndex:kTabLand guid:guid];
        [app switchToPropertyGuid: info.guid tabIndex:kTabLand guid:guid];
        return YES;
    }
    if([className caseInsensitiveCompare:@"XLand"]==NSOrderedSame)
    {
        XLand *xland = object;
        
        RealPropInfo *info = xland.realPropInfo;
        SelectedProperties *selObject = [[SelectedProperties alloc]initWithRealPropInfo:info];
        [RealProperty setSelectedProperties:selObject];

//        [app switchToProperty:[NSNumber numberWithInt:info.realPropId] tabIndex:kTabLand guid:guid];
        [app switchToPropertyGuid: info.guid tabIndex:kTabLand guid:guid];
        return YES;
    }
    if([className caseInsensitiveCompare:@"ResBldg"]==NSOrderedSame)
    {
        ResBldg *resBldg = object;
        //RealPropInfo *info = resBldg.land.realPropInfo;
        RealPropInfo *info = resBldg.realpropInfo;
        SelectedProperties *selObject = [[SelectedProperties alloc]initWithRealPropInfo:info];
        [RealProperty setSelectedProperties:selObject];

//        [app switchToProperty:[NSNumber numberWithInt:info.realPropId] tabIndex:kTabBuilding guid:guid];
        [app switchToPropertyGuid: info.guid tabIndex:kTabBuilding guid:guid];
        return YES;
    }
    
    return NO;
}
@end
