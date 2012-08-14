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

void main() {
	PointTests();
	RectangleTests();
	SizeTests();
	LineTests();
	ColorTests();
	SegmentTests();
}