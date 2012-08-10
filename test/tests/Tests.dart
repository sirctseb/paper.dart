#library("paper.dart.test");
#import("../../../../../Desktop/dart/dart-sdk/lib/unittest/unittest.dart");
#import("../../src/basic/Basic.dart");
#import("../../src/color/Color.dart");
#source("./Point.dart");
#source("./Rectangle.dart");
#source("./Size.dart");
#source("./Line.dart");
#source("./Color.dart");

void main() {
	PointTests();
	RectangleTests();
	SizeTests();
	LineTests();
	ColorTests();
}