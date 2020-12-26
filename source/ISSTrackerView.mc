using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Position;
using Toybox.System;
using Toybox.Graphics;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Timer;

class ISSTrackerView extends WatchUi.View {
	
	//user data
	var lat = null;
	var long = null;
	var alt = null;
	var connected = true;
	var failed = false;
	
	//ISS data
	var passCount = null; //how many passes in the next 2 days
	var allPasses = []; //the information on those passes
	var ISSvisible = false;
	var ISSPosition = null;
	var ISS = null;
	
	var attempts = 0;
	
	var ISSVisibilityRefresh = null;

    function initialize(info) {
        View.initialize();
        
        if(info != null) {
        	lat = info["user"]["lat"];
        	long = info["user"]["long"];
        	alt = info["user"]["alt"];
        	passCount = info["iss"]["passCount"];
        	allPasses = info["iss"]["allPasses"];
        	ISSvisible = info["iss"]["ISSvisible"];
        	ISSPosition = info["iss"]["ISSPosition"];
        }

        //re-check if ISS visible every 8 seconds and update position
    	ISSVisibilityRefresh = new Timer.Timer();
    	refreshISSOnScreen();
		ISSVisibilityRefresh.start(method(:refreshISSOnScreen), 8000, true);
		
		ISS = new WatchUi.Bitmap({:rezId=>Rez.Drawables.ISS});
    }
    
    function getInfo() {

    	var userData = {
    		"lat" => lat,
    		"long" => long,
    		"alt" => alt
    	};
    	
    	var issData = {
    		"passCount" => passCount,
    		"allPasses" => allPasses,
    		"ISSvisible" => ISSvisible,
    		"ISSPosition" => ISSPosition
    	};
    	
    	var info = {
    		"user" => userData,
    		"iss" => issData
    	};
    	
    	return info;
    }

    // Load your resources here
    function onLayout(dc) {
    	setLayout(Rez.Layouts.LoadingScreen(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        if(failed == true) {//tried to connect and failed
        
        	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        	dc.clear();
        	View.findDrawableById("text").setText("check connection");
        	View.findDrawableById("date").setText("and try again");
        	View.findDrawableById("nextViewing").setText("");
        	View.onUpdate(dc);
        
        } else if(connected != true || System.getDeviceSettings().phoneConnected != true) {//phone not connected
        	
        	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        	dc.clear();
        	View.findDrawableById("text").setText("Connection unavailable");
        	View.findDrawableById("date").setText("");
        	View.findDrawableById("nextViewing").setText("");
        	View.onUpdate(dc);
        
        } else if(passCount != null && ISSvisible != true && allPasses.size() > 0) {//visible passes coming up, not visible
        	
			View.findDrawableById("text").setText("");
			
			var timeStart = new Time.Moment(allPasses[0]["startUnix"]);
			var dateStart = Gregorian.info(timeStart, Time.FORMAT_MEDIUM);

			View.findDrawableById("nextViewing").setText("Next viewing:");
			if(!System.getDeviceSettings().is24Hour && dateStart.hour > 12) {
				View.findDrawableById("date").setText("" + dateStart.month + " " + dateStart.day + " " + (dateStart.hour - 12) + ":" + dateStart.min.format("%02d") + "pm");
			} else {
				View.findDrawableById("date").setText("" + dateStart.month + " " + dateStart.day + " " + dateStart.hour + ":" + dateStart.min.format("%02d") + "am");
			}
			
			View.onUpdate(dc);
			
			dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
			dc.setPenWidth(2);
			
			var minSide = dc.getWidth();
			if(dc.getHeight() < minSide) {
				minSide = dc.getHeight();
			}
			
			dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, minSide/2 - 1, Graphics.ARC_CLOCKWISE, 90, 90);
        
        } else if(passCount != null && ISSvisible != true && allPasses.size() == 0) {//no passes coming up
        	
        	View.findDrawableById("text").setText("no visible passes");
			View.findDrawableById("nextViewing").setText("");
			View.findDrawableById("date").setText("in the next 2 days");
			
			View.onUpdate(dc);
			
        	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
			dc.setPenWidth(6);
			
			var minSide = dc.getWidth();
			if(dc.getHeight() < minSide) {
				minSide = dc.getHeight();
			}
			
			dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, minSide/2 - 3, Graphics.ARC_CLOCKWISE, 90, 90);
        
        } else if(passCount != null && ISSvisible == true && ISSPosition != null) {//ISS visible
        		
	        	var minSide = dc.getWidth();
				if(dc.getHeight() < minSide) {
					minSide = dc.getHeight();
				}
				
				var ISSCoordinates = returnGraphFromCircle(ISSPosition["az"], ISSPosition["el"], minSide/2);
				ISS.setLocation(ISSCoordinates[0] - 17, ISSCoordinates[1] - 12);
				ISS.draw(dc);
				
				//-----
				dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
				dc.setPenWidth(2);
				
				dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, minSide/2 - 1, Graphics.ARC_CLOCKWISE, 90, 90);
				
				//print the N, S, E, W labels
				var fontDimentions = dc.getTextDimensions("W", Graphics.FONT_XTINY);
				dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
				dc.drawText(dc.getWidth() / 2, 2, Graphics.FONT_XTINY, "N", Graphics.TEXT_JUSTIFY_CENTER);
				dc.drawText(fontDimentions[0] + 2, (dc.getHeight() / 2) - (fontDimentions[1] / 2), Graphics.FONT_XTINY, "E", Graphics.TEXT_JUSTIFY_CENTER);
				dc.drawText(dc.getWidth() - fontDimentions[0] - 2, (dc.getHeight() / 2) - (fontDimentions[1] / 2), Graphics.FONT_XTINY, "W", Graphics.TEXT_JUSTIFY_CENTER);
				dc.drawText(dc.getWidth() / 2, dc.getHeight() - fontDimentions[1] - 2, Graphics.FONT_XTINY, "S", Graphics.TEXT_JUSTIFY_CENTER);      
        		  	
        } else {//loading data
        	
        	if(lat != null && long != null && alt != null) {
        		
        		View.findDrawableById("text").setText("Loading ISS Data");
	    		getISSVisualPasses();
	        
	        } else {
	        
	        	View.findDrawableById("text").setText("Loading User Location");
	        	        
	        }
	        
	        View.onUpdate(dc);
        }
    }
    
    function refreshISSOnScreen() {
    	var myAPI = "https://api.n2yo.com/rest/v1/satellite/positions/25544/" + lat + "/" + long + "/" + alt + "/1/&apiKey=ANT4SS-CZHGZG-QF6BWZ-4FQ2";
		Communications.makeWebRequest(
        	myAPI,
        	{
        	},
        	{
        		:method => Communications.HTTP_REQUEST_METHOD_GET,
        		:header => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
        		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        	},
        	method(:checkIfISSVisible)
        );
    }
    
    function validateData(d) {
		if(d["positions"] != null) {
			if(d["positions"][0] != null) {
				if(d["positions"][0]["azimuth"] != null && d["positions"][0]["elevation"] != null && d["positions"][0]["eclipsed"] != null) {
					if(d["positions"][0]["azimuth"] > 0 && d["positions"][0]["elevation"] > 1 && d["positions"][0]["eclipsed"] == false) {
						return true;
					}
				}
			}
		}
		return false;
	}
    
    function checkIfISSVisible(responseCode, data) {//sets the ISS's visibility
    	if(responseCode == 200 && data != null) {
    		if(validateData(data)) {
    			ISSPosition = {
    				"az" => data["positions"][0]["azimuth"],
    				"el" => data["positions"][0]["elevation"],
    			};
    			ISSvisible = true;
    		} else {
    			ISSPosition = null;
    			ISSvisible = false;
    		}
    	}
    	WatchUi.requestUpdate();
    }
    
    function getISSVisualPasses() {
    	var myAPI = "https://api.n2yo.com/rest/v1/satellite/visualpasses/25544/" + lat + "/" + long + "/" + alt + "/2/180/&apiKey=ANT4SS-CZHGZG-QF6BWZ-4FQ2";
    	System.println(myAPI);
        Communications.makeWebRequest(
        	myAPI,
        	
        	{
        	},
        	
        	{
        		:method => Communications.HTTP_REQUEST_METHOD_GET,
        		:header => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
        		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        	},
        	
        	method(:onReceive)
        );
    }
    
    function returnGraphFromCircle(GivenAz, GivenEl, r) {
    
    	var az = GivenAz.toFloat();
    	var el = GivenEl.toFloat();
    
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
    
    function onReceive(responseCode, data) {
    	if(responseCode == 200 && data != null) {
    		connected = true;
        	allPasses = [];
        	passCount = data["info"]["passescount"];
        	if(passCount != null) {
	        	if(passCount > 0) {
		        	for(var i = 0; i < passCount; i ++) {
		        		var myPass = {
		        			"startAz" => data["passes"][i]["startAz"],
		        			"maxAz" => data["passes"][i]["maxAz"],
		        			"endAz" => data["passes"][i]["endAz"],
		        			"startCompass" => data["passes"][i]["startAzCompass"],
		        			"maxCompass" => data["passes"][i]["maxAzCompass"],
		        			"endCompass" => data["passes"][i]["endAzCompass"],
		        			"startEl" => data["passes"][i]["startEl"],
		        			"maxEl" => data["passes"][i]["maxEl"],
		        			"endEl" => data["passes"][i]["endEl"],
		        			"startUnix" => data["passes"][i]["startUTC"],
		        			"maxUnix" => data["passes"][i]["maxUTC"],
		        			"endUnix" => data["passes"][i]["endUTC"],
		        			"duration" => data["passes"][i]["duration"],
		        			"mag" => data["passes"][i]["mag"],
		        		};
		        		allPasses.add(myPass);
		        	}
	        	}
        	}
        	WatchUi.requestUpdate();
    	} else {
    		if(responseCode == -104 || responseCode == 200) {
    			if(connected == true) {
    				connected = false;
    				WatchUi.requestUpdate();
    			}
    		} else {
    			if(attempts < 3) {
    				attempts++;
    				var timer = new Timer.Timer();
    				timer.start(method(:getISSVisualPasses), 3000, false);
    			} else {
    				failed = true;
    				WatchUi.requestUpdate();
    			}
    		}
    	}
    }
    
    function setPosition(info) {
    	var myLocation = info.position.toDegrees();
    	lat = myLocation[0];
    	long = myLocation[1];
    	alt = info.altitude;
		WatchUi.requestUpdate();
    }
    
    function getPasses() {
    	if(passCount == null) {
    		return null;
    	}
    	return allPasses;
    }

    function onHide() {
    	if(ISSVisibilityRefresh != null) {
    		ISSVisibilityRefresh.stop();
    	}
    }

}
