#!/usr/bin/perl --
#use strict;
use warnings;
use Config;
use FindBin qw($Bin);
use File::Basename;

my $DirectoryFiles;

#the BEGIN loop is needed to link our App to the desired Tcl/Tk binary
#it differs for Windows and macOS. In macOS we differentiate between developement and deployment since the relative path will change in the .app
BEGIN {
    our $dirFrameworks;

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
        $TCLpath = $BaseFolder . "/tcltk/bin";
        print "TCL BIN: " . $TCLpath . "\n";
        $ENV{'TCLLIBPATH'} = $TCLpath;    # path of tkConfig.sh

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
            $TCLpath = $appBaseDirectory . '/Frameworks/Tcl.framework/Tcl';

            print "DIR for Frameworks: $dirFrameworks\n";
            print "TCL: $TCLpath\n";

            $ENV{'PERL_TCL_DL_PATH'} = "$TCLpath";
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
            
            $dirFrameworks = "$appBaseDirectory/macOS/Frameworks";
            my $TCLpath           = "$dirFrameworks/Tcl.framework/Tcl";

            print "Dir Frameworks: $dirFrameworks" . "/\n";
            print "TCL: $TCLpath\n";

            $ENV{'PERL_TCL_DL_PATH'} = $TCLpath;
            $ENV{'TCLLIBPATH'}       = $dirFrameworks;
        }
    }
}

#The following is just a demo GUI to see the linking to a custom Tcl/Tk binary. It also prints some information about it.
use Tcl::pTk;
my $mw  = MainWindow->new();
my $int = $mw->interp;
my ($variable1, $variable2, $variable3, $text);

#icons
my $Png1 = $mw->Photo( -file =>  $DirectoryFiles ."/1.png");
my $Png2 = $mw->Photo( -file =>  $DirectoryFiles ."/2.png");

#styling - comment out if you want the native style
my $tk_dark = 0; #this can be read from OS
if ($^O eq 'MSWin32') {  
    my $tclStylingFile= $dirFrameworks . "/tcltk/lib/Azure/azure.tcl";
    $int->Eval("source {$tclStylingFile}");
    if ($tk_dark eq 1){
        $int->Eval('set_theme dark');
    }else{
        $int->Eval('set_theme light');
    }
}else{
    my $tclStylingFile= $dirFrameworks . "/Tcl.framework/Versions/8.6/Resources/Scripts/azure/azure.tcl";      
    $int->Eval("source $tclStylingFile");
    if ($tk_dark eq 1){
        $int->Eval('set_theme dark');
    }else{
        $int->Eval('set_theme light');
    }
}

my $FrameRibbon = $mw->ttkFrame()->pack(-side => 'top', -expand => '0', -fill => 'y', -pady=>20);
	my $Icon1 = $FrameRibbon->ttkCheckbutton(
		-image => $Png1,
		-text => "Open",
		-compound => 'top',
		-style =>'Toolbutton',
		-variable=>\$variable1, 
		-onvalue=>'1', 
		-offvalue=>'0',
		#-command => \&SetViewConferenceMode,
	)->pack(-side => "left");
	$Icon1->tooltip('Icon 1');
	my $Icon2 = $FrameRibbon->ttkCheckbutton(
		-image => $Png2,
		-text => "Add",
		-compound => 'top',
		-style =>'Toolbutton',
		-variable=>\$variable3, 
		-onvalue=>'1', 
		-offvalue=>'0',
		#-command => \&SetViewConferenceMode,
	)->pack(-side => "left");
	$Icon1->tooltip('Icon 2');

my $FrameBody = $mw->ttkFrame()->pack(-side => 'top', -expand => '0', -fill => 'y', -padx=> 20);


my $FrameForm = $FrameBody->ttkFrame()->pack(-side => 'top', -expand => '0', -fill => 'y', -pady=>6);
    $FrameForm->ttkLabel(-text=>"Name of entry ")->pack(-side => 'left', -expand=>0, -fill=>'both');
    $FrameForm->ttkEntry(-textvariable => \$text)->pack(-side => 'left', -expand=>0, -fill=>'both');

$FrameBody -> ttkCheckbutton(
    -variable=>\$variable2, 
    -text=>"Check button", 
    -onvalue=>'1', 
    -offvalue=>'0', 
)->pack(-side => "top", -anchor=>'w', -expand => 0, -fill => 'x');

my $FrameButtons = $mw->ttkFrame()->pack(-side => 'top', -expand => '0', -fill => 'y', -pady=>20);

my $but = $FrameButtons->ttkButton(
    -text    => "Close",
    -command => sub {
        $mw->destroy;
    }
)->pack();

$int->MainLoop;
