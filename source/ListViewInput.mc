using Toybox.System;
using Toybox.WatchUi;
using Toybox.Application;

class ListViewInput extends WatchUi.BehaviorDelegate {

	var allPasses = null;
	var index = null;
	
	var positionView;
	var pathInfo;
	var info = null;
	
	function initialize(number, passes, myInfo) {
		BehaviorDelegate.initialize();
		allPasses = passes;
		index = number;
		info = myInfo;
	}
	
	function onSelect() {
		pathInfo = new ISSPathInfoView(allPasses[index-1]);
		WatchUi.pushView(pathInfo, new ISSPathInfoInput(method(:nextPage), method(:previousPage), index, allPasses, info), WatchUi.SLIDE_LEFT);
		return true;
	}
	
	function nextPage() {
		return pathInfo.nextPage();
	}
	
	function previousPage() {
		return pathInfo.previousPage();
	}
	
	function onNextPage() {
		if(index < allPasses.size()) {
			WatchUi.pushView(new ListView(allPasses[index], index+1, allPasses.size()), new ListViewInput(index+1, allPasses, info), WatchUi.SLIDE_UP);
			System.println("going DOWN");
		} else {
		System.println("NOT going DOWN");
		}
		return true;
	}
	
	function onPreviousPage() {
		if(index > 1) {
			WatchUi.pushView(new ListView(allPasses[index - 2], index-1, allPasses.size()), new ListViewInput(index-1, allPasses, info), WatchUi.SLIDE_DOWN);
			System.println("going UP");
		} else {
			System.println("NOT going UP");
		}
		return true;
	}
	
	function onSwipe(swipeEvent) {
        if(swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
        	positionView = new ISSTrackerView(info); 
        	WatchUi.pushView(positionView, new ISSTrackerInput(method(:getPasses), method(:getInfo)), WatchUi.SLIDE_RIGHT);
        	Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
        }
        return true;
    }
    
    function onBack() {
    	positionView = new ISSTrackerView(info); 
    	WatchUi.pushView(positionView, new ISSTrackerInput(method(:getPasses), method(:getInfo)), WatchUi.SLIDE_RIGHT);
    	Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));
    	return true;
    }
    
    function getInfo() {
    	return info;
    }
    
    function onPosition(info) {
        positionView.setPosition(info);
    }
    
    function getPasses() {
    	return allPasses;
    }
}