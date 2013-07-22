//
//  OverlayImportController.m
//  OverlayImporter
//
//  Created by Nucleus on 19/07/2013.
//  Copyright (c) 2013 Chappelltime. All rights reserved.
//

#import "OverlayImportController.h"
#import "ZipArchive.h"

@implementation OverlayImportController

- (void)addOverlayToDocumentsDirectory:(NSURL *)url
{
    NSLog(@"%@", url.lastPathComponent);
    
 
    dispatch_queue_t queue = dispatch_get_global_queue(
                                                       DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        BOOL unzip = [self downloadZipFileToDocumentsDirectory:url];
        
        if ( unzip ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Told main queue everyting fine");
            });
        }
    });
}

- (BOOL)downloadZipFileToDocumentsDirectory:(NSURL *)url {
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    BOOL unzippedCorrectly = NO;
    
    if(!error)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *savePath = [paths objectAtIndex:0];
        
        NSString *zipPath = [savePath stringByAppendingPathComponent:url.lastPathComponent];
        [data writeToFile:zipPath options:0 error:&error];
        
        if(!error)
        {
            BOOL didUnzip = [self unzipFileAtPath:zipPath toSavePath:savePath];
            
            if ( didUnzip ) {
                NSLog(@"Delete original downloaded zip");
                //clean up
                NSURL *originalZipURL = url;
                NSURL *createdZipURL = [NSURL URLWithString:url.lastPathComponent relativeToURL:[NSURL URLWithString:savePath]];
                
                [[NSFileManager defaultManager] removeItemAtURL:originalZipURL error:&error];
                [[NSFileManager defaultManager] removeItemAtURL:createdZipURL error:&error];
                
                unzippedCorrectly = YES;
                
                return unzippedCorrectly;
            }
        }
        else
        {
            NSLog(@"Error saving file %@",error);
            return unzippedCorrectly;
        }
    }
    else
    {
        NSLog(@"Error downloading zip file: %@", error);
        return unzippedCorrectly;
    }
    
    return unzippedCorrectly;
}

- (BOOL)unzipFileAtPath:(NSString *)zipPath toSavePath:(NSString *)savePath
{
    BOOL ret = NO;
    ZipArchive *za = [[ZipArchive alloc] init];
    if ([za UnzipOpenFile: zipPath]) {
        NSLog(@"Available for unzipping");
        ret = [za UnzipFileTo: savePath overWrite: YES];
        if (NO == ret){} [za UnzipCloseFile];
    }
    
    return ret;
}

@end
