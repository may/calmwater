# Created: 2020-05-30
# Revised: 2021-10-28

require_relative 'common_project_task'

class Task < CommonProjectTask
  attr_reader :action_context
  
  def initialize(title, action_context)
    super(title)
    case action_context
    when 'f', 'fr', 'aof', 'aofr', 'afr', 'focus', 'resp'
      action_context = 'focus/resp'
    when 'c', 'co', 'com', 'comp'
      action_context = 'computer'
    when 'g', 'go', 'goa', 'goal', 'goals'
      action_context = 'goals'
    when 'j', 'jo', 'job'
      action_context = 'job'
    when 'jc', 'job-computer'
      action_context = 'job-computer'
    when 's/m', 'sm', 's', 'm'
      action_context = 'someday/maybe' # not really an action context, but potentially useful
    when 'w', 'wai', 'wait'
      action_context = 'waiting'
    else
      # leave action context unchanged
    end
    @action_context = action_context.to_sym
  end

  # default to true, since we won't always have a life context
  # needed in list_tasks in extbrain_data
  # might even remove this if b/c it's annoying but we'll see
  # was surpsied to find it  2020-07-15 
  def to_s
    if action_context == 'waiting'.to_sym
      "[#{action_context}: #{created.strftime($time_formatting_string)}] #{@title}"
    else
      "[#{action_context}] #{@title}"
    end
  end

  def view_task
    puts self # use to_s
    puts self.view_notes
  end
end



