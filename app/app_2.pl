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
            
            #my $dirFrameworks = "$appBaseDirectory/macOS/FrameworksM1";#if you are using an arm macOS
            my $dirFrameworks = "$appBaseDirectory/macOS/Frameworks";#if you are using a intel macOS
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
my $window  = MainWindow->new();
$window->title("CodTubify");
$window->geometry("930x506");
$window->configure(-bg => "#171435");

my $int = $window->interp;

my $canvas = $window->Canvas(
    -bg => '#171435',
    -height => 506,
    -width => 930,
    -bd => 0,
    -highlightthickness => 0,
    -relief => 'ridge'
)->place(
    -x => 0,
    -y => 0
);

my $background_image = $window->Photo(
    -file => "image_1.png"
);

my $image_1 = $canvas->createImage(
    566.0,
    253.0,
    -image => $background_image
);

my $page_navigator = $canvas->createText(
    251.0,
    37.0,
    -anchor => 'nw',
    -text => "Home",
    -fill => "#171435",
    -font => "{Montserrat Bold} -26"
);


$int->MainLoop;