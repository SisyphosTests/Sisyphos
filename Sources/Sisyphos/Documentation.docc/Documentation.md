# ``Sisyphos`` 

Declarative end-to-end and UI testing for iOS and macOS

## Which problem does Sisyphos solve?

Sisyphos enables you to write user interface tests in a declarative way and even with the support of automatic code
generation based on the user interface of your running app.
You don't need to write lots of imperative code to match elements or to validate screens.
It significantly reduces the time that is needed for writing and maintaing user interface tests.
Looking at tests written with Sisyphos will give you a precise idea how the user interface of the app looks like.

## Overview

Sisyphos uses a declarative syntax, 
so you can simply state how the user interface of your app under test should look like. 
Your code is simpler and easier to read than ever before, saving you time and maintenance.

There's no need for manually tweaking sleeps or timeouts. 
And no need to write imperative code to wait for elements to appear.
Your tests will wait automatically exactly as long as needed to have all elements on the screen.
As soon as the elements appear, the tests will interact with them and continue.

Sisyphos builds on top of Apple's [XCTest framework](https://developer.apple.com/documentation/xctest/user_interface_tests).
Therefore, no extra software or tooling is needed and the risk of breaking with new Xcode or 
Swift versions is limited.

## Contributing, Bugs, and Feature Requests

Sisyphos is an open-source project licensed under the Apache-2.0 license.
Please report any bugs or feature requests at its [GitHub project](https://github.com/SisyphosTests/Sisyphos).

## Topics

### Essentials

- <doc:Integration>
- <doc:WritingTests>
- <doc:Interruptions>

### Page Elements

- ``Alert``
- ``Button``
- ``Cell``
- ``CollectionView``
- ``NavigationBar``
- ``SecureTextField``
- ``StaticText``
- ``Switch``
- ``TabBar``
- ``TextField``

