# load_usrds_file() stops when no files are mapped

    Code
      load_usrds_file("PAYHIST")
    Condition
      Error in `load_usrds_file()`:
      ! No USRDS files are mapped yet.
      i Run `set_USRDS_wd("<your USRDS folder>")` first.

# load_usrds_file() stops on an unknown file key

    Code
      load_usrds_file("NOT_A_FILE")
    Condition
      Error in `load_usrds_file()`:
      ! File key 'NOT_A_FILE' not found.

