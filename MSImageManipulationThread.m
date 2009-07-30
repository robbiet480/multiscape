//
//  MSImageManipulationThread.m
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
//

#import "MSImageManipulationThread.h"
#import "MSImageManipulationDTO.h"
#import "MSImageManipulationHelper.h"

@implementation MSImageManipulationThread

@synthesize procDto;

-(void) main
{	
	NSLog(@"MSImageManipulationThread: main +");
	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
		
	fileManager = [NSFileManager defaultManager];
	
	sysEventsBridgeApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.SystemEvents"];
	
	if(procDto == nil)
	{
		NSLog(@"MSImageManipulationThread: ProcDTO is nil.  Exiting thread.");
		return;
	}
	
	if(procDto.shouldContinueProcessing)
	{
		[self executeImageProcessing];
	}
	else
	{
		NSLog(@"MSImageManipulationThread: procDto prematurely forced thread exit.");
	}
		
	[pool release];
	
	NSLog(@"MSImageManipulationThread: main -");
}

- (void) executeImageProcessing
{
	NSLog(@"MSImageManipulationThread: executeImageProcessing +");
	
	if(procDto.imageToProcess == nil)
	{
		NSLog(@"MSImageManipulationThread: Image to process is nil.");
		return;
	}
		
	NSRect fullSpace = [MSImageManipulationHelper fullMonitorSpace];

	CIImage *baseCIImage =[CIImage imageWithData:[procDto.imageToProcess TIFFRepresentation]];
	
	if(! procDto.shouldContinueProcessing)
	{
		NSLog(@"MSImageManipulationThread: procDto cancelling process after baseCIImage calculation.");
		return;
	}
			
	CIImage *scaledImage = [MSImageManipulationHelper scaleImage:baseCIImage toFullSpace:fullSpace];
	
	if(! procDto.shouldContinueProcessing)
	{
		NSLog(@"MSImageManipulationThread: procDto cancelling process after scaledImage calculation.");
		return;
	}
	
	NSString *outputDirectory = [self outputDirectory];
	
	NSArray *screens = [NSScreen screens];
	
	NSMutableArray *completedDesktopPaths = [NSMutableArray array];
	for (int i = 0; i < [screens count]; i++) 
	{
		NSScreen *screen = [screens objectAtIndex:i];
		
		CIVector *cropForScreen = [MSImageManipulationHelper cropRectForScreen:screen inFullSpace:fullSpace];
			
		CIImage *croppedImageForScreen = [MSImageManipulationHelper cropImage:scaledImage forScreenVector:cropForScreen];
			
		NSBitmapImageRep *bitmapImage = [MSImageManipulationHelper bitmapImageRepForImage:croppedImageForScreen];
				
		NSString *croppedImagePath = [NSString stringWithFormat:@"%@/%i.tiff", outputDirectory, i];
		
		NSLog(@"MSImageManipulationThread: Saving cropped image for screen %i to path %@.", i, croppedImagePath);			
		
		[self saveImageToFile:croppedImagePath imageRep:bitmapImage];
		
		[completedDesktopPaths addObject:croppedImagePath];
	}
	
	if(! procDto.shouldContinueProcessing)
	{
		NSLog(@"MSImageManipulationThread: procDto cancelling process after image processing.");
		return;
	}
	
	for (int i = 0; i < [screens count]; i++) 
	{
		SystemEventsDesktop *thisDesktop = [[sysEventsBridgeApp desktops] objectAtIndex:i];
		
		[thisDesktop setPicture:[NSURL URLWithString:[completedDesktopPaths objectAtIndex:i]]];			
	}
	
	NSLog(@"MSImageManipulationThread: executeImageProcessing -");
}

-(NSString*) outputDirectory
{
	NSString *directoryForOutput = [[NSString stringWithFormat:@"~/Pictures/MultiScape/%f", procDto.timeStamp]  stringByExpandingTildeInPath];
	
	NSLog(@"MSImageManipulationThread: Output directory: %@", directoryForOutput);
	
	if(! [fileManager fileExistsAtPath:[@"~/Pictures/MultiScape" stringByExpandingTildeInPath]])
		[fileManager createDirectoryAtPath:[@"~/Pictures/MultiScape" stringByExpandingTildeInPath] attributes:nil]; 
	
	[fileManager createDirectoryAtPath:directoryForOutput attributes:nil];	
	
	return directoryForOutput;
}

-(void) saveImageToFile:(NSString*)fileLocation 
			   imageRep:(NSBitmapImageRep*)outputBitmapImageRep
{
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSImageCompressionFactor, [NSNumber numberWithBool:FALSE], NSImageProgressive, nil];
    NSData *outputData = [outputBitmapImageRep representationUsingType:NSJPEGFileType properties:properties];
	[outputData writeToFile:fileLocation atomically:NO];
}

@end