/*
 * AddressBook.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class AddressBookApplication, AddressBookDocument, AddressBookWindow, AddressBookAddress, AddressBookContactInfo, AddressBookAIMHandle, AddressBookCustomDate, AddressBookEmail, AddressBookEntry, AddressBookGroup, AddressBookICQHandle, AddressBookJabberHandle, AddressBookMSNHandle, AddressBookPerson, AddressBookPhone, AddressBookRelatedName, AddressBookUrl, AddressBookYahooHandle;

enum AddressBookSaveOptions {
	AddressBookSaveOptionsYes = 'yes ' /* Save the file. */,
	AddressBookSaveOptionsNo = 'no  ' /* Do not save the file. */,
	AddressBookSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum AddressBookSaveOptions AddressBookSaveOptions;

enum AddressBookPrintingErrorHandling {
	AddressBookPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	AddressBookPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum AddressBookPrintingErrorHandling AddressBookPrintingErrorHandling;

enum AddressBookSaveableFileFormat {
	AddressBookSaveableFileFormatArchive = 'abbu' /* The native Address Book file format */
};
typedef enum AddressBookSaveableFileFormat AddressBookSaveableFileFormat;



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface AddressBookApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(AddressBookSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (id) save;  // Save all Address Book changes. Also see the unsaved property for the application class.
- (NSString *) actionProperty;  // RollOver - Which property this roll over is associated with (Properties can be one of maiden name, phone, email, url, birth date, custom date, related name, aim, icq, jabber, msn, yahoo, address.)
- (NSString *) actionTitleWith:(id)with for:(AddressBookPerson *)for_;  // RollOver - Returns the title that will be placed in the menu for this roll over
- (BOOL) performActionWith:(id)with for:(AddressBookPerson *)for_;  // RollOver - Performs the action on the given person and value
- (BOOL) shouldEnableActionWith:(id)with for:(AddressBookPerson *)for_;  // RollOver - Determines if the rollover action should be enabled for the given person and value

@end

// A document.
@interface AddressBookDocument : SBObject

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.

- (void) closeSaving:(AddressBookSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(AddressBookSaveableFileFormat)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// A window.
@interface AddressBookWindow : SBObject

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?
@property (copy, readonly) AddressBookDocument *document;  // The document whose contents are displayed in the window.

- (void) closeSaving:(AddressBookSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(AddressBookSaveableFileFormat)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * Address Book Script Suite
 */

@interface AddressBookApplication (AddressBookScriptSuite)

- (SBElementArray *) groups;
- (SBElementArray *) people;

@property (copy) AddressBookPerson *myCard;  // Returns my Address Book card.
@property (readonly) BOOL unsaved;  // Does Address Book have any unsaved changes?
@property (copy) NSArray *selection;  // Currently selected entries
@property (copy, readonly) id defaultCountryCode;  // Returns the default country code for addresses.

@end

// Address for the given record.
@interface AddressBookAddress : SBObject

@property (copy) id city;  // City part of the address.
@property (copy, readonly) id formattedAddress;  // properly formatted string for this address.
@property (copy) id street;  // Street part of the address, multiple lines separated by carriage returns.
- (NSString *) id;  // unique identifier for this address.
- (void) setId: (NSString *) id;
@property (copy) id zip;  // Zip or postal code of the address.
@property (copy) id country;  // Country part of the address.
@property (copy) id label;  // Label.
@property (copy) id countryCode;  // Country code part of the address (should be a two character iso country code).
@property (copy) id state;  // State, Province, or Region part of the address.

- (void) closeSaving:(AddressBookSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(AddressBookSaveableFileFormat)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// Container object in the database, holds a key and a value
@interface AddressBookContactInfo : SBObject

@property (copy) id label;  // Label is the label associated with value like "work", "home", etc.
@property (copy) id value;  // Value.
- (NSString *) id;  // unique identifier for this entry, this is persistent, and stays with the record.

- (void) closeSaving:(AddressBookSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(AddressBookSaveableFileFormat)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// User name for America Online (AOL) instant messaging.
@interface AddressBookAIMHandle : AddressBookContactInfo


@end

// Arbitrary date associated with this person.
@interface AddressBookCustomDate : AddressBookContactInfo


@end

// Email address for a person.
@interface AddressBookEmail : AddressBookContactInfo


@end

// An entry in the address book database
@interface AddressBookEntry : SBObject

@property (copy, readonly) NSDate *modificationDate;  // when the contact was last modified.
@property (copy, readonly) NSDate *creationDate;  // when the contact was created.
- (NSString *) id;  // unique and persistent identifier for this record.
@property BOOL selected;  // Is the entry selected?

- (void) closeSaving:(AddressBookSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(AddressBookSaveableFileFormat)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (AddressBookPerson *) addTo:(SBObject *)to;  // Add a child object.
- (AddressBookPerson *) removeFrom:(SBObject *)from;  // Remove a child object.

@end

// A Group Record in the address book database
@interface AddressBookGroup : AddressBookEntry

- (SBElementArray *) groups;
- (SBElementArray *) people;

@property (copy) NSString *name;  // The name of this group.


@end

// User name for ICQ instant messaging.
@interface AddressBookICQHandle : AddressBookContactInfo


@end

// User name for Jabber instant messaging.
@interface AddressBookJabberHandle : AddressBookContactInfo


@end

// User name for Microsoft Network (MSN) instant messaging.
@interface AddressBookMSNHandle : AddressBookContactInfo


@end

// A person in the address book database.
@interface AddressBookPerson : AddressBookEntry

- (SBElementArray *) MSNHandles;
- (SBElementArray *) urls;
- (SBElementArray *) addresses;
- (SBElementArray *) phones;
- (SBElementArray *) JabberHandles;
- (SBElementArray *) groups;
- (SBElementArray *) customDates;
- (SBElementArray *) AIMHandles;
- (SBElementArray *) YahooHandles;
- (SBElementArray *) ICQHandles;
- (SBElementArray *) relatedNames;
- (SBElementArray *) emails;

@property (copy) id nickname;  // The Nickname of this person.
@property (copy) id organization;  // Organization that employs this person.
@property (copy) id maidenName;  // The Maiden name of this person.
@property (copy) id suffix;  // The Suffix of this person.
@property (copy, readonly) id vcard;  // Person information in vCard format, this always returns a card in version 3.0 format.
@property (copy) id homePage;  // The home page of this person.
@property (copy) id birthDate;  // The birth date of this person.
@property (copy) id phoneticLastName;  // The phonetic version of the Last name of this person.
@property (copy) id title;  // The title of this person.
@property (copy) id phoneticMiddleName;  // The Phonetic version of the Middle name of this person.
@property (copy) id department;  // Department that this person works for.
@property (copy) id image;  // Image for person.
@property (copy, readonly) NSString *name;  // First/Last name of the person, uses the name display order preference setting in Address Book.
@property (copy) id note;  // Notes for this person.
@property BOOL company;  // Is the current record a company or a person.
@property (copy) id middleName;  // The Middle name of this person.
@property (copy) id phoneticFirstName;  // The phonetic version of the First name of this person.
@property (copy) id jobTitle;  // The job title of this person.
@property (copy) id lastName;  // The Last name of this person.
@property (copy) id firstName;  // The First name of this person.


@end

// Phone number for a person.
@interface AddressBookPhone : AddressBookContactInfo


@end

// Other names related to this person.
@interface AddressBookRelatedName : AddressBookContactInfo


@end

// URLs for this person.
@interface AddressBookUrl : AddressBookContactInfo


@end

// User name for Yahoo instant messaging.
@interface AddressBookYahooHandle : AddressBookContactInfo


@end

