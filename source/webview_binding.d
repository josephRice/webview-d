/*
 * MIT License
 *
 * Copyright (c) 2018 Joseph M. Rice
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

module webview_binding;

alias ubyte uint8_t;

version (linux) {
    alias GtkWidget = void;
    alias GAsyncQueue = void;

    extern (C) struct webview_priv {
        GtkWidget *window;
        GtkWidget *scroller;
        GtkWidget *webview;
        GtkWidget *inspector_window;
        GAsyncQueue *queue;
        int ready;
        int js_busy;
        int should_exit;
    };
}

version (windows) {
    alias HWND = void;
    alias IOleObject = void;
    alias BOOL = bool;
    alias DWORD dword;
    alias RECT = void;

    extern (C) struct webview_priv {
        HWND hwnd;
        IOleObject **browser;
        BOOL is_fullscreen;
        DWORD saved_style;
        DWORD saved_ex_style;
        RECT saved_rect;
    };
}

alias webview_CallBack = void *function(void*, const char*);
alias webview_external_invoke_cb_t = void *function(void*, const char*);
alias webview_dispatch_fn = void *function(void*, const char*);

extern (C) struct webview {
        char *url;
        char *title;
        int width;
        int height;
        int resizable;
        int _debug;
        webview_external_invoke_cb_t external_invoke_cb;
        webview_priv priv;
        void *userdata;
    };


enum webview_dialog_type {
    WEBVIEW_DIALOG_TYPE_OPEN = 0,
    WEBVIEW_DIALOG_TYPE_SAVE = 1,
    WEBVIEW_DIALOG_TYPE_ALERT = 2
};

enum WEBVIEW_DIALOG_FLAG_FILE = (0 << 0);
enum WEBVIEW_DIALOG_FLAG_DIRECTORY = (1 << 0);

enum WEBVIEW_DIALOG_FLAG_INFO = (1 << 1);
enum WEBVIEW_DIALOG_FLAG_WARNING = (2 << 1);
enum WEBVIEW_DIALOG_FLAG_ERROR = (3 << 1);
enum WEBVIEW_DIALOG_FLAG_ALERT_MASK = (3 << 1);

enum DEFAULT_URL = "data:text/" ~
"html,%3C%21DOCTYPE%20html%3E%0A%3Chtml%20lang=%22en%22%3E%0A%3Chead%3E%"    ~
"3Cmeta%20charset=%22utf-8%22%3E%3Cmeta%20http-equiv=%22X-UA-Compatible%22%" ~
"20content=%22IE=edge%22%3E%3C%2Fhead%3E%0A%3Cbody%3E%3Cdiv%20id=%22app%22%" ~
"3E%3C%2Fdiv%3E%3Cscript%20type=%22text%2Fjavascript%22%3E%3C%2Fscript%3E%"  ~
"3C%2Fbody%3E%0A%3C%2Fhtml%3E";

enum CSS_INJECT_FUNCTION = "(function(e){var " ~
"t=document.createElement('style'),d=document.head||document." ~
"getElementsByTagName('head')[0];t.setAttribute('type','text/" ~
"css'),t.styleSheet?t.styleSheet.cssText=e:t.appendChild(document." ~
"createTextNode(e)),d.appendChild(t)})";

    //static const char *webview_check_url(const char *url);

    //int webview(const char *title, const char *url, int width,
    //            int height, int resizable);

extern (C) static int webview_init(webview *w);
extern (C) static int webview_loop(webview *w, int blocking);
extern (C) static int webview_eval(webview *w, const char *js);
extern (C) static int webview_inject_css(webview *w, const char *css);
extern (C) static void webview_set_title(webview *w, const char *title);
extern (C) static void webview_set_fullscreen(webview *w, int fullscreen);
extern (C) static void webview_set_color(webview *w, uint8_t r, uint8_t g,
                            uint8_t b, uint8_t a);
extern (C) static void webview_dialog(webview *w,
                        webview_dialog_type dlgtype, int flags,
                        const char *title, const char *arg,
                        char *result, size_t resultsz);
extern (C) static void webview_dispatch(webview *w, webview_dispatch_fn fn,
                            void *arg);
extern (C) static void webview_terminate(webview *w);
extern (C) static void webview_exit(webview *w);
extern (C) static void webview_debug(const char *format, ...);
extern (C) static void webview_print_log(const char *s);

/**
 * Open a window with title pointing to url with a given 
 * width and height, and if the window should be able to 
 * be sizeable 
 *
 * @param title - string of the title of the window
 * @param url - string url to load
 * @param width - int width of the window 
 * @param height - 
 **/
int webview_simple( string title, 
                    string url, 
                    int width, 
                    int height, 
                    int resizable) {    

    char[] _title = (title ~ '\0').dup;
    char[] _url = (url ~ '\0').dup;

    webview w;

    w.title = _title.ptr;
    w.url = _url.ptr;
    w.width = width;
    w.height = height;
    w.resizable = resizable;

    int r = webview_init(&w);
    if (r != 0) {
        return r;
    }
    while (webview_loop(&w, 1) == 0) {
    }
    webview_exit(&w);

    return 0;
}
