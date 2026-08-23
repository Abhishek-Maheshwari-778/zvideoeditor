#include "run_loop.h"

RunLoop::RunLoop() {}

RunLoop::~RunLoop() {}

void RunLoop::Run() {
  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }
}

void RunLoop::RegisterFlutterInstance(
    class FlutterWindow* flutter_window) {
  flutter_instances_.insert(flutter_window);
}

void RunLoop::UnregisterFlutterInstance(
    class FlutterWindow* flutter_window) {
  flutter_instances_.erase(flutter_window);
}
