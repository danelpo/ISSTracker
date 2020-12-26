using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;

class ISSPathInfoView extends WatchUi.View {

	var page = 1;
	var pass;

    function initialize(myPass) {
    	View.initialize();
    	pass = myPass;
    	System.println(myPass);
    }

    function onLayout(dc) {
    	setLayout(Rez.Layouts.InfoView(dc));
    }

    function onShow() {
    }

    function onUpdate(dc) {
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.clear();
    	
    	if(page == 1) {//start
    		
    		var startUnix = new Time.Moment(pass["startUnix"]);
        	var startTime = Gregorian.info(startUnix, Time.FORMAT_MEDIUM);
        	var hour = startTime.hour;
        	if(!System.getDeviceSettings().is24Hour && hour > 12) {
        		hour = hour - 12;
        	}
    		View.findDrawableById("Time").setText("Start time: " + hour + ":" + startTime.min.format("%02d"));
			View.findDrawableById("Middle").setText("Duration: " + Math.round(pass["duration"]/60).toNumber() + " minutes");
			View.findDrawableById("Direction").setText("Start Direction: " + pass["startCompass"]);
    	
    	} else if(page == 2) {//end
    		
    		var endUnix = new Time.Moment(pass["endUnix"]);
        	var endTime = Gregorian.info(endUnix, Time.FORMAT_MEDIUM);
        	var hour = endTime.hour;
        	if(!System.getDeviceSettings().is24Hour && hour > 12) {
        		hour = hour - 12;
        	}
    		View.findDrawableById("Time").setText("End time: " + hour + ":" + endTime.min.format("%02d"));
			View.findDrawableById("Middle").setText("");
			View.findDrawableById("Direction").setText("End Direction: " + pass["endCompass"]);
    	
    	} else if(page == 3) {//max
    		
			var maxUnix = new Time.Moment(pass["maxUnix"]);
        	var maxTime = Gregorian.info(maxUnix, Time.FORMAT_MEDIUM);
        	var hour = maxTime.hour;
        	if(!System.getDeviceSettings().is24Hour && hour > 12) {
        		hour = hour - 12;
        	}
    		View.findDrawableById("Time").setText("Max time: " + hour + ":" + maxTime.min.format("%02d"));
			View.findDrawableById("Middle").setText("Eleavtion: " + Math.round(pass["maxEl"]).toNumber() + " degrees");
			View.findDrawableById("Direction").setText("Max Direction: " + pass["maxCompass"]);

    	}
    	
    	View.onUpdate(dc);
    }

    function onHide() {
    }
    
    function nextPage() {
    	System.println(page);
    	if(page < 3) {
    		page++;
    	}
    	System.println(page);
    	WatchUi.requestUpdate();
    }
    
    function previousPage() {
    	System.println(page);
    	if(page > 1) {
    		page--;
    	}
    	System.println(page);
    	WatchUi.requestUpdate();
    }
}