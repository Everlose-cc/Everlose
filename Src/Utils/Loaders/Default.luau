--!nocheck

return function()
	warn('Loading Tabs...')
	wax.shared.Load('Tabs', 'Main')()
	wax.shared.Load('Tabs', 'Visuals')()
	wax.shared.Load('Tabs', 'UISettings')()
	warn('Tabs Loaded!')
	task.wait(1/60) -- Delay so that the tabs load before the functions, preventing errors from trying to access UI elements that haven't been created yet, and prevent crashe.
	warn('Loading Functions...')
	wax.shared.Load('Functions', 'Main')()
	wax.shared.Load('Functions', 'Visuals')()
	wax.shared.Load('Functions', 'UISettings')()
	warn('Functions Loaded!')
end
