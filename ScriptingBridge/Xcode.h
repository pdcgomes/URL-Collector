/*
 * Xcode.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class XcodeItem, XcodeApplication, XcodeColor, XcodeDocument, XcodeWindow, XcodeAttributeRun, XcodeCharacter, XcodeParagraph, XcodeText, XcodeAttachment, XcodeWord, XcodeInputPath, XcodeOutputPath, XcodeBuildConfigurationType, XcodeBuildMessage, XcodeContainerItem, XcodeEnvironmentVariable, XcodeLaunchArgument, XcodeProject, XcodeProjectItem, XcodeBuildPhase, XcodeBuildJavaResourcesPhase, XcodeBuildResourceManagerResourcesPhase, XcodeCompileApplescriptsPhase, XcodeCompileSourcesPhase, XcodeCopyBundleResourcesPhase, XcodeCopyFilesPhase, XcodeCopyHeadersPhase, XcodeLinkBinaryWithLibrariesPhase, XcodeRunScriptPhase, XcodeBookmark, XcodeBreakpoint, XcodeBuildConfiguration, XcodeBuildFile, XcodeExecutable, XcodeFileBreakpoint, XcodeSourceDirectory, XcodeSymbolicBreakpoint, XcodeTextBookmark, XcodeItemReference, XcodeFileReference, XcodeGroup, XcodeScmRevision, XcodeBuildSetting, XcodeBaseBuildSetting, XcodeFlattenedBuildSetting, XcodeTarget, XcodeTargetDependency, XcodeTargetTemplate, XcodeAttribute, XcodeCodeClass, XcodeEntity, XcodeFetchRequest, XcodeFetchedProperty, XcodeOperation, XcodeRelationship, XcodeVariable, XcodeInsertionPoint, XcodeFileDocument, XcodeModelDocument, XcodeClassModelDocument, XcodeDataModelDocument, XcodeProjectDocument, XcodeTextDocument, XcodeSourceDocument, XcodePrintSettings, XcodeBuildStyle;

enum XcodeSavo {
	XcodeSavoAsk = 'ask ' /* Ask the user whether or not to save the file. */,
	XcodeSavoNo = 'no  ' /* Do not save the file. */,
	XcodeSavoYes = 'yes ' /* Save the file. */
};
typedef enum XcodeSavo XcodeSavo;

enum XcodePwpa {
	XcodePwpaExecutablesDirectory = 'pwpe',
	XcodePwpaFrameworks = 'pwpf',
	XcodePwpaJavaResources = 'pwpj',
	XcodePwpaPluginsDirectory = 'pwpl',
	XcodePwpaProductsDirectory = 'pwpp',
	XcodePwpaResources = 'pwre',
	XcodePwpaRootVolume = 'pwpn',
	XcodePwpaSharedFrameworks = 'pwsf',
	XcodePwpaSharedSupport = 'pwss',
	XcodePwpaWrapper = 'pwpr'
};
typedef enum XcodePwpa XcodePwpa;

enum XcodeBmte {
	XcodeBmteAnalyzerResult = 'bmta',
	XcodeBmteError = 'bmte',
	XcodeBmteNone = 'bmtn',
	XcodeBmteNotice = 'bmto',
	XcodeBmteWarning = 'bmtw'
};
typedef enum XcodeBmte XcodeBmte;

enum XcodeLied {
	XcodeLiedCR = 'crle',
	XcodeLiedCRLF = 'crlf',
	XcodeLiedLF = 'lfle',
	XcodeLiedPreserveExisting = 'pele'
};
typedef enum XcodeLied XcodeLied;

enum XcodeFenc {
	XcodeFencIso2022Japanese = 'isjp',
	XcodeFencIsoLatin1 = 'ila1',
	XcodeFencIsoLatin2 = 'ila2',
	XcodeFencJapaneseEUC = 'jeuc',
	XcodeFencMacosRoman = 'mosr',
	XcodeFencNextstep = 'next',
	XcodeFencNonlossyAscii = 'nlas',
	XcodeFencShiftJisString = 'sjis',
	XcodeFencSymbolString = 'syms',
	XcodeFencUnicode = 'unic',
	XcodeFencUtf8 = 'utf8',
	XcodeFencWindowsCyrillic = 'wco1',
	XcodeFencWindowsGreek = 'wcp3',
	XcodeFencWindowsLatin1 = 'wcp2',
	XcodeFencWindowsLatin2 = 'wcp0',
	XcodeFencWindowsTurkish = 'wcp4'
};
typedef enum XcodeFenc XcodeFenc;

enum XcodeReft {
	XcodeReftAbsolute = 'asrt',
	XcodeReftBuildProductRelative = 'bprt',
	XcodeReftCurrentSDKRelative = 'sdrt',
	XcodeReftGroupRelative = 'grrt',
	XcodeReftOther = 'orft',
	XcodeReftProjectRelative = 'prrt',
	XcodeReftXcodeFolderRelative = 'xrrt'
};
typedef enum XcodeReft XcodeReft;

enum XcodeAsms {
	XcodeAsmsHasConflict = 'sccs',
	XcodeAsmsLocallyAdded = 'slas',
	XcodeAsmsLocallyModified = 'slms',
	XcodeAsmsLocallyRemoved = 'slrs',
	XcodeAsmsNeedsMerge = 'snms',
	XcodeAsmsNeedsUpdate = 'sncs',
	XcodeAsmsUnknown = 'scus',
	XcodeAsmsUpToDate = 'suds'
};
typedef enum XcodeAsms XcodeAsms;

enum XcodeXdel {
	XcodeXdelCPlusPlus = 'xdep',
	XcodeXdelJava = 'xdej',
	XcodeXdelObjectiveC = 'xdeo'
};
typedef enum XcodeXdel XcodeXdel;

enum XcodeXdeh {
	XcodeXdehAlwaysHide = 'xdea',
	XcodeXdehAlwaysShow = 'xdes',
	XcodeXdehHidePerFilter = 'xdef'
};
typedef enum XcodeXdeh XcodeXdeh;

enum XcodeEnum {
	XcodeEnumStandard = 'lwst' /* Standard PostScript error handling */,
	XcodeEnumDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum XcodeEnum XcodeEnum;



/*
 * Standard Suite
 */

// A scriptable object.
@interface XcodeItem : SBObject

@property (copy) NSDictionary *properties;  // All of the object's properties.

- (void) closeSaving:(XcodeSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(NSURL *)in_;  // Save an object.
- (NSString *) buildStaticAnalysis:(BOOL)staticAnalysis transcript:(BOOL)transcript using:(XcodeBuildConfigurationType *)using_;  // Build the indicated target or project in Xcode. If the project is asked to build, then the active target is built.
- (NSString *) cleanRemovingPrecompiledHeaders:(BOOL)removingPrecompiledHeaders transcript:(BOOL)transcript using:(XcodeBuildConfigurationType *)using_;  // Clean the indicated target or project in Xcode. If the project is asked to build, then the active target is cleaned.
- (NSString *) debug;  // Debug the indicated executable or project under Xcode. If the project is asked to be debugged, then the active executable is debugged. Returns a string indicating success or failure in running the application under the debugger.
- (NSString *) launch;  // Launch the indicated executable or project under Xcode. If the project is asked to be launched, then the active executable is launched. Returns a string indicating success or failure in launching the application.
- (id) upgrade;  // Upgrade the indicated target or project to native targets. If the project is asked to be upgraded to native targets then all eligible targets are upgraded. With a target, the upgraded target is returned. With a project, a list of upgraded targets is retur
- (void) scmClearStickyTags;  // Clear sticky tags from the indicated project or file reference in Xcode.
- (void) scmCommitWithMessage:(NSString *)withMessage;  // Commit the indicated project or file reference in Xcode to the SCM repository.
- (void) scmCompareWith:(XcodeFileReference *)with withRevision:(NSString *)withRevision;  // Compare the indicated file reference with the given revision or file reference. If no file reference or revision is supplied, the base revision will be used.
- (void) scmRefresh;  // Refresh the SCM status of the indicated project or file reference in Xcode.
- (void) scmUpdateToRevision:(NSString *)toRevision;  // Perform an SCM Update on the indicated project or file reference in Xcode.
- (void) addTo:(SBObject *)to;  // Adds an existing object to the container specified.
- (void) removeFrom:(id)from;  // Removes the object from the designated container without deleting it.

@end

// An application's top level scripting object.
@interface XcodeApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy, readonly) NSString *name;  // The name of the application.
@property (copy, readonly) NSString *version;  // The version of the application.

- (XcodeDocument *) open:(NSURL *)x;  // Open an object.
- (void) print:(NSURL *)x printDialog:(BOOL)printDialog withProperties:(XcodePrintSettings *)withProperties;  // Print an object.
- (void) quitSaving:(XcodeSavo)saving;  // Quit an application.
- (void) loadDocumentationSetWithPath:(NSString *)x display:(BOOL)display;  // Load documentation set at supplied path.
- (void) pathForApple_ref:(NSString *)x;  // Return path of document containing apple_ref.
- (void) pathForDocumentWithUUID:(NSString *)x;  // Return path of document identified by UUID.
- (void) showDocumentWithApple_ref:(NSString *)x;  // Show document containing supplied apple_ref in the documentation window.
- (void) showDocumentWithPath:(NSString *)x;  // Show document at supplied path in the documentation window.
- (void) showDocumentWithUUID:(NSString *)x;  // Show document identified by supplied UUID in the documentation window.
- (void) upgradeProjectFile:(NSURL *)x as:(NSString *)as;  // Upgrade the given project file to the latest project file format. This will open the project if the upgrade succeeds.

@end

// A color.
@interface XcodeColor : XcodeItem


@end

// A document.
@interface XcodeDocument : XcodeItem

@property (readonly) BOOL modified;  // Has the document been modified since the last save?
@property (copy) NSString *name;  // The document's name.
@property (copy) NSString *path;  // The document's path.


@end

// A window.
@interface XcodeWindow : XcodeItem

@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Whether the window has a close box.
@property (copy, readonly) XcodeDocument *document;  // The document whose contents are being displayed in the window.
@property (readonly) BOOL floating;  // Whether the window floats.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property (readonly) BOOL miniaturizable;  // Whether the window can be miniaturized.
@property BOOL miniaturized;  // Whether the window is currently miniaturized.
@property (readonly) BOOL modal;  // Whether the window is the application's current modal window.
@property (copy) NSString *name;  // The full title of the window.
@property (readonly) BOOL resizable;  // Whether the window can be resized.
@property (readonly) BOOL titled;  // Whether the window has a title bar.
@property BOOL visible;  // Whether the window is currently visible.
@property (readonly) BOOL zoomable;  // Whether the window can be zoomed.
@property BOOL zoomed;  // Whether the window is currently zoomed.


@end



/*
 * Text Suite
 */

// This subdivides the text into chunks that all have the same attributes.
@interface XcodeAttributeRun : XcodeItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// This subdivides the text into characters.
@interface XcodeCharacter : XcodeItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// This subdivides the text into paragraphs.
@interface XcodeParagraph : XcodeItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end

// Rich (styled) text
@interface XcodeText : XcodeItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.

- (void) loadDocumentationSetWithPathDisplay:(BOOL)display;  // Load documentation set at supplied path.
- (void) pathForApple_ref;  // Return path of document containing apple_ref.
- (void) pathForDocumentWithUUID;  // Return path of document identified by UUID.
- (void) showDocumentWithApple_ref;  // Show document containing supplied apple_ref in the documentation window.
- (void) showDocumentWithPath;  // Show document at supplied path in the documentation window.
- (void) showDocumentWithUUID;  // Show document identified by supplied UUID in the documentation window.

@end

// Represents an inline text attachment.  This class is used mainly for make commands.
@interface XcodeAttachment : XcodeText

@property (copy) NSString *fileName;  // The path to the file for the attachment


@end

// This subdivides the text into words.
@interface XcodeWord : XcodeItem

- (SBElementArray *) attachments;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@property (copy) NSColor *color;  // The color of the first character.
@property (copy) NSString *font;  // The name of the font of the first character.
@property NSInteger size;  // The size in points of the first character.


@end



/*
 * Xcode Build Phase Suite
 */

// An object that represents a input path that is used by a run script phase.
@interface XcodeInputPath : XcodeItem

@property (copy) NSString *path;  // The path of the input file.
@property (copy, readonly) XcodeRunScriptPhase *runScriptPhase;  // The run script phase that contains this input path.


@end

// An object that represents a output path that is used by a run script phase.
@interface XcodeOutputPath : XcodeItem

@property (copy) NSString *path;  // The path of the output file.
@property (copy, readonly) XcodeRunScriptPhase *runScriptPhase;  // The run script phase that contains this output path.


@end



/*
 * Xcode Project Suite
 */

// A type of build configuration available for a project and all its targets. Build configuration types can only be created by duplicating an existing build configuration type.
@interface XcodeBuildConfigurationType : XcodeItem

- (NSString *) id;  // The unique identifier for the build configuration type.
@property (copy) NSString *name;  // The name of this build configuration type.


@end

// A message generated during a build that usually points to a warning or error in the associated build file.
@interface XcodeBuildMessage : XcodeItem

@property (copy) XcodeBuildFile *buildFile;  // The build file that contains this build message
@property XcodeBmte kind;  // Indicates the kind of build message.
@property NSInteger location;  // The line number in the file that the build message corresponds to.
@property (copy) NSString *message;  // The text of the build message.
@property (copy) NSString *path;  // The absolute path to the file that the build message is referencing.


@end

// The abstract class for any item in a container, one of which is a project.
@interface XcodeContainerItem : XcodeItem

@property (copy) NSString *comments;  // Comments about this project item.
- (NSString *) id;  // The unique identifier for the project item.
@property (copy, readonly) XcodeProject *project;  // The project that contains this item.


@end

// An object that represents a environment variable.
@interface XcodeEnvironmentVariable : XcodeItem

@property BOOL active;  // Is this environment variable set in the executable's environment?
@property (copy, readonly) XcodeExecutable *executable;  // The executable that contains this environment variable.
@property (copy) NSString *name;  // The name of the environment variable to be set in the executable's environment.
@property (copy) NSString *value;  // The value of the environment variable to be set in the executable's environment.


@end

// An object that represents a launch argument.
@interface XcodeLaunchArgument : XcodeItem

@property BOOL active;  // Is this argument passed to the executable at launch?
@property (copy, readonly) XcodeExecutable *executable;  // The executable that contains this launch argument.
@property (copy) NSString *name;  // The name of the argument to be passed at launch.


@end

// The model for an Xcode project file. Note that the item references, file references, and groups elements are read-only. Changing the contents of these element relationships is unsupported.
@interface XcodeProject : XcodeItem

- (SBElementArray *) bookmarks;
- (SBElementArray *) breakpoints;
- (SBElementArray *) buildConfigurations;
- (SBElementArray *) buildConfigurationTypes;
- (SBElementArray *) executables;
- (SBElementArray *) fileBreakpoints;
- (SBElementArray *) fileReferences;
- (SBElementArray *) groups;
- (SBElementArray *) itemReferences;
- (SBElementArray *) symbolicBreakpoints;
- (SBElementArray *) targets;
- (SBElementArray *) targetTemplates;
- (SBElementArray *) textBookmarks;

@property (copy) NSString *activeArchitecture;  // The active architecture. This is used when telling the project to compile, show assembly code, or preprocess.
@property (copy) XcodeBuildConfigurationType *activeBuildConfigurationType;  // The active build configuration type used for actions that do not explicity specify a configuration.
@property (copy) XcodeExecutable *activeExecutable;  // The active executable. This is used when telling the project to run or debug.
@property (copy) NSString *activeSDK;  // The active SDK for the project.  This overrides any Base SDK set in the active target or project.
@property (copy) XcodeTarget *activeTarget;  // The active target. This is used when telling the project to be built or cleaned.
@property (readonly) BOOL currentlyBuilding;  // Is the project currently building or cleaning a target?
@property (copy) XcodeBuildConfigurationType *defaultBuildConfigurationType;  // The default build configuration type used when building with xcodebuild if no -configuration option is supplied.
@property (copy, readonly) NSString *fullPath;  // The full path to the project file on disk.
- (NSString *) id;  // The unique identifier for the project.
@property (copy) NSString *intermediatesDirectory;  // The full path to the folder that contains all intermediate files for the project. This is dependent on the active build style.
@property (copy, readonly) NSString *name;  // The name of this project.
@property (copy) NSString *organizationName;  // The name to use in the header file of new files created with project templates.  Defaults to Apple Inc.
@property (copy, readonly) NSString *path;  // The path to the project file on disk.
@property (copy) NSString *productDirectory;  // The full path to the folder that contains any built products.  This is dependent on the active build style.
@property (copy, readonly) NSString *projectDirectory;  // The full path to the folder that contains the project file.
@property (copy, readonly) XcodeFileReference *projectFileReference;  // A file reference to the core project.pbxproj file itself.
@property (copy) NSArray *projectRoots;  // A list of paths to all directories that contain files referenced in this project.
@property (readonly) BOOL readOnly;  // Is the project only open for reading?
@property (copy, readonly) NSString *realPath;  // The fully resolved path to the project file on disk. Specifically, all symlinks in the path have been resolved.
@property (copy, readonly) XcodeGroup *rootGroup;  // The root of the files & groups hierarchy in the project.
@property (copy, readonly) XcodeFileReference *userFileReference;  // A file reference to the current user's pbxuser file.


@end

// The abstract class for any item in a project.
@interface XcodeProjectItem : XcodeContainerItem

- (void) moveTo:(SBObject *)to;  // Moves an existing object to the container specified.

@end



/*
 * Xcode Build Phase Suite
 */

// A build phase represents a stage in the build of a target.  Each build phase contains a set of build files and information about how to process those files.
@interface XcodeBuildPhase : XcodeProjectItem

- (SBElementArray *) buildFiles;

@property (copy, readonly) NSString *name;  // The name of this build phase.
@property (copy, readonly) XcodeTarget *target;  // The target that contains this build phase.


@end

// A build phase that archives its contained items into a class hierarchy or archive file (.jar or .zip file).
@interface XcodeBuildJavaResourcesPhase : XcodeBuildPhase


@end

// A build file that rezzes any contained .r files into a .rsrc file.
@interface XcodeBuildResourceManagerResourcesPhase : XcodeBuildPhase


@end

// A build phase that compiles the applescripts that it contains.
@interface XcodeCompileApplescriptsPhase : XcodeBuildPhase


@end

// A build phase that compiles its contained files into the target's binary.
@interface XcodeCompileSourcesPhase : XcodeBuildPhase


@end

// A build phase that copies its contained items into the Resources directory of the target's wrapped product. Localized files are copied into the proper sub-directory of Resources.
@interface XcodeCopyBundleResourcesPhase : XcodeBuildPhase


@end

// A build phase that copies its contained items to a location on disk. 
@interface XcodeCopyFilesPhase : XcodeBuildPhase

@property XcodePwpa destinationDirectory;  // The base location to copy items relative to. If "root volume" is chosen then "path" is an absolute path. Otherwise "path" is relative to the base location.
@property (copy) NSString *path;  // The path relative to the destination to copy items to
@property BOOL runOnlyWhenInstalling;  // Indicates if the build phase should only be run when performing an install build.


@end

// A build phase that copies its contained items into the proper locations for public and private headers.
@interface XcodeCopyHeadersPhase : XcodeBuildPhase


@end

// A build phase that links its contained items into the binary produced by the containing target.
@interface XcodeLinkBinaryWithLibrariesPhase : XcodeBuildPhase


@end

@interface XcodeRunScriptPhase : XcodeBuildPhase

- (SBElementArray *) inputPaths;
- (SBElementArray *) outputPaths;

@property BOOL runOnlyWhenInstalling;  // Indicates if the build phase should only be run when performing an install build.
@property (copy) NSString *shellPath;  // The absolute path to the shell used by the shell script.
@property (copy) NSString *shellScript;  // The actual shell script to run during this build phase.
@property BOOL showEnvironmentVariables;  // Indicates if shell environment variables should be output to the build log.


@end



/*
 * Xcode Project Suite
 */

//  A bookmark is a persistent reference to a file.
@interface XcodeBookmark : XcodeProjectItem

@property (copy, readonly) XcodeFileReference *fileReference;  // A file reference to the file pointed to by this bookmark.
@property (copy) NSString *name;  // The name of this bookmark.


@end

// An abstract class that represents a generic breakpoint that is used by the debugger to stop execution in a program. If you want to create breakpoints, use file breakpoints or symbolic breakpoints.
@interface XcodeBreakpoint : XcodeProjectItem

@property BOOL automaticallyContinue;  // Should the debugger automatically continue when it hits this breakpoint after performing any associated breakpoint actions?
@property (copy) NSString *condition;  // Condition in which breakpoint should stop.
@property BOOL enabled;  // Is the breakpoint enabled?
@property (copy, readonly) NSString *name;  // The name of this breakpoint.


@end

// A set of build settings for a target or project. Each target and project has one build configuration for each build configuration type in the project. New build configurations are created automatically when a new build configuration type is created.
@interface XcodeBuildConfiguration : XcodeProjectItem

- (SBElementArray *) baseBuildSettings;
- (SBElementArray *) buildSettings;
- (SBElementArray *) flattenedBuildSettings;

@property (copy, readonly) XcodeBuildConfigurationType *buildConfigurationType;  // The associated build configuration type.
@property (copy) XcodeFileReference *configurationSettingsFile;  // The optional configuration settings file this configuration is based on. May be 'missing value'.
@property (copy, readonly) NSString *name;  // The name of the associated build configuration type.


@end

// A "build file" represents an association between a target and a file reference and tracks any target-specific settings for that file reference.
@interface XcodeBuildFile : XcodeProjectItem

- (SBElementArray *) buildMessages;

@property (copy, readonly) XcodeBuildPhase *buildPhase;  // The build phase that this build file is contained by.
@property (readonly) NSInteger compiledCodeSize;  // The size of the object file generated when compiling the associated file.
@property (copy, readonly) XcodeFileReference *fileReference;  // A file reference to the file on disk that this build file represents.
@property (copy, readonly) NSString *name;  // The name of this build file.
@property (copy, readonly) XcodeTarget *target;  // The target that contains this build file.


@end

// The context for running or debugging a launchable executable.
@interface XcodeExecutable : XcodeProjectItem

- (SBElementArray *) environmentVariables;
- (SBElementArray *) launchArguments;
- (SBElementArray *) sourceDirectories;

@property (copy, readonly) NSString *activeArguments;  // The arguments passed into the executable when it is launched.
@property (readonly) BOOL launchable;  // Can this executable be launched?
@property (copy) NSString *name;  // The name of this executable.
@property (copy, readonly) NSString *path;  // The path of the executable referenced.
@property (copy) NSString *startupDirectory;  // The full path to the directory that the executable is launched in.
@property (copy, readonly) XcodeTarget *target;  // The target that creates the product this executable points to.


@end

// A breakpoint that is defined by a file name:line location.
@interface XcodeFileBreakpoint : XcodeBreakpoint

@property (copy) XcodeFileReference *fileReference;  // A reference to the file that contains the breakpoint.
@property NSInteger lineNumber;  // The line number the breakpoint is set on.


@end

// An object that represents a source directory that is used by the debugger to load source files.
@interface XcodeSourceDirectory : XcodeItem

@property (copy, readonly) XcodeExecutable *executable;  // The executable that contains this source directory.
@property (copy) NSString *path;  // The full path of the source directory.


@end

// A breakpoint that is defined using a symbol name.
@interface XcodeSymbolicBreakpoint : XcodeBreakpoint

@property (copy) NSString *symbolName;  // The name of the symbol that the breakpoint stops at.


@end

// A text bookmark represents a selection in a file reference.
@interface XcodeTextBookmark : XcodeBookmark

@property (copy) NSArray *characterRange;  // The character range for this bookmark, which is of the form {x ,y} where x is the position of the first selected character and y is the position of the last selected character.


@end



/*
 * Xcode Reference Suite
 */

// This class represents references to files and folders on disk and to groups in the project model. The item reference does not contain the referred-to item itself; rather, it contains enough information to let it locate the referred-to item when needed.
@interface XcodeItemReference : XcodeContainerItem

@property (copy, readonly) NSString *buildProductsRelativePath;  // The path to the item referenced relative to the build products folder.
@property (copy) NSArray *contents;  // A list of the immediate contents of this reference.
@property (copy) NSArray *entireContents;  // A list of the contents of this reference, including the entire contents of its children.
@property XcodeFenc fileEncoding;  // The file encoding used to display the contents of any text files referenced by this item. In the case of a group or folder reference, this encoding is used for the items contained by this item.
@property (copy, readonly) NSString *fullPath;  // The full path to the item referenced.
@property (copy, readonly) XcodeGroup *group;  // The group that this reference is contained in.
@property NSInteger indentWidth;  // The number of spaces to indent wrapped lines in the referenced item. In the case of a group or folder reference, this indent width is used for any contained items.
@property (readonly) BOOL leaf;  // Indicates if this reference cannot contain other references.
@property XcodeLied lineEnding;  // The style of line endings to use for the referenced item. In the case of a group or folder reference, this style is used for any contained items.
@property (readonly) BOOL localized;  // Indicates if this reference refers to a localized item.
@property (copy) NSString *name;  // The name of this item reference.
@property (copy) NSString *path;  // Returns the path to the item referenced. The format of this path depends on the path type.
@property XcodeReft pathType;  // Specifies how the reference tries to locate the item it refers to. Xcode does not provide full scripting support to user-defined source trees, and will report such reference types as "other".
@property (copy, readonly) NSString *projectRelativePath;  // The project relative path to the item referenced.
@property (copy, readonly) NSString *realPath;  // The fully resolved path to the item referenced. Specifically, all symlinks in the path have been resolved.
@property NSInteger tabWidth;  // The number of spaces to use for a tab for the referenced item. In the case of a group or folder reference, this value is used for any contained items.
@property BOOL usesTabs;  // Indicates if tabs characters should be used instead of spaces when entering tabs. In the case of a group or folder reference, this value is used for any contained items.


@end

@interface XcodeFileReference : XcodeItemReference

- (SBElementArray *) scmRevisions;

@property (copy, readonly) NSString *fileKind;  // The identifier for the file type used when referencing the file.
@property (copy, readonly) NSString *headRevisionNumber;  // The current SCM head revision for the referenced file. If the file is on a branch this is the top of the branch, not the top of the tree.
@property (copy, readonly) NSString *revisionNumber;  // The current SCM revision for the referenced file.
@property (readonly) XcodeAsms status;  // The current SCM status for the referenced file.
@property (copy, readonly) NSString *tag;  // The current SCM tag for the referenced file.


@end

// A group is a container of references in a project's group hierarchy.  A group does not represent a specific file or path on disk, but is internal to the project's structure.
@interface XcodeGroup : XcodeItemReference

- (SBElementArray *) fileReferences;
- (SBElementArray *) groups;
- (SBElementArray *) itemReferences;


@end

@interface XcodeScmRevision : XcodeItem

@property (copy, readonly) NSString *author;  // The short name of the user who added this revision to the SCM repository.
@property (copy, readonly) NSString *commitMessage;  // The commit message associated with this revision.
@property (copy, readonly) NSString *name;  // The number for this revision.
@property (copy, readonly) NSString *revision;  // The number for this revision.
@property (copy, readonly) NSString *tag;  // If present, the tag that this revision is associated with.
@property (copy, readonly) NSDate *timestamp;  // The date and time when this revision was added to the SCM repository. This is always returned in the user's local time.


@end



/*
 * Xcode Target Suite
 */

// An object that represents a build setting.
@interface XcodeBuildSetting : XcodeItem

@property (copy, readonly) XcodeProjectItem *container;  // The build configuration that contains this build setting.
@property (copy) NSString *name;  // The unlocalized build setting name (e.g. DSTROOT).
@property (copy) NSString *value;  // A string value for the build setting.


@end

// An object that represents the value defined for a build setting in the Configuration Settings File.
@interface XcodeBaseBuildSetting : XcodeBuildSetting


@end

// An object that represents the highest precedence value for a build setting.
@interface XcodeFlattenedBuildSetting : XcodeBuildSetting


@end

// A target is a blueprint for building a product. Besides specifying the type of product to build, a target consists of an ordered list of build phases, a record of 'build settings', an Info.plist record (the 'product settings'), a list of build rules, and 
@interface XcodeTarget : XcodeProjectItem

- (SBElementArray *) buildConfigurations;
- (SBElementArray *) buildFiles;
- (SBElementArray *) buildPhases;
- (SBElementArray *) compileApplescriptsPhases;
- (SBElementArray *) copyFilesPhases;
- (SBElementArray *) runScriptPhases;
- (SBElementArray *) targetDependencies;

@property (copy, readonly) XcodeBuildJavaResourcesPhase *buildJavaResourcesPhase;  // The "Build Java Resources" build phase for this target if it exists.
@property (copy, readonly) XcodeBuildResourceManagerResourcesPhase *buildResourceManagerResourcesPhase;  // The "Build Resource Manager Resources" build phase for this target if it exists.
@property (copy, readonly) XcodeCompileSourcesPhase *compileSourcesPhase;  // The "Compile Sources" build phase for this target if it exists.
@property (copy, readonly) XcodeCopyBundleResourcesPhase *copyBundleResourcesPhase;  // The "Copy Bundle Resources" build phase for this target if it exists.
@property (copy, readonly) XcodeCopyHeadersPhase *copyHeadersPhase;  // The "Copy Headers" build phase for this target if it exists.
@property (copy, readonly) XcodeExecutable *executable;  // The executable used by this target to launch and debug the product. Only exists if the product is executable.
@property (copy, readonly) XcodeLinkBinaryWithLibrariesPhase *linkBinaryWithLibrariesPhase;  // The "Link Binary with Libraries" build phase for this target if it exists.
@property (copy) NSString *name;  // The name of this target.
@property (readonly) BOOL native;  // Does this target use the native build system?
@property (copy, readonly) XcodeFileReference *productReference;  // An item reference to the generated product on disk.
@property (copy, readonly) NSString *targetType;  // The type of target. Usually this is related to the type of product the target produces.


@end

// A target dependency provides a link between a target and another target upon which the first target depends.
@interface XcodeTargetDependency : XcodeProjectItem

@property (copy, readonly) XcodeTarget *target;  // The target that the containing target depends on.


@end

// A target template, used when creating a new target.
@interface XcodeTargetTemplate : XcodeItem

@property (copy) NSString *objectDescription;  // The description of this target template.
@property (copy) NSString *name;  // The name of this target template.


@end



/*
 * Xcode Design Tools Suite
 */

// Data model attributes of the entity
@interface XcodeAttribute : XcodeItem

@property (copy, readonly) NSString *attributeType;  // The CoreData type of the attribute
@property (copy, readonly) NSString *defaultValue;  // Default value of the attribute
@property (copy) NSString *name;  // Attribute name
@property BOOL optional;  // is the attribute optional?
@property BOOL transient;  // is the attribute transient?
@property (copy) NSDictionary *userInfo;  // User info dictionary for the attribute


@end

// A source code class in the model
@interface XcodeCodeClass : XcodeItem

- (SBElementArray *) operations;
- (SBElementArray *) variables;

@property NSRect bounds;  // Bounding rectangle of the class object in diagram
@property (readonly) BOOL category;  // Is the class an Objective-C category?
@property (readonly) BOOL hiddenInDiagram;  // Is the class hidden in the diagram?
@property (readonly) BOOL hiddenPerFilter;  // Will the class be hidden in the diagram if its hide action is set to hide per filter?
@property XcodeXdeh hideAction;  // Under what conditions the diagram should hide or show this class
@property (readonly) XcodeXdel implementationLanguage;  // The implementation language for the class
@property (copy) NSString *name;  // Name of the class
@property (readonly) BOOL projectMember;  // Is the class implemented in the project (versus a framework)?
@property (copy) NSString *superclasses;  // Names of the superclasses of this class


@end

// Entity in a data model
@interface XcodeEntity : XcodeItem

- (SBElementArray *) attributes;
- (SBElementArray *) fetchRequests;
- (SBElementArray *) fetchedProperties;
- (SBElementArray *) relationships;

@property BOOL abstract;  // is the entity abstract?
@property (copy) NSString *name;  // Name of the entity
@property (copy) NSString *objectClass;  // The Objective C class of the object backing this entity
@property (copy, readonly) XcodeEntity *parent;  // Parent from which the entity inherits
@property (copy) NSDictionary *userInfo;  // User info dictionary for the entity


@end

// Fetch Requests of the schema associated with this entity
@interface XcodeFetchRequest : XcodeItem

@property (copy) NSString *name;  // Fetch Request name
@property (copy) NSString *predicate;  // Text form of the predicate for the Fetch Request


@end

// Entity attribute whose value is fetched from the database dynamically
@interface XcodeFetchedProperty : XcodeItem

@property (copy) XcodeEntity *destination;  // The destination entity of the fetched property
@property (copy) NSString *name;  // Fetched Property attribute name
@property BOOL optional;  // is the attribute optional?
@property (copy) NSString *predicate;  // Text form of the predicate that selects the property
@property BOOL transient;  // is the attribute transient?
@property (copy) NSDictionary *userInfo;  // User info dictionary for the attribute


@end

// A method or function the class or its instances implement
@interface XcodeOperation : XcodeItem

@property (copy) NSString *availability;  // How other classes can invoke this operation
@property (copy, readonly) NSString *name;  // Method or function name


@end

// A relationship from a data model entity to another
@interface XcodeRelationship : XcodeItem

@property (copy) XcodeEntity *destinationEntity;  // The other entity related to this one.
@property (copy) XcodeRelationship *inverseRelationship;  // The relationship that the related element has to this one.
@property NSInteger maximumCount;  // Maximum number of related data objects
@property NSInteger minimumCount;  // Minimum number of related data objects
@property (copy) NSString *name;  // Name of the relationship
@property BOOL optional;  // is the relationship optional?
@property BOOL toMany;  // is the relationship a “to-many” relationship?
@property BOOL transient;  // is the relationship transient?
@property (copy) NSDictionary *userInfo;  // User information dictionary for the relationship


@end

// An instance or class variable of the class
@interface XcodeVariable : XcodeItem

@property (copy, readonly) NSString *availability;  // How other classes can access this variable
@property (copy) NSString *name;  // Variable name


@end



/*
 * Xcode Application Suite
 */

// The Xcode application.
@interface XcodeApplication (XcodeApplicationSuite)

- (SBElementArray *) textDocuments;
- (SBElementArray *) breakpoints;
- (SBElementArray *) classModelDocuments;
- (SBElementArray *) dataModelDocuments;
- (SBElementArray *) documents;
- (SBElementArray *) fileBreakpoints;
- (SBElementArray *) fileDocuments;
- (SBElementArray *) modelDocuments;
- (SBElementArray *) projects;
- (SBElementArray *) projectDocuments;
- (SBElementArray *) sourceDocuments;
- (SBElementArray *) symbolicBreakpoints;
- (SBElementArray *) windows;

@property (copy) XcodeProjectDocument *activeProjectDocument;  // The active project document in Xcode.

@end

// This subdivides the text into chunks that all have the same attributes.
@interface XcodeAttributeRun (XcodeApplicationSuite)

- (SBElementArray *) texts;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@end

// This subdivides the text into characters.
@interface XcodeCharacter (XcodeApplicationSuite)

- (SBElementArray *) texts;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@end

// The insertion point in a document, which is either empty or has an associated text selection.
@interface XcodeInsertionPoint : XcodeItem

@property (copy) XcodeText *contents;  // The contents at the insertion point.


@end

// This subdivides the text into paragraphs.
@interface XcodeParagraph (XcodeApplicationSuite)

- (SBElementArray *) texts;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@end

// An object that represents a block of text.
@interface XcodeText (XcodeApplicationSuite)

- (SBElementArray *) texts;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@end

// This subdivides the text into words.
@interface XcodeWord (XcodeApplicationSuite)

- (SBElementArray *) texts;
- (SBElementArray *) attributeRuns;
- (SBElementArray *) characters;
- (SBElementArray *) insertionPoints;
- (SBElementArray *) paragraphs;
- (SBElementArray *) words;

@end



/*
 * Xcode Document Suite
 */

// A document that represents a file on disk. It also provides access to the window it appears in.
@interface XcodeFileDocument : XcodeDocument


@end



/*
 * Xcode Design Tools Suite
 */

// Generic model document
@interface XcodeModelDocument : XcodeFileDocument

@property (copy, readonly) NSString *name;  // The name of the document


@end

// Document containing a Class Model
@interface XcodeClassModelDocument : XcodeModelDocument

- (SBElementArray *) codeClasses;
- (SBElementArray *) itemReferences;


@end

// Document containing a Data Model for generating Core Data schema
@interface XcodeDataModelDocument : XcodeModelDocument

- (SBElementArray *) entities;


@end



/*
 * Xcode Document Suite
 */

// A project document contains references to both its project and the window they are displayed in.
@interface XcodeProjectDocument : XcodeDocument

@property (copy, readonly) XcodeProject *project;  // The project for this document.
@property (copy, readonly) NSString *scmTranscript;  // The transcript of SCM operations for this document.


@end

// A document that represents a text file on disk. It also provides access to the window it appears in.
@interface XcodeTextDocument : XcodeFileDocument

@property (copy) XcodeText *contents;  // The contents of the text file.
@property BOOL notifiesWhenClosing;  // Should Xcode notify other apps when this document is closed?
@property (copy) NSArray *selectedCharacterRange;  // The first and last character positions in the selection.
@property (copy) NSArray *selectedParagraphRange;  // The first and last paragraph positions that contain the selection.
@property (copy) id selection;  // The current selection in the text document.
@property (copy) XcodeText *text;  // The text of the text file referenced.


@end

// A document that represents a source file on disk. It also provides access to the window it appears in.
@interface XcodeSourceDocument : XcodeTextDocument

@property (copy) NSDictionary *editorSettings;  // A record of source editor settings and values.


@end



/*
 * Type Definitions
 */

@interface XcodePrintSettings : SBObject

@property NSInteger copies;  // the number of copies of a document to be printed
@property BOOL collating;  // Should printed copies be collated?
@property NSInteger startingPage;  // the first page of the document to be printed
@property NSInteger endingPage;  // the last page of the document to be printed
@property NSInteger pagesAcross;  // number of logical pages laid across a physical page
@property NSInteger pagesDown;  // number of logical pages laid out down a physical page
@property (copy) NSDate *requestedPrintTime;  // the time at which the desktop printer should print the document
@property XcodeEnum errorHandling;  // how errors are handled
@property (copy) NSString *faxNumber;  // for fax number
@property (copy) NSString *targetPrinter;  // for target printer

- (void) closeSaving:(XcodeSavo)saving savingIn:(NSURL *)savingIn;  // Close an object.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy object(s) and put the copies at a new location.
- (BOOL) exists;  // Verify if an object exists.
- (void) moveTo:(SBObject *)to;  // Move object(s) to a new location.
- (void) saveAs:(NSString *)as in:(NSURL *)in_;  // Save an object.
- (NSString *) buildStaticAnalysis:(BOOL)staticAnalysis transcript:(BOOL)transcript using:(XcodeBuildConfigurationType *)using_;  // Build the indicated target or project in Xcode. If the project is asked to build, then the active target is built.
- (NSString *) cleanRemovingPrecompiledHeaders:(BOOL)removingPrecompiledHeaders transcript:(BOOL)transcript using:(XcodeBuildConfigurationType *)using_;  // Clean the indicated target or project in Xcode. If the project is asked to build, then the active target is cleaned.
- (NSString *) debug;  // Debug the indicated executable or project under Xcode. If the project is asked to be debugged, then the active executable is debugged. Returns a string indicating success or failure in running the application under the debugger.
- (NSString *) launch;  // Launch the indicated executable or project under Xcode. If the project is asked to be launched, then the active executable is launched. Returns a string indicating success or failure in launching the application.
- (id) upgrade;  // Upgrade the indicated target or project to native targets. If the project is asked to be upgraded to native targets then all eligible targets are upgraded. With a target, the upgraded target is returned. With a project, a list of upgraded targets is retur
- (void) scmClearStickyTags;  // Clear sticky tags from the indicated project or file reference in Xcode.
- (void) scmCommitWithMessage:(NSString *)withMessage;  // Commit the indicated project or file reference in Xcode to the SCM repository.
- (void) scmCompareWith:(XcodeFileReference *)with withRevision:(NSString *)withRevision;  // Compare the indicated file reference with the given revision or file reference. If no file reference or revision is supplied, the base revision will be used.
- (void) scmRefresh;  // Refresh the SCM status of the indicated project or file reference in Xcode.
- (void) scmUpdateToRevision:(NSString *)toRevision;  // Perform an SCM Update on the indicated project or file reference in Xcode.
- (void) addTo:(SBObject *)to;  // Adds an existing object to the container specified.
- (void) removeFrom:(id)from;  // Removes the object from the designated container without deleting it.

@end

