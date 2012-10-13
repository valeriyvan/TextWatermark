//
//  main.m
//  textoverimage
//
//  Created by Valeriy Van on 15.09.12.
//  Copyright (c) 2012 w7software.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "NSFileManager+NameForTempFile.h"

#define kDefaultXOffset 0.0
#define kDefaultYOffest 0.0
#define kDefaultRotationDegrees 0.0
#define kDefaultColor whiteColor
#define kDefaultAlpha 0.8
#define kDefaultFontName @"Helvetica"
#define kDefaultFontSize 50.0
#define kDefaultCorner 1
#define kCompressionFactor 0.98

int main(int argc, char * argv[])
{
    
    @autoreleasepool {
        
        CGFloat x_offset = kDefaultXOffset;
        CGFloat y_offset = kDefaultYOffest;
        CGFloat rotation = kDefaultRotationDegrees;
        CGFloat alpha = kDefaultAlpha;
        SEL colorSelector = @selector(kDefaultColor);
        CGFloat fontSize = kDefaultFontSize;
        NSString *fontName = kDefaultFontName;
        NSString *folderForResultingFiles = nil;
        NSString *folderWhereOriginalFilesWillBeMovedTo = nil;
        float compressionFactor = kCompressionFactor;
        BOOL overwrireFiles = NO;
        int corner = kDefaultCorner;
        int c;
        
        opterr = 0; // supresses message prints in getopt
        
        while ((c = getopt (argc, argv, "x:y:r:a:c:f:s:d:D:q:1234oh")) != -1) {
            switch (c)
            {
                case 'x':
                    x_offset = atof(optarg);
                    if (x_offset<0) {
                        fprintf(stderr, "x coordinate should be not negative integer\n");
                        return 0;
                    }
                    break;
                case 'y':
                    y_offset = atof(optarg);
                    if (y_offset<0) {
                        fprintf(stderr, "y coordinate should be not negative integer\n");
                        return 0;
                    }
                    break;
                case 'r':
                    rotation = atof(optarg);
                    if (rotation!=0 && rotation!=90 && rotation!=-90) {
                        fprintf(stderr, "rotation angle should be 0, -90 or 90 degrees\n");
                        return 0;
                    }
                    break;
                case 'a':
                    alpha = atof(optarg);
                    if (alpha<0 || alpha>1) {
                        fprintf(stderr, "alpha component should be float from 0 up to 1\n");
                        return 0;
                    }
                    break;
                case 'c':
                    colorSelector = NSSelectorFromString([NSString stringWithCString:optarg encoding:NSUTF8StringEncoding]);
                    if (![NSColor respondsToSelector:colorSelector]) {
                        fprintf(stderr, "don't know such color %s\n", optarg);
                        return 0;
                    }
                    break;
                case 'f':
                    fontName = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                    break;
                case 's':
                    fontSize = atof(optarg);
                    if (fontSize<10) {
                        fprintf(stderr, "WARNING: font size %f seems to be too small\n", fontSize);
                        return 0;
                    }
                    break;
                case 'd':
                    folderForResultingFiles = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                    break;
                case 'D':
                    folderWhereOriginalFilesWillBeMovedTo = [NSString stringWithCString:optarg encoding:NSUTF8StringEncoding];
                    break;
                case '1':
                    corner = 1;
                    break;
                case '2':
                    corner = 2;
                    break;
                case '3':
                    corner = 3;
                    break;
                case '4':
                    corner = 4;
                    break;
                case 'o':
                    overwrireFiles = YES;
                    break;
                case 'q':
                    compressionFactor = atof(optarg);
                    if (compressionFactor<0.0 || compressionFactor>1.0) {
                        fprintf(stderr, "compression should be float from 0 up to 1\n");
                        return 0;
                    }
                    break;
                case 'h':
                    fprintf(stderr, "Images text watermarking utility. Ⓒ www.w7software.com\n");
                    fprintf(stderr, "%s [-x x_offest] [-y y_offset] [-r 0|90|-90] [-a alpha] [-c color] [-f font name] [-s font size] [1|2|3|4] (-o|(-d res_folder)) [-q comression] text file1 [file2 ... filen]\n", strrchr(argv[0], '/')+1);
                    fprintf(stderr, "Inserts text into image files specified. Only JPG format supported now.\n" );
                    fprintf(stderr, "-x float for x offset of text, 0 is default\n");
                    fprintf(stderr, "-y float for y offset of text, 0 is default\n");
                    fprintf(stderr, "Offsets are calculated from corner specified.\n");
                    fprintf(stderr, "-r float for rotation angle of text, 0, 90, -90 degrees are supported, 0 is default\n");
                    fprintf(stderr, "-c text for color text, like lightGrayColor, whiteColor is default\n");
                    fprintf(stderr, "-f font name, Helvetica is default\n");
                    fprintf(stderr, "-s float for font size, 50 is default\n");
                    fprintf(stderr, "-a float from 0.0 to 1.0 alpha component of text color, 1.0 is default\n");
                    fprintf(stderr, "-1 .. -4 corner for text origin, counter clockwise starting from 1 for down left, 1 is default\n");
                    fprintf(stderr, "-o files will be overwritten or\n");
                    fprintf(stderr, "-d specifies folder for resulting files\n");
                    fprintf(stderr, "-D specifies folder where origin images will be moved on success; couldn't be used with -o key\n");
                    fprintf(stderr, "-q float from 0.0 to 1.0 for quality of output JPG images, 0.98 is default\n");
                    fprintf(stderr, "One of -o or -d should be specified explicitly.\n");
                    return 1;
                case '?':
                    if ( strchr("xyracfsdDq", optopt) )
                        fprintf (stderr, "Option -%c requires an argument.\n", optopt);
                    else if (isprint (optopt))
                        fprintf (stderr, "Unknown option `-%c'.\n", optopt);
                    else
                        fprintf (stderr, "Unknown option character `\\x%x'.\n", optopt);
                    return 1;
                default:
                    return 1;
            }
        }
        
        //NSLog(@"argc=%d, optind=%d\n", argc, optind);
        if (argc - optind < 2 ) { // TODO: что-то здесь не так!!!
            fprintf(stderr, "Two parameters are necessary. Run with -h for help.\n" );
            return 1;
        }
        
        if ((folderForResultingFiles==nil && overwrireFiles==NO) || (folderForResultingFiles!=nil && overwrireFiles==YES)) {
            fprintf(stderr, "One of -o or -d should be specified explicitly. Run with -h for help.\n");
            return 1;
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDirectory;
        if (folderForResultingFiles && ![fileManager fileExistsAtPath:folderForResultingFiles isDirectory:&isDirectory]) {
            fprintf(stderr, "Directory %s doesn't exist\n", [folderForResultingFiles cStringUsingEncoding:NSUTF8StringEncoding]);
            return 1;
        }
        if (folderForResultingFiles && !isDirectory) {
            fprintf(stderr, "%s is not a directory\n", [folderForResultingFiles cStringUsingEncoding:NSUTF8StringEncoding]);
            return 1;
        }

        if (folderWhereOriginalFilesWillBeMovedTo!=nil && overwrireFiles!=NO) {
            fprintf(stderr, "-D coudn't be used with -o. Run with -h for help.\n");
            return 1;
        }
        if (folderWhereOriginalFilesWillBeMovedTo && ![fileManager fileExistsAtPath:folderWhereOriginalFilesWillBeMovedTo isDirectory:&isDirectory]) {
            fprintf(stderr, "Directory %s doesn't exist\n", [folderWhereOriginalFilesWillBeMovedTo cStringUsingEncoding:NSUTF8StringEncoding]);
            return 1;
        }
        if (folderWhereOriginalFilesWillBeMovedTo && !isDirectory) {
            fprintf(stderr, "%s is not a directory\n", [folderWhereOriginalFilesWillBeMovedTo cStringUsingEncoding:NSUTF8StringEncoding]);
            return 1;
        }
        
        NSColor *colorWithoutAlpha = [[NSColor class] performSelector:colorSelector];
        NSColor *color = [colorWithoutAlpha colorWithAlphaComponent:alpha];
        NSFont *font = [NSFont fontWithName:fontName size:fontSize];
        NSDictionary *stringAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          color, NSForegroundColorAttributeName,
                                          nil];
        
        NSString* text = [NSString stringWithCString:argv[optind] encoding:NSUTF8StringEncoding];
        
        for (int index = optind+1; index < argc; index++) {
            @autoreleasepool {
                // without this GB memory is not freed on every step,
                // and memory footpring for 150 of photographs 5MB each easy goes close 20GB and freeses
                // system with 4GB RAM

                NSString *pathname = [NSString stringWithCString:argv[index] encoding:NSUTF8StringEncoding];
                
                if ([text isEqualToString:@"debug"]) {
                    // Change "debug" text with:
                    // (realx, realy)> commandline
                    NSMutableString *debugText = [NSMutableString stringWithFormat:@"(%.1f,%.1f)> ", x_offset, y_offset];
                    [debugText appendString:[NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding]];
                    for (int i=2; i<argc; i++) {
                        [debugText appendString:@" "];
                        [debugText appendString:[NSString stringWithCString:argv[i] encoding:NSUTF8StringEncoding]];
                    }
                    text = [debugText copy];
                }
                
                NSRect sizeOfText = [text boundingRectWithSize:NSMakeSize(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes];
                
                if (![fileManager fileExistsAtPath:pathname]) {
                    fprintf(stderr, "Doesn't exist file %s\n", argv[index]);
                    continue;
                }
                
                NSImage* image = [[NSImage alloc] initWithContentsOfFile: pathname];
                if (!image) {
                    fprintf(stderr, "Couldn't open image from file %s\n", argv[index]);
                    continue;
                }
                
                // Get compression rate
                //NSTIFFCompression compression;
                //float compressionFactor;
                //NSData *imageData = [NSData dataWithContentsOfFile:pathname];
                //if (!imageData)
                //    NSLog(@"Error reading data of %@", pathname);
                //NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                //[imageRep getCompression:&compression factor:&compressionFactor];
                //NSLog(@"compressionFactor = %f", compressionFactor);
                
                CGFloat realx, realy;
                // (0,0) of a string is it's down left corner, obviously.
                // remember that doing following transforms
                switch (corner) {
                    default:
                    case 1:
                        if (rotation==0) {
                            // text is horisontal, everythins is straghtforward
                            realx = x_offset;
                            realy = y_offset;
                        } else if (rotation==90) {
                            // text is vertical from down up
                            realx = x_offset + fontSize; // without this, provided x_offset is 0, vertical text will be off the left edge
                            realy = y_offset;
                        } else if (rotation==-90) {
                            // text is vertical from up down
                            realx = x_offset;
                            realy = y_offset + sizeOfText.size.width; // (0,0) of text is flipped to be up
                        } else {
                            fprintf(stderr, "Something wrong with rotation angle %f\n", rotation);
                        }
                        break;
                    case 2:
                        if (rotation==0) {
                            // horizontal
                            realx = image.size.width - x_offset - sizeOfText.size.width;
                            realy = y_offset;
                        } else if (rotation==90) {
                            // text is vertical from down up
                            realx = image.size.width -  x_offset;
                            realy = y_offset;
                        } else if (rotation==-90) {
                            // text is vertical from up down
                            realx = image.size.width - x_offset - fontSize; // without this, provided x_offset is 0, vertical text will be off the right edge
                            realy = y_offset + sizeOfText.size.width; // (0,0) of text is flipped to be up
                        } else {
                            fprintf(stderr, "Something wrong with rotation angle %f\n", rotation);
                        }
                        break;
                    case 3:
                        if (rotation==0) {
                            // horizontal
                            realx = image.size.width - x_offset - sizeOfText.size.width;
                            realy = image.size.height - y_offset - fontSize;
                        } else if (rotation==90) {
                            // text is vertical from down up
                            realx = image.size.width -  x_offset;
                            realy = image.size.height - y_offset - sizeOfText.size.width;
                        } else if (rotation==-90) {
                            // text is vertical from up down
                            realx = image.size.width - x_offset - fontSize; // without this, provided x_offset is 0, vertical text will be off the right edge
                            realy = image.size.height - y_offset; // (0,0) of text is flipped to be up
                        } else {
                            fprintf(stderr, "Something wrong with rotation angle %f\n", rotation);
                        }
                        break;
                    case 4:
                        if (rotation==0) {
                            // horizontal
                            realx = x_offset;
                            realy = image.size.height - y_offset - fontSize;
                        } else if (rotation==90) {
                            // text is vertical from down up
                            realx = x_offset + fontSize; // without this, provided x_offset is 0, vertical text will be off the right edge
                            realy = image.size.height - y_offset - sizeOfText.size.width;
                        } else if (rotation==-90) {
                            // text is vertical from up down
                            realx = x_offset;
                            realy = image.size.height - y_offset; // (0,0) of text is flipped to be up
                        } else {
                            fprintf(stderr, "Something wrong with rotation angle %f\n", rotation);
                        }
                        break;
                }
                // Not a problem if text is bigger that image
                //NSLog(@"x=%f, y=%f\n", realx, realy);
                
                [image lockFocus];
                
                // Explained http://www.cocoabuilder.com/archive/cocoa/222242-nsattributedstring-in-nsaffinetransform.html
                NSAffineTransform* transform = [NSAffineTransform transform];
                [transform translateXBy:realx yBy:realy];
                [transform rotateByDegrees:rotation];
                [transform translateXBy:-realx yBy:-realy];
                //[NSGraphicsContext saveGraphicsState]; // TODO: это лишнее, мне кажется
                [transform concat];
                //[myAttributedString drawAtPoint:myPoint];
                [text drawAtPoint: NSMakePoint(realx, realy) withAttributes: stringAttributes];
                //[NSGraphicsContext restoreGraphicsState];
                
                [image unlockFocus];
                
                // Save file. based on http://stackoverflow.com/questions/3038820/how-to-save-a-nsimage-as-a-new-file
                // Cache the reduced image
                NSData *imageData = [image TIFFRepresentation]; //The call to "TIFFRepresentation" is essential otherwise you may not get a valid image.
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
                NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:compressionFactor] forKey:NSImageCompressionFactor];
                imageData = [imageRep representationUsingType:NSJPEGFileType properties:imageProps];
                
                NSString *resPathname;
                if (overwrireFiles) {
                    resPathname = [pathname copy];
                } else {
                    NSString *filenameAndExtention = [pathname lastPathComponent];
                    resPathname = [folderForResultingFiles stringByAppendingPathComponent:filenameAndExtention];
                    if ([fileManager fileExistsAtPath:resPathname]) {
                        resPathname = [fileManager uniqueFileName:resPathname];
                    }
                }
                
                BOOL writingSuccess = [imageData writeToFile:resPathname atomically:NO];
                
                if (!writingSuccess) {
                    fprintf(stderr, "Writing file %s wasn't successful\n", [pathname cStringUsingEncoding:NSUTF8StringEncoding]);
                } else {
                    fprintf(stderr, "Finished with file %s", [pathname cStringUsingEncoding:NSUTF8StringEncoding]);
                    if (folderWhereOriginalFilesWillBeMovedTo) {
                        NSError *error;
                        NSString *filename = [pathname lastPathComponent];
                        NSString *newPath = [folderWhereOriginalFilesWillBeMovedTo stringByAppendingPathComponent:filename];
                        if ([fileManager fileExistsAtPath:newPath]) {
                            newPath = [fileManager uniqueFileName:newPath];
                        }
                        if (![fileManager moveItemAtPath:pathname toPath:newPath error:&error]) {
                            fprintf(stderr, ", could'n move original into folder %s", [folderWhereOriginalFilesWillBeMovedTo cStringUsingEncoding:NSUTF8StringEncoding]);
                        }
                    }
                    fprintf(stderr, "\n");
                }
            } // @autoreleasepool
        } // for
        
    }
    
    return 0;
}