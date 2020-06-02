# Created: 2020-05-30
# Revised: 2020-06-01

require_relative 'extbrain_data.rb'
require_relative 'writing_mode.rb'
$writing_mode = false
$exit = false

at_exit do
  $projects_and_tasks.save_data
  puts "Thank you for using extbrain. Have a good day!"
end

# #psudocode #TODO
def command_loop
  until $exit # We don't actually set this anymore, we just call exit straight up.
    $writing_mode ? print("wm> ") : print("> ")
    input = gets
    dispatch_user_input(input)
  end
end

# # psudocode TODO
def dispatch_user_input(input_string)
  input_string.rstrip! # remove trailing whitespace, which is at minimum a newline
  if $writing_mode
    unless 'exit' == input_string or '!!' == input_string
      writing_mode_input(input_string)
    else
      disable_writing_mode
    end
  else 
    case input_string 
    when '!!', 'wm'
      enable_writing_mode
     when 'exit'
#       $exit = true
       exit
     end
   end
end 



