#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// A class that abstracts the creation and management of a Win32 window.
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  // Creates a win32 window with |title| that bounds |top_left| and |size|.
  // Returns true on success.
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  // Show the current window.
  bool Show();

  // Releases OS resources associated with window.
  void Destroy();

  // Inserts |content| into the window tree.
  void SetChildContent(HWND content);

  // Returns the backing Window handle to enable clients to set capture and other
  // specific windowing features. Returns nullptr if the window has been
  // destroyed.
  HWND GetHandle() const;

  // If true, closing this window will result in the application exiting.
  void SetQuitOnClose(bool quit_on_close);

  // Return a RECT of the entire window area, including title bar and borders.
  RECT GetBounds() const;

  // Return a RECT of the client area (excluding title bar and borders).
  RECT GetClientArea() const;

 protected:
  // Processes and acts on any OS messages sent to the window.
  virtual LRESULT MessageHandler(HWND window, UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  // Called when Create is completed.
  virtual bool OnCreate();

  // Called when Destroy is completed.
  virtual void OnDestroy();

 private:
  friend class WindowClassRegistrar;

  // OS callback called by message pump. Handles the WM_NCCREATE message which
  // is passed when the window is first created.
  static LRESULT CALLBACK WndProc(HWND const window, UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  // Retrieves a class instance pointer for |window|
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  bool quit_on_close_ = false;

  // window handle for top level window.
  HWND window_handle_ = nullptr;

  // window handle for hosted content.
  HWND child_content_ = nullptr;
};

#endif  // RUNNER_WIN32_WINDOW_H_
