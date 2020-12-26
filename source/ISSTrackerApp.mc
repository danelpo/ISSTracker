using Toybox.Application;
using Toybox.Timer;

class ISSTrackerApp extends Application.AppBase {

	var positionView;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }
    
    function onPosition(info) {
        positionView.setPosition(info);
    }
    
    function getPasses() {
    	return positionView.getPasses();
    }
    
    function getInfo() {
    	return positionView.getInfo();
    }

    // Return the initial view of your application here
    function getInitialView() {
    	positionView = new ISSTrackerView(null); 
        return [ positionView, new ISSTrackerInput(method(:getPasses), method(:getInfo))];
    }

}