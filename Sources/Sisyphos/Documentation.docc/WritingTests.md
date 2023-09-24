# Writing Tests with Sisyphos

A short introduction into how to describe user interfaces and how to write tests with Sisyphos.


## The basic building block: Pages

Pages are the basic building blocks in Sisyphos. A ``Page`` describes the user interface which you expect in your tests.
You describe pages with a syntax that is very familiar if you are used to SwiftUI:

```swift
struct ExamplePage: Page {
    var body: PageDescription {
        NavigationBar {
            StaticText("Title in the Nav Bar")
        }
    }
}
```

This page describes that you are expecting a screen with a navigation bar. Inside the Navigation bar, there should be
the title _Title in the Nav Bar_.

The name of the page elements are the capitalized versions of
[XCUIElement.ElementType](https://developer.apple.com/documentation/xctest/xcuielement/elementtype).
Sisyphos doesn't implement all element types which are available for `XCUIElements`.
Instead, it only implements a subset of elements.
You can check the ``PageElement`` protocol to see all elements which are available in Sisyphos.

After you have defined your page, you usually want to use it in your tests to interact with its elements 
and to validate that your app behaves correctly and displays the correct information.
There are two ways to check if a page exists:

1. Calling its ``Sisyphos/Page/waitForExistence(timeout:file:line:)`` method.
   This method will check if all the page's elements exist and are in the expected state. 
   If not, it will wait until the timeout is reached and periodically check if the page exists. 
   As soon as page exists, the method returns. 
   This means that your tests will only take as long as needed to have all the elements visible 
   and will execute as fast as possible.
   If the page doesn't exist after the timeout, then this method will automatically fail the currently running test.
2. Using its ``Page/exists()`` method.
   This method will check if the page exists and return immediately with the results.
   If the page doesn't exist, it will tell you in the ``PageExistsResults/missingElements`` property which elements
   weren't found. 
   A non-existing page will not automatically fail your test.

In a test, where you want to validate that a page exists and all its elements are in the expected state, 
you should usually use its ``Page/waitForExistence(timeout:file:line:)`` method.

If you want to interact with a page's element, then you need to put it in a property on the page.
E.g. if you want to tap on a button which is in the nav bar:

```swift
struct ExamplePage: Page {
    
    let buttonInNavBar = Button()
    
    var body: PageDescription {
        NavigationBar {
            StaticText("Title in the Nav Bar")
            buttonInNavBar
        }
    }
}

final class Tests: XCTestCase {
    func testApp() {
        let app = XCUIApplication()
        app.launch()
        
        let page = ExamplePage()
        page.waitForExistence()
        page.buttonInNavBar.tap()
    }
}
```

> Important: Always call a page's `waitForExistence()` method before you interact with its elements.

## Pages can describe other apps than the target app

By default, a page describes screens of the application which is configured as the tests' target application. 
But you can also interact with screens of other applications, e.g. the settings app in iOS. 

All pages need to provide an `application` parameter which is the bundle identifier of the app which should be tested.
By default, this bundle identifier is empty, therefore Sisyphos will use the application which is configured as the
tests' target application in the tests target configuration.
If you set this to a bundle identifier of another application, then Sisyphos will use this bundle identifier and check
the elements of the app with this bundle identifier.

```
struct Preferences: Page {

    let application = "com.apple.Preferences"
    
    var body: PageDescription {
        NavigationBar {}
    }
}
```

## General principles for building pages

Now that you learned what a _Page_ is in Sisyphos, here are some of the basic principles which will help you to work
with pages.

> Info: Why do we call it _pages_? We don't test websites. Or even books. Shouldn't we call this _screens_?
> The name `Page` is influenced by the [page object pattern](https://martinfowler.com/bliki/PageObject.html).

First of all, when describing pages, you should describe the page like it's visible for the user.
Start from the upper left and go to the lower right.

### You can omit elements in which you are not interested

You don't need to add every element which is visible on the screen. 
It's perfectly fine to omit elements.
You only need to add the elements which are relevant and which should make a test fail if they are not present or
if they have the wrong contents.

### The order and hierarchy of elements is important

Although you can skip elements, the relative order of elements which are expected in your page is important.
For example, if you have the following screen:

```swift
struct ExamplePage: Page {
    var body: PageDescription {
        StaticText("First Name")
        TextField()
    }
}
```

In this example, it's important that the text field actually appears after the static text - which means that the text
should be above the text field. If the text is below the text field, then the tests will fail because the page will
never match with the screen contents.

You can utilize this to match elements which would be hard to match otherwise. For example, in the following page the
text fields wouldn't be distinguishable as they neither have an accessibility identifier nor any other attribute.

```swift
struct ExamplePage: Page {
    let firstNameField = TextField()
    
    let lastNameField = TextField()
    
    var body: PageDescription {
        StaticText("First Name")
        firstNameField
        StaticText("Last Name")
        lastNameField
    }
}
```

In a regular XCUITest without Sisyphos, you would need to go via the text fields' indices which will make the test very
fragile if the order of elements change.

With Sisyphos, you have an easy way to describe the relations between the position of elements.

### You don't need to describe all ancestors of an element

The hierarchy of elements can be deeply nested. It's not uncommon for elements to have 5-10 ancestors. 
In Sisyphos, you can omit arbitrary ancestors and the element matching will work nevertheless. 
This makes the tests very maintainable as usually the ancestors of an element change quite a lot, but the element and 
its contents are stable.


## Code Generation

Instead of building the descriptions of the screens yourself, Sisyphos can automatically generate the code for you.
Call `startCodeGeneration()` inside of an `XCTestCase`. Sisyphos will then record any new screen
which will appear and add the screens' source code at the end of the file while you manually browse through the app.

```swift
import XCTest
import Sisyphos

class UITests: XCTestCase {

    func testNew() {
        let app = XCUIApplication()
        app.launch()
        
        startCodeGeneration()
    }

}
```

![](codegeneration)


> Info: The Code generation will add the generated code at the end of the file from which you call 
> `startCodeGeneration()`. This will only work when running the code generation on a simulator.
> When running on a real device, the code generation cannot access the source file.

## Extracting Test Data

It's best practices to expect screen contents upfront and to not react dynamically on the things that are
happening inside your app. However, sometimes you need to extract data which you cannot predict upfront because
it's created dynamically as a side effect or your actual test, and you need to use the data for further steps or
validations in your tests.

For situations like this, Sisyphos provides the ``TestData`` property wrapper. 
You can use it to extract contents out of static texts or the labels of elements.
Simply use it on a string property on your page. 
Then, wherever you want to extract the text, use the property in a string interpolation.

```swift
struct ExamplePage: Page {
    
    @TestData var invoiceNumber: String
    
    struct PurchaseLastStep: Page {
        var body: PageDescription {
            NavigationBar {
                StaticText("Success")
            }
            
            StaticText("Invoice \(invoiceNumber)")
            StaticText("Thank you for your purchase!")
        }
    }
}

final class PurchaseTests: XCTestCase {
    func testPurchase() {
        // ....
        let page = PurchaseLastStep()
        page.waitForExistence()
        
        // The invoiceNumber property is now available and you can use it in the test.
        // It will contain the invoice number which was extracted from the page.
        print(page.invoiceNumber)
    }
}
```
