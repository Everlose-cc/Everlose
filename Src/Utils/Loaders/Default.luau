--!nocheck

return function()
	warn('Loading Tabs...')
	wax.shared.Load('Tabs', 'Default', 'Main')()
	wax.shared.Load('Tabs', 'Default', 'Visuals')()
	warn('Tabs Loaded!')
	task.wait(1/60) -- Delay so that the tabs load before the functions, preventing errors from trying to access UI elements that haven't been created yet, and prevent crashe.
	warn('Loading Functions...')
	wax.shared.Load('Functions', 'Default', 'Main')()
	wax.shared.Load('Functions', 'Default', 'Visuals')()
	warn('Functions Loaded!')
end