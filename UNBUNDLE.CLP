/*********************************************************************/
/*                                                                   */
/*  Program:  UNBUNDLEZ.                                             */
/*  Purpose:  Execute CL commands from UNBUNDLER or UNBUNDLEL.       */
/*                                                                   */
/*********************************************************************/
PGM  (                                                                +
       &cmdstr      /* Command string                              */ +
     )

   DCL  &caller      *CHAR    10
   DCL  &cmd_short   *CHAR    50
   DCL  &cmdlen      *DEC   ( 15 5 )  512
   DCL  &cmdstr      *CHAR   512
   DCL  &msgkey      *CHAR     4
   DCL  &sender      *CHAR    80

   /*                                                                 +
    | Execute the requested command.  If the command fails, send a    +
    | diagnostic message to the caller of UNBUNDLER or UNBUNDLEL.     +
   */
   CALL  qcmdexc  (                                                   +
                    &cmdstr      /* Command string                 */ +
                    &cmdlen      /* Command length                 */ +
                  )
   MONMSG  cpf0000  EXEC( DO )
      /* Find this program's caller name */
      SNDPGMMSG  MSG( 'Dummy' )                                       +
                 TOPGMQ( *PRV * )                                     +
                 MSGTYPE( *INFO )                                     +
                 KEYVAR( &msgkey )
      RCVMSG  PGMQ( *PRV * )                                          +
              MSGKEY( &msgkey )                                       +
              WAIT( 0 )                                               +
              RMV( *YES )                                             +
              SENDER( &sender )
      CHGVAR  &caller  %SST( &sender 56 10 )

      CHGVAR  &cmd_short  %SST( &cmdstr 1 50 )

      SNDPGMMSG  TOPGMQ( *PRV &caller )                               +
                 MSGID( cpf9898 )                                     +
                 MSGF( qcpfmsg )                                      +
                 MSGDTA( 'Execution of compile command beginning'     +
                         *BCAT &cmd_short *BCAT                       +
                         'failed.  See job log for details' )         +
                 MSGTYPE( *DIAG )
   ENDDO

ENDPGM
