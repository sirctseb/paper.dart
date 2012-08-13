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

ColorTests() {
  group("Color Tests", () {
    test('Set named color', () {
      //var path = new Path();
      //path.fillColor = 'red';
      Color color = new Color("red");
      //compareRgbColors(path.fillColor, new RgbColor(1, 0, 0));
      compareRgbColors(color, new RgbColor(1,0,0));
      //expect(path.fillColor.toCssString(), equals('rgba(255, 0, 0, 1)'));
      expect(color.toCssString(), equals('rgba(255, 0, 0, 1)'));
    });

    test('Set color to hex', () {
      //var path = new Path();
      //path.fillColor = '#ff0000';
      //compareRgbColors(path.fillColor, new RgbColor(1, 0, 0));
      //expect(path.fillColor.toCssString(), equals('rgba(255, 0, 0, 1)'));
      Color color = new Color("#ff0000");
      compareRgbColors(color, new RgbColor(1,0,0));
      expect(color.toCssString(), equals('rgba(255, 0, 0, 1)'));

      //var path = new Path();
      //path.fillColor = '#f00';
      //compareRgbColors(path.fillColor, new RgbColor(1, 0, 0));
      //expect(path.fillColor.toCssString(), equals('rgba(255, 0, 0, 1)'));
      color = new Color("f00");
      compareRgbColors(color, new RgbColor(1, 0, 0));
      expect(color.toCssString(), equals('rgba(255, 0, 0, 1)'));
    });

    test('Set color to object', () {
      //var path = new Path();
      //path.fillColor = { "red": 1, "green": 0, "blue": 1};
      //compareRgbColors(path.fillColor, new RgbColor(1, 0, 1));
      //expect(path.fillColor.toCssString(), equals('rgba(255, 0, 255, 1)'));
      Color color = new Color({"red": 1, "green": 0, "blue": 1});
      compareRgbColors(color, new RgbColor(1, 0, 1));
      expect(color.toCssString(), equals('rgba(255, 0, 200, 1)'));

      //var path = new Path();
      //path.fillColor = { "gray": 0.2 };
      //compareRgbColors(path.fillColor, new RgbColor(0.8, 0.8, 0.8));
      //expect(path.fillColor.toCssString(), equals('rgba(204, 204, 204, 1)'));
      color = new Color({"gray": 0.2});
      compareRgbColors(color, new RgbColor(0.8, 0.8, 0.8));
      expect(color.toCssString(), equals('rgba(204, 204, 204, 1)'));
    });

    test('Set color to array', () {
      //var path = new Path();
      //path.fillColor = [1, 0, 0];
      //compareRgbColors(path.fillColor, new RgbColor(1, 0, 0));
      //expect(path.fillColor.toCssString(), equals('rgba(255, 0, 0, 1)'));
      Color color = new Color([1, 0, 0]);
      compareRgbColors(color, new RgbColor(1, 0, 0));
      expect(color.toCssString(), equals('rgba(255, 0, 0, 1)'));
    });

    test('Creating colors', () {

      compareRgbColors(new RgbColor('#ff0000'), new RgbColor(1, 0, 0),
        'RgbColor from hex code');

      compareRgbColors(new RgbColor({ "red": 1, "green": 0, "blue": 1}),
        new RgbColor(1, 0, 1), 'RgbColor from rgb object literal');

      compareRgbColors(new RgbColor({ "gray": 0.2 }),
        new RgbColor(0.8, 0.8, 0.8), 'RgbColor from gray object literal');

      compareRgbColors(new RgbColor({ "hue": 0, "saturation": 1, "brightness": 1}),
        new RgbColor(1, 0, 0), 'RgbColor from hsb object literal');

      compareRgbColors(new RgbColor([1, 0, 0]), new RgbColor(1, 0, 0),
        'RgbColor from array');

      compareHsbColors(new HsbColor('#000000'), new HsbColor(0, 0, 0),
        'HsbColor from hex code');

      compareHsbColors(new HsbColor({ "red": 1, "green": 0, "blue": 0}),
        new HsbColor(0, 1, 1), 'HsbColor from rgb object literal');

      compareHsbColors(new HsbColor({ "gray": 0.8 }),
        new HsbColor(0, 0, 0.2), 'RgbColor from gray object literal');

      compareHsbColors(new HsbColor([1, 0, 0]), new HsbColor(1, 0, 0),
        'HsbColor from array');

      compareGrayColors(new GrayColor('#000000'), new GrayColor(1),
        'GrayColor from hex code');

      compareGrayColors(new GrayColor('#ffffff'), new GrayColor(0),
        'GrayColor from hex code');

      compareGrayColors(new GrayColor({ "red": 1, "green": 1, "blue": 1}),
        new GrayColor(0), 'GrayColor from rgb object literal');

      compareGrayColors(new GrayColor({ "gray": 0.2 }),
        new GrayColor(0.2), 'GrayColor from gray object literal');

      compareGrayColors(new GrayColor({ "hue": 0, "saturation": 0, "brightness": 0.8}),
        new GrayColor(0.2), 'GrayColor from hsb object literal');

      compareGrayColors(new GrayColor([1]), new GrayColor(1),
        'GrayColor from array');
    });

    test('get gray from rgbcolor', () {
      var color = new RgbColor(1, 0.5, 0.2);
      compareNumbers(color.gray, 0.38458251953125);

      color = new RgbColor(0.5, 0.2, 0.1);
      compareNumbers(color.gray, 0.72137451171875);
    });

    test('Get gray from HsbColor', () {
      var color = new HsbColor(0, 0, 0.2);
      compareNumbers(color.gray, 0.8);
    });

    test('Get red from HsbColor', () {
      var color = new HsbColor(0, 1, 1);
      compareNumbers(color.red, 1);
    });

    test('Get hue from RgbColor', () {
      var color = new RgbColor(1, 0, 0);
      compareNumbers(color.hue, 0);
      compareNumbers(color.saturation, 1);
    });

    test('Gray Color', () {
      var color = new GrayColor(1);
      compareNumbers(color.gray, 1);
      compareNumbers(color.red, 0);

      color.red = 0.5;
      compareNumbers(color.gray, 0.84999);

      color.green = 0.2;
      compareNumbers(color.gray, 0.82051);
    });

    test('Converting Colors', () {
      var rgbColor = new RgbColor(1, 0.5, 0.2);
      compareNumbers(new GrayColor(rgbColor).gray, 0.38299560546875);

      var grayColor = new GrayColor(0.2);
      rgbColor = new RgbColor(grayColor);
      compareRgbColors(rgbColor, new Color([ 0.8, 0.8, 0.8, 1]));

      var hsbColor = new HsbColor(grayColor);
      compareHsbColors(hsbColor, new HsbColor([ 0, 0, 0.8, 1]));

      rgbColor = new RgbColor(1, 0, 0);
      compareHsbColors(new HsbColor(rgbColor), [0, 1, 1, 1]);
    });

    test('Setting RgbColor#gray', () {
      var color = new RgbColor(1, 0.5, 0.2);
      color.gray = 0.1;
      compareRgbColors(color, [ 0.9, 0.9, 0.9, 1]);
    });

    test('Setting HsbColor#red', () {
      var color = new HsbColor(180, 0, 0);
      color.red = 1;
      compareHsbColors(color, [0, 1, 1, 1]);
    });

    test('Setting HsbColor#gray', () {
      var color = new HsbColor(180, 0, 0);
      color.gray = 0.5;
      compareHsbColors(color, [0, 0, 0.5, 1]);
    });

    test('Color.read(channels)', () {
      // TODO fix
      //var color = Color.read([0, 0, 1]);
      //compareRgbColors(color, [0, 0, 1, 1]);
      expect(false);
    });

    test('Cloning colors', () {
      var color = new RgbColor(0, 0, 0);
      expect(color.clone() != color);

      expect(new RgbColor(color) != color);
    });

    test('Color#convert', () {
      var color = new RgbColor(0, 0, 0);
      var converted = color.convert('rgb');
      expect(converted !== color);
      expect(converted.equals(color));
    });

    test('Saturation from black rgb', () {
      expect(new RgbColor(0, 0, 0).saturation == 0);
    });
  });
}