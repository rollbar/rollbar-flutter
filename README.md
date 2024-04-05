<p align="center">
  <img alt="rollbar-logo" src="https://user-images.githubusercontent.com/3300063/207964480-54eda665-d6fe-4527-ba51-b0ab3f41f10b.png" />
</p>

<h1 align="center">Rollbar Dart Monorepo</h1>

<p align="center">
  <strong>Proactively discover, predict, and resolve errors in real-time with <a href="https://rollbar.com">Rollbar’s</a> error monitoring platform. <a href="https://rollbar.com/signup/">Start tracking errors today</a>!</strong>
</p>

---

<p> Attention:</p>

<p>As of April 2024, Rollbar will not be actively updating this repository and plans to archive it. We encourage our community to fork this repo if you wish to continue its development. While Rollbar will no longer be engaging in active development, we remain committed to reviewing and merging pull requests, particularly those about security updates. If an actively maintained fork emerges, please let us know, and we will gladly link to it from our documentation.</p>

This repository contains the `rollbar_dart` package and the `rollbar_flutter` plugin.

For `rollbar-dart`, see its [README](rollbar_dart/README.md).

For `rollbar-flutter`, see its [README](rollbar_flutter/README.md).

## `rollbar-dart` `rollbar-flutter` are currently in Beta. We are looking for beta-testers and feedback

## Key benefits of using Rollbar for Dart are:
- **Automatic error grouping:** Rollbar aggregates Occurrences caused by the same error into Items that represent application issues. <a href="https://docs.rollbar.com/docs/grouping-occurrences">Learn more about reducing log noise</a>.
- **Advanced search:** Filter items by many different properties. <a href="https://docs.rollbar.com/docs/search-items">Learn more about search</a>.
- **Customizable notifications:** Rollbar supports several messaging and incident management tools where your team can get notified about errors and important events by real-time alerts. <a href="https://docs.rollbar.com/docs/notifications">Learn more about Rollbar notifications</a>.


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

```sh
./build_tools/publish.sh rollbar_dart
./build_tools/publish.sh rollbar_flutter
```

## License

`rollbar-dart` and `rollbar-flutter` are free software released under the MIT License. See [LICENSE](./LICENSE) for details.
