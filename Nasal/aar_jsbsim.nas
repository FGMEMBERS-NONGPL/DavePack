#
#
# aar to use with jsbsim aircraft, using refuel properties available in JSBSim
#
#


var UPDATE_PERIOD = 0.3;

var ai_enabled = nil;
var refuelingN = nil;
var aimodelsN = nil;
var types = {};



var update_loop = func {
	# check for contact with tanker aircraft
	var tankers = [];
	if (ai_enabled) {
		var ac = aimodelsN.getChildren("tanker");
		var mp = aimodelsN.getChildren("multiplayer");

		foreach (var a; ac ~ mp) {
			if (!a.getNode("valid", 1).getValue())
				continue;
			if (!a.getNode("tanker", 1).getValue())
				continue;
			if (!a.getNode("refuel/contact", 1).getValue())
				continue;
			foreach (var t; a.getNode("refuel", 1).getChildren("type")) {
				var type = t.getValue();
				if (contains(types, type) and types[type])
					append(tankers, a);
			}
		}
	}

	if (size(tankers) > 0) refuelingN.setDoubleValue("1") 
		else refuelingN.setDoubleValue("0");

	
	settimer(update_loop, UPDATE_PERIOD);
}



setlistener("/sim/signals/fdm-initialized", func {
	if (contains(globals, "fuel") and typeof(fuel) == "hash")
		fuel.loop = func nil;       # kill $FG_ROOT/Nasal/fuel.nas' loop

	refuelingN = props.globals.initNode("/fdm/jsbsim/systems/refuel/contact", 0);
	aimodelsN = props.globals.getNode("ai/models", 1);
	

	foreach (var t; props.globals.getNode("systems/refuel", 1).getChildren("type"))
		types[t.getValue()] = 1;

	setlistener("sim/ai/enabled", func(n) ai_enabled = n.getBoolValue(), 1);
	update_loop();
});


