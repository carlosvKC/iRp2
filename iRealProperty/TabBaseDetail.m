#import "TabBaseDetail.h"


@implementation TabBaseDetail

    @synthesize itsController;



// buble up the change in the content
    - (void)entityContentHasChanged:(ItemDefinition *)entity
        {
            [itsController entityContentHasChanged:entity];
        }

#pragma - Handles the medias (pass them to the controller)

    - (void)gridMediaSelection:(id)grid
                         media:(id)media
                   columnIndex:(int)columnIndex
        {
            [itsController gridMediaSelection:grid media:media columnIndex:columnIndex];
        }



    - (void)gridMediaAddPicture:(id)grid
        {
            [itsController gridMediaAddPicture:grid];
        }


    - (void)gridMediaAddCad:(id)grid
        {
            [itsController gridMediaAddCad:grid];
        }



    - (void)gridMediaLongSelection:(id)grid
                            inCell:(id)cell
                         withMedia:(id)media
        {
            [itsController gridMediaLongSelection:grid inCell:cell withMedia:media];
        }

#pragma mark - Rotate the view

    - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
        {
            return YES;
        }



    - (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
        {
            // new rotation is here
        }

#pragma mark - View LifeCycle

    - (id)initWithNibName:(NSString *)nibNameOrNil
                   bundle:(NSBundle *)nibBundleOrNil
        {
            self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
            if (self)
                {
                }
            return self;
        }



    - (void)didReceiveMemoryWarning
        {
            [super didReceiveMemoryWarning];
        }



    - (void)viewDidLoad
        {
            [super viewDidLoad];
            [self setScreenEntities];
        }



    - (void)viewDidUnload
        {
            [super viewDidUnload];

            gridControlBar = nil;
        }



    - (void)setupBusinessRules:(id)baseEntity
        {
        }



    - (void)setupGrid:(id)tempBaseEntity
             withItem:(ItemDefinition *)item
        {
        }
@end