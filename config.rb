# Created: 2020-06-06
# Revised: 2021-12-12

## Weekly review configuration

### Custom inboxes you want to check each week during your weekly review.
$custom_inboxes = [ "Work email", "Work chat client", "Voice memos on Apple Watch"] 



## 


## User options

# Extbrain uses color to denote when you need to do something or error states.
# For example, if you have a project with no next action -- it turns red.
# If you'd rather not have colors, you can turn this off with no (or limited)
# loss of function; for instance projects with no next action will be listed with !
# in front of them.
# TODO rename to $color ? 10/27
$color_only = true # If perfer b&w, if colorblind, or if using Windows, set this to false.


# Project list sorting - possible values:
#  :keyword
#  :creation [i.e. creation date, oldest first; see what you're avoiding
#             or may be taking awhile]
$project_sort = :keyword 
#$project_sort = :creation

# ISO standard is good, so is human-readable.
$time_formatting_string = "%Y-%m-%d %H:%M, %A."

# If true, running a second session of extbrain on the same computer
# will kill the first session.
$take_over_lock = true

## Developer options
$log_command_usage = false

## Saving options

$save_directory = "#{Dir.home}/.calmwater" # default for release
#$save_directory = "#{Dir.home}/pCloud Drive/calmwater-data" # for my personal use 
$save_file = "#{$save_directory}/calmwater.yaml"
$lockfile = "#{$save_directory}/lockfile.txt" 
$archive_file = "#{$save_directory}/#{Time.now.year}_calmwater_completed_or_deleted.yaml"

$data_file_command_usage = "#{$save_directory}/command_usage.yaml"




