
local originalMedPackOnTouch
originalMedPackOnTouch = Class_ReplaceMethod("MedPack", "OnTouch",
	function(self, recipient)
        self.expireTime = 0
		originalMedPackOnTouch(self, recipient)
	end)
	