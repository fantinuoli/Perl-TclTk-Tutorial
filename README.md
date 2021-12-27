# Perl-TclTk-Crossplatform-UI

## Deploy Perl + Tcl/Tk applications on Windows and macOS

This is a tutorial on how to use Perl and Tcl/Tk (not to be confused with Perl/Tk) and create UI-based Perl+Tcl/Tk applications deploying them on Windows and macOS as stand-alone .exe or .app.

Advantages of Tcl/Tk over Perl/Tk

- It runs on Windows, macOS, and Linux and it looks native
- It is actively mantained (https://core.tcl-lang.org/tk/reportlist). For example Tk was recently adapted for macOS Mojave/Catalina/Monterey.
- It is the basic GUI toolkit of Python, so it has a large number of users
- Similar/Same syntax as Perl/Tk

Disadvantages of Tcl/Tk

- Binding for Perl (Tcl::pTk) seems not to be used very much, so not a big community to help
- Not very documented
- You need to install Tcl/Tk separately (different to Perl/Tk which is just a normal Perl module), and learn how to deploy it in an application if you are gonna to distribute it

In a nutshell, the GUI application will be packed in an executable using [pp](https://metacpan.org/pod/pp) and will be distributed/shipped togheter with the Tcl/Tk binary. 

## Installation
### Windows
- Install [Strawberryperl](http://strawberryperl.com/). Since all modern Windows PC are 64, target the 64bit version if no other requirements must be met.
- Install the latest binary Tcl/Tk distribution, for example [BAWT](http://www.bawt.tcl3d.org/). This will install Tcl/Tk in C:
- Install the Perl module Tcl (needed by Tcl::pTk to communicate with the Tcl/Tk installation): `cpanm Tcl`
- Install the Perl module [Tcl::pTk](https://metacpan.org/release/Tcl-pTk): `cpanm Tcl::pTk`
- Install the Perl module [pp](https://metacpan.org/pod/pp) in order to create an executable of your Perl program: `cpanm pp`

### macOS
- Install a recent version of Perl: [Perlbrew](http://www.perlbrew.pl)
- Tcl/Tk (obsolete version) is already installed on most macOS. For the purpose of the next steps, this old version will suffice
- Install the Perl module Tcl (needed by Tcl::pTk to communicate with the Tcl/Tk installation): `cpanm Tcl`
- Install the Perl module [Tcl::pTk](https://metacpan.org/release/Tcl-pTk): `cpanm Tcl::pTk`
- Install the Perl module [pp](https://metacpan.org/pod/pp) in order to create an executable of your Perl program: `cpanm pp`

### Explore Tcl/Tk from Perl
To test that Perl can use the installed version of Tcl/Tk, simply start the Demo widget. Open a terminal and digit `widgetTclpTk`. If a demo widget is shown, Perl is now using the Tcl/Tk installation on your machine. 

## Developement
### Organizing the App structure
Create a folder structure as described below:
1. Main APP folder called 'MyApp':
   - MyApp.pl + modules
   - a folder called 'Files' containing images, configuration files, etc
   - a folder called 'TclTk' containing the bare bone Tcl/Tk binary for Windows (see below)
   - a folder called 'Frameworks' containing the Tcl/Tk Frameworks for macOS (see below)

### Download/Compile a Tcl/Tk installation to integrate and ship with the APP
For deployment we need a 'portable' Tcl/Tk installation (in order to include it with the APP) and tell Perl, i.e. the Tcl module, to use it instead of the installed version (which is normally not present on the user's machine).  

#### Windows
You can compile Tcl/Tk from source or use a pre-compiled binary, for example from [Ashok](https://sourceforge.net/projects/magicsplat/files/barebones-tcl/). Download it, rename the containing folder 'TclTk' and put it in the APP structure indicated above

#### macOS
Compilation of the Tcl/Tk Frameworks is super easy on macOS. Download the [Tcl/Tk Sources](https://www.tcl.tk/software/tcltk/download.html). In Terminal:
`````
export ver="8.6.11"
make -C tcl8.6.11/macosx embedded CFLAGS_OPTIMIZE="-O2 -mmacosx-version-min=10.11"
make -C tk8.6.11/macosx embedded CFLAGS_OPTIMIZE="-O2 -mmacosx-version-min=10.11"
`````

(Detailed information are available in the README file of macOS directory of distribution)
This will generate a `Tcl.framework` and a `Tk.framework`. Put them in the folder 'Frameworks' inside our APP structure indicated above.

### Linking the Application to the desired (portable) Tcl/Tk installation
Run the barebone script `app.pl` to see Perl calling the Tcl/Tk version in our data structure. A GUI will popup with information about the linked Tcl/Tk.







