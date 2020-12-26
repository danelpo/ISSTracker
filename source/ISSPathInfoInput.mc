using Toybox.System;
using Toybox.WatchUi;
using Toybox.Application;

class ISSPathInfoInput extends WatchUi.BehaviorDelegate {

	var next;
	var previous;

	var allPasses;
	var index;
	var info;
	
	function initialize(up, down, number, passes, myInfo) {
		BehaviorDelegate.initialize();
		next = up;
		previous = down;
		
		index = number;
		allPasses = passes;
		info = myInfo;
	}
	
	function onNextPage() {
		next.invoke();
		return true;
	}
	
	function onPreviousPage() {
		previous.invoke();
		return true;
	}
	
	function onSwipe(swipeEvent) {
        if(swipeEvent.getDirection() == WatchUi.SWIPE_RIGHT) {
        	WatchUi.pushView(new ListView(allPasses[index-1], index, allPasses.size()), new ListViewInput(index, allPasses, info), WatchUi.SLIDE_RIGHT);
        }
        return true;
    }
    
    function onBack() {
    	WatchUi.pushView(new ListView(allPasses[index-1], index, allPasses.size()), new ListViewInput(index, allPasses, info), WatchUi.SLIDE_RIGHT);
    	return true;
    }
}