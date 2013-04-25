**Quick Start Guide**

The ENiOS library is an open source Objective-C library for the Echo Nest APIs. It provides the iOS/Objective-C programmer full access to all of the Echo Nest methods including those for artists, songs, playlisting, and taste profiles,as well as methods for retrieving detailed analysis information about an uploaded track. It also includes an example app to demonstrate how to integrate this library into an XCode project.

Note: This library is an update to our previous libechonest library, which removes several dependencies and simplifies the code needed to interact with our API. Although we will continue to keep libechonest available on a limited basis, we recommend using this library for all iOS projects moving forward.

The preferred way to include this library is to reference the project as a static library, from either an ARC or a Memory Managed development environment. (Note that there are links to screen shots embedded in these steps.)

1) Create an 'ENWorkspace' folder, and add the library files into this folder.

2) Create a new workspace folder for your project in the same folder, and name it something like 'MyWorkspace'.

3) In Xcode, create a new Project Workspace by selecting File/New/Workspace, save it in the 'MyWorkspace'folder and title it something like 'MyWorkspace'.

4) Right click in the project navigator window, create your new project, and title it something like 'MyProject'.  Your file structure should now look something like [this](docs/ENAPILibraryDocumentation/step4.png).

Alternately, for adding the the ENAPILibrary to an existing project: in the Finder, drag an existing project folder into the MyProjectsWorkspace folder, andn add the project to the workspace in Xcode by dragging the .xcodeproj file into the project navigator window.

5) Right click on 'MyProject' in the project navigator and select Add Files to 'MyProject'. Navigate to the file 'ENAPILibrary.xcodeproj' in the ENAPILibrary folder and add it to your project. Your XCode project should now look something like [this](docs/ENAPILibraryDocumentation/step5.png).

6) Select the 'MyProject' target.  In 'Build Settings' tab for this target, find the line 'User Header Search Paths' and paste the string '"${SRCROOT}"/../../**' into this value to point to a directory above the ENAPILibrary.  Your Xcode window should look something like [this](docs/ENAPILibraryDocumentation/step6.png).

7) Select the 'MyProject' target.  In 'Build Phases', expand 'Target Dependencies' and select the '+' button. Add ENAPILibrary.  

8) Select the 'MyProject' target.  In 'Build Phases' expand 'Link Binary With Libraries', and select the '+' button. Add the ENAPILibrary library and the Apple MediaPlayer framework. Your Your Xcode window should look something like [this](docs/ENAPILibraryDocumentation/step9.png).

9) In your project's "AppDelegate.m" file, include the line '#import "ENAPI.h"' at the top below the other imports.

10) In the AppDelegate.m file, within the '- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions' method, include the line... 

        [ENAPIRequest setApiKey:@"DEFAULTAPIKEY"];

11) Change the default api key value to your Echo Nest API Key.  Your ApplicationDelegate file should look something like [this](docs/ENAPILibraryDocumentation/step11.png).

12) Use the ENAPIRequest class methods "GETWithEndpoint:andParameters:andCompletionBlock" and  "POSTWithEndpoint:andParameters:andCompletionBlock" to interact with the Echo Nest web services. Your ViewController file should look something like [this](docs/ENAPILibraryDocumentation/step12.png).


