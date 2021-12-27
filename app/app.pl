#!/usr/bin/perl --
use strict;
use warnings;
use Config;
use FindBin qw($Bin);
use File::Basename;

my $DirectoryFiles;

#the BEGIN loop is needed to link our App to the desired Tcl/Tk binary
#it differs for Windows and macOS. In macOS we differentiate between developement and deployment since the relative path will change in the .app
BEGIN {
    if ( $Config{osname} eq "MSWin32" ) {
        print "This is WINDOWS\n";
        print "Base Installation Dir: $Bin\n";
        my $BaseFolder;

        if ( $ENV{PAR_0} ) {
            print "DEPLOYMENT VERSION\n";
            $BaseFolder = $Bin;
        }
        else {
            print "DEVELOPEMENT VERSION\n";
            my $myFullPath = dirname($Bin);
            $BaseFolder = $myFullPath . "/WIN";
        }

        #Linking TCL/TK DLL
        my $pathTclDLL = $BaseFolder . "/tcltk/bin/tcl86t.dll";
        print "TCL DLL: " . $pathTclDLL . "\n";
        $ENV{'PERL_TCL_DL_PATH'} = $pathTclDLL;
        my $pathTclBin = $BaseFolder . "/tcltk/bin";
        print "TCL BIN: " . $pathTclBin . "\n";
        $ENV{'TCLLIBPATH'} = $pathTclBin;    # path of tkConfig.sh

        #Directory with application files
        $DirectoryFiles = $BaseFolder . "/files";
        print "Files: $DirectoryFiles\n";
    }
    else {
        print "This is macOS\n";

        #For macOS, Tcl/Tk will be in a different relative path in the final .app
        if ( $ENV{PAR_0} ) {
            print "DEPLOYMENT VERSION!\n";
            
            #detecting base directory of .app
            print "Directory script/executable: $Bin\n";
            my $appBaseDirectory = dirname($Bin);
            print "Directory .app \"Contents\": $appBaseDirectory\n";

            print "Loading Frameworks\n";
            my $dirFrameworks = $appBaseDirectory . '/Frameworks';
            my $Tcl = $appBaseDirectory . '/Frameworks/Tcl.framework/Tcl';

            print "DIR for Frameworks: $dirFrameworks\n";
            print "TCL: $Tcl\n";

            $ENV{'PERL_TCL_DL_PATH'} = "$Tcl";
            $ENV{'TCLLIBPATH'}       = $dirFrameworks;    # path of tkConfig.sh

            $DirectoryFiles = "$appBaseDirectory/Resources/files";
            print "Dir for application files: $DirectoryFiles\n";
        }
        else {
            print "DEVELOPEMENT VERSION!\n";
            
            #detecting base directory
            print "Dir script/executable: $Bin\n";
            my $appBaseDirectory = dirname($Bin);
            print "Dir project: $appBaseDirectory\n";
            $DirectoryFiles = "$appBaseDirectory/macOS/files";
            print "Dir application files: $DirectoryFiles\n";   
            
            my $dirFrameworks = "$appBaseDirectory/macOS/Frameworks";
            my $Tcl           = "$dirFrameworks/Tcl.framework/Tcl";

            print "Dir Frameworks: $dirFrameworks" . "/\n";
            print "TCL: $Tcl\n";

            $ENV{'PERL_TCL_DL_PATH'} = $Tcl;
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
