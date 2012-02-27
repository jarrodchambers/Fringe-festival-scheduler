#!/usr/bin/env ruby

# Created: February 12, 2012
# A little program to traverse the Ottawa Fringe schedule and
# find an attendance plan that lets someone see all the shows

# Class representing a showtime for a play
# available - this slot is still available to see a play
# attended - this slot has been chosen to attend the associated play

class Showtime
	attr_accessor :day, :hour, :available, :attended

	def initialize(day, hour)
		@day = day
		@hour = hour
		@available = true
		@attended = false
	end
	
	def mark_attended
		@attended = true
	end
	
	def mark_unavailable
		@available = false
	end
end

# Class representing a play
# num_avail - number of timeslots still available to choose from
# attended - whether or not a timeslot has been chosen for this play

class Show
	attr_accessor :num_avail, :title, :venue, :times, :attended
	
	def initialize(title, venue)
		@title = title
		@venue = venue
		@num_avail = 0;
		@attended = false;
		@times = [];
	end
	
	def add_showtime(day, hour)
		@times.push(Showtime.new(day, hour))
		@num_avail += 1
	end

	def print_showtimes
		@times.each do |time|
#			if (time.attended) then	puts "Attending at this time:" end
			if (time.attended)
				puts "Attending at this time:"
				puts "Playing at #{time.hour} on #{time.day}"
			end
		end
	end	
	
	def get_available
		@times.each do |time|
			if (time.available) then return time end
		end
		return nil
	end
	
	def mark_time_unavailable(day, hour)
		@times.each do |showtime|
			if ((day == showtime.day) && ((showtime.hour - hour).abs <= 0.5) && showtime.available)
				showtime.mark_unavailable
				@num_avail -= 1
			end
		end
	end
end

# Recursive implementation of the scheduling algorithm
# Will need failure handling in the case of a dead end in scheduling
def schedule_next_show(schedule, index)
	# Get first available showtime
	this_time =	schedule[index].get_available
	
	# If no time is available, return false to signal failure
	if !this_time then return false end
	
	# Mark this time as attended
	this_time.mark_attended
	schedule[index].attended = true

	# Mark this slot as unattended for all other plays
	schedule[index + 1..-1].each do |play|
		# puts "Checking #{play.title}"
		play.mark_time_unavailable(this_time.day, this_time.hour)
	end
	
	# Return true if we're done, otherwise schedule the next play
	index += 1
	if index == schedule.length
		return true
	else
		# Sort schedule by number of showtimes available
		schedule = schedule.sort {|x,y| x.num_avail > y.num_avail ? 1 : -1}
		return schedule_next_show(schedule, index)
	end
end

# Read shows from file in CSV format: title, venue, day, hour

shows = Hash.new

file = File.new("shows.txt", "r")
while (line = file.gets)
	# Parse lines into shows hash
	fields = line.split(/,/)
	if !shows[fields[0]] then shows[fields[0]] = Show.new(fields[0],fields[1]) end
	time = fields[3].split(/:/)
	hour = time[0].to_f + (time[1].to_f / 60.0)
	shows[fields[0]].add_showtime(fields[2],hour)
end

# Convert the hash to an array for easier manipulation
schedule = shows.values

# Sort by number of slots available
schedule = schedule.sort {|x,y| x.num_avail > y.num_avail ? 1 : -1}

# Keep scheduling until all the plays have slots assigned
success = schedule_next_show(schedule, 0)

# Print out plays
schedule.each do |play|
	puts play.title, play.venue
	play.print_showtimes
end
