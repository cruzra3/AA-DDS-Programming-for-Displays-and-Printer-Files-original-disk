/* Copyright 1994 (c) Duke Communications International              */
/* All rights reserved                                               */
/*                                                                   */
CMD  'Unbundle NEWS 3X/400 Code'

   PARM  bundle  q1                                                   +
         MIN( 1 )                                                     +
         PROMPT( 'Bundle file' )

   PARM  srcfile  q2                                                  +
         MIN( 1 )                                                     +
         PROMPT( 'Target source file' )


Q1:                                                                   +
      QUAL  *NAME  8                                                  +
            MIN( 1 )                                                  +
            EXPR( *YES )
      QUAL  *NAME  10                                                 +
            MIN( 1 )                                                  +
            EXPR( *YES )                                              +
            PROMPT( 'Library' )
Q2:                                                                   +
      QUAL  *NAME  10                                                 +
            MIN( 1 )                                                  +
            EXPR( *YES )
      QUAL  *NAME  10                                                 +
            MIN( 1 )                                                  +
            EXPR( *YES )                                              +
            PROMPT( 'Library' )
