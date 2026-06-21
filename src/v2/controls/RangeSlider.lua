local Factory = require("v2/ControlFactory")
return function(ctx, parent, options) return Factory.create(ctx, parent, "range-slider", options) end
