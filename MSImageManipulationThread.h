//
//  MSImageManipulationThread.h
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
#import "SystemEvents.h"

@class MSImageManipulationDTO;

@interface MSImageManipulationThread : NSThread {
	MSImageManipulationDTO *procDto;
	
	//For setting the desktop
	SystemEventsApplication *sysEventsBridgeApp;
	
	//For creating the folders for output
	NSFileManager *fileManager;
}

@property (assign, readwrite) MSImageManipulationDTO *procDto;

- (void) executeImageProcessing;
- (NSString*) outputDirectory;
-(void) saveImageToFile:(NSString*)fileLocation imageRep:(NSBitmapImageRep*)outputBitmapImageRep;

@end
