/*
 
 File: MyOpenAL.h
 Abstract: OpenAL-related support functions
 Source: http://www.gehacktes.net/2009/03/iphone-programming-part-6-multiple-sounds-with-openal/

 Contributor: Alexander Shvetsov <ashvetsov@definitif.ru>
 */
 
#import <OpenAL/al.h>
#import <OpenAL/alc.h>

@interface MyOpenAL : NSObject {
    ALCcontext* mContext;
    ALCdevice* mDevice;
    NSMutableArray* bufferStorageArray;
    NSMutableDictionary* soundDictionary;
}

@property (nonatomic, retain) NSMutableArray* bufferStorageArray;
@property (nonatomic, retain) NSMutableDictionary* soundDictionary;

- (id)init;

- (void)playSoundWithId:(NSUInteger)soundId;
- (void)playSoundWithKey:(NSString*)soundKey;

- (void)playSoundWithId:(NSUInteger)soundId atVolume:(float)vol;
- (void)playSoundWithKey:(NSString*)soundKey atVolume:(float)vol;

- (void)stopSoundWithId:(NSUInteger)soundId;
- (void)stopSoundWithKey:(NSString*)soundKey;

- (bool)isPlayingSoundWithId:(NSUInteger)soundId;
- (bool)isPlayingSoundWithKey:(NSString*)soundKey;

- (void)rewindSoundWithId:(NSUInteger)soundId;
- (void)rewindSoundWithKey:(NSString*)soundKey;

- (NSUInteger)loadSoundFromFile:(NSString*)file ext:(NSString*)ext withLoop:(bool)loops;
- (bool)loadSoundWithKey:(NSString*)soundKey fromFile:(NSString*)file ext:(NSString*)ext withLoop:(bool)loops;

@end
