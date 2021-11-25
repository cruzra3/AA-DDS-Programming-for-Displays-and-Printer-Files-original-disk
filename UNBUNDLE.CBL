       IDENTIFICATION DIVISION.
       PROGRAM-ID.  unbundlel.

      ******************************************************************
      * Copyright (c) 1994 Duke Communications International.
      * All rights reserved.
      ******************************************************************
       ENVIRONMENT DIVISION.
      *-----------------------------------------------------------------
       INPUT-OUTPUT SECTION.
       file-control.
           SELECT bundle-file ASSIGN TO DATABASE-bundle
                              ORGANIZATION IS SEQUENTIAL
                              ACCESS MODE IS SEQUENTIAL.
           SELECT source-file ASSIGN TO DATABASE-source
                              ORGANIZATION IS SEQUENTIAL
                              ACCESS MODE IS SEQUENTIAL.

      ******************************************************************
       DATA DIVISION.
      *-----------------------------------------------------------------
       FILE SECTION.
       FD  bundle-file.
       01  bundle-file-record           PIC X(100).

       FD  source-file.
       01  source-file-record           PIC X(92).
      *-----------------------------------------------------------------
       WORKING-STORAGE SECTION.
       01  bundle-structure.
           02  t-record.
               03  record-type          PIC X(1).
               03  FILLER               PIC X(1).
               03  free-form-text       PIC X(80).
               03  FILLER               PIC X(18).
           02  m-record REDEFINES t-record.
               03  record-type          PIC X(1).
               03  FILLER               PIC X(1).
               03  source-member        PIC X(10).
               03  FILLER               PIC X(1).
               03  source-type          PIC X(10).
               03  FILLER               PIC X(1).
               03  source-text          PIC X(52).
               03  FILLER               PIC X(14).
           02  w-record REDEFINES t-record.
               03  record-type          PIC X(1).
               03  FILLER               PIC X(1).
               03  source-member        PIC X(10).
               03  FILLER               PIC X(1).
               03  source-line          PIC X(80).
               03  FILLER               PIC X(7).
           02  c-record REDEFINES t-record.
               03  record-type          PIC X(1).
               03  FILLER               PIC X(1).
               03  source-member        PIC X(10).
               03  FILLER               PIC X(1).
               03  compile-command      PIC X(80).
               03  FILLER               PIC X(7).
           02  e-record REDEFINES t-record.
               03  record-type          PIC X(1).
               03  FILLER               PIC X(1).
               03  source-member        PIC X(10).
               03  FILLER               PIC X(88).

       01  command-string               PIC X(512).
       01  command-string-length        PIC S9(10)V9(5) PACKED-DECIMAL
           VALUE 512.

       01  source-structure.
           02  source-sequence          PIC X(6).
           02  source-date              PIC X(6).
           02  source-line              PIC X(80).

       01  exit-program-switch          PIC X(1).
           88  exit-program             VALUE "Y".
           88  stay-in-program          VALUE "N".

       01  command-to-execute.
           02  portion-1-of-command     PIC X(80).
           02  portion-2-of-command     PIC X(80).
           02  portion-3-of-command     PIC X(80).
           02  portion-4-of-command     PIC X(80).
           02  portion-5-of-command     PIC X(80).

       01  right-adjusted-library-name  PIC X(10).
       01  source-library-name-length   PIC S9(3) PACKED-DECIMAL.
       01  starting-position            PIC S9(3) PACKED-DECIMAL.
       01  sequence-number              PIC 9(6).
      *-----------------------------------------------------------------
       LINKAGE SECTION.
       01  qualified-bundle-file.
           02  bundle-file-name         PIC X(8).
           02  bundle-file-library      PIC X(10).
       01  qualified-source-file.
           02  source-file-name         PIC X(10).
           02  source-file-library      PIC X(10).

      ******************************************************************
       PROCEDURE DIVISION USING qualified-bundle-file
                                qualified-source-file.
      *----------------------------------------------------------------
       mainline.
           PERFORM initialize-program.
           PERFORM read-input-file UNTIL exit-program.
           PERFORM terminate-program.
           GOBACK.
      *----------------------------------------------------------------
       initialize-program.
           PERFORM open-bundle-file.
           SET stay-in-program TO TRUE.
           PERFORM right-adjust-library-name.
      *----------------------------------------------------------------
       open-bundle-file.
           MOVE SPACES TO command-string.
           STRING "OVRDBF FILE(BUNDLE) TOFILE(" DELIMITED BY SIZE
                  bundle-file-library           DELIMITED BY SPACE
                  "/"                           DELIMITED BY SIZE
                  bundle-file-name              DELIMITED BY SPACE
                  ")"                           DELIMITED BY SIZE
             INTO command-string
           END-STRING.
           CALL "QCMDEXC" USING command-string
                                command-string-length.
           OPEN INPUT bundle-file.
      *----------------------------------------------------------------
       right-adjust-library-name.
           MOVE 0 TO source-library-name-length.
           INSPECT source-file-library
              TALLYING source-library-name-length
              FOR CHARACTERS BEFORE INITIAL SPACE.
           MOVE SPACES TO right-adjusted-library-name.
           SUBTRACT source-library-name-length FROM 11
              GIVING starting-position.
           MOVE source-file-library TO
              right-adjusted-library-name ( starting-position: ).
      *----------------------------------------------------------------
       read-input-file.
           READ bundle-file
              INTO bundle-structure
              AT END
                 SET exit-program TO TRUE
              NOT AT END
                 PERFORM process-input-record
           END-READ.
      *----------------------------------------------------------------
       process-input-record.
           EVALUATE record-type OF t-record
               WHEN "T"
                  CONTINUE
               WHEN "M"
                  PERFORM new-member
               WHEN "W"
                  PERFORM write-source
               WHEN "C"
                  PERFORM compile-source
               WHEN "E"
                  PERFORM end-of-member
               WHEN OTHER
                  CONTINUE
           END-EVALUATE.
      *----------------------------------------------------------------
       new-member.
           MOVE SPACES TO command-string.
           STRING "ADDPFM FILE("            DELIMITED BY SIZE
                  source-file-library       DELIMITED BY SPACE
                  "/"                       DELIMITED BY SIZE
                  source-file-name          DELIMITED BY SPACE
                  ") MBR("                  DELIMITED BY SIZE
                  source-member OF m-record DELIMITED BY SPACE
                  ") SRCTYPE("              DELIMITED BY SIZE
                  source-type OF m-record   DELIMITED BY SPACE
                  ") TEXT("                 DELIMITED BY SIZE
                  source-text OF m-record   DELIMITED BY SIZE
                  ")"                       DELIMITED BY SIZE
             INTO command-string
           END-STRING.
           CALL "UNBUNDLEZ" USING command-string.

           MOVE SPACES TO command-string.
           STRING "OVRDBF FILE(SOURCE) TOFILE(" DELIMITED BY SIZE
                  source-file-library           DELIMITED BY SPACE
                  "/"                           DELIMITED BY SIZE
                  source-file-name              DELIMITED BY SPACE
                  ") MBR("                      DELIMITED BY SIZE
                  source-member OF m-record     DELIMITED BY SPACE
                  ")"                           DELIMITED BY SIZE
             INTO command-string
           END-STRING.
           CALL "QCMDEXC" USING command-string
                                command-string-length.

           OPEN OUTPUT source-file.
           MOVE 0 TO sequence-number.
      *----------------------------------------------------------------
       write-source.
           ADD 1 TO sequence-number.
           MOVE CORRESPONDING w-record TO source-structure.
           MOVE sequence-number TO source-sequence.
           MOVE "000000"        TO source-date.
           WRITE source-file-record
              FROM source-structure
           END-WRITE.
      *----------------------------------------------------------------
       compile-source.
           MOVE compile-command TO portion-1-of-command.

           READ bundle-file
              INTO bundle-structure
           END-READ.
           MOVE compile-command TO portion-2-of-command.

           READ bundle-file
              INTO bundle-structure
           END-READ.
           MOVE compile-command TO portion-3-of-command.

           READ bundle-file
              INTO bundle-structure
           END-READ.
           MOVE compile-command TO portion-4-of-command.

           READ bundle-file
              INTO bundle-structure
           END-READ.
           MOVE compile-command TO portion-5-of-command.

           MOVE SPACES TO command-string.
           STRING portion-1-of-command DELIMITED BY SIZE
                  portion-2-of-command DELIMITED BY SIZE
                  portion-3-of-command DELIMITED BY SIZE
                  portion-4-of-command DELIMITED BY SIZE
                  portion-5-of-command DELIMITED BY SIZE
             INTO command-string
           END-STRING.

           INSPECT command-string REPLACING
              ALL "LLLLLLLLLL" BY right-adjusted-library-name
              ALL "FFFFFFFFFF" BY source-file-name.

           IF command-string (1:3) = "OVR" THEN
              CALL "QCMDEXC" USING command-string
                                   command-string-length
           ELSE
              CALL "UNBUNDLEZ" USING command-string
           END-IF.
      *----------------------------------------------------------------
       end-of-member.
           CLOSE source-file.
           MOVE "DLTOVR FILE(SOURCE)" TO command-string.
           CALL "QCMDEXC" USING command-string
                                command-string-length.
      *----------------------------------------------------------------
       terminate-program.
           CLOSE bundle-file.
