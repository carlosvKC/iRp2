#import "DownloadFiles.h"
#import "Helper.h"
#import "AxDataManager.h"
#import "Requester.h"
#import "Container.h"
#import "Blob.h"
#import "Configuration.h"
#import "RealPropertyApp.h"


@interface DownloadFiles () {
        UIButton            *btnPause;
        UIButton            *btnCancel;
        UIAlertView         *closeAppView;
        BOOL                pausing;

        // Current container
        Container           *currentContainer;
        Blob                *currentBlob;
        unsigned long long  totalLength;         // total length in bytes
        double              downloadedBytes;     // number of bytes downloaded
        double              estimatedTime;       // estimated time to download the current container

        NSTimeInterval      startTime;
        NSTimeInterval      lastCallTime;
        NSTimeInterval      lastUpdate;
        BOOL                updateCommon;
    }
@end


@implementation DownloadFiles

    @synthesize textView;
    @synthesize cancelView;
    @synthesize progressBar;
    @synthesize infoText;
    @synthesize delegate;
    @synthesize saveDirectory;
    @synthesize hideCancel;



    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                }
            return self;
        }



    - (void)viewDidLoad
        {
            [super viewDidLoad];
#if 0
    btnPause = [Helper createBlueButton:pauseView.frame withTitle:@"Pause"];
    [self.view addSubview:btnPause];
    [pauseView removeFromSuperview];
    [btnPause addTarget:self action:@selector(pauseDownload:) forControlEvents:UIControlEventTouchUpInside];
#endif
            if (!hideCancel)
                {
                    btnCancel = [Helper createRedButton:cancelView.frame withTitle:@"Cancel"];
                    [self.view addSubview:btnCancel];
                    [cancelView removeFromSuperview];
                    [btnCancel addTarget:self action:@selector(cancelDownload:) forControlEvents:UIControlEventTouchUpInside];
                }
            pausing = NO;
            [progressBar setProgress:0 animated:YES];
            [self resumeContainer];
        }



    - (void)viewDidUnload
        {
            [self setTextView:nil];
            [self setCancelView:nil];
            [self setProgressBar:nil];
            [self setInfoText:nil];
            [super viewDidUnload];
            textView.text = @"";
        }



    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }



#pragma mark - Download the files




    //  ..........SAMPLE OF *currentContainer..........
    //
    //  <Container: 0xced1da0> (entity: Container; id: 0xce402c0 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Container/p8> ; data: {
    //      blobs =     (
    //          "0xced1d70 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p28>",
    //          "0xce98e60 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p29>",
    //          "0xce7e560 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p31>",
    //          "0xceb0300 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p30>"
    //      );
    //          eTag             = 0x8D0D954B2424A87;
    //          lastModifiedDate = "Tue, 07 Jan 2014 00:15:25 GMT";
    //          name             = Area02;
    //          url              = "http://irealproperty.blob.core.windows.net/area02";
    //  })
    //
    - (BOOL)resumeContainer
        {
            // Stop the timer
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

            // get the first container
            NSManagedObjectContext *context = [AxDataManager noteContext];

            // Get the list of containers that need downloading from the Container table in PersonalNotes database.
            NSArray *array = [AxDataManager dataListEntity:@"Container" andSortBy:@"name" sortAscending:YES withContext:context];

            if ([array count] == 0)
                {
                    // Here because all containers have been processed and we're now ready to wrap everything up.

                    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

                    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];

                    [RealPropertyApp allowToSync:YES];

                    if (updateCommon)
                        {
                            closeAppView = [[UIAlertView alloc] initWithTitle:@"Files Updated" message:@"The latest file update requires you to restart iRealProperty" delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:nil];
                            [closeAppView show];
                        }

                    if (!saveDirectory)
                        {
                            [Helper alertWithOk:@"Download Complete" message:@"The area was successfully downloaded. Please select a current area from the option menu."];
                            [delegate downloadFileTerminate:YES];
                        }
                    else
                        [delegate downloadFileTerminate:YES];

                    return NO;
                }

            // Get the first container in the list.
            currentContainer = [array objectAtIndex:0];
            totalLength      = 0;
            downloadedBytes  = 0;
            estimatedTime    = 0;

            // Calculate the number of bytes to download
            for (Blob *blob in currentContainer.blobs)
                {
                    totalLength += blob.length;
                }

            
            // Validate that the directory container exists
            if (!saveDirectory)
                [Helper createDirectory:[Helper fileSystemContainerName:currentContainer.name]];

            startTime = [NSDate timeIntervalSinceReferenceDate];

            if (totalLength > 0)
                {
                    [self addMessage:[NSString stringWithFormat:@"*** start download of '%@' ***\n", currentContainer.name]];
                    [self resumeBlob];
                    return YES;
                }
            else
                return NO;
        }





    //  ..........SAMPLE OF *currentContainer..........
    //
    //  <Container: 0xced1da0> (entity: Container; id: 0xce402c0 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Container/p8> ; data: {
    //      blobs =     (
    //          "0xced1d70 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p28>",
    //          "0xce98e60 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p29>",
    //          "0xce7e560 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p31>",
    //          "0xceb0300 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p30>"
    //      );
    //          eTag             = 0x8D0D954B2424A87;
    //          lastModifiedDate = "Tue, 07 Jan 2014 00:15:25 GMT";
    //          name             = Area02;
    //          url              = "http://irealproperty.blob.core.windows.net/area02";
    //  })
    //
    //
    //  ..........SAMPLE OF *currentBlob..........
    //
    //  <Blob: 0xced1760> (entity: Blob; id: 0xced1d70 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p28> ; data: {
    //      container 		= "0xce402c0 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Container/p8>";
    //      contentType 	= "text/xml";
    //      downloaded 		= 0;
    //      eTag 			= 0x8D12C5540DB3BED;
    //      lastModifiedDate = "Tue, 22 Apr 2014 15:18:30 GMT";
    //      leaseStatus 	= unlocked;
    //      length 			= 5160;
    //      name 			= "Area02.layers.xml";
    //      type 			= BlockBlob;
    //      url 			= "http://irealproperty.blob.core.windows.net/area02/Area02.layers.xml";
    //  })
    //
    //
    //  ..........SAMPLE OF *filePath:..........
    //  /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/Applications/8A2A07B6-725C-4FC2-ADD6-29A398ECEB1C/Documents/Area02/Area02.layers.xml
    //
    //  ..........SAMPLE OF *paths:..........
    //  /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/Applications/8A2A07B6-725C-4FC2-ADD6-29A398ECEB1C/Documents
    //
    //  ..........SAMPLE OF *fileNamesInPath: (notice some of these are dir names though)..........
    //  <__NSArrayM 0xdfaffc0>(
    //  	Area01,
    //  	Area02,
    //  	common,
    //  	PersonalNotes.sqlite,
    //  	PersonalNotes.sqlite-shm,
    //  	PersonalNotes.sqlite-wal,
    //  	Preferences.sqlite,
    //  	Preferences.sqlite-shm,
    //  	Preferences.sqlite-wal
    //
    //  ..........SAMPLE OF *documentDirectory:..........
    //  /Users/davidbaun/Library/Application Support/iPhone Simulator/7.1/Applications/8A2A07B6-725C-4FC2-ADD6-29A398ECEB1C/Documents
    //
    //  ..........SAMPLE OF *dirName:..........
    //  Area02
    //
    - (void)resumeBlob
        {
            if ([currentContainer.blobs count] == 0)
                {
                    // Here because this container has no more blobs to download.

                    // If we downloaded files for the 'common' or 'testcommon' container, then set the 'updateCommon' variable to YES to show that.
                    if ([currentContainer.name rangeOfString:@"common" options:NSCaseInsensitiveSearch].location != NSNotFound)
                        {
                            updateCommon = YES;
                        }

                    [self addMessage:[NSString stringWithFormat:@"*** '%@' *** completed\n\n", currentContainer.name]];

                    [Helper deleteBlobsForContainer:currentContainer.name];

                    NSManagedObjectContext *personalNotesSqlite = [AxDataManager noteContext];

                    [personalNotesSqlite deleteObject:currentContainer];
                    currentContainer = nil;

                    [personalNotesSqlite save:nil];

                    [self resumeContainer];

                    return;
                }

            NSString *filePath;
            NSArray  *paths;
            NSArray  *fileAndFolderNamesInPath;
            NSString *documentDirectory;
            NSString *thisDirItemsName = @"";

            paths                       = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            documentDirectory           = [paths objectAtIndex:0];
            fileAndFolderNamesInPath    = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:nil];
            currentBlob                 = [currentContainer.blobs anyObject];

            // This code will result in locating an existing directory for the current container name.
            // If that directory is found, then it will be appended to the path where the file is downloaded to.
            // This way, if the container being downloaded already has a directory on the device, the file will
            // be placed there, otherwise it will just wind up in the /Directory folder and have to be moved to a subfolder later.
            
            NSString* theStandardizedAreaName = [Helper fileSystemContainerName:currentContainer.name];
            
            for (thisDirItemsName in fileAndFolderNamesInPath)
            {
                if ([thisDirItemsName caseInsensitiveCompare:theStandardizedAreaName] == NSOrderedSame)
                    {
                        break;
                    }
            }

            filePath = [documentDirectory stringByAppendingPathComponent:thisDirItemsName];
            filePath = [filePath stringByAppendingPathComponent:currentBlob.name];


            [self addMessage:[NSString stringWithFormat:@"'%@' started\n", currentBlob.name]];

            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];

            [app downloadAzureFile:currentBlob.name
                       inContainer:[Helper versionSpecificContainerName:currentContainer.name]
                            toPath:filePath
                    withFileLength:currentBlob.length
               andResumingDownload:NO
                 andCallBackObject:self];
        }


#pragma mark - delegate


    - (void)downloadAzureFileDidFailWithError:(NSError *)error
        {
            [Helper alertWithOk:@"Error Downloading" message:[NSString stringWithFormat:@"%@", error]];
            [RealPropertyApp allowToSync:YES];

        }



    - (void)downloadAzureFileDidReceiveDataWithLength:(NSNumber *)dataLength
        {
            downloadedBytes += [dataLength floatValue];
            lastCallTime = [NSDate timeIntervalSinceReferenceDate];
            [self updateMessage];
        }



    //  ..........SAMPLE OF currentContainer AND currentBlob
    //
    //  <Container: 0xdda8e20> (entity: Container; id: 0xdda8030 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Container/p7> ; data: {
    //      blobs =     (
    //          "0xdda8b70 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p24>",
    //          "0xdda8770 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p25>",
    //          "0xdda7f10 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p26>",
    //          "0xdda7fb0 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p27>"
    //      );
    //      eTag 			 = 0x8D0D954B34D3909;
    //      lastModifiedDate = "Tue, 07 Jan 2014 00:15:26 GMT";
    //      name 			 = Area03;
    //      url				 = "http://irealproperty.blob.core.windows.net/area03";
    //  })
    //
    //  <Blob: 0xdda8840> (entity: Blob; id: 0xdda8b70 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Blob/p24> ; data: {
    //      container 		 = "0xdda8030 <x-coredata://D4647817-E3AC-4AD2-A4ED-9F7AFACB6BD8/Container/p7>";
    //      contentType 	 = "text/xml";
    //      downloaded 		 = 0;
    //      eTag 			 = 0x8D12C56EE2A09D8;
    //      lastModifiedDate = "Tue, 22 Apr 2014 15:30:31 GMT";
    //      leaseStatus 	 = unlocked;
    //      length 			 = 5174;
    //      name 			 = "Area03.layers.xml";
    //      type 			 = BlockBlob;
    //      url 			 = "http://irealproperty.blob.core.windows.net/area03/Area03.layers.xml";
    //  })
    //
    - (void)downloadAzureFileDidLoadData
        {
            [self addMessage:[NSString stringWithFormat:@"'%@' completed\n", currentBlob.name]];

            NSManagedObjectContext *personalNotesSqlite;
            Configuration          *config;

            personalNotesSqlite = [AxDataManager noteContext];
            config              = [RealPropertyApp getConfiguration];

            if (config)
                {
                    [Helper addOrUpdateFilesSyncRecordUsingContainerName:[currentContainer.name lowercaseString]
                                                            BlobFileName:currentBlob.name
                                                                    ETag:currentBlob.eTag
                                                         FileSizeInBytes:currentBlob.length
                                                             WithContext:personalNotesSqlite
                                                            ShouldDoSave:YES
                                                              UpdateType:kFilesSyncCreateOrUpdate];

                    config.checkAzureFile = YES;
                }

            // Remove the Blob from the Container.blobs list of blobs to download
            if ([currentContainer.blobs count]>0)
                {
                    [currentContainer removeBlobsObject:currentBlob];
                }


            // Download the next file
            [self resumeBlob];
        }


#pragma mark - buttons


    - (void)pauseDownload:(id)sender
        {
            pausing = !pausing;
            NSString *title = pausing ? @"Resume" : @"Pause";

            [btnPause setTitle:title forState:UIControlStateNormal];
        }



    - (void)cancelDownload:(id)sender
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stop Download"
                                                            message:@"Are you sure you want to stop the download? You will have to restart the operation from the beginning."
                                                           delegate:self
                                                  cancelButtonTitle:@"Continue"
                                                  otherButtonTitles:@"Stop", nil];
            [alert show];
        }



    - (void)alertView:(UIAlertView *)alertView
 clickedButtonAtIndex:(NSInteger)buttonIndex
        {
            if (alertView == closeAppView)
                {
                    exit(0);
                }

            if (buttonIndex == 0)
                return;

            RealPropertyApp *app = (RealPropertyApp *) [[UIApplication sharedApplication] delegate];
            [app cancelAzureFileDownload];

            // Delete the directory
            [Helper deleteDirectory:currentContainer.name];

            NSManagedObjectContext *personalNotesSqlite = [AxDataManager noteContext];

            if (currentContainer != nil)
                [personalNotesSqlite deleteObject:currentContainer];

            [personalNotesSqlite save:nil];

            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

            [delegate downloadFileTerminate:YES];
        }


#pragma mark - Update message


    - (void)updateMessage
        {
            double ratio = downloadedBytes / totalLength;
            [progressBar setProgress:ratio animated:NO];
            // estimate the time of download...

            if (downloadedBytes == 0)
                infoText.text = @"Calculating time left...";
            else
                {
                    if ([NSDate timeIntervalSinceReferenceDate] - lastUpdate > 1.0)
                        {
                            double timeByByte = (lastCallTime - startTime) / downloadedBytes;
                            long   timeLeft   = (totalLength - downloadedBytes) * timeByByte;

                            int hours = timeLeft / 3600;
                            timeLeft -= hours * 3600;
                            int minutes = timeLeft / 60;
                            timeLeft -= minutes * 60;
                            int seconds = timeLeft;

                            if (hours > 0)
                                infoText.text = [NSString stringWithFormat:@"Estimated time left: %dh %02dm %02ds", hours, minutes, seconds];
                            else if (minutes > 0)
                                infoText.text = [NSString stringWithFormat:@"Estimated time left: %dm %02ds", minutes, seconds];
                            else
                                infoText.text = [NSString stringWithFormat:@"Estimated time left: %ds", seconds];
                            lastUpdate = [NSDate timeIntervalSinceReferenceDate];
                        }
                }
        }



    - (void)addMessage:(NSString *)message
        {
            textView.text = [textView.text stringByAppendingString:message];
        }



    - (NSString *)description
        {
            NSMutableString *outputString;

            outputString = [[NSMutableString alloc] initWithCapacity:250];

            [outputString appendString:@"*** [DownloadFiles description] ***\n"];
            [outputString appendFormat:@"currentContainer.name  = %@\n", currentContainer.name];
            [outputString appendFormat:@"currentBlob.name       = %@\n", currentBlob.name];
            [outputString appendFormat:@"currentBlob.URL        = %@\n", currentBlob.url];
            [outputString appendFormat:@"updateCommon           = %@\n", (updateCommon ? @"YES" : @"NO")];

            return outputString;
        }

@end




/*
    -(NSString *)descriptionWithMethodName:(NSString *)nameOfCaller andTitle:(NSString *)titleMessage
        {
            NSMutableString *outputString;
            outputString = [[NSMutableString alloc] initWithCapacity:250];

            if (titleMessage)
                [outputString appendFormat:@"* Title: %@\n",titleMessage];

            if (nameOfCaller)
                [outputString appendFormat:@"* Method: %@\n",nameOfCaller];

            [outputString appendString:[self description]];

            return outputString;
        }
*/
