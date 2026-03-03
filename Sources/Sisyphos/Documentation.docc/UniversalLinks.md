# Opening Universal Links

Learn how to open universal links in your UI tests on iOS.

## Overview

[Universal links](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app) allow your app 
to handle specific URLs directly instead of opening them in Safari.

Sisyphos provides the ``open(universalLink:timeout:file:line:)`` function that allows testing such links.
It launches Safari and causes iOS to interact with the link in a way that opens open your app 
if you implemented universal link support for the specific link.

## Opening a universal link

Call ``open(universalLink:timeout:file:line:)`` with the URL you want to open.
After the link is opened, your app will be brought to the foreground and you can continue your test
by validating the resulting screen with a page.

```swift
import XCTest
import Sisyphos

final class UniversalLinkTests: XCTestCase {
    func testUniversalLink() {
        open(universalLink: "https://example.com/product/42")

        let page = ProductDetailPage()
        page.waitForExistence()
    }
}
```

> Important: Universal links only work on a real device or a simulator that has your app installed with a valid
> Associated Domains entitlement. Make sure your `apple-app-site-association` file is set up correctly.

> Tip: Resolving associated domains can take time. You might need to launch your app and wait a couple of seconds
> before linking into your app works reliably in UI tests.

## Customizing the timeout

By default, the function waits up to 10 seconds for Safari elements to appear.
You can adjust this with the `timeout` parameter if your environment needs more time:

```swift
open(universalLink: "https://example.com/path", timeout: 20)
```

## Platform availability

The ``open(universalLink:timeout:file:line:)`` function is only available on iOS.
It handles differences in Safari's UI across iOS versions automatically, including iOS 26 and later.
