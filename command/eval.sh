# -*- shell-script -*-
# Eval and Print commands.
#
#   Copyright (C) 2008, 2010, 2011 Rocky Bernstein <rocky@gnu.org>
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation; either version 2, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public License for more details.
#   
#   You should have received a copy of the GNU General Public License
#   along with this program; see the file COPYING.  If not, write to
#   the Free Software Foundation, 59 Temple Place, Suite 330, Boston,
#   MA 02111 USA.

# temp file for internal eval'd commands
typeset _Dbg_evalfile=$(_Dbg_tempname eval)

_Dbg_help_add eval \
'eval CMD 
eval 

In the first form CMD is a string CMD is a string sent to special
shell builtin eval. 

In the second form, use evaluate the current source line text

See also "print" and "set autoeval".'

_Dbg_do_eval() {

   print ". ${_Dbg_libdir}/lib/set-d-vars.sh" > $_Dbg_evalfile
   if (( $# == 0 )) ; then
       # FIXME: add parameter to get unhighlighted line, or 
       # always save a copy of that in _Dbg_sget_source_line
       typeset source_line
       _Dbg_get_source_line
       typeset source_line_save="$source_line"
       typeset highlight_save=$_Dbg_set_highlight
       _Dbg_set_highlight=0
       _Dbg_get_source_line

       # Were we called via ? as the suffix? 
       typeset suffix
       suffix=${_Dbg_orig_cmd[-1,-1]}
       if [[ '?' == "$suffix" ]] ; then
	   typeset extracted
	   _Dbg_eval_extract_condition "$source_line"
	   _Dbg_source_line="$extracted"
	   source_line_save="$extracted"
       fi

       print "$_Dbg_source_line" >> $_Dbg_evalfile
       _Dbg_msg "eval: ${source_line_save}"
       _Dbg_source_line="$source_line_save"
       _Dbg_set_highlight=$_Dbg_highlight_save
   else
       print "$@" >> $_Dbg_evalfile
   fi
   print '_Dbg_rc=$?' >> $_Dbg_evalfile
   typeset -i _Dbg_rc
   if [[ -t $_Dbg_fdi  ]] ; then
       _Dbg_set_dol_q $_Dbg_debugged_exit_code
       . $_Dbg_evalfile >&${_Dbg_fdi}
   else
       _Dbg_set_dol_q $_Dbg_debugged_exit_code
       . $_Dbg_evalfile
   fi
  ## _Dbg_msg "\$? is $_Dbg_rc"
  # We've reset some variables like IFS and PS4 to make eval look
  # like they were before debugger entry - so reset them now.
  _Dbg_set_debugger_internal
  _Dbg_last_cmd='eval'
  return 0
}

_Dbg_alias_add 'eval?' 'eval'
_Dbg_alias_add 'ev' 'eval'
_Dbg_alias_add 'ev?' 'eval'

# The arguments in the last "print" command.
typeset _Dbg_last_print_args=''

_Dbg_help_add print \
'print EXPRESSION -- Print EXPRESSION.

EXPRESSION is a string like you would put in a print statement.
See also eval.'

_Dbg_do_print() {
  typeset _Dbg_expr=${@:-"$_Dbg_last_print_args"}
  typeset dq_expr
  dq_expr=$(_Dbg_esc_dq "$_Dbg_expr")
  _Dbg_do_eval _Dbg_msg "$_Dbg_expr"
  _Dbg_last_cmd='print'
}

_Dbg_alias_add 'p' 'print'
