open_project C:/Users/heyso/32bitrisc/32bitrisc.xpr

open_run impl_1

set timing_file "timing_report.txt"

report_timing_summary \
    -delay_type max \
    -max_paths 10 \
    -file $timing_file

puts "========================================"
puts "POWER ARCHITECTURE CHARACTERIZATION"
puts "========================================"
puts "Timing report written to:"
puts $timing_file
puts "========================================"

close_project