#  Handling Interruptions

Learn how to handle interruptions that can happen unexpectedly or at any time, such as alerts and permission dialogues.

## Registering interruption handlers

Sisyphos has the philosophy that you always describe what to expect upfront.
You usually don't react on things happening in your tested app. Instead, you describe what you expect that happens and
Sisyphos is validating that the app does like expected.

However, there are sometimes UI elements which will interrupt the user interface and you are not in control when or 
where these elements will appear. 

For such situations, Sisyphos provides the possibility to register interruption handlers. 
You can describe the interruption that appears with a page, similar to what you do in regular tests.

Let's say we want to react on an alert that has the message `There was an error` and a button that says `OK`. 
We can describe the alert with the following page:

```swift
struct ErrorAlert: Page {
    let button: Button(label: "OK")
    var body: PageDescription {
        Alert {
            StaticText("There was an error")
            button
        }
    }
}
```

Then, in the test, you register an interruption monitor that presses on the button whenever the alert is currently
displayed and interrupting the user interface because of this.

```swift
addInterruptionMonitor(page: ErrorAlert()) { page in
    page.button.tap()
}
```

See the ``XCTest/XCTestCase/addUIInterruptionMonitor(page:handler:)`` method for more details.

## Unregistering interruption handlers

A Sisyphos interruption monitor only handles interruptions in the test case in which it was registered. It will not
handle interruptions that are called in other test cases.

Yet, sometimes you want to have even more precise control and only handle interruptions that happen in selected parts of
a test case. 

To achieve this, you can unregister any interruption monitor that was previously registered via the
``XCTest/XCTestCase/removeUIInterruptionMonitor(_:)`` method.


## Provided Pages for iOS Permission interruptions

Sisyphos comes with page implementations that enable you to write tests for permission flows on iOS.
You can use this pages to add interruption handlers that can handle permission dialogues.

* ``DefaultPermissionAlert`` A page that can describe permission dialogues on iOS.
* ``DefaultAlert``: A page that can describe certain iOS permission alerts such as App Tracking Transparency prompt.

## Removing Default Interruption Handlers

By default, XCTest will handle interruptions such as permission dialogues automatically. 
This is done with implicit interruption handlers that take care of the most common interruptions for you. 
On iOS, XCTest handles interrupting elements if they have a cancel button or a default button. 
Starting from Xcode 12, it also implicitly handles Banner notifications. 
The details are explained in a [WWDC 2020 video](https://developer.apple.com/videos/play/wwdc2020/10220/?time=209).

If you want to test permission flows, then this implicit handling will interfere with your tests, 
which ultimatively makes it impossible to write such tests.

Therefore, Sisyphos extends the ``XCTest/XCTestCase`` class 
and provides the ``XCTest/XCTestCase/disableDefaultXCUIInterruptionHandlers()`` method.
Calling this method will disable the implicit handlers, so you can write tests that test permission flows.
