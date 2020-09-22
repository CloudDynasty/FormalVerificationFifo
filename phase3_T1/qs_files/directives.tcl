# Enable all checks except the arithmetic checks
  autocheck enable
  autocheck disable -type ARITH*

# Change default severity
  autocheck report type -severity violation FSM*
  autocheck report type -severity info LOGIC_UNUSED

