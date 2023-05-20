set history save on
set print pretty on
set pagination off
set confirm off
# See https://sourceware.org/gdb/onlinedocs/gdb/Background-Execution.html#Background-Execution
# allow background execution when running commands.
set mi-async off
# let unblocked thread blocked continue running.
set non-stop off
# limit how much data we show with print
set print max-depth 3

# From https://stackoverflow.com/questions/3832964/
define ostr
    call (void)operator<<(std::cerr, $arg0)
    call (void)fflush(0)
    print "\n"
end

define ostrx
    call (void)$arg0.print(std::cerr, 0, 2)
    call (void)fflush(0)
    print "\n"
end
