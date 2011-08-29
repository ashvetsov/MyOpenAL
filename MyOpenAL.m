/*
 
 File: MyOpenAL.m
 Abstract: OpenAL-related support functions
 Source: http://www.gehacktes.net/2009/03/iphone-programming-part-6-multiple-sounds-with-openal/

 Contributor: Alexander Shvetsov <ashvetsov@definitif.ru>
 */

#import "MyOpenAL.h"
#import "MyOpenALSupport.h"

@implementation MyOpenAL
@synthesize bufferStorageArray, soundDictionary;

// Gets size property of file (in bytes).
- (UInt32)audioFileSize:(AudioFileID)fileDescriptor {
    UInt64 outDataSize = 0;
    UInt32 thePropSize = sizeof(UInt64);
    OSStatus result = AudioFileGetProperty(fileDescriptor, kAudioFilePropertyAudioDataByteCount, &thePropSize, &outDataSize);
    if(result != 0) NSLog(@"cannot find file size");
    return (UInt32)outDataSize;
}

- (id)init {
    [super init];

    // Creating OpenAL device.
    mDevice = alcOpenDevice(NULL);
    if (!mDevice) {
        [self release];
        return nil;
    }

    // Creating and assigning context.
    mContext = alcCreateContext(mDevice, NULL);
    alcMakeContextCurrent(mContext);

    // Initializing dictionaries and arrays.
    self.bufferStorageArray = [[[NSMutableArray alloc] init] autorelease];
    self.soundDictionary = [[[NSMutableDictionary alloc] init] autorelease];

    return self;
}

// Plays sound with identifier specified.
- (void)playSoundWithId:(NSUInteger)soundId {
    alSourcePlay(soundId);
}
- (void)playSoundWithKey:(NSString*)soundKey {
    NSNumber * numVal = [soundDictionary objectForKey:soundKey];
    if (numVal == nil) return;

    alSourcePlay([numVal unsignedIntValue]);
}

// Plays sound with identifier specified with volume specified.
- (void)playSoundWithId:(NSUInteger)soundId atVolume:(float)vol {
    alSourcef(soundId, AL_GAIN, vol);
    alSourcePlay(soundId);
}
- (void)playSoundWithKey:(NSString*)soundKey atVolume:(float)vol {
    NSNumber * numVal = [soundDictionary objectForKey:soundKey];
    if (numVal == nil) return;

    [self playSoundWithId:[numVal unsignedIntValue] atVolume:vol];
}

// Stops sound with identifier specified.
- (void)stopSoundWithId:(NSUInteger)soundId {
    alSourceStop(soundId);
}
- (void)stopSoundWithKey:(NSString*)soundKey {
    NSNumber* numVal = [soundDictionary objectForKey:soundKey];
    if (numVal == nil) return;

    alSourceStop([numVal unsignedIntValue]);
}

// Rewinds sound with identifier specified.
- (void)rewindSoundWithId:(NSUInteger)soundId {
    alSourceRewind(soundId);
}
- (void)rewindSoundWithKey:(NSString*)soundKey {
    NSNumber* numVal = [soundDictionary objectForKey:soundKey];
    if (numVal == nil) return;
    alSourceRewind([numVal unsignedIntValue]);
}

// Checks if sound with identifier specified
// is in playing state.
- (bool)isPlayingSoundWithId:(NSUInteger)soundId {
    ALenum state;

    alGetSourcei(soundId, AL_SOURCE_STATE, &state);
    return (state == AL_PLAYING);
}
- (bool)isPlayingSoundWithKey:(NSString*)soundKey {
    NSNumber* numVal = [soundDictionary objectForKey:soundKey];
    if (numVal == nil) return false;

    return [self isPlayingSoundWithId:[numVal unsignedIntValue]];
}

// Loads sound to OpenAL and returns it's identifier.
- (NSUInteger)loadSoundFromFile:(NSString*)file ext:(NSString*)ext withLoop:(bool)loops {
    ALvoid* outData;
    ALenum format, error = AL_NO_ERROR;
    ALsizei size, freq;

    // Getting file location in bundle.
    NSBundle * bundle = [NSBundle mainBundle];
    CFURLRef fileURL = (CFURLRef)[[NSURL fileURLWithPath:[bundle pathForResource:file ofType:ext]] retain];
    if (!fileURL) return 0;

    // Getting audio data.
    outData = MyGetOpenALAudioData(fileURL, &size, &format, &freq);
    CFRelease(fileURL);
    if ((error = alGetError()) != AL_NO_ERROR) return 0;

    // Getting buffer ID from OpenAL.
    NSUInteger bufferID;
    alGenBuffers(1, &bufferID);

    // Loading awaiting data blob into buffer.
    alBufferData(bufferID, format, outData, size, freq);

    // Getting source ID from OpenAL.
    NSUInteger sourceID;
    alGenSources(1, &sourceID);

    // Attacing buffer to source.
    alSourcei(sourceID, AL_BUFFER, bufferID);
    // Setting some basic source preferences.
    alSourcef(sourceID, AL_PITCH, 1.0f);
    alSourcef(sourceID, AL_GAIN, 1.0f);
    if (loops) alSourcei(sourceID, AL_LOOPING, AL_TRUE);

    // Saving buffer identifier.
    [bufferStorageArray addObject:[NSNumber numberWithUnsignedInteger:bufferID]];

    // Cleaning awaiting data.
    if (outData)
    {
        free(outData);
        outData = NULL;
    }

    return sourceID;
}
- (bool)loadSoundWithKey:(NSString*)soundKey fromFile:(NSString*)file ext:(NSString*)ext withLoop:(bool)loops {
    // Loading sound to OpenAL.
    NSUInteger sourceID = [self loadSoundFromFile:file ext:ext withLoop:loops];
    if (sourceID == 0) return false;

    // Saving source identifier.
    [soundDictionary setObject:[NSNumber numberWithUnsignedInt:sourceID] forKey:soundKey];

    return true;
}

- (void)dealloc {
    // Deleting all sources from OpenAL.
    for (NSNumber* sourceNumber in [soundDictionary allValues]) {
        NSUInteger sourceID = [sourceNumber unsignedIntegerValue];
        alDeleteSources(1, &sourceID);
    }
    self.soundDictionary = nil;

    // Deleting buffers from OpenAL.
    for (NSNumber * bufferNumber in bufferStorageArray) {
        NSUInteger bufferID = [bufferNumber unsignedIntegerValue];
        alDeleteBuffers(1, &bufferID);
    }
    self.bufferStorageArray = nil;

    // Destroying context and closing device.
    alcDestroyContext(mContext);
    alcCloseDevice(mDevice);

    [super dealloc];
}

// Retain and release methods overrides.
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX;
}
- (id)autorelease {
    return self;
}

@end
