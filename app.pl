#!/usr/bin/perl --
use strict;
use warnings;
use Config;
use FindBin qw($Bin);
use File::Basename;

#the BEGIN loop is needed to link our App to the desired Tcl/Tk binary
#it differs for Windows and macOS. In macOS we differentiate between developement and deployment since the relative path will change in the .app
BEGIN {
    if ( $Config{osname} eq "MSWin32" ) {
        print "WINDOWS version\n";
        $ENV{'PERL_TCL_DL_PATH'} = $Bin . "\\tcltk\\bin\\tcl86t.dll";
        $ENV{PATH} = $Bin . "\\tcltk\\bin" . ';' . $ENV{PATH};
    }
    else {
        print "macOS version\n";
        #For macOS Tcl/Tk will be in a different relative path in the final .app
        if ( $ENV{PAR_0} ) {
            print ".APP VERSION!\n";
            
            my $appBaseDirectory = dirname($Bin);
            my $dirFrameworks    = $appBaseDirectory . '/Frameworks';
            my $TCL = $appBaseDirectory . '/Frameworks/Tcl.framework/Tcl';

            $ENV{'PERL_TCL_DL_PATH'} = $TCL;
            $ENV{'TCLLIBPATH'}       = $dirFrameworks;
        }
        else {
            print "DEVELOPEMENT VERSION!\n";

            my $dirFrameworks = 'Frameworks';
            my $TCL           = "$dirFrameworks/Tcl.framework/Tcl";

            $ENV{'PERL_TCL_DL_PATH'} = $TCL;
            $ENV{'TCLLIBPATH'}       = $dirFrameworks;
        }
    }
}

#The following is just a demo GUI to see the linking to a custom Tcl/Tk binary. It also prints some information about it.
use Tcl::pTk;
my $mw  = MainWindow->new();

my $int = $mw->interp;
my $tcl_version   = $int->Eval('info tclversion');
my $tk_patchLevel = $int->Eval('info patchlevel');
my $library = $int->Eval('info library');

my $text = $mw->Text()->pack();
$text->insert(
    "end", 
"
tcl_version      $tcl_version
tk_patchLevel    $tk_patchLevel
library    $library
Tcl::pTk $Tcl::pTk::VERSION
Tcl $Tcl::VERSION
\$^V $^V
\$] $]
"
);

my $but = $mw->ttkButton(
    -text    => "Close",
    -command => sub {
        $mw->destroy;
    }
)->pack();

$int->MainLoop;
