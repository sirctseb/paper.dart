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

class PathFlattener {
  
  List curves = []; // The curve values as returned by getValues()
  List<Map> parts = []; // The calculated, subdivided parts of the path
  double length = 0.0; // The total length of the path
  // Keep a current index from the part where we last where in
  // getParameterAt(), to optimise for iterator-like usage of flattener.
  int index = 0;
  
  PathFlattener(Path path) {

		// Instead of relying on path.curves, we only use segments here and
		// get the curve values from them.

		// Now walk through all curves and compute the parts for each of them,
		// by recursively calling _computeParts().
		var segments = path._segments,
			segment1 = segments[0],
			segment2;

		var addCurve = (segment1, segment2) {
			var curve = Curve._getValues(segment1, segment2);
			curves.add(curve);
			_computeParts(curve, segment1._index, 0, 1);
		};

		for (var i = 1, l = segments.length; i < l; i++) {
			segment2 = segments[i];
			addCurve(segment1, segment2);
			segment1 = segment2;
		}
		if (path._closed)
			addCurve(segment2, segments[0]);
	}

	_computeParts(curve, index, minT, maxT) {
		// Check if the t-span is big enough for subdivision.
		// We're not subdividing more than 32 times...
		if ((maxT - minT) > 1 / 32 && !Curve.isFlatEnough(curve)) {
			var curves = Curve._subdivide(curve);
			var halfT = (minT + maxT) / 2;
			// Recursively subdive and compute parts again.
			_computeParts(curves[0], index, minT, halfT);
			_computeParts(curves[1], index, halfT, maxT);
		} else {
			// Calculate distance between p1 and p2
			var x = curve[6] - curve[0],
				y = curve[7] - curve[1],
				dist = sqrt(x * x + y * y);
			if (dist > Numerical.TOLERANCE) {
				length += dist;
				parts.add({
					"offset": length,
					"value": maxT,
					"index": index
				});
			}
		}
	}

	getParameterAt(offset) {
		// Make sure we're not beyond the requested offset already. Search the
		// start position backwards from where to then process the loop below.
		var i, j = index;
		for (;;) {
			i = j;
			if (j == 0 || parts[--j]["offset"] < offset)
				break;
		}
		// Find the part that succeeds the given offset, then interpolate
		// with the previous part
		for (var l = parts.length; i < l; i++) {
			var part = parts[i];
			if (part["offset"] >= offset) {
				// Found the right part, remember current position
				index = i;
				// Now get the previous part so we can linearly interpolate
				// the curve parameter
				var prev = parts[i - 1];
				// Make sure we only use the previous parameter value if its
				// for the same curve, by checking index. Use 0 otherwise.
				var prevVal = prev != null && prev["index"] == part["index"] ? prev["value"] : 0,
					prevLen = prev != null ? prev["offset"] : 0;
				return {
					// Interpolate
					"value": prevVal + (part["value"] - prevVal)
						* (offset - prevLen) /  (part["offset"] - prevLen),
					"index": part["index"]
				};
			}
		}
		// Return last one
		var part = parts[parts.length - 1];
		return {
			"value": 1,
			"index": part["index"]
		};
	}

	evaluate(offset, type) {
		var param = getParameterAt(offset);
		return Curve._evaluate(curves[param.index], param.value, type);
	}

	drawPart(ctx, from, to) {
		from = getParameterAt(from);
		to = getParameterAt(to);
		for (var i = from.index; i <= to.index; i++) {
			var curve = Curve._getPart(curves[i],
					i == from.index ? from.value : 0,
					i == to.index ? to.value : 1);
			if (i == from.index)
				ctx.moveTo(curve[0], curve[1]);
			ctx.bezierCurveTo.apply(ctx, curve.getRange(2, curve.length - 2));
		}
	}
}
