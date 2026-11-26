# check_repo_for_usrds_data() reports paths only

    Code
      check_repo_for_usrds_data(".")
    Condition
      Warning:
      1 file in '.' may be USRDS data:
      * cohort.csv: identifier column (USRDS_ID)
      i Checked all files (not a git repository, or git not found).
      i Remove these files, or move them outside the project, or list them in '.gitignore'.

# check_repo_for_usrds_data() says when nothing is found

    Code
      result <- check_repo_for_usrds_data(".")
    Message
      v No files that look like USRDS data in '.'.
      i Checked 1 file: all files (not a git repository, or git not found).

# check_repo_for_usrds_data() stops on a missing folder

    Code
      check_repo_for_usrds_data("no-such-folder")
    Condition
      Error in `check_repo_for_usrds_data()`:
      ! Folder 'no-such-folder' does not exist.
      i Give the project folder to check.

