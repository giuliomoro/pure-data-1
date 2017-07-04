package provide pd_bindings 0.1

package require pd_menucommands
package require dialog_find

namespace eval ::pd_bindings:: {
    namespace export global_bindings
    namespace export dialog_bindings
    namespace export patch_bindings
}

# TODO rename pd_bindings to window_bindings after merge is done

# Some commands are bound using "" quotations so that the $mytoplevel is
# interpreted immediately.  Since the command is being bound to $mytoplevel,
# it makes sense to have value of $mytoplevel already in the command.  This is
# the opposite of most menu/bind commands here and in pd_menus.tcl, which use
# {} to force execution of any variables (i.e. $::focused_window) until later

# binding by class is not recursive, so its useful for window events
proc ::pd_bindings::class_bindings {} {
    # and the Pd window is in a class to itself
    bind PdWindow <FocusIn>           "::pd_bindings::window_focusin %W"
    # bind to all the windows dedicated to patch canvases
    bind PatchWindow <FocusIn>        "::pd_bindings::window_focusin %W"
    bind PatchWindow <Map>            "::pd_bindings::patch_map %W"
    bind PatchWindow <Unmap>          "::pd_bindings::patch_unmap %W"
    bind PatchWindow <Configure>      "::pd_bindings::patch_configure %W %w %h %x %y"
    # dialog panel windows bindings, which behave differently than PatchWindows
    bind DialogWindow <Configure>     "::pd_bindings::dialog_configure %W"
    bind DialogWindow <FocusIn>       "::pd_bindings::dialog_focusin %W"
    # help browser bindings
    bind HelpBrowser <Configure>      "::pd_bindings::dialog_configure %W"
    bind HelpBrowser <FocusIn>        "::pd_bindings::dialog_focusin %W"
}

proc ::pd_bindings::global_bindings {} {
    # we use 'bind all' everywhere to get as much of Tk's automatic binding
    # behaviors as possible, things like not sending an event for 'O' when
    # 'Control-O' is pressed.
    bind all <$::modifier-Key-a>      {menu_send %W selectall}
    bind all <$::modifier-Key-b>      {menu_helpbrowser}
    bind all <$::modifier-Key-c>      {menu_send %W copy}
    bind all <$::modifier-Key-d>      {menu_send %W duplicate}
    bind all <$::modifier-Key-e>      {menu_toggle_editmode}
    bind all <$::modifier-Key-f>      {menu_find_dialog}
    bind all <$::modifier-Key-g>      {menu_send %W findagain}
    bind all <$::modifier-Key-n>      {menu_new}
    bind all <$::modifier-Key-o>      {menu_open}
    bind all <$::modifier-Key-p>      {menu_print $::focused_window}
    bind all <$::modifier-Key-r>      {menu_raise_pdwindow}
    bind all <$::modifier-Key-s>      {menu_send %W menusave}
    bind all <$::modifier-Key-v>      {menu_send %W paste}
    bind all <$::modifier-Key-w>      {::pd_bindings::window_close %W}
    bind all <$::modifier-Key-x>      {menu_send %W cut}
    bind all <$::modifier-Key-z>      {menu_undo}
    bind all <$::modifier-Key-1>      {menu_send_float %W obj 0}
    bind all <$::modifier-Key-2>      {menu_send_float %W msg 0}
    bind all <$::modifier-Key-3>      {menu_send_float %W floatatom 0}
    bind all <$::modifier-Key-4>      {menu_send_float %W symbolatom 0}
    bind all <$::modifier-Key-5>      {menu_send_float %W text 0}
    bind all <$::modifier-Key-slash>  {pdsend "pd dsp 1"}
    bind all <$::modifier-Key-period> {pdsend "pd dsp 0"}

    # take the '=' key as a zoom-in accelerator, because '=' is the non-shifted
    # "+" key... this only makes sense on US keyboards but some users
    # expected it... go figure.
    bind all <$::modifier-Key-equal>  {menu_send_float %W zoom 2}
    bind all <$::modifier-Key-plus>   {menu_send_float %W zoom 2}
    bind all <$::modifier-Key-minus>  {menu_send_float %W zoom 1}
    bind all <$::modifier-Key-KP_Add>      {menu_send_float %W zoom 2}
    bind all <$::modifier-Key-KP_Subtract> {menu_send_float %W zoom 1}

    # annoying, but Tk's bind needs uppercase letter to get the Shift
    bind all <$::modifier-Shift-Key-B> {menu_send %W bng}
    bind all <$::modifier-Shift-Key-C> {menu_send %W mycnv}
    bind all <$::modifier-Shift-Key-D> {menu_send %W vradio}
    bind all <$::modifier-Shift-Key-H> {menu_send %W hslider}
    bind all <$::modifier-Shift-Key-I> {menu_send %W hradio}
    bind all <$::modifier-Shift-Key-L> {menu_clear_console}
    bind all <$::modifier-Shift-Key-N> {menu_send %W numbox}
    bind all <$::modifier-Shift-Key-Q> {pdsend "pd quit"}
    bind all <$::modifier-Shift-Key-S> {menu_send %W menusaveas}
    bind all <$::modifier-Shift-Key-T> {menu_send %W toggle}
    bind all <$::modifier-Shift-Key-U> {menu_send %W vumeter}
    bind all <$::modifier-Shift-Key-V> {menu_send %W vslider}
    bind all <$::modifier-Shift-Key-W> {menu_send_float %W menuclose 1}
    bind all <$::modifier-Shift-Key-Z> {menu_redo}
    # lowercase bindings, for the CapsLock case
    bind all <$::modifier-Shift-Key-b> {menu_send %W bng}
    bind all <$::modifier-Shift-Key-c> {menu_send %W mycnv}
    bind all <$::modifier-Shift-Key-d> {menu_send %W vradio}
    bind all <$::modifier-Shift-Key-h> {menu_send %W hslider}
    bind all <$::modifier-Shift-Key-i> {menu_send %W hradio}
    bind all <$::modifier-Shift-Key-l> {menu_clear_console}
    bind all <$::modifier-Shift-Key-n> {menu_send %W numbox}
    bind all <$::modifier-Shift-Key-q> {pdsend "pd quit"}
    bind all <$::modifier-Shift-Key-s> {menu_send %W menusaveas}
    bind all <$::modifier-Shift-Key-t> {menu_send %W toggle}
    bind all <$::modifier-Shift-Key-u> {menu_send %W vumeter}
    bind all <$::modifier-Shift-Key-v> {menu_send %W vslider}
    bind all <$::modifier-Shift-Key-w> {menu_send_float %W menuclose 1}
    bind all <$::modifier-Shift-Key-z> {menu_redo}
    # OS-specific bindings
    if {$::windowingsystem eq "aqua"} {
        # Cmd-m = Minimize and Cmd-t = Font on Mac OS X for all apps
        bind all <$::modifier-Key-t>         {menu_font_dialog}
        if {$::tcl_version < 8.5} {
            # TK 8.5+ Cocoa handles quit, minimize, & raise next window for us
            bind all <$::modifier-Key-q>     {pdsend "pd verifyquit"}
            bind all <$::modifier-Key-m>     {menu_minimize %W}
            bind all <$::modifier-Key-comma> {pdsend "pd start-path-dialog"}
            bind all <$::modifier-Shift-Key-M> {menu_message_dialog}
            bind all <$::modifier-Key-M>       {menu_minimize %W}
            bind all <$::modifier-Key-T>       {menu_font_dialog}

            bind all <$::modifier-quoteleft>   {menu_raisenextwindow}
        }
    } else {
        bind all <$::modifier-Key-q>       {pdsend "pd verifyquit"}
        #bind all <$::modifier-Key-t>       {menu_texteditor}
        bind all <$::modifier-Key-M>       {menu_message_dialog}
        #bind all <$::modifier-Key-T>       {menu_texteditor}

        bind all <$::modifier-Next>        {menu_raisenextwindow}    ;# PgUp
        bind all <$::modifier-Prior>       {menu_raisepreviouswindow};# PageDown
        # these can conflict with Cmd+comma & Cmd+period bindings in Tk Cococa
        bind all <$::modifier-greater>     {menu_raisenextwindow}
        bind all <$::modifier-less>        {menu_raisepreviouswindow}
    }

    # annoying, but somtimes Tk's bind needs uppercase letters to get the Shift
    if {$::bind_shiftcaps == 1 } {
        bind all <$::modifier-Shift-Key-A> {menu_send %W menuarray}
        bind all <$::modifier-Shift-Key-B> {menu_send %W bng}
        bind all <$::modifier-Shift-Key-C> {menu_send %W mycnv}
        bind all <$::modifier-Shift-Key-D> {menu_send %W vradio}
        bind all <$::modifier-Shift-Key-G> {menu_send %W graph}
        bind all <$::modifier-Shift-Key-I> {menu_send %W hradio}
        bind all <$::modifier-Shift-Key-J> {menu_send %W hslider}
        bind all <$::modifier-Shift-Key-M> {menu_message_dialog}
        bind all <$::modifier-Shift-Key-L> {menu_clear_console}
        bind all <$::modifier-Shift-Key-N> {menu_send %W numbox}
        bind all <$::modifier-Shift-Key-Q> {pdsend "pd quit"}
        bind all <$::modifier-Shift-Key-R> {menu_send %W tidy}
        bind all <$::modifier-Shift-Key-S> {menu_send %W menusaveas}
        bind all <$::modifier-Shift-Key-T> {menu_send %W toggle}
        bind all <$::modifier-Shift-Key-U> {menu_send %W vumeter}
        bind all <$::modifier-Shift-Key-V> {menu_send %W vslider}
        bind all <$::modifier-Shift-Key-W> {menu_send_float %W menuclose 1}
        bind all <$::modifier-Shift-Key-Z> {menu_redo}
    } else {
        # ... and sometimes not (I'm looking at you Tk Cocoa on Mac)
        bind all <$::modifier-Shift-Key-a> {menu_send %W menuarray}
        bind all <$::modifier-Shift-Key-b> {menu_send %W bng}
        bind all <$::modifier-Shift-Key-c> {menu_send %W mycnv}
        bind all <$::modifier-Shift-Key-d> {menu_send %W vradio}
        bind all <$::modifier-Shift-Key-g> {menu_send %W graph}
        bind all <$::modifier-Shift-Key-i> {menu_send %W hradio}
        bind all <$::modifier-Shift-Key-j> {menu_send %W hslider}
        bind all <$::modifier-Shift-Key-m> {menu_message_dialog}
        bind all <$::modifier-Shift-Key-l> {menu_clear_console}
        bind all <$::modifier-Shift-Key-n> {menu_send %W numbox}
        bind all <$::modifier-Shift-Key-q> {pdsend "pd quit"}
        bind all <$::modifier-Shift-Key-r> {menu_send %W tidy}
        bind all <$::modifier-Shift-Key-s> {menu_send %W menusaveas}
        bind all <$::modifier-Shift-Key-t> {menu_send %W toggle}
        bind all <$::modifier-Shift-Key-u> {menu_send %W vumeter}
        bind all <$::modifier-Shift-Key-v> {menu_send %W vslider}
        bind all <$::modifier-Shift-Key-w> {menu_send_float %W menuclose 1}
        bind all <$::modifier-Shift-Key-z> {menu_redo}
    }

    bind all <KeyPress>         {::pd_bindings::sendkey %W 1 %K %A 0}
    bind all <KeyRelease>       {::pd_bindings::sendkey %W 0 %K %A 0}
    bind all <Shift-KeyPress>   {::pd_bindings::sendkey %W 1 %K %A 1}
    bind all <Shift-KeyRelease> {::pd_bindings::sendkey %W 0 %K %A 1}
}

# bindings for .pdwindow are found in ::pdwindow::pdwindow_bindings in pdwindow.tcl

# this is for the dialogs: find, font, sendmessage, gatom properties, array
# properties, iemgui properties, canvas properties, data structures
# properties, Audio setup, and MIDI setup
proc ::pd_bindings::dialog_bindings {mytoplevel dialogname} {
    variable modifier

    bind $mytoplevel <KeyPress-Escape>   "dialog_${dialogname}::cancel $mytoplevel"
    bind $mytoplevel <KeyPress-Return>   "dialog_${dialogname}::ok $mytoplevel"
    bind $mytoplevel <$::modifier-Key-w> "dialog_${dialogname}::cancel $mytoplevel"
    # these aren't supported in the dialog, so alert the user, then break so
    # that no other key bindings are run
    bind $mytoplevel <$::modifier-Key-s>       {bell; break}
    bind $mytoplevel <$::modifier-Shift-Key-s> {bell; break}
    bind $mytoplevel <$::modifier-Shift-Key-S> {bell; break}
    bind $mytoplevel <$::modifier-Key-p>       {bell; break}
    bind $mytoplevel <$::modifier-Key-t>       {bell; break}
    # and the CapsLock case...
    bind $mytoplevel <$::modifier-Key-W> "dialog_${dialogname}::cancel $mytoplevel"
    bind $mytoplevel <$::modifier-Key-S>       {bell; break}
    bind $mytoplevel <$::modifier-Shift-Key-s> {bell; break}
    bind $mytoplevel <$::modifier-Key-P>       {bell; break}
    bind $mytoplevel <$::modifier-Key-T>       {bell; break}

    wm protocol $mytoplevel WM_DELETE_WINDOW "dialog_${dialogname}::cancel $mytoplevel"
}

# this is for canvas windows
proc ::pd_bindings::canvas_bindings {mytoplevel} {
    variable modifier
    set tkcanvas [tkcanvas_name $mytoplevel]

    # on Mac OS X/Aqua, the Alt/Option key is called Option in Tcl
    if {$::windowingsystem eq "aqua"} {
        set alt "Option"
    } else {
        set alt "Alt"
    }

    # TODO move mouse bindings to global and bind to 'all'

    # mouse bindings -----------------------------------------------------------
    # these need to be bound to $tkcanvas because %W will return $mytoplevel for
    # events over the window frame and $tkcanvas for events over the canvas
    bind $tkcanvas <Motion>                   "pdtk_canvas_motion %W %x %y 0"
    bind $tkcanvas <Shift-Motion>             "pdtk_canvas_motion %W %x %y 1"
    bind $tkcanvas <$::modifier-Motion>       "pdtk_canvas_motion %W %x %y 2"
    bind $tkcanvas <$::modifier-Shift-Motion> "pdtk_canvas_motion %W %x %y 3"
    bind $tkcanvas <$alt-Motion>               "pdtk_canvas_motion %W %x %y 4"
    bind $tkcanvas <$alt-Shift-Motion>         "pdtk_canvas_motion %W %x %y 5"
    bind $tkcanvas <$::modifier-$alt-Motion>   "pdtk_canvas_motion %W %x %y 6"
    bind $tkcanvas <$::modifier-$alt-Shift-Motion> "pdtk_canvas_motion %W %x %y 7"

    bind $tkcanvas <ButtonPress-1> \
        "pdtk_canvas_mouse %W %x %y %b 0"
    bind $tkcanvas <Shift-ButtonPress-1> \
        "pdtk_canvas_mouse %W %x %y %b 1"
    bind $tkcanvas <$::modifier-ButtonPress-1> \
        "pdtk_canvas_mouse %W %x %y %b 2"
    bind $tkcanvas <$::modifier-Shift-ButtonPress-1> \
        "pdtk_canvas_mouse %W %x %y %b 3"
    bind $tkcanvas <$alt-ButtonPress-1> \
        "pdtk_canvas_mouse %W %x %y %b 4"
    bind $tkcanvas <$alt-Shift-ButtonPress-1> \
        "pdtk_canvas_mouse %W %x %y %b 5"
    bind $tkcanvas <$::modifier-$alt-ButtonPress-1> \
        "pdtk_canvas_mouse %W %x %y %b 6"
    bind $tkcanvas <$::modifier-$alt-Shift-ButtonPress-1> \
        "pdtk_canvas_mouse %W %x %y %b 7"

    bind $tkcanvas <ButtonRelease-1>          "pdtk_canvas_mouseup %W %x %y %b"

    if {$::windowingsystem eq "x11"} {
        # from http://wiki.tcl.tk/3893
        bind all <Button-4> \
            {event generate [focus -displayof %W] <MouseWheel> -delta  1}
        bind all <Button-5> \
            {event generate [focus -displayof %W] <MouseWheel> -delta -1}
        bind all <Shift-Button-4> \
            {event generate [focus -displayof %W] <Shift-MouseWheel> -delta  1}
        bind all <Shift-Button-5> \
            {event generate [focus -displayof %W] <Shift-MouseWheel> -delta -1}
    }
    bind $tkcanvas <MouseWheel>       {::pdtk_canvas::scroll %W y %D}
    bind $tkcanvas <Shift-MouseWheel> {::pdtk_canvas::scroll %W x %D}

    # "right clicks" are defined differently on each platform
    switch -- $::windowingsystem { 
        "aqua" {
            bind $tkcanvas <ButtonPress-2>        "pdtk_canvas_rightclick %W %x %y %b"
            # on Mac OS X, make a rightclick with Ctrl-click for 1 button mice
            bind $tkcanvas <Control-Button-1> "pdtk_canvas_rightclick %W %x %y %b"
        } "x11" {
            bind $tkcanvas <ButtonPress-3>     "pdtk_canvas_rightclick %W %x %y %b"
            # on X11, button 2 "pastes" from the X windows clipboard
            bind $tkcanvas <ButtonPress-2>   "pdtk_canvas_clickpaste %W %x %y %b"
        } "win32" {
            bind $tkcanvas <ButtonPress-3>   "pdtk_canvas_rightclick %W %x %y %b"
        }
    }

    # window protocol bindings
    wm protocol $mytoplevel WM_DELETE_WINDOW "pdsend \"$mytoplevel menuclose 0\""
    bind $tkcanvas <Destroy> "::pd_bindings::patch_destroy %W"
}


#------------------------------------------------------------------------------#
# event handlers

# do tasks when changing focus (Window menu, scrollbars, etc.)
proc ::pd_bindings::window_focusin {mytoplevel} {
    # focused_window is used throughout for sending bindings, menu commands,
    # etc. to the correct patch receiver symbol.  MSP took out a line that
    # confusingly redirected the "find" window which might be in mid search
    set ::focused_window $mytoplevel
    ::pd_menucommands::set_filenewdir $mytoplevel
    ::dialog_font::update_font_dialog $mytoplevel
    if {$mytoplevel eq ".pdwindow"} {
        ::pd_menus::configure_for_pdwindow 
    } else {
        ::pd_menus::configure_for_canvas $mytoplevel
    }
    if {[winfo exists .font]} {wm transient .font $::focused_window}
    # if we regain focus from another app, make sure to editmode cursor is right
    if {$::editmode($mytoplevel)} {
        $mytoplevel configure -cursor hand2
    }
}

# global window close event, patch windows are closed by pd
# while other window types are closed via their own bindings
proc ::pd_bindings::window_close {mytoplevel} {
    # catch any non-existent windows
    # ie. the helpbrowser after it's been
    # closed by it's own binding
    if {![winfo exists $mytoplevel]} {
        return
    }
    menu_send_float $mytoplevel menuclose 0
}

# "map" event tells us when the canvas becomes visible, and "unmap",
# invisible.  Invisibility means the Window Manager has minimized us.  We
# don't get a final "unmap" event when we destroy the window.
proc ::pd_bindings::patch_map {mytoplevel} {
    pdsend "$mytoplevel map 1"
    ::pdtk_canvas::finished_loading_file $mytoplevel
}

proc ::pd_bindings::patch_unmap {mytoplevel} {
    pdsend "$mytoplevel map 0"
}

proc ::pd_bindings::patch_configure {mytoplevel width height x y} {
    # check if the window is not fully created aka 1x1
    if {$width == 1 || $height == 1} {return}
    pdtk_canvas_getscroll [tkcanvas_name $mytoplevel]
    # send the size/location of the window and canvas to 'pd' in the form of:
    #    left top right bottom
    pdsend "$mytoplevel setbounds $x $y [expr $x + $width] [expr $y + $height]"
}
    
proc ::pd_bindings::patch_destroy {window} {
    set mytoplevel [winfo toplevel $window]
    unset ::editmode($mytoplevel)
    unset ::editingtext($mytoplevel)
    unset ::loaded($mytoplevel)
    # unset my entries all of the window data tracking arrays
    array unset ::windowname $mytoplevel
    array unset ::parentwindows $mytoplevel
    array unset ::childwindows $mytoplevel
}

proc ::pd_bindings::dialog_configure {mytoplevel} {
}

proc ::pd_bindings::dialog_focusin {mytoplevel} {
    set ::focused_window $mytoplevel
    ::pd_menus::configure_for_dialog $mytoplevel
}

#------------------------------------------------------------------------------#
# key usage

# canvas_key() expects to receive the patch's mytoplevel because key messages
# are local to each patch.  Therefore, key messages are not send for the
# dialog panels, the Pd window, help browser, etc. so we need to filter those
# events out.
proc ::pd_bindings::sendkey {window state key iso shift} {
    # TODO canvas_key on the C side should be refactored with this proc as well
    switch -- $key {
        "BackSpace" { set iso ""; set key 8    }
        "Tab"       { set iso ""; set key 9 }
        "Return"    { set iso ""; set key 10 }
        "Escape"    { set iso ""; set key 27 }
        "Space"     { set iso ""; set key 32 }
        "Delete"    { set iso ""; set key 127 }
        "KP_Delete" { set iso ""; set key 127 }
    }
    if {$iso ne ""} {
        scan $iso %c key
    }
    # some pop-up panels also bind to keys like the enter, but then disappear,
    # so ignore their events.  The inputbox in the Startup dialog does this.
    if {! [winfo exists $window]} {return}
    #$window might be a toplevel or canvas, [winfo toplevel] does the right thing
    set mytoplevel [winfo toplevel $window]
    if {[winfo class $mytoplevel] eq "PatchWindow"} {
        pdsend "$mytoplevel key $state $key $shift"
    } else {
        pdsend "pd key $state $key $shift"
    }
}
