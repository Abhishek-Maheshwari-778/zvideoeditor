#ifndef RUNNER_RUN_LOOP_H_
#define RUNNER_RUN_LOOP_H_

#include <windows.h>

#include <chrono>
#include <set>

class RunLoop {
 public:
  RunLoop();
  ~RunLoop();

  void Run();

  void RegisterFlutterInstance(
      class FlutterWindow* flutter_window);

  void UnregisterFlutterInstance(
      class FlutterWindow* flutter_window);

 private:
  using TimePoint = std::chrono::steady_clock::time_point;

  std::set<FlutterWindow*> flutter_instances_;
};

#endif  // RUNNER_RUN_LOOP_H_
