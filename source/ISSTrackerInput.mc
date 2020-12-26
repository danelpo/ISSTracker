using Toybox.System;
using Toybox.WatchUi;

class ISSTrackerInput extends WatchUi.BehaviorDelegate {
	
	var getPasses;
	var getInfo;
	
	function initialize(methodGetPasses, methodGetInfo) {
		BehaviorDelegate.initialize();
		getPasses = methodGetPasses;
		getInfo = methodGetInfo;
	}
	
	function onSelect() {
		var allPasses = getPasses.invoke();
		var info = getInfo.invoke();
		if(allPasses == null) {
			System.println("Passes not initiated yet");
		} else if(allPasses.size() > 0) {
			WatchUi.pushView(new ListView(allPasses[0], 1, allPasses.size()), new ListViewInput(1, allPasses, info), WatchUi.SLIDE_LEFT);
		}
		return true;
	}
}