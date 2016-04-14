//
//  MSBackgroundWorker.h
//  MultiScape
//
//  Created by David Zwerdling on 11/11/10.
//  Copyright 2010 Laughing Man Software. All rights reserved.
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

#define MSBackgroundWorkerFinishedNotification @"MSBackgroundWorkerFinishedNotification"

@interface MSBackgroundWorker : NSObject {
	NSImage *__weak baseImage;
	
	//For setting the desktop
	SystemEventsApplication *sysEventsBridgeApp;
	
	//For creating the folders for output
	NSFileManager *fileManager;	
	
	NSString *__weak procText;
}

@property (weak, readwrite) NSImage *baseImage; 
@property (weak, readwrite) NSString *procText;

-(void) execute;
-(void) notifyOfCompletionInMainThread;

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

@end
