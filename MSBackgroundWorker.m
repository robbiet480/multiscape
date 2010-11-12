//
//  MSBackgroundWorker.m
//  MultiScape
//
//  Created by David Zwerdling on 11/11/10.
//  Copyright 2010 Laughing Man Software. All rights reserved.
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

#import "MSBackgroundWorker.h"

@interface MSBackgroundWorker ()

-(void) mainThreadCompletionNotification;

@end


@implementation MSBackgroundWorker

@synthesize baseImage;
@synthesize procText;

-(id) init
{
	if([super init] != nil)
	{
		fileManager = [NSFileManager defaultManager];
		
		sysEventsBridgeApp = [SBApplication applicationWithBundleIdentifier:@"com.apple.SystemEvents"];		
	}	
	
	return self;
}

-(void) mainThreadCompletionNotification
{
	NSNotification *n = [NSNotification notificationWithName:MSBackgroundWorkerFinishedNotification object:self];
	
	[[NSNotificationCenter defaultCenter] postNotification:n];
}

-(void) notifyOfCompletionInMainThread
{
	[self performSelectorOnMainThread:@selector(mainThreadCompletionNotification) withObject:nil waitUntilDone:FALSE];
}

-(void) execute
{
	NSArray *screens = [NSScreen screens];
	
	NSRect fullSpace = [self fullSpaceFromScreens:screens];
	
	CIImage *baseCIImage =[CIImage imageWithData:[baseImage TIFFRepresentation]];
	
	double scaleFactor = [self scaleFactorWithFullspace:fullSpace withOriginalImage:baseCIImage];	
	
	NSLog(@"Scale factor for image:%f", scaleFactor);
	
	CIImage *scaledImage = [self scaleImage:baseCIImage byFactor:scaleFactor];
	
	self.procText = [NSString stringWithFormat:@"%ix%i -(x%f)-> %ix%i", (int)[baseCIImage extent].size.width,  (int)[baseCIImage extent].size.height, scaleFactor, (int)[scaledImage extent].size.width, (int)[scaledImage extent].size.height];		
	
	NSString *outputDirectory = [self outputDirectory];
	
	NSUInteger i, count = [screens count];
	for (i = 0; i < count; i++) {
		NSScreen *screen = [screens objectAtIndex:i];
		
		CIVector *cropForScreen = [self cropRectForScreen:screen inFullSpace:fullSpace];
		
		CIImage *croppedImageForScreen = [self cropImage:scaledImage forScreen:cropForScreen];
		
		NSBitmapImageRep *bitmapImage = [self bitmapImageRepForImage:croppedImageForScreen];
		NSString *directoryForOutput = [NSString stringWithFormat:@"%@/%i.tiff", outputDirectory, i];
		
		[self saveImageToFile:directoryForOutput imageRep:bitmapImage];
		
		SystemEventsDesktop *thisDesktop = [[sysEventsBridgeApp desktops] objectAtIndex:i];
		
		[thisDesktop setPicture:[NSURL URLWithString:directoryForOutput]];			
	}
	
	[self notifyOfCompletionInMainThread];
}

-(NSString*) outputDirectory
{
	NSString *directoryForOutput = [NSString stringWithFormat:[@"~/Pictures/MultiScape/%f" stringByExpandingTildeInPath],[[NSDate date] timeIntervalSince1970]];
		
	if(! [fileManager fileExistsAtPath:[@"~/Pictures/MultiScape" stringByExpandingTildeInPath]])
		[fileManager createDirectoryAtPath:[@"~/Pictures/MultiScape" stringByExpandingTildeInPath] attributes:nil]; 
	
	[fileManager createDirectoryAtPath:directoryForOutput attributes:nil];	
	
	return directoryForOutput;
}

- (NSBitmapImageRep *)bitmapImageRepForImage:(CIImage*)ciImage 
{
	NSBitmapImageRep *bitmapImageRep = nil;
	CGRect extent = [ciImage extent];
	bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL 
															 pixelsWide:extent.size.width 
															 pixelsHigh:extent.size.height 
														  bitsPerSample:8 
														samplesPerPixel:4 
															   hasAlpha:YES
															   isPlanar:NO 
														 colorSpaceName:NSDeviceRGBColorSpace
															bytesPerRow:0
														   bitsPerPixel:0];
	NSGraphicsContext *nsContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:nsContext];
	[[NSColor clearColor] set];
	NSRectFill(NSMakeRect(0, 0, [bitmapImageRep pixelsWide], [bitmapImageRep pixelsHigh]));
	CGRect imageDestinationRect = CGRectMake(0.0, [bitmapImageRep pixelsHigh] - extent.size.height, extent.size.width, extent.size.height);
	CIContext *ciContext = [nsContext CIContext];
	[ciContext drawImage:ciImage atPoint:imageDestinationRect.origin fromRect:extent];
	[NSGraphicsContext restoreGraphicsState];
	[NSGraphicsContext restoreGraphicsState];
    return [bitmapImageRep autorelease];
}

-(CIImage*)	cropImage:(CIImage*)imageToCrop forScreen:(CIVector*)screenCropVector
{
	CIFilter *thisCropFilter = [CIFilter filterWithName:@"CICrop"];
	
	[thisCropFilter setDefaults];
	
	[thisCropFilter setValue:screenCropVector forKey:@"inputRectangle"];
	[thisCropFilter setValue:imageToCrop forKey:@"inputImage"];
	
	return [thisCropFilter valueForKey:@"outputImage"];
}

- (CIVector*) cropRectForScreen:(NSScreen*)screen inFullSpace:(NSRect)fullSpace
{	
	NSRect thisScreenFrame = [screen frame];
	
	float thisX = thisScreenFrame.origin.x - fullSpace.origin.x;
	float thisY = thisScreenFrame.origin.y - fullSpace.origin.y;
	float thisZ = thisScreenFrame.size.width;
	float thisW = thisScreenFrame.size.height;
	
	CIVector *thisVector = [[CIVector alloc] initWithX:thisX Y:thisY Z:thisZ W:thisW];
	
	return thisVector;
}

-(CIImage*) scaleImage:(CIImage*)imageToScale byFactor:(double)scaleFactor
{		
	CIFilter *scaleTransformFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
	
	[scaleTransformFilter setValue:[NSNumber numberWithDouble:scaleFactor] forKey:@"inputScale"];
	[scaleTransformFilter setValue:imageToScale forKey:@"inputImage"];
	[scaleTransformFilter setValue:[NSNumber numberWithInt:1] forKey:@"inputAspectRatio"];
	
	CIImage *scaledBaseImage = [scaleTransformFilter valueForKey:@"outputImage"];
	
	NSLog(@"Scaled base image dimensions: %f x %f",[scaledBaseImage extent].size.width, [scaledBaseImage extent].size.height);
	
	return [scaleTransformFilter valueForKey:@"outputImage"];
}

-(double) scaleFactorWithFullspace:(NSRect)fullSpace withOriginalImage:(CIImage*)originalImage
{
	CGRect baseImageRect = [originalImage extent]; 
	
	NSLog(@"\nBase Image Dimensions:\n              %f\n%f                 %f\n              %f",baseImageRect.size.height, baseImageRect.origin.x, baseImageRect.size.width, baseImageRect.origin.y);
	
	double hScale = fullSpace.size.width / baseImageRect.size.width;
	double vScale = fullSpace.size.height / baseImageRect.size.height;
	
	double scaleFactor = hScale;
	
	if(vScale > scaleFactor)
		scaleFactor = vScale;
	
	
	return scaleFactor;
}

-(NSRect) fullSpaceFromScreens:(NSArray*)screens
{
	NSRect fullSpace;
	
	fullSpace.origin.x = 0;
	fullSpace.origin.y = 0;
	fullSpace.size.width = 0;
	fullSpace.size.height = 0;
	
	for (NSScreen *thisScreen in screens) 
	{
		fullSpace.origin.x = [self minXBetween:fullSpace andScreen:thisScreen];
		fullSpace.origin.y = [self minYBetween:fullSpace andScreen:thisScreen];
		fullSpace.size.width = [self maxXBetween:fullSpace andScreen:thisScreen];
		fullSpace.size.height = [self maxYBetween:fullSpace andScreen:thisScreen];
		NSLog(@"\nIntermediate fullspace:\n              %f\n%f                 %f\n              %f",fullSpace.size.height, fullSpace.origin.x, fullSpace.size.width, fullSpace.origin.y);
	}
	
	NSLog(@"\nCompleted fullspace:\n              %f\n%f                 %f\n              %f",fullSpace.size.height, fullSpace.origin.x, fullSpace.size.width, fullSpace.origin.y);
	
	return fullSpace;
}

-(double) minXBetween:(NSRect)rect andScreen:(NSScreen*)screen
{
	double minX = [screen frame].origin.x;
	
	if(minX >  rect.origin.x)
		minX =  rect.origin.x;
	
	NSLog(@"New Min X:%f", minX);
	
	return minX;	
}

-(double) minYBetween:(NSRect)rect andScreen:(NSScreen*)screen
{
	double minY = [screen frame].origin.y;
	
	if(minY >  rect.origin.y)
		minY =  rect.origin.y;
	
	NSLog(@"New Min Y:%f", minY);
	
	return minY;	
}

-(double) maxXBetween:(NSRect)rect andScreen:(NSScreen*)screen
{
	double maxX = ([screen frame].origin.x + [screen frame].size.width);
	double chalX = (rect.origin.x + rect.size.width);
	
	if(maxX < chalX)
		maxX = chalX;
	
	NSLog(@"New Max X:%f", maxX);
	
	return maxX;	
}

-(double) maxYBetween:(NSRect)rect andScreen:(NSScreen*)screen
{
	double maxY = ([screen frame].origin.y + [screen frame].size.height);
	double chalY = (rect.origin.y + rect.size.height);
	
	if(maxY <  chalY)
		maxY =  chalY;
	
	NSLog(@"New Max Y:%f", maxY);
	
	return maxY;	
}

-(void)updateDimensions:(NSRect)fullSpace forScreen:(NSScreen*)displayToCheck
{	
	NSRect thisScreenFrame = [displayToCheck frame];
	
	float thisXMin = thisScreenFrame.origin.x;	
	float thisYMin = thisScreenFrame.origin.y;
	
	float thisXMax = thisScreenFrame.origin.x + thisScreenFrame.size.width;
	float thisYMax = thisScreenFrame.origin.y + thisScreenFrame.size.height;
	
	NSLog(@"\nScreen %@ Dimensions:\n              %f\n%f                 %f\n              %f",[displayToCheck description],thisYMax, thisXMin, thisXMax, thisYMin);
	
	if(thisXMin < fullSpace.origin.x)
		fullSpace.origin.x = thisXMin;
	if(thisXMax > (fullSpace.origin.x + fullSpace.size.width))
		fullSpace.size.width = thisXMax;
	
	if(thisYMin < (fullSpace.origin.y))
		fullSpace.origin.y = thisYMin;
	if(thisYMax > (fullSpace.origin.y + fullSpace.size.height))
		fullSpace.size.height= thisYMax;	
	
	NSLog(@"\nUpdated fullspace:\n              %f\n%f                 %f\n              %f",fullSpace.size.height, fullSpace.origin.x, fullSpace.size.width, fullSpace.origin.y);
}

-(void) saveImageToFile:(NSString*)fileLocation 
			   imageRep:(NSBitmapImageRep*)outputBitmapImageRep
{
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSImageCompressionFactor, [NSNumber numberWithBool:FALSE], NSImageProgressive, nil];
    NSData *outputData = [outputBitmapImageRep representationUsingType:NSJPEGFileType properties:properties];
	[outputData writeToFile:fileLocation atomically:NO];
}

#pragma mark Window Delegate Methods

- (BOOL)windowShouldClose:(id)window
{
	[NSApp terminate:self];
	
	return YES;
}

@end
