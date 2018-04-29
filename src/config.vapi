/**
 * Copyright (C) 2011 Canonical Ltd 
 * Copyright (C) 2018 Keith Mitchell 
*/

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace Config
{
  public const string GETTEXT_PACKAGE;
  public const string LOCALEDIR;
  public const string VERSION;
  public const string PKGDATADIR;
  public const string THEME_DIR;
}