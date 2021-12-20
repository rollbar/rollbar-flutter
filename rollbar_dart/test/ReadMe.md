# References
https://pub.dev/documentation/mockito/latest/

# Notes

## Useful Imports
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';


## Generating Mocks

    // Annotation which generates the cat.mocks.dart library and the MockCat class.
    @GenerateMocks([Cat])
    void main() {
        // Create mock object.
        var cat = MockCat();
    }

To force the mock code generation run:

    dart run build_runner build

