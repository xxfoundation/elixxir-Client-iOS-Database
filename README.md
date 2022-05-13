# xx-client-ios-db

![Swift 5.6](https://img.shields.io/badge/swift-5.6-orange.svg)
![platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg)

Database layer for xx Messenger iOS app.

## 🛠 Development

Open `Package.swift` in Xcode (≥13).

### Package structure

```
xx-client-ios-db (Swift Package)
 ├─ XXModels (Swift Library)
 └─ XXDatabase (Swift Library)
     ├─ XXModels
     └─ GRDB.swift
```

|Library|Description|
|:--|:--|
|**XXModels**|Domain models and database interfaces.|
|**XXDatabase**|Database interface implementation powered by [GRDB library](https://github.com/groue/GRDB.swift).|

### Build schemes

- Use `xx-client-ios-db-Package` scheme to build and run tests for the whole package.
- Use other schemes for building and testing individual libraries.

## 📄 License

Copyright © 2022 xx network SEZC

[License](LICENSE)
