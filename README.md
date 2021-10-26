# rollbar-dart and rollbar-flutter

This repository contains the `rollbar_dart` package and the `rollbar_flutter` plugin. 

For `rollbar-dart`, see its [README](rollbar_dart/README.md).

For `rollbar-flutter`, see its [README](rollbar_flutter/README.md).

## `rollbar-dart` `rollbar-flutter` are currently in Beta. We are looking for beta-testers and feedback!

## Documentation

For complete usage instructions and configuration reference, see our [`rollbar-dart` and `rollbar-flutter` SDK docs](https://docs.rollbar.com/docs/flutter).

## Release History & Changelog

See our [Releases](https://github.com/rollbar/rollbar-flutter/releases) page for a list of all releases and changes.

## Help / Support

If you run into any issues, please email us at [support@rollbar.com](mailto:support@rollbar.com).

For bug reports, please open an issue on [GitHub](https://github.com/rollbar/rollbar-flutter/issues/new).

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Run tests and static analysis (`build_tools/check.sh`)
6. If all the checks pass, create new Pull Request

## Publishing packages

The official packages are published as [`rollbar_dart`](https://pub.dev/packages/rollbar_dart) and [`rollbar_flutter`](https://pub.dev/packages/rollbar_flutter). 

Publishing is straightforward using `pub`, but due to quirks of how ignore files work, the script `build_tools/publish.sh` should always be used to make sure only the necessary files are included, and that the right tool versions are used for publishing.

Eg.:

```
./build_tools/publish.sh rollbar_dart
./build_tools/publish.sh rollbar_flutter
```

## License

`rollbar-dart` and `rollbar-flutter` are free software released under the MIT License. See [LICENSE](./LICENSE) for details.
