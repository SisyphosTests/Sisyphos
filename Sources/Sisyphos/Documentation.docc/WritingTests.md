# Writing Tests with Sisyphos

A short introduction into how to describe user interfaces and how to write tests with Sisyphos.


## General principles

> Note:
> Sisyphos' documentation is still work in progress. So far, a lot of the basic principles and ideas are not described
> which makes it very hard to understand the framework and its philosophy.
> 
> This will change with future releases of the framework.

Describe the page how it's visible for the user, starting from the upper left and going to the lower right.

The name of the page elements are the capitalized versions of
[XCUIElement.ElementType](https://developer.apple.com/documentation/xctest/xcuielement/elementtype).
Sisyphos doesn't implement all element types which are available for `XCUIElements`. 
Instead, it only implements a subset of elements.

### You can omit elements you are not interested in

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


## Code generation

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
