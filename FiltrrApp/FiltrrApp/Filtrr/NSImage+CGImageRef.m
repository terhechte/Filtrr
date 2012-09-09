//
//  NSImage+CGImageRef.m
//  JukeBox
//
//  Created by Benedikt Terhechte on 06.01.10.
//  Copyright 2010 StyleMac. All rights reserved.
//

#import "NSImage+CGImageRef.h"


@implementation NSImage (CGImageRefAdditions)

+ (NSImage*) imageWithCGImage:(CGImageRef)imageRef size:(NSSize)size {
    NSImage *anImage = [[NSImage alloc] initWithCGImage:imageRef size:size];
    return anImage;
}

- (NSBitmapImageRep *)bitmapImageRepresentation
{
    NSBitmapImageRep *ret = (NSBitmapImageRep *)[self bestRepresentationForDevice:nil];

    if(![ret isKindOfClass:[NSBitmapImageRep class]])
    {
        ret = nil;
        for(NSBitmapImageRep *rep in [self representations])
            if([rep isKindOfClass:[NSBitmapImageRep class]])
            {
                ret = rep;
                break;
            }
    }

    // if ret is nil we create a new representation
    if(ret == nil)
    {
        NSSize size = [self size];

        size_t width         = size.width;
        size_t height        = size.height;
        size_t bitsPerComp   = 32;
        size_t bytesPerPixel = (bitsPerComp / CHAR_BIT) * 4;
        size_t bytesPerRow   = bytesPerPixel * width;
        size_t totalBytes    = height * bytesPerRow;

        NSMutableData *data = [NSMutableData dataWithBytesNoCopy:calloc(totalBytes, 1) length:totalBytes freeWhenDone:YES];

        CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

        CGContextRef ctx = CGBitmapContextCreate([data mutableBytes], width, height, bitsPerComp, bytesPerRow, space, kCGBitmapFloatComponents | kCGImageAlphaPremultipliedLast);

        if(ctx != NULL)
        {
            [NSGraphicsContext saveGraphicsState];
            [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:[self isFlipped]]];

            [self drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];

            [NSGraphicsContext restoreGraphicsState];

            CGImageRef img = CGBitmapContextCreateImage(ctx);

            ret = [[NSBitmapImageRep alloc] initWithCGImage:img];
            [self addRepresentation:ret];

            CFRelease(img);
            CFRelease(space);

            CGContextRelease(ctx);
        }
        else NSLog(@"%@ Couldn't create CGBitmapContext", self);
    }

    return ret;
}

- (CGImageRef)CGImage
{
    return [[self bitmapImageRepresentation] CGImage];
}

- (NSImage *)scaleImageToSize:(NSSize)newSize {
    NSRect drawRect = NSMakeRect(0, 0, newSize.width, newSize.height);
	NSImage *tempImage = [[NSImage alloc] initWithSize:NSMakeSize(NSWidth(drawRect), NSHeight(drawRect) )];
	[tempImage lockFocus]; {
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		[self drawInRect:drawRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
	}
	[tempImage unlockFocus];
	NSImage *newImage = [[NSImage alloc] initWithData:[tempImage TIFFRepresentation]]; //*** UGH! why do I have to do this to commit the changes?;
	return newImage;
}


@end
