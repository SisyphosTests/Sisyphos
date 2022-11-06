# ``Sisyphos`` 

Declarative end-to-end and UI testing for iOS and macOS

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

### Page Elements

- ``Button``
- ``Cell``
- ``CollectionView``
- ``NavigationBar``
- ``SecureTextField``
- ``StaticText``
- ``TabBar``
- ``TextField``

