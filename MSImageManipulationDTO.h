//
//  MSImageManipulationDTO.h
//  MultiScape
//
//  Created by David Zwerdling on 7/28/09.
//  Copyright 2009 Miami University, Ohio. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MSImageManipulationDTO : NSObject {
	bool shouldContinueProcessing;
	double timeStamp;
	NSImage *imageToProcess;
}

@property (assign, readwrite) NSImage *imageToProcess;
@property (readwrite) bool shouldContinueProcessing;
@property (readwrite) double timeStamp;

@end
