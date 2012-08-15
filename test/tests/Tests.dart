#library("paper.dart.test");
#import("../../../../../Desktop/dart/dart-sdk/lib/unittest/unittest.dart");
#import("../../src/basic/Basic.dart");
#import("../../src/color/Color.dart");
#import("../../src/path/Segment.dart");
#source("./Point.dart");
#source("./Rectangle.dart");
#source("./Size.dart");
#source("./Line.dart");
#source("../lib/helpers.dart");
#source("./Color.dart");
#source("./Segment.dart");
#source("Group.dart");
#source("HitResult.dart");
#source("CompoundPath.dart");
#source("Item.dart");
#source("Item_Bounds.dart");
#source("Item_Cloning.dart");
#source("Item_Order.dart");
#source("Layer.dart");
#source("Path.dart");
#source("PathStyle.dart");
#source("Path_Bounds.dart");
#source("Path_Curves.dart");
#source("Path_Drawing_Commands.dart");
#source("Path_Length.dart");
#source("Path_Shapes.dart");

void main() {
	PointTests();
	RectangleTests();
	SizeTests();
	LineTests();
	ColorTests();
	SegmentTests();
}