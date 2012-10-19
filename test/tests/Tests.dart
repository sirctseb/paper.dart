library paper_dart_test;
import "../../../../Downloads/dart/dart-sdk/pkg/unittest/unittest.dart";
import "../../src/basic/Basic.dart";
import "../../src/color/Color.dart";
import "../../src/path/Path.dart";
part "./Point.dart";
part "./Rectangle.dart";
part "./Size.dart";
part "./Line.dart";
part "../lib/helpers.dart";
part "./Color.dart";
part "./Segment.dart";
part "Group.dart";
part "HitResult.dart";
part "CompoundPath.dart";
part "Item.dart";
part "Item_Bounds.dart";
part "Item_Cloning.dart";
part "Item_Order.dart";
part "Layer.dart";
part "Path.dart";
part "PathStyle.dart";
part "Path_Bounds.dart";
part "Path_Curves.dart";
part "Path_Drawing_Commands.dart";
part "Path_Length.dart";
part "Path_Shapes.dart";
part "PlacedSymbol.dart";
part "Project.dart";

void main() {
	PointTests();
	RectangleTests();
	SizeTests();
	LineTests();
	ColorTests();
	SegmentTests();
}