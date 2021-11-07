# Created: 2020-05-30
# Revised: 2021-11-07
# Methods to access data. Saving and loading of data.

require 'yaml'
require_relative 'project.rb'
require_relative 'task.rb'
require_relative '../config.rb'

## .find_task
## .update_task(replaced task object)
## .delete_task(sets deleted flag on that task object)
## .find_project


# you searched: andrew
# results:
#  1. (phone) call andrew and wish him a happy birthday
#  2. (someday/maybe) visit andrew and natalie and try their pizza
#  3. (computer) update the invite with a google meet instead


class ExtbrainData
  attr_reader :stats
  
  #  attr_reader :projects
  # todo accessors? NO, try to encapsulate.
  def initialize()
    puts 'GOTEH ERE'
    # todo
    load_data
    @somedaymaybe = Array.new unless @somedaymaybe
    @projects = Array.new unless @projects
    @tasks = Array.new unless @tasks
    @stats = Array.new unless @stats
    # format of stats:
    # each entry is an array: date, total all, total proj



    ## STATS
    total = number_of_projects + number_of_tasks
    
    one_day_in_seconds = 86400 # 24 * 60 * 60
    three_days_ago = Time.now.to_i - one_day_in_seconds * 3

    # If our most recent timestamp further away than 'three days ago' it's time for another snapshot.
    if @stats.any? # Handle nil, initial case.
      if @stats.last.first.to_i < three_days_ago
        @stats.append([Time.now, total, number_of_projects])
      end
    else
      puts "Initalizing stats..."
      @stats.append([Time.now, total, number_of_projects])
    end

    # Should printing really be in the data layer?
    puts " Total: #{total}. #{number_of_projects} projects and #{number_of_tasks} tasks."
    # TODO stats here regarding average and color coding if in DANGER ZONE? 
    print "Last weekly review: "


    if $last_weekly_review
      days = Time.now.yday - $last_weekly_review.yday
      if days >= 0
        case 
        when days < 4
          print `tput setaf 2` if $color_only # green
        when days < 7
          print `tput setaf 3` if $color_only # yellow
        when days >= 7 
          print `tput setaf 1` if $color_only # red
        end
        puts "#{days} days ago."
        print `tput sgr0` if $color_only # reset colors
      else
        puts $last_weekly_review.strftime($time_formatting_string)
        puts "Happy New Year(ish)! Start fresh with a weekly review, using the friendly 'wr' command."
        puts "The 'wr' command will only prompt you for things that /need/ review."
        puts
        puts
        puts
        puts "Plus running it will fix this edge case where I can't be arsed/don't know how to fix my algorithm around Time.now.yday."
        puts
        puts "But, in an effort to be useful, the last date of the weekly review was: #{$last_weekly_review.strftime($time_formatting_string)}"
        puts
      end 
    else
#      puts "NEVER! That's bad. Use the 'wr' command to fix."
      puts "No weekly review yet. Use 'wr' to fix this!"
    end
  end

  ## COUNTS
  
  def number_of_projects
    # Assumes the code that removes/archives the completed or deleted
    # projects continues to operate sucessfully on each save.
    projects.count
  end
  
  def number_of_tasks
    # Assumes the code that removes/archives the completed or deleted tasks
    # continues to operate sucessfully on each save.
    tasks_all = tasks.dup
    tasks_all << projects_with_tasks.collect { |proj| proj.tasks }
    tasks_all.flatten!
    tasks_all.count
  end

  def number_of_someday_maybe
# TODO    @somedaymaybe.count
    tasks.filter { |t| t.action_context == 'someday/maybe'.to_sym }
  end
  
  ## SEARCHING

  # s string
  # .downcase to ensure case-insensitive search
  def search(keyword, content, projects_only = nil)
    if keyword and content
      string = keyword + ' ' + content
    elsif keyword
      string = keyword
    end
    p = find_projects(string)
    t = find_tasks(string)
    if p.nil? and t.nil?
      nil
    elsif t.nil?
      p
    elsif p.nil? && projects_only
      [] # empty array
    elsif p.nil?
      t
    elsif projects_only
      p
    else
      t + p
    end 
  end

  def search_all # including notes, shortcut should be sa
    # should also not filter to life context.. hence 'all'
    # TODO if you implement this, need to account for completed and deleted at least as an option. grabbing those files and reading from disk.
    puts 'todo search_all'
  end
  
  ## TASKS

  def tasks
    tasks_all = @tasks.filter { |task| not (task.completed? or task.deleted?) }
    tasks_all << projects_with_tasks.collect { |proj| proj.tasks }
    tasks_all.flatten!
  end
  
  def new_task(title, action_context)
    task = Task.new(title, action_context)
    @tasks << task
    task
  end 

  # Returns array of tasks containing search_string
  def find_tasks(search_string)
    tasks.filter { |task| task.title.downcase.include?(search_string.downcase) }
  end
  
  def list_tasks(action_context = nil, keyword = nil)
    if keyword
      tasks_to_display = find_tasks(keyword)
    else
      tasks_to_display = tasks
    end 
    if action_context
      tsk = tasks_to_display.filter { |t| t.action_context == action_context.to_sym }
    else
      tsk = tasks_to_display
    end
    # sort by oldest on top. no .modified, so use .creation.
    # oldest on top to try to avoid procrastionation.
    # may also TODO try randomize sometimes to avoid me skipping the top 5 tasks everytime I look at the list
    tsk.sort_by! {|t| t.created } 
    tsk.each { |t| puts t }
    puts "No #{action_context} tasks, yet. Add one with 'pt' or 't':" if tsk.empty?
    puts "Usage: 't action_context title of your task'" if tsk.empty?
  end 

  
  ## PROJECTS

  def projects
    p = @projects.filter { |project| not (project.completed? or project.deleted?) }
  end

  # TODO filter for completed/deleted
  def projects_with_tasks
    proj_w_tasks = projects.filter { |project| not project.tasks.empty? }
  end
  
  def project_exist?(keyword)
    keyword = keyword.to_sym
    projects.detect { |project| project.keyword == keyword }
  end

  
  # Returns array of projects containing search_string
  def find_projects(search_string)
    projs = projects.filter { |project| project.title.downcase.include?(search_string.downcase) }
    projs << projects.filter { |project| project.keyword.to_s.downcase.include?(search_string.downcase) }
    projs.flatten!
    projs.uniq! # since we search both title and keyword, ensure we only list each project once
    if projs.empty?
      nil
    else
      projs
    end
  end

  def list_projects
    proj = projects # consider projects.dup if you use sort!
    unless proj.empty?
      ## Group by tags.
      ## TODO as of 2020-08-09, not using tags, so skip this
      ##    proj.sort { |a, b| a.tags <=> b.tags }
      case $project_sort
      when :keyword
        proj = proj.sort { |a, b| a.keyword <=> b.keyword }
      when :creation
        proj = proj.sort { |a, b| a.created <=> b.created }
      else
        # default is keyword sort
        proj = proj.sort { |a, b| a.keyword <=> b.keyword }
      end   
      puts "#{proj.count} projects:"
      puts
      proj.each { |p| p.puts_project }
    else
      puts "No projects, yet. Add one with 'p keyword title of your project'"
    end
  end 
  
  # # TODO decide if color coding useful for projects
  # # ideas include:
  # # yellow if review date > 7 days
  # # red if review date > 14 days
  

  def new_project(title, keyword)
    if project_exist?(keyword)
      puts "Project exists with that keyword: #{keyword}. Try again."
      success = nil
    else
      project = Project.new(title, keyword)
      @projects << project
      success = true
    end
    success
  end

  ## SAVING AND LOADING DATA
  
  def load_data
    # ensure save directory exists
    Dir.mkdir($save_directory) unless Dir.exist?($save_directory)

    # Handle multiple instances of extbrain
    if File.exist?($lockfile)
      $lockfile_locked = true
      $lockfile_pid = File.read($lockfile).to_i
      if $take_over_lock
        puts "Taking over existing lock..."
        begin
          Process.kill('TERM',$lockfile_pid)
          while (Process.getpgid($lockfile_pid) rescue nil)
            puts "Waiting on first process to exit..."
            sleep 0.5
          end
        rescue Errno::ESRCH
          puts "No process to kill, taking over lock gleefully..."
        end
        # reset flag so we can save changes on exit
        $lockfile_locked = false
      else # if no takeover
        exit
      end # takeover?
    end # if locked
    puts "Locking..."
    # be sure to keep 'w' to overwrite when we are taking over the lock
    File.open($lockfile, 'w') {|f| f.write(Process.pid) } 
    print "Loading files..."
    
    if File.exist?($save_file)
      all_five = YAML.load(File.read($save_file))
      # order is critical 
      @stats = all_five.pop
      # TODO s/m make $last_weekly_review not be a global
      $last_weekly_review = all_five.pop
      @somedaymaybe = all_five.pop
      @tasks = all_five.pop
      @projects = all_five.pop
      puts "loaded."
    else
      puts
      puts " File not found: #{$save_file}."
      puts ' If this is your first run you can ignore this message. Welcome!'
    end
  end

  # We save frequently.
  # We tell the user what we're doing if it's the final save of the session.
  # unlock == true means final save.
  def save_data(unlock=nil)
    # ensure save directory exists
    Dir.mkdir($save_directory) unless Dir.exist?($save_directory)
    # make sure it's our lock, else don't save
    if Process.pid == File.open($lockfile, &:gets).to_i
      print "Archiving completed and deleted tasks & projects..." if unlock 
      # If you ever edit this code, be sure to keep using @projects & @tasks; projects/tasks already exclude completed/deleted.
      to_archive = Array.new
      p = @projects.filter { |project| (project.completed? or project.deleted?) }
      to_archive << p unless p.empty?
      t = @tasks.filter { |task| (task.completed? or task.deleted?) }
      to_archive << t unless t.empty? 
      sm = @somedaymaybe.filter { |sm| sm.deleted? }
      to_archive << sm unless sm.empty? 
      
      unless to_archive.empty?
        File.open($archive_file, 'a') { |f| f.write(YAML.dump(to_archive)) }
        @projects = @projects - p # remove completed/deleted
        @tasks = @tasks - t # remove completed/deleted
        @somedaymaybe = @somedaymaybe - sm # remove completed/deleted
        puts "archival complete." if unlock
      end

      # order is critical
      all_five = [@projects, @tasks, @somedaymaybe, $last_weekly_review, @stats]
      print "Saving file..." if unlock 
      File.open($save_file, 'w') { |f| f.write(YAML.dump(all_five)) } 
      
      # if saving on exit
      if unlock
        File.delete($lockfile)
        puts "saved!" if unlock
      end # if saving on exit; if unlock
    else
      puts "Can't get lock, unable to save."
      system("touch extbrain_debug_unable_to_get_lock_not_saved") # in case no user there to see termination
    end # if it's our lock
  end
end

