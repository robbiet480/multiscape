//
//  MSImageManipulationHelper.h
//  MultiScape
//
//  Created by David Zwerdling on 7/28/09.
//
//This file is part of MultiScape.
//
//MultiScape is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.

//MultiScape is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with MultiScape.  If not, see <http://www.gnu.org/licenses/>.
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "SystemEvents.h"

@interface MSImageManipulationHelper : NSObject {

}

+(NSRect) fullMonitorSpace;
+(double) minXBetween:(NSRect)rect andScreen:(NSScreen*)screen;
+(double) minYBetween:(NSRect)rect andScreen:(NSScreen*)screen;
+(double) maxXBetween:(NSRect)rect andScreen:(NSScreen*)screen;
+(double) maxYBetween:(NSRect)rect andScreen:(NSScreen*)screen;

+(double) scaleFactorWithFullspace:(NSRect)fullSpace withOriginalImage:(CIImage*)originalImage;
+(CIImage*) scaleImage:(CIImage*)imageToScale toFullSpace:(NSRect)fullSpace;
+(CIVector*) cropRectForScreen:(NSScreen*)screen inFullSpace:(NSRect)fullSpace;
+(CIImage*)	cropImage:(CIImage*)imageToCrop forScreenVector:(CIVector*)screenCropVector;
+(NSBitmapImageRep *)bitmapImageRepForImage:(CIImage*)ciImage;

@end
