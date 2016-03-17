before_fork do
	PumaWorkerKiller.config do |config|
		config.ram = 4096
		config.frequency = 5
		config.percent_usage = 0.8
		config.rolling_restart_frequency = false
	end
	PumaWorkerKiller.start
end

threads 4,8
workers 8
preload_app!

