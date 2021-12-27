if {[info exists ::scrolledframe::version]} { return }
namespace eval ::scrolledframe {
    # beginning of ::scrolledframe namespace definition
    
    namespace export scrolledframe
    
    # ==============================
    #
    # scrolledframe
    #
    # a scrolled frame
    #
    # (C) 2003, ulis
    #
    # NOL licence (No Obligation Licence)
    #
    # ==============================
    
    package provide Scrolledframe 0.9
    
    # --------------
    #
    # create a scrolled frame
    #
    # --------------
    # parm1: widget name
    # parm2: options key/value list
    # --------------
    proc scrolledframe {w args} {
        variable {}
        # create a scrolled frame
        ttk::frame $w
        # trap the reference
        rename $w ::scrolledframe:w:$w
        # redirect to dispatch
        interp alias {} $w {} ::scrolledframe::dispatch $w
        # create scrollable internal frame
        ttk::frame $w.scrolled
        # place it
        place $w.scrolled -in $w -x 0 -y 0
        # init internal data
        set ($w:vheight) 0
        set ($w:vwidth) 0
        set ($w:vtop) 0
        set ($w:vleft) 0
        set ($w:xscroll) ""
        set ($w:yscroll) ""
        # configure
        if {$args != ""} { eval dispatch $w config $args }
        # bind <Configure>
        bind $w <Configure> [namespace code [list vresize $w]]
        bind $w.scrolled <Configure> [namespace code [list resize $w]]
        # return widget ref
        return $w
    }
    
    # --------------
    #
    # dispatch the trapped command
    #
    # --------------
    # parm1: widget name
    # parm2: operation
    # parm2: operation args
    # --------------
    proc dispatch {w cmd args} {
        variable {}
        switch -glob -- $cmd {
            con*    {
                # config
                eval [linsert $args 0 config $w]
            }
            xvi*    {
                # new xview operation
                eval [linsert $args 0 xview $w]
            }
            yvi*    {
                # new yview operation
                eval [linsert $args 0 yview $w]
            }
            default {
                # other operations
                eval [linsert $args 0 w:$w $cmd]
            }
        }
    }
    
    # --------------
    # configure operation
    #
    # configure the widget
    # --------------
    # parm1: widget name
    # parm2: options
    # --------------
    proc config {w args} {
        variable {}
        set options {}
        set flag 0
        foreach {key value} $args {
            switch -glob -- $key {
                -xsc*   {
                    # new xscroll option
                    set ($w:xscroll) $value
                    set flag 1
                }
                -ysc*   {
                    # new yscroll option
                    set ($w:yscroll) $value
                    set flag 1
                }
                default { lappend options $key $value }
            }
        }
        # check if needed
        if {!$flag || $options != ""} {
            # call frame config
            eval [linsert $options 0 ::scrolledframe:w:$w config]
        }
    }
    
    # --------------
    # resize proc
    #
    # resize the scrolled part
    # --------------
    # parm1: widget name
    # --------------
    proc resize {w} {
        variable {}
        # compute new height & width
        set ($w:vheight) [winfo reqheight $w.scrolled]
        set ($w:vwidth) [winfo reqwidth $w.scrolled]
        # resize the scroll bars
        vresize $w
    }
    
    # --------------
    # vresize proc
    #
    # resize the visible part
    # --------------
    # parm1: widget name
    # --------------
    proc vresize {w} { xset $w; yset $w }
    
    # --------------
    # xset proc
    #
    # resize the visible part
    # --------------
    # parm1: widget name
    # --------------
    proc xset {w} {
        variable {}
        # call the xscroll command
        set cmd $($w:xscroll)
        if {$cmd != ""} { catch { eval $cmd [xview $w] } }
    }
    
    # --------------
    # yset proc
    #
    # resize the visible part
    # --------------
    # parm1: widget name
    # --------------
    proc yset {w} {
        variable {}
        # call the yscroll command
        set cmd $($w:yscroll)
        if {$cmd != ""} { catch { eval $cmd [yview $w] } }
    }
    
    # -------------
    # xview
    #
    # called on horizontal scrolling
    # -------------
    # parm1: widget path
    # parm2: optional moveto or scroll
    # parm3: fraction if parm2 == moveto, count unit if parm2 == scroll
    # -------------
    # return: scrolling info if parm2 is empty
    # -------------
    
    proc xview {w {cmd ""} args} {
        variable {}
        # check args
        set len [llength $args]
        switch -glob -- $cmd {
            ""      {}
            mov*    {
                if {$len != 1} {
                    error "wrong # args: should be \"$w xview moveto fraction\""
                }
            }
            scr*    {
                if {$len != 2} {
                    error "wrong # args: should be \"$w xview scroll count unit\""
                }
            }
            default {
                error "unknown operation \"$cmd\": should be empty, moveto or scroll"
            }
        }
        # save old values
        set _vleft $($w:vleft)
        set _vwidth $($w:vwidth)
        set _width [winfo width $w]
        # compute new vleft
        switch $len {
            0       {
                # return fractions
                if {$_vwidth == 0} { return {0 1} }
                set first [expr {double($_vleft) / $_vwidth}]
                set last [expr {double($_vleft + $_width) / $_vwidth}]
                if {$last > 1.0} { return {0 1} }
                return [list [format %g $first] [format %g $last]]
            }
            1       {
                # absolute movement
                set vleft [expr {int(double($args) * $_vwidth)}]
            }
            2       {
                # relative movement
                foreach {count unit} $args break
                if {[string match p* $unit]} { set count [expr {$count * 9}] }
                set vleft [expr {$_vleft + $count * 0.1 * $_width}]
            }
        }
        if {$vleft < 0} {
            set vleft 0
        }
        if {$vleft + $_width > $_vwidth} {
            set vleft [expr {$_vwidth - $_width}]
        }
        if {$vleft != $_vleft} {
            set ($w:vleft) $vleft
            xset $w
            place $w.scrolled -in $w -x [expr {-$vleft}]
        }
    }
    
    # -------------
    # yview
    #
    # called on vertical scrolling
    # -------------
    # parm1: widget path
    # parm2: optional moveto or scroll
    # parm3: fraction if parm2 == moveto, count unit if parm2 == scroll
    # -------------
    # return: scrolling info if parm2 is empty
    # -------------
    
    proc yview {w {cmd ""} args} {
        variable {}
        # check args
        set len [llength $args]
        switch -glob -- $cmd {
            ""      {}
            mov*    {
                if {$len != 1} {
                    error "wrong # args: should be \"$w yview moveto fraction\""
                }
            }
            scr*    {
                if {$len != 2} {
                    error "wrong # args: should be \"$w yview scroll count unit\""
                }
            }
            default {
                error "unknown operation \"$cmd\": should be empty, moveto or scroll"
            }
        }
        # save old values
        set _vtop $($w:vtop)
        set _vheight $($w:vheight)
        set _height [winfo height $w]
        # compute new vtop
        switch $len {
            0       {
                # return fractions
                if {$_vheight == 0} { return {0 1} }
                set first [expr {double($_vtop) / $_vheight}]
                set last [expr {double($_vtop + $_height) / $_vheight}]
                if {$last > 1.0} { return {0 1} }
                return [list [format %g $first] [format %g $last]]
            }
            1       {
                # absolute movement
                set vtop [expr {int(double($args) * $_vheight)}]
            }
            2       {
                # relative movement
                foreach {count unit} $args break
                if {[string match p* $unit]} { set count [expr {$count * 9}] }
                set vtop [expr {$_vtop + $count * 0.1 * $_height}]
            }
        }
        if {$vtop < 0} { set vtop 0 }
        if {$vtop + $_height > $_vheight} { set vtop [expr {$_vheight - $_height}] }
        if {$vtop != $_vtop} {
            set ($w:vtop) $vtop
            yset $w
            place $w.scrolled -in $w -y [expr {-$vtop}]
        }
    }
    
    # end of ::scrolledframe namespace definition
}