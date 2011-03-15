/*
 * iCal.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class iCalApplication, iCalDocument, iCalWindow, iCalCalendar, iCalDisplayAlarm, iCalMailAlarm, iCalSoundAlarm, iCalOpenFileAlarm, iCalAttendee, iCalTodo, iCalEvent;

enum iCalSaveOptions {
	iCalSaveOptionsYes = 'yes ' /* Save the file. */,
	iCalSaveOptionsNo = 'no  ' /* Do not save the file. */,
	iCalSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum iCalSaveOptions iCalSaveOptions;

enum iCalPrintingErrorHandling {
	iCalPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	iCalPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum iCalPrintingErrorHandling iCalPrintingErrorHandling;

enum iCalCALParticipationStatus {
	iCalCALParticipationStatusUnknown = 'E6na' /* No anwser yet */,
	iCalCALParticipationStatusAccepted = 'E6ap' /* Invitation has been accepted */,
	iCalCALParticipationStatusDeclined = 'E6dp' /* Invitation has been declined */,
	iCalCALParticipationStatusTentative = 'E6tp' /* Invitation has been tentatively accepted */
};
typedef enum iCalCALParticipationStatus iCalCALParticipationStatus;

enum iCalCALStatusType {
	iCalCALStatusTypeCancelled = 'E4ca' /* A cancelled event */,
	iCalCALStatusTypeConfirmed = 'E4cn' /* A confirmed event */,
	iCalCALStatusTypeNone = 'E4no' /* An event without status */,
	iCalCALStatusTypeTentative = 'E4te' /* A tentative event */
};
typedef enum iCalCALStatusType iCalCALStatusType;

enum iCalCALPriorities {
	iCalCALPrioritiesNoPriority = 'tdp0' /* No priority */,
	iCalCALPrioritiesLowPriority = 'tdp9' /* Low priority */,
	iCalCALPrioritiesMediumPriority = 'tdp5' /* Medium priority */,
	iCalCALPrioritiesHighPriority = 'tdp1' /* High priority */
};
typedef enum iCalCALPriorities iCalCALPriorities;

enum iCalCALViewTypeForScripting {
	iCalCALViewTypeForScriptingDayView = 'E5da' /* The iCal day view */,
	iCalCALViewTypeForScriptingWeekView = 'E5we' /* The iCal week view */,
	iCalCALViewTypeForScriptingMonthView = 'E5mo' /* The iCal month view */
};
typedef enum iCalCALViewTypeForScripting iCalCALViewTypeForScripting;



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface iCalApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(iCalSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) createCalendarWithName:(NSString *)withName;  // Creates a new calendar (obsolete, will be removed in next release)
- (void) reloadCalendars;  // Tell the application to reload all calendar files contents
- (void) switchViewTo:(iCalCALViewTypeForScripting)to;  // Show calendar on the given view
- (void) viewCalendarAt:(NSDate *)at;  // Show calendar on the given date
- (void) GetURL:(NSString *)x;  // Subscribe to a remote calendar through a webcal or http URL

@end

// A document.
@interface iCalDocument : SBObject

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

// A window.
@interface iCalWindow : SBObject

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
@property (copy, readonly) iCalDocument *document;  // The document whose contents are displayed in the window.

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end



/*
 * iCal
 */

// This class represents iCal.
@interface iCalApplication (ICal)

- (SBElementArray *) calendars;


@end

// This class represents a calendar.
@interface iCalCalendar : SBObject

- (SBElementArray *) todos;
- (SBElementArray *) events;

@property (copy) NSString *name;  // This is the calendar title.
@property (copy) NSColor *color;  // The calendar color.
@property (copy, readonly) NSString *uid;  // An unique calendar key
@property (readonly) BOOL writable;  // This is the calendar title.
@property (copy) NSString *objectDescription;  // This is the calendar description.

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

// This class represents a message alarm.
@interface iCalDisplayAlarm : SBObject

@property NSInteger triggerInterval;  // The interval in minutes between the event and the alarm: (positive for alarm that trigger after the event date or negative for alarms that trigger before).
@property (copy) NSDate *triggerDate;  // An absolute alarm date.

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

// This class represents a mail alarm.
@interface iCalMailAlarm : SBObject

@property NSInteger triggerInterval;  // The interval in minutes between the event and the alarm: (positive for alarm that trigger after the event date or negative for alarms that trigger before).
@property (copy) NSDate *triggerDate;  // An absolute alarm date.

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

// This class represents a sound alarm.
@interface iCalSoundAlarm : SBObject

@property NSInteger triggerInterval;  // The interval in minutes between the event and the alarm: (positive for alarm that trigger after the event date or negative for alarms that trigger before).
@property (copy) NSDate *triggerDate;  // An absolute alarm date.
@property (copy) NSString *soundName;  // The system sound name to be used for the alarm
@property (copy) NSString *soundFile;  // The (POSIX) path to the sound file to be used for the alarm

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

// This class represents an 'open file' alarm.
@interface iCalOpenFileAlarm : SBObject

@property NSInteger triggerInterval;  // The interval in minutes between the event and the alarm: (positive for alarm that trigger after the event date or negative for alarms that trigger before).
@property (copy) NSDate *triggerDate;  // An absolute alarm date.
@property (copy) NSString *filepath;  // The (POSIX) path to be opened by the alarm

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

// This class represents a attendee.
@interface iCalAttendee : SBObject

@property (copy, readonly) NSString *displayName;  // The first and last name of the attendee.
@property (copy, readonly) NSString *email;  // e-mail of the attendee.
@property (readonly) iCalCALParticipationStatus participationStatus;  // The invitation status for the attendee.

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

// This class represents a task.
@interface iCalTodo : SBObject

- (SBElementArray *) displayAlarms;
- (SBElementArray *) mailAlarms;
- (SBElementArray *) openFileAlarms;
- (SBElementArray *) soundAlarms;

@property (copy) NSDate *completionDate;  // The todo completion date.
@property (copy) NSDate *dueDate;  // The todo due date.
@property iCalCALPriorities priority;  // The todo priority.
@property (readonly) NSInteger sequence;  // The todo version.
@property (copy, readonly) NSDate *stampDate;  // The todo modification date.
@property (copy) NSString *summary;  // This is the todo summary.
@property (copy) NSString *objectDescription;  // The todo notes.
@property (copy, readonly) NSString *uid;  // An unique todo key.
@property (copy) NSString *url;  // The URL associated to the todo.

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

// This class represents an event.
@interface iCalEvent : SBObject

- (SBElementArray *) attendees;
- (SBElementArray *) displayAlarms;
- (SBElementArray *) mailAlarms;
- (SBElementArray *) openFileAlarms;
- (SBElementArray *) soundAlarms;

@property (copy) NSString *objectDescription;  // The events notes.
@property (copy) NSDate *startDate;  // The event start date.
@property (copy) NSDate *endDate;  // The event end date.
@property BOOL alldayEvent;  // True if the event is an all-day event
@property (copy) NSString *recurrence;  // The iCalendar (RFC 2445) string describing the event recurrence, if defined
@property (readonly) NSInteger sequence;  // The event version.
@property (copy) NSDate *stampDate;  // The event modification date.
@property (copy) NSArray *excludedDates;  // The exception dates.
@property iCalCALStatusType status;  // The event status.
@property (copy) NSString *summary;  // This is the event summary.
@property (copy) NSString *location;  // This is the event location.
@property (copy, readonly) NSString *uid;  // An unique todo key.
@property (copy) NSString *url;  // The URL associated to the event.

- (void) closeSaving:(iCalSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) show;  // Show the event or to-do in the calendar window

@end

