#import "DialogBoxNote.h"
#import "PictureDetails.h"
#import "MediaView.h"
#import "Helper.h"
#import "RealPropertyApp.h"
#import "RealProperty.h"


@implementation DialogBoxNote

    @synthesize textHelp;



    - (void)setupBusinessRules:(id)baseEntity
        {
            NoteInstance *note = (NoteInstance *) [self workingBase];

            NSMutableArray *array = [[NSMutableArray alloc] init];
            [Helper addSetToArray:note.mediaNote array:array];
            // setup the media
            [self addMedia:210 mediaArray:array];
            self.contentSizeForViewInPopover = self.view.frame.size;
            // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
            [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:note.mediaNote]]];

        }



    - (IBAction)showPictures:(id)sender
        {
            [self refreshMedias];
        }



    - (void)refreshMedias
        {
            NoteInstance *note = (NoteInstance *) [self workingBase];
            self.contentSizeForViewInPopover = self.view.frame.size;
            // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
            [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:note.mediaNote]]];
            //[self refreshMedias:[AxDataManager orderSet:note.mediaNote property:@"mediaDate" ascending:NO]];
        }



//
// A new media is created
//
    - (void)addNewMedia
        {
            NoteSale *noteSale = (NoteSale *) [self workingBase];

            MediaNote *media = [AxDataManager getNewEntityObject:@"MediaNote"];
            media.rowStatus = @"I";

            [self defaultMediaInformation:media];

            media.noteGuid = noteSale.guid;
            [noteSale addMediaNoteObject:media];

            // Refresh the grid
            // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
            [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:noteSale.mediaNote]]];
            //[self refreshMedias:[AxDataManager orderSet:noteSale.mediaNote property:@"mediaDate" ascending:NO]];

            self.contentSizeForViewInPopover = self.view.frame.size;
        }



    - (void)deleteMedia:(id)media
        {
            NoteSale               *noteSale = (NoteSale *) [self workingBase];
            NSManagedObjectContext *context  = [AxDataManager defaultContext];

            if ([[media rowStatus] isEqualToString:@"I"])
                {
                    [noteSale removeMediaNoteObject:media];
                    [context deleteObject:media];
                }
            else
                [media setRowStatus:@"D"];
//undo                [media setUpdateDate:[[Helper localDate]timeIntervalSinceReferenceDate]];
            // 2/21/13 HNN sort before calling refresh medias because I don't want to sort accross mediatypes (land, bldg, accy, etc)
            [self refreshMedias:[RealProperty sortMedia:[AxDataManager setToArray:noteSale.mediaNote]]];
            //[self refreshMedias:[AxDataManager orderSet:noteSale.mediaNote property:@"mediaDate" ascending:NO]];
            self.isDirty = YES;
            [self entityContentHasChanged:nil];
        }



    - (IBAction)addPicture:(id)sender
        {
            [self gridMediaAddPicture:nil];
        }



    - (void)didDismissModalView:(UIViewController *)dialogSender
                    saveContent:(BOOL)saveContent
        {
            NoteRealPropInfo *note = (NoteRealPropInfo *) [self workingBase];

            if (saveContent && [mediaDialogBox getImage] != nil)
                {
                    MediaNote *mediaNote = [AxDataManager getNewEntityObject:@"MediaNote"];
                    [MediaView createNewMedia:mediaNote fromMedia:[mediaDialogBox workingBase] withImage:[mediaDialogBox getImage]];
                    [note addMediaNoteObject:mediaNote];
                    self.isDirty = YES;
                }
            mediaDialogBox = nil;
            [self dismissViewControllerAnimated:YES completion:^(void)
                {
                }];
            // [self setupMedia:note.mediaNote];
        }



    - (void)viewDidUnload
        {
            [self setTextHelp:nil];
            [super viewDidUnload];
        }
@end
