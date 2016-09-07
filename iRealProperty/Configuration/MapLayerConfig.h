//
//  MapLayerConfig.h
//  iRealProperty
//
//  Created by Regis Bridon on 6/20/12.
//  Copyright (c) 2012 to be changed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MapLayerConfig : NSManagedObject

@property (nonatomic, retain) NSString * area;
@property (nonatomic) BOOL clipping;
@property (nonatomic, retain) NSString * columnLabel;
@property (nonatomic, retain) NSString * descriptionColumn;
@property (nonatomic, retain) NSString * fillColor;
@property (nonatomic, retain) NSString * fillStyle;
@property (nonatomic, retain) NSString * friendlyName;
@property (nonatomic, retain) NSString * geoColumnName;
@property (nonatomic) BOOL isParcel;
@property (nonatomic) BOOL isPolygon;
@property (nonatomic) BOOL isSID;
@property (nonatomic) BOOL isStreet;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isWtrBdy;
@property (nonatomic, retain) NSString * labelColor;
@property (nonatomic) float labelFontSize;
@property (nonatomic, retain) NSString * layerName;
@property (nonatomic, retain) NSString * lineColor;
@property (nonatomic) double lineWidth;
@property (nonatomic) float maxScale;
@property (nonatomic) float minScale;
@property (nonatomic) BOOL removeLabelDuplicates;
@property (nonatomic) BOOL scaleLabel;
@property (nonatomic, retain) NSString * shapeType;
@property (nonatomic) BOOL showAnnotationPolygons;
@property (nonatomic) BOOL showLabels;
@property (nonatomic) BOOL showShapes;
@property (nonatomic, retain) NSString * tableName;
@property (nonatomic, retain) NSString * titleColumn;
@property (nonatomic) int32_t uid;
@property (nonatomic, retain) NSString * fontFamily;
@property (nonatomic) BOOL bold;
@property (nonatomic) BOOL italic;
@property (nonatomic, retain) NSString * fontFamilyColumnName;
@property (nonatomic) float labelAngle;
@property (nonatomic, retain) NSString * labelAngleColumnName;
@property (nonatomic, retain) NSString * labelFontSizeColumnName;
@property (nonatomic, retain) NSString * bolColumnName;
@property (nonatomic, retain) NSString * labelColorColumnName;
@property (nonatomic) NSTimeInterval updateDate;

@end
