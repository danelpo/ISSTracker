using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ListView extends WatchUi.View {

	var myPass;
	var index;
	var totalPasses;

    function initialize(pass , number, outOf) {
    	//how many list view
    	//all passes information
        View.initialize();
        myPass = pass;
        index = number;
        totalPasses = outOf;
    }

    function onLayout(dc) {
    	setLayout(Rez.Layouts.ListView(dc));
    }

    function onShow() {
    }

    function onUpdate(dc) {
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.clear();
    	
    	View.findDrawableById("number").setText(index + "/" + totalPasses);
    	
    	var timeStart = new Time.Moment(myPass["startUnix"]);
        var dateStart = Gregorian.info(timeStart, Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$",[dateStart.month, dateStart.day]);
        var hour = dateStart.hour;
        hour = hour > 12 && !System.getDeviceSettings().is24Hour ? hour - 12 : hour;
        var timeString = Lang.format("$1$:$2$",[hour, dateStart.min.format("%02d")]);
    	
    	View.findDrawableById("date").setText(dateString);
    	View.findDrawableById("time").setText(timeString);
    	
    	View.onUpdate(dc);
    	
    	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    	dc.setPenWidth(2);
    	
    	var smallerSide = dc.getHeight();
    	if(smallerSide > dc.getWidth()) {
    		smallerSide = dc.getWidth();
    	}
    	
    	//draw circle
    	var r = Math.round(smallerSide / 4);
    	dc.drawCircle(smallerSide / 2, smallerSide - (Math.round(r / 2 + 1) * 2), r);
    	var circleX = (dc.getWidth() - (smallerSide/2)) / 2;
    	var circleY = dc.getHeight() - (smallerSide/2);
    	var circleDiameter = r*2;
		
		//draw graph
		var startCoordinates = returnGraphFromCircle(myPass["startAz"], myPass["startEl"], r);
		var maxCoordinates = returnGraphFromCircle(myPass["maxAz"], myPass["maxEl"], r);
		var endCoordinates = returnGraphFromCircle(myPass["endAz"], myPass["endEl"], r);
		
		startCoordinates[0] = startCoordinates[0] + circleX;
		startCoordinates[1] = startCoordinates[1] + circleY;
		maxCoordinates[0] = maxCoordinates[0] + circleX;
		maxCoordinates[1] = maxCoordinates[1] + circleY;
		endCoordinates[0] = endCoordinates[0] + circleX;
		endCoordinates[1] = endCoordinates[1] + circleY;
		
		dc.setPenWidth(2);
		dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
		
		dc.drawLine(maxCoordinates[0], maxCoordinates[1], startCoordinates[0], startCoordinates[1]);
		dc.drawLine(maxCoordinates[0], maxCoordinates[1], endCoordinates[0], endCoordinates[1]);
		
		//draw N, S, E, W
		var fontDimentions = dc.getTextDimensions("W", Graphics.FONT_XTINY);
		dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
		dc.drawText(dc.getWidth() / 2, circleY + 2, Graphics.FONT_XTINY, "N", Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawText(circleX + fontDimentions[0] + 2, (circleDiameter / 2) - (fontDimentions[1] / 2) + circleY, Graphics.FONT_XTINY, "E", Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawText(circleX + circleDiameter - fontDimentions[0] - 2, circleY + (circleDiameter / 2) - (fontDimentions[1] / 2), Graphics.FONT_XTINY, "W", Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawText(dc.getWidth() / 2, circleDiameter + circleY - fontDimentions[1] - 2, Graphics.FONT_XTINY, "S", Graphics.TEXT_JUSTIFY_CENTER);
    }
    
    function returnGraphFromCircle(az, el, r) {
    
    	var azXPoint = Math.round(r*Math.cos(3.14*(az+90)/180) + r);
		var azYPoint = Math.round(r*Math.sin(3.14*(az+90)/180) - r) * -1;
		
		var theta = Math.asin((azXPoint - r)/r);
		theta = theta < 0 ? theta * -1 : theta;
		
		var disFromEdge = r * (el/90);
		
		var diffX = disFromEdge * Math.sin(theta);
		var diffY = disFromEdge * Math.cos(theta);
		
		var xPoint = azXPoint < r ? azXPoint + diffX : azXPoint - diffX;
		var yPoint = azYPoint < r ? azYPoint + diffY : azYPoint - diffY;
		
		var results = [xPoint, yPoint];
		return results;
    	
    }

    function onHide() {
    }
}