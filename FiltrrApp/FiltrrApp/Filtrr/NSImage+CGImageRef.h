//
//  NSImage+CGImageRef.h
//  JukeBox
//
//  Created by Benedikt Terhechte on 06.01.10.
//  Copyright 2010 StyleMac. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (CGImageRefAdditions)
+ (NSImage*) imageWithCGImage:(CGImageRef)imageRef size:(NSSize)size;
- (CGImageRef) CGImage;
- (NSImage *)scaleImageToSize:(NSSize)newSize;
    
@end
