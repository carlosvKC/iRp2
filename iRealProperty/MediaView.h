#import <Foundation/Foundation.h>
enum MediaTypeConstant
{
    kMediaPict = 1,
    kMediaFplan = 2,
    kMediaMini  = 3
};
enum MediaTypeDescConstant
{
    kMediaImage = 1,
    kMediaVideo,
    kMediaAudio,
    kMediaDocumentation,
   kMediaPlan = 1
};
enum MediaTypeSrcConstant
{
    kMediaFromAccy = 0,
    kMediaFromBldg,
    kMediaFromLand,
    kMediaFromMobile,
    kMediaFromNote
};
@class NSManagedObject;

@interface MediaView : NSObject

+(UIImage *)getImageFromMedia:(NSManagedObject *)media;

+(UIImage *)getImageFromMiniMedia:(NSObject *)mediaLandRecord;

+(void)drawImageFromMediaInRect:(NSManagedObject *)media destRect:(CGRect)destRect scale:(BOOL)scale;
+(void)drawImageFromMediaInRect:(NSManagedObject *)media destRect:(CGRect)destRect scale:(BOOL)scale withColor:(UIColor *)color;
+(void)drawImageFromMiniMediaInRect:(NSManagedObject *)media destRect:(CGRect)destRect scale:(BOOL)scale;

+(void)drawImageFromImageInRect:(UIImage *)image destRect:(CGRect)destRect scale:(BOOL)scale;

+(void) createNewMedia:(id)destination fromMedia:(id)source withImage:(UIImage *)image;
+(UIImage*)imageScaledToSize:(CGSize)newSize
                 sourceImage:(UIImage *)image;
//+(NSArray*) sortMedia:(NSSet*)media;
@end
