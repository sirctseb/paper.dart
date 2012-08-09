#library("paper.dart.test");
#import("../../../../../Desktop/dart/dart-sdk/lib/unittest/unittest.dart");
#import("../../src/basic/Point.dart");
#import("../../src/basic/Rectangle.dart");
#import("../../src/basic/Size.dart");
#import("../../src/basic/Line.dart");
#source("./Point.dart");
#source("./Rectangle.dart");
#source("./Size.dart");
#source("./Line.dart");

void main() {
	PointTests();
	RectangleTests();
	SizeTests();
	LineTests();
}