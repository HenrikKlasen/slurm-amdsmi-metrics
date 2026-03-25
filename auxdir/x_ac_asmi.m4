##*****************************************************************************
#  AUTHOR:
#    Advanced Micro Devices
#
#  SYNOPSIS:
#    X_AC_ASMI
#
#  DESCRIPTION:
#    Determine if AMD's RSMI API library exists
##*****************************************************************************

AC_DEFUN([X_AC_ASMI],
[

  # /opt/rocm is the current default location.
  # /opt/rocm/rocm_smi was the default location for before to 5.2.0
  # We will use a for loop to check for both.
  # Unless _x_ac_rsmi_dirs is overwritten with --with-rsmi
  _x_ac_asmi_dirs="/opt/rocm"

  AC_ARG_WITH(
    [asmi],
    AS_HELP_STRING(--with-asmi=PATH, Specify path to asmi installation),
    [AS_IF([test "x$with_asmi" != xno && test "x$with_asmi" != xyes],
           [_x_ac_asmi_dirs="$with_asmi"])])

  if [test "x$with_asmi" = xno]; then
     AC_MSG_NOTICE([support for amdsmi disabled])
  else
    AC_MSG_CHECKING([whether RSMI/ROCm in installed in this system])
    # Check for RSMI header and library in the default location
    # or in the location specified during configure
    #
    # NOTE: Just because this is where we are looking and finding the
    # libraries they must be in the ldcache when running as that is what the
    # card will be using.
    AC_MSG_RESULT([])
    for _x_ac_asmi_dir in $_x_ac_asmi_dirs; do
      cppflags_save="$CPPFLAGS"
      ldflags_save="$LDFLAGS"
      AMDSMI_FLAGS="-I$_x_ac_asmi_dir/include"
      CPPFLAGS="$AMDSMI_FLAGS"
      ASMI_LIB_DIR="$_x_ac_asmi_dir/lib"
      LDFLAGS="-L$ASMI_LIB_DIR"
      AS_UNSET([ac_cv_header_amd_smi_h])
      AS_UNSET([ac_cv_lib_amd_smi_rsmi_init])
      AS_UNSET([ac_cv_lib_amd_smi_dev_drm_render_minor_get])
      AC_CHECK_HEADER([amdsmi/amdsmi.h], [ac_asmi_h=yes], [ac_asmi_h=no])
      AC_CHECK_LIB([amdsmi], [amdsmi_init], [ac_asmi_l=yes], [ac_asmi_l=no])
      AC_CHECK_LIB([amdsmi64], [amdsmi_dev_drm_render_minor_get], [ac_asmi_version=yes], [ac_asmi_version=no])
      CPPFLAGS="$cppflags_save"
      LDFLAGS="$ldflags_save"
      if test "$ac_asmi_l" = "yes" && test "$ac_asmi_h" = "yes"; then
        if test "$ac_asmi_version" = "yes"; then
          ac_rsmi="yes"
          AC_DEFINE(HAVE_ASMI, 1, [Define to 1 if RSMI library found])
	  AC_SUBST(AMDSMI_FLAGS)
          break;
        fi
      fi
    done

    # Only print errors/wanrings if both _x_ac_rsmi_dirs don't work
    if test "$ac_asmi_l" = "yes" && test "$ac_asmi_h" = "yes"; then
      if test "$ac_asmi_version" != "yes"; then
        if test -z "$with_asmi"; then
          AC_MSG_WARN([upgrade to newer version of ROCm/rsmi])
        else
          AC_MSG_ERROR([upgrade to newer version of ROCm/rsmi])
        fi
      fi
    else
      if test -z "$with_asmi"; then
        AC_MSG_WARN([unable to locate librocm_smi64.so and/or amdsmi.h])
      else
        AC_MSG_ERROR([unable to locate libamdsmi.so and/or amdsmi.h])
      fi
    fi
  fi
  AM_CONDITIONAL(BUILD_RSMI, test "$ac_asmi" = "yes")
])
