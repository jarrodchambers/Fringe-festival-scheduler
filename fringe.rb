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
	attr_accessor :num_avail, :title, :venue, :times, :attended, :time_attending
	
	def initialize(title, venue)
		@title = title
		@venue = venue
		@num_avail = 0
		@attended = false
		@times = []
		@time_attending = nil
	end
	
	def add_showtime(day, hour)
		@times.push(Showtime.new(day, hour))
		@num_avail += 1
	end
	
	def is_showtime(day, hour)
		@times.each do |time|
			if (time.day == day && time.hour == hour)
				return true
			end
		end
		return false
	end

	def print_showtimes
		@times.each do |time|
			puts "Playing at #{time.hour} on #{time.day}"
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
def schedule_next_show(unscheduled, scheduled)
	# Get first available showtime
	this_time =	unscheduled[0].get_available
	
	# If no time is available, return false to signal failure
	if !this_time then 
		# Find the play that has a common time with the most number of shows
		# Simple because scheduled just happens to be sorted by number of slots
		new_play = nil
		scheduled.each do |play|
			unscheduled[0].times.each do |time|
				if play.is_showtime(time.day, time.hour)
					this_time = time
					new_play = play
					break
				end
			end
			break if this_time
		end
		
		if !this_time
			return false # We give up! This is not likely to happen. We're more likely to end up in an infinite loop...
		end
					
		# Move that play to unscheduled and mark it unattended, and the common time unavailable
		new_play.attended = false
		new_play.time_attending = nil
		new_play.mark_time_unavailable(this_time.day, this_time.hour)
		unscheduled.push(scheduled.delete(new_play))
	end
	
	# Mark this time as attended
	this_time.mark_attended
	unscheduled[0].attended = true
	unscheduled[0].time_attending = this_time

	# Mark this slot as unattended for all other plays
	scheduled[0..-1].each do |play|
		play.mark_time_unavailable(this_time.day, this_time.hour)
	end
	unscheduled[1..-1].each do |play|
		play.mark_time_unavailable(this_time.day, this_time.hour)
	end
	
	scheduled.push(unscheduled.shift)
	
	# Return true if we're done, otherwise schedule the next play
	if 0 == unscheduled.length
		return true
	else
		return schedule_next_show(unscheduled, scheduled)
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
unscheduled = shows.values
scheduled = []

puts "Attempting to schedule #{unscheduled.length} plays."

# Sort by number of slots available
unscheduled = unscheduled.sort {|x,y| x.num_avail > y.num_avail ? 1 : -1}

# Keep scheduling until all the plays have slots assigned
success = schedule_next_show(unscheduled, scheduled)

# Sort by date and time before printing out
scheduled = scheduled.sort do |a,b|
  comp = (a.time_attending.day <=> b.time_attending.day)
  comp.zero? ? (a.time_attending.hour <=> b.time_attending.hour) : comp
end

# Print out plays
scheduled.each do |play|
	puts play.title, play.venue
	puts "Time attending: #{play.time_attending.hour} on #{play.time_attending.day}"
end
puts "Scheduled #{scheduled.length} plays."
