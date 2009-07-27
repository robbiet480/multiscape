//
//  MSMainWinController.h
//  MultiScape
//
//  Created by David Zwerdling on 12/20/08.
//  Copyright 2008 Miami University, Ohio. All rights reserved.
//
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
#define MAX_DISPLAYS 32

@interface MSMainWinController : NSWindowController
{
	
	//For setting the desktop
	SystemEventsApplication *sysEventsBridgeApp;
	
	//For creating the folders for output
	NSFileManager *fileManager;
	
	//Interface elements
	IBOutlet NSTextField *infoField;
	IBOutlet NSImageView *baseImageView;
	
	NSImage *baseImage;
}

@property(assign, readwrite) NSImage *baseImage; 

#pragma mark Main Execute Methods
- (void) executeForImage:(NSImage*) startImage;

#pragma mark Image Manipulation Methods
-(NSRect) fullSpaceFromScreens:(NSArray*)screens;

-(void)updateDimensions:(NSRect)fullSpace forScreen:(NSScreen*)displayToCheck;

-(double) scaleFactorWithFullspace:(NSRect)fullSpace withOriginalImage:(CIImage*)originalImage;
-(CIImage*) scaleImage:(CIImage*)imageToScale byFactor:(double)scaleFactor;
-(CIImage*)	cropImage:(CIImage*)imageToCrop forScreen:(CIVector*)screenCropVector;
-(CIVector*) cropRectForScreen:(NSScreen*)screen inFullSpace:(NSRect)fullSpace;
-(NSBitmapImageRep *)bitmapImageRepForImage:(CIImage*)ciImage;
-(NSString*) outputDirectory;
-(void) saveImageToFile:(NSString*)fileLocation imageRep:(NSBitmapImageRep*)outputBitmapImageRep;

-(double) minXBetween:(NSRect)rect andScreen:(NSScreen*)screen;
-(double) minYBetween:(NSRect)rect andScreen:(NSScreen*)screen;
-(double) maxXBetween:(NSRect)rect andScreen:(NSScreen*)screen;
-(double) maxYBetween:(NSRect)rect andScreen:(NSScreen*)screen;







//- (void) updateNonRelativeSize;
//
//- (void) setupFilesForOutput;
//
//- (NSBitmapImageRep*) bitmapImageRepForImage:(CIImage*)ciImage;
//
//- (void) saveImageToFile:(NSString*)fileLocation imageRep:(NSBitmapImageRep*)outputBitmapImageRep;
//
//#pragma mark Output Methods
//- (void) setImageAtPath:(NSString*)pathToImage forScreen:(NSScreen*)screen;
//
//#pragma mark Image Modification Methods
//- (int) getAddrOfScreen:(NSScreen*)screen;
//
//- (CIVector*) getCropRectForScreen:(NSScreen*)screen;
//
//- (CIImage*) cropImage:(CIImage*)scaledBaseImage forScreen:(NSScreen*)screenToProcessImageFor;
//
//- (float)  scaleFactorForImageWithDimensions:(CGRect)baseImageSize;
//
//- (void) processImage:(CIImage*)scaledBaseImage forScreen:(NSScreen*)screenToProcessImageFor;
//
//- (CIImage*) processSelectedImage;


@end
