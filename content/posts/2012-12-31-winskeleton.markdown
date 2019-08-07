---
layout: post
title: "Native Desktop Window Skeleton with ATL"
date: "2012-12-31 12:50:06"
comments: false
categories: "C++"
---

Building native Windows application with C++ can be done using a variety of techniques, from handrolled win32 to MFC. Some uglier than others. Using some ATL macros, here is the most minimalist implementation I could find, that will get you a native Windows desktop shell up and running.

Here's a skeleton native Windows desktop application that uses <a href="http://msdn.microsoft.com/en-us/library/t9adwcde(v=vs.110).aspx">ATL</a> (Abstract Template Library) as a thin wrapper on top of the underlying Windows scaffolding (e.g. the winproc, the message pump and so on). Compared to hand rolling this plumbing yourself, ATL (although its largly macro based) keeps the code lean and mean. I plan to use this as a shell DirectX render target for testing. For buildable VS2012 solution see [github](https://github.com/benjaminify/WindowsAtlSkeleton).

    #define WIN32_LEAN_AND_MEAN
    #define _AFXDLL
    
    #include <windows.h>
    #include <atlbase.h>
    #include <atlwin.h>
    
    struct FooWindow : CWindowImpl<FooWindow, CWindow, CWinTraits<WS_OVERLAPPEDWINDOW | WS_VISIBLE>>
    {
        DECLARE_WND_CLASS_EX(L"window", CS_HREDRAW | CS_VREDRAW, -1);
    
        BEGIN_MSG_MAP(FooWindow)
            MESSAGE_HANDLER(WM_PAINT, PaintHandler)
            MESSAGE_HANDLER(WM_DESTROY, DestroyHandler)
        END_MSG_MAP()
    
        LRESULT PaintHandler(UINT, WPARAM, LPARAM, BOOL&)
        {
            PAINTSTRUCT ps;
            BeginPaint(&ps);
            ATLTRACE(L"i like to paint\n");
            EndPaint(&ps);
            return 0;
        }
    
        LRESULT DestroyHandler(UINT, WPARAM, LPARAM, BOOL&)
        {
            PostQuitMessage(0);
            return 0;
        }
    };
    
    int APIENTRY _tWinMain(HINSTANCE, HINSTANCE, LPTSTR, int)
    {
        FooWindow window;
        window.Create(nullptr, 0, L"title");
    
        MSG message;
        BOOL result;
    
        while (result = GetMessage(&message, 0, 0, 0))
        {
            if (-1 != result)
            {
                DispatchMessage(&message);
            }
        }
    
        return 0;
    }


