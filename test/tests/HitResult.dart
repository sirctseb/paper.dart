part of paper.dart.test;

/*
 * Paper.js
 *
 * This file is part of Paper.js, a JavaScript Vector Graphics Library,
 * based on Scriptographer.org and designed to be largely API compatible.
 * http://paperjs.org/
 * http://scriptographer.org/
 *
 * Copyright (c) 2011, Juerg Lehni & Jonathan Puckey
 * http://lehni.org/ & http://jonathanpuckey.com/
 *
 * Distributed under the MIT license. See LICENSE file for details.
 *
 * All rights reserved.
 */

HitResultTests() {
  group("Hit Result Tests", () {
    test('hitting a filled shape', () {
      var path = new Path.Circle([50, 50], 50);
      
      var hitResult = path.hitTest([75, 75]);
      expect(hitResult == null, true, 'Since the path is not filled, the hit-test should return null');

      path.fillColor = 'red';
      hitResult = path.hitTest([75, 75]);
      expect(hitResult.type == 'fill');
      expect(hitResult.item == path);
    });

    test('the item on top should be returned', () {
      var path = new Path.Circle([50, 50], 50);
      path.fillColor = 'red';

      // The cloned path is lying above the path:
      var copy = path.clone();

      var hitResult = paper.project.hitTest([75, 75]);
      expect(hitResult.item == copy);
    });

    test('hitting a stroked path', () {
      var path = new Path([0, 0], [50, 0]);
      
      // We are hit testing with an offset of 5pt on a path with a stroke width
      // of 10:

      var hitResult = paper.project.hitTest([25, 5]);
      expect(hitResult == null, true,
        'Since the path is not stroked yet, the hit-test should return null');

      path.strokeColor = 'black';
      path.strokeWidth = 10;
      hitResult = path.hitTest([25, 5]);
      expect(hitResult.type == 'stroke');
      expect(hitResult.item == path);
    });

    test('hitting a selected path', () {
      var path = new Path.Circle([50, 50], 50);
      path.fillColor = 'red';
      
      var hitResult = paper.project.hitTest([75, 75], {
        "selected": true
      });
      expect(hitResult == null, true,
        'Since the path is not selected, the hit-test should return null');

      path.selected = true;
      hitResult = paper.project.hitTest([75, 75]);
      expect(hitResult.type == 'fill');
      expect(hitResult.item == path);
    });

    test('hitting path segments', () {
      var path = new Path([0, 0], [10, 10], [20, 0]);

      var hitResult = paper.project.hitTest([10, 10]);
      
      expect(hitResult != null, true, 'A HitResult should be returned.');
      
      if (hitResult) {
        expect(hitResult.type, 'segment');
      
        expect(hitResult.item == path);
      }
    });

    test('hitting the center of a path', () {
      var path = new Path([0, 0], [100, 100], [200, 0]);
      path.closed = true;

      var hitResult = paper.project.hitTest(path.position, {
        "center": true
      });

      expect(hitResult != null, true, 'A HitResult should be returned.');
      
      if (hitResult) {
        expect(hitResult.point.toString(), path.position.toString());

        expect(hitResult.type, 'center');
        expect(hitResult.item !== paper.project.activeLayer, true,
          'We should not be hitting the active layer.');

        expect(hitResult.item == path, true, 'We should be hitting the path.');
      }
    });

    test('hitting the center of a path with tolerance', () {
      var path = new Path([0, 0], [100, 100], [200, 0]);
      path.closed = true;
      var hitResult = paper.project.hitTest(path.position.add(1, 1), {
        "center": true
      });

      expect(hitResult != null, true, 'A HitResult should be returned.');
      
      if (hitResult) {
        expect(hitResult.point != null, true, 'HitResult#point should not be empty');
        
        if (hitResult.point) {
          expect(hitResult.point.toString(), path.position.toString());
        }

        expect(hitResult.type, 'center');

        expect(hitResult.item !== paper.project.activeLayer, true,
          'We should not be hitting the active layer.');

        expect(hitResult.item == path, true, 'We should be hitting the path.');
      }
    });

    test('hitting path handles', () {
      var path = new Path.Circle(new Point(), 10);
      path.firstSegment.handleIn = [-50, 0];
      path.firstSegment.handleOut = [50, 0];
      var firstPoint = path.firstSegment.point;
      var hitResult = paper.project.hitTest(firstPoint.add(50, 0), {
        "handles": true
      });

      expect(hitResult != null, true, 'A HitResult should be returned (1)');
      
      if (hitResult) {
        expect(hitResult.type, 'handle-out');
      
        expect(hitResult.item == path);
      }

      hitResult = paper.project.hitTest(firstPoint.add(-50, 0), {
        "handles": true
      });

      expect(hitResult != null, true, 'A HitResult should be returned (2)');

      if (hitResult) {
        expect(hitResult.type, 'handle-in');

        expect(hitResult.item == path);
      }
    });

    test('hitting path handles (2)', () {
      var path = new Path(new Segment({
        "point": [0, 0],
        "handleIn": [-50, -50],
        "handleOut": [50, 50]
      }));

      var hitResult = paper.project.hitTest([50, 50], {
        "handles": true
      });
      
      expect(hitResult != null, true, 'A HitResult should be returned (1)');
      
      if (hitResult) {
        expect(hitResult.type, 'handle-out');
      
        expect(hitResult.item == path);
      }

      hitResult = paper.project.hitTest([-50, -50], {
        "handles": true
      });

      expect(hitResult != null, true, 'A HitResult should be returned (2)');

      if (hitResult) {
        expect(hitResult.type, 'handle-in');

        expect(hitResult.item == path);
      }
    });

    test('hit testing stroke on segment point of a path', () {
      var path = new Path([0, 0], [50, 50], [100, 0]);
      path.strokeColor = 'black';
      path.closed = true;

      var error = null;
      try {
        var hitResult = paper.project.hitTest(path.firstSegment.point, {
          "stroke": true
        });
      } catch (e) {
        error = e;
      }
      var description = 'This hit test should not throw an error';
      if (error)
        description += ': ' + error;
      expect(error == null, true, description);
    });

    test('Hit testing a point that is extremely close to a curve', () {
      var path = new Path.Rectangle([0, 0], [100, 100]);
      // A point whose x value is extremely close to 0:
      var point = new Point(2.842 / Math.pow(10, 14), 0);
      var error;
      try {
        var hitResult = path.hitTest(point, {
          "stroke": true
        });
      } catch(e) {
        error = e;
      }
      var description = 'This hit test should not throw an error';
      if (error)
        description = '$description: error';
      expect(error == null, true, description);
    });

    test('hitting path ends', () {
      var path = new Path([0, 0], [50, 50], [100, 0]);
      path.closed = true;

      expect(!paper.project.hitTest(path.firstSegment.point, {
          "ends": true
        }), true, 'No hitresult should be returned, because the path is closed.');

      path.closed = false;

      var hitResult = paper.project.hitTest(path.lastSegment.point, {
        "ends": true
      });

      expect(hitResult != null, true, 'A HitResult should be returned (1)');
      
      if (hitResult) {
        expect(hitResult.type, 'segment');
      
        expect(hitResult.segment == path.lastSegment);
      }

      expect(!paper.project.hitTest(path.segments[1].point, {
          "ends": true
        }), true, 'No HitResult should be returned, since the second segment is not an end');
    });

    test('When a path is closed, the end of a path cannot be hit.', () {
      var path = new Path([0, 0], [50, 50], [100, 0]);
      path.closed = true;

      var hitResult = paper.project.hitTest([0, 0], {
        "ends": true
      });
      expect(hitResult == null, true,
        'When a path is closed, the end of a path cannot be hit.');
    });

    test('hitting path bounding box', () {
      var path = new Path.Circle(new Point(100, 100), 50);

      var hitResult = paper.project.hitTest(path.bounds.topLeft, {
        "bounds": true
      });

      expect(hitResult != null, true, 'A HitResult should be returned (1)');
      
      if (hitResult) {
        expect(hitResult.type, 'bounds');

        expect(hitResult.name, 'top-left');

        expect(hitResult.point.toString(), path.bounds.topLeft.toString());
      }
    });

    test('hitting guides', () {
      var path = new Path.Circle(new Point(100, 100), 50);
      path.fillColor = 'red';

      var copy = path.clone();

      var hitResult = paper.project.hitTest(path.position);

      expect(hitResult != null, true, 'A HitResult should be returned (1)');
      
      if (hitResult) {
        expect(hitResult.item == copy, true, 'The copy is returned, because it is on top.');
      }
      
      path.guide = true;
      
      hitResult = paper.project.hitTest(path.position, {
        "guides": true,
        "fill": true
      });
      
      expect(hitResult != null, true, 'A HitResult should be returned (2)');
      
      if (hitResult) {
        expect(hitResult.item == path, true, 'The path is returned, because it is a guide.');
      }
    });

    test('hitting raster items', () {
      // Create a path, rasterize it and then remove the path:
      var path = new Path.Rectangle(new Point(), new Size(320, 240));
      path.fillColor = 'red';
      var raster = path.rasterize();
      
      var hitResult = paper.project.hitTest(new Point(160, 120));

      expect(hitResult && hitResult.item == raster, true, 'Hit raster item before moving');
      
      // Move the raster:
      raster.translate(100, 100);
      
      hitResult = paper.project.hitTest(new Point(160, 120));

      expect(hitResult && hitResult.item == raster, true, 'Hit raster item after moving');
    });

    test('hitting path with a text item in the project', () {
        var path = new Path.Rectangle(new Point(50, 50), new Point(100, 100));
        path.fillColor = 'blue';
      
      var hitResult = paper.project.hitTest(new Point(75, 75));

      expect(hitResult && hitResult.item == path, true, 'Hit path item before adding text item');

      var text1 = new PointText(30, 30);
      text1.content = "Text 1";

      hitResult = paper.project.hitTest(new Point(75, 75));
      
      expect(hitResult, true, 'A hitresult should be returned.');

      expect((hitResult != null) && hitResult.item == path, true, 'We should have hit the path');
      
    });
  });
  // TODO: project.hitTest(point, {type: AnItemType});
}