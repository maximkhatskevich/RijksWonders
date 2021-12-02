# RijksWonders

Small demo project app for iOS.

## Overview

Displays data from Rijks Museum (Netherlands). Simple demonstration of essential functionality around fetching JSON data from backend via HTTP request and displaying it in GUI. Almost completely vanilla iOS SDK, the only 3rd party dependency used is [Kingfisher](https://github.com/onevcat/Kingfisher) for lazy asyncronous images downloading. Follows MVVP and CLEAN Architecture principles with strict separation into layers, where each layer can only depend on 1 layer below: **Services ⬅ Models ⬅ ViewModels ⬅ View (the app itself)**.



<img src="Resources/Loading.png" alt="Loading" style="zoom:25%;" /><img src="Resources/Ready.png" alt="Ready" style="zoom:25%;" /><img src="Resources/Details.png" alt="Details" style="zoom:25%;" />
