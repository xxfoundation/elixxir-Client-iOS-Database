# xx-client-ios-db

![Swift 5.7](https://img.shields.io/badge/swift-5.6-orange.svg)
![platform iOS macOS](https://img.shields.io/badge/platform-iOS_macOS-blue.svg)

Database layer for xx Messenger iOS app.

## 🛠 Development

Open `Package.swift` in Xcode (≥14).

### Package structure

```
xx-client-ios-db (Swift Package)
 ├─ XXModels (Swift Library)
 ├─ XXLegacyDatabaseMigrator (Swift Library)
 |   ├─ XXModels
 |   └─ XXDatabase
 └─ XXDatabase (Swift Library)
     ├─ XXModels
     └─ GRDB.swift
```

|Library|Description|
|:--|:--|
|**XXModels**|Domain models and database interfaces.|
|**XXLegacyDatabaseMigrator**|Legacy database migration helper.|
|**XXDatabase**|Database interface implementation powered by [GRDB library](https://github.com/groue/GRDB.swift).|

### Build schemes

- Use `xx-client-ios-db-Package` scheme to build and run tests for the whole package.
- Use other schemes for building and testing individual libraries.

## 📄 License

Copyright © 2022 xx network SEZC

[License](LICENSE)
