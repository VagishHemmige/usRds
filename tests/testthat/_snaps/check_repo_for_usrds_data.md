# check_repo_for_usrds_data() reports paths only

    Code
      check_repo_for_usrds_data(".")
    Condition
      Warning:
      1 file in '.' may be USRDS data:
      * cohort.csv: identifier column (USRDS_ID)
      i Checked all files (not a git repository, or git not found).
      i Move these files outside the project, or list untracked ones in '.gitignore'.
      i '.gitignore' does not stop git tracking a file it already tracks; remove such files from git with `git rm --cached <file>`. Data already pushed needs separate remediation.

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

# check_repo_for_usrds_data() prints file names with braces as they are

    Code
      check_repo_for_usrds_data(".")
    Condition
      Warning:
      1 file in '.' may be USRDS data:
      * {not_code}.parquet: data file type (.parquet)
      i Checked all files (not a git repository, or git not found).
      i Move these files outside the project, or list untracked ones in '.gitignore'.
      i '.gitignore' does not stop git tracking a file it already tracks; remove such files from git with `git rm --cached <file>`. Data already pushed needs separate remediation.

