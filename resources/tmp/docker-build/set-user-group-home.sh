#!/bin/sh

# The goal of this script is to allow mapping of host user (the one running
# docker), to the desired container user, as to enable the use of more
# restrictive file permission (700 or 600)

group="";
gid="";
user="";
uid="";
home="";
no_login="";
ch_own_home="true";
shell="/bin/zsh";
fallback_shell="/bin/ash";

run() {
   if [ ! -x "${shell}" ]; 
   then
      shell="${fallback_shell}"
   fi

   # does a group with name = EGROUP already exist ?
   EXISTING_GID=$(getent group ${group} | cut -f3 -d ':')

   if [ ! -z $EXISTING_GID ]; then
      if [ $EXISTING_GID != ${gid} ]; then
         # change id of the existing group
         groupmod -g ${gid} ${group}
      fi
   else
      # create new group with id = EGID
   if 

      addgroup -g $(${gid} ${group})
   fi

   EXISTING_UID="$(getent passwd ${user} | cut -f3 -d ':')"

   if [ ! -z "$EXISTING_UID" ]; then
      if [ "$EXISTING_UID" != "${uid}" ]; then
         if [ ! -z ${home} ]; then
            if [ ${no_login} = "true" ]; then
               usermod -s /sbin/nologin -u "${uid}" -g "${group}" -d "${home}" "${user}"
            else
               usermod -s "${shell}" -u "${uid}" -g "${group}" -d "${home}" "${user}"
            fi
         else
            if [ ${no_login} = "true" ]; then
               usermod -s /sbin/nologin -u "${uid}" -g "${group}" "${user}"
            else
               usermod -s "${shell}" -u "${uid}" -g "${group}" "${user}"
            fi
         fi
      fi
   else
      if [ ! -z "${home}" ]; then
         if [ ${no_login} = "true" ]; then
            adduser -s /sbin/nologin -u "${uid}" -G "${group}" -h "${home}" -D "${user}"
         else
            adduser -s "${shell}" -u "${uid}" -G "${group}" -h "${home}" -D "${user}"
         fi
      else
         if [ ${no_login} = "true" ]; then
            adduser -s /sbin/nologin -u "${uid}" -G "${group}" -D "${user}"
         else
            adduser -s "${shell}" -u "${uid}" -G "${group}" -D "${user}"
         fi
      fi
   fi

   if [ ! -z "${home}" ]; then
      chown "${user}":"${group}" "${home}"
   fi
}

main() {
   while [ "$#" -gt 0 ]; do
      case "$1" in
         --username)
            user="$2";  
         ;;
         --uid)
            uid="$2";
         ;;
         --group)
            group="$2";
         ;;
         --gid)
            gid="$2";
         ;;
         --home)
            home="$2";
         ;;
         --no-login)
            no-login="true";
         ;;   
         --shell)
            shell="$2";
         ;;
      esac
   done
}

main "$@";

if [ -n ${no_login} ]; then
   shell="/sbin/nologin";
fi

if [ ! -x ${shell} ]; then
   shell="${fallback_shell}";
fi

run