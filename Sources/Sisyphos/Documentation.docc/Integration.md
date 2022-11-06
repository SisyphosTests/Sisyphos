# Integrating Sisyphos in your tests

Learn how to add Sisyphos to your app's UI tests.

## Overview

Sisyphos is distributed via the [Swift Package Manager](https://www.swift.org/getting-started/#using-the-package-manager) 
with the repository URL `https://github.com/SisyphosTests/sisyphos`.

Please refer to [Apple's documentation](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)
on how to add a Swift package dependency to your app.

> Warning: Please make sure to add the `Sisyphos` library to your app's UI test target, not the app target itself! 
> 
> If you see errors such as the errors below when building the app, then you added the Sisyphos library to the wrong target. 
> ![](integration-wrong-target.png)
