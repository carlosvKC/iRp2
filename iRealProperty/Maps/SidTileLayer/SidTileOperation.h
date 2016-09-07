#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface SidTileOperation : NSOperation <AGSTileOperation> {
    
@private
	id _target;
	SEL _action;
	
	AGSTile* _tile;
    AGSLOD* _lod;
    NSString *_sidFileName;
}

- (id)initWithTile:(AGSTile *)tile lod:(AGSLOD *)lod target:(id)target action:(SEL)action andSidFileName: (NSString *)sidFileName;


@property (nonatomic,strong) AGSTile* tile;
@property (nonatomic,strong) AGSLOD* lod;
@property (nonatomic,strong) id target;
@property (nonatomic,assign) SEL action;
@property (nonatomic,strong) NSString* sidFileName;

@end


