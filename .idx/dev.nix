
{ pkgs, ... }: {
  channel = "stable-24.05"; # or "unstable"
  packages = [
    pkgs.jdk17               # Java 17 (Best for Android Gradle)
    pkgs.unzip               # Required for extracting resources
    pkgs.gradle              # Run './gradlew' commands easily
    pkgs.android-tools       # Gives you 'adb', 'logcat', 'fastboot'
    pkgs.bundletool          # CRITICAL: For testing App Bundles (.aab) for Play Store
    pkgs.cmake               # Required if you ever add C++ code to your app
    pkgs.clang               # C/C++ Compiler (often needed for native dependencies)
  ];
  # Sets environment variables in the workspace
  env = {};
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      # -- Core Flutter & Dart --
      "Dart-Code.flutter"
      "Dart-Code.dart-code"

      # -- Native Android (Kotlin/Java) --
      "fwcd.kotlin"                # Syntax highlighting for your Service files
      "vscjava.vscode-java-pack"   # HUGE pack: Intellisense, Debugger, Maven for Java
      "mathiasfrohlich.Kotlin"     # Extra Kotlin language support

      # -- Android Config Files --
      "dotjoshjohnson.xml"         # ESSENTIAL for editing AndroidManifest.xml
      "njpwerner.autodocstring"    # Generates documentation comments automatically

      # -- Visual Helpers --
      "usernamehw.errorlens"       # 🔥 Shows errors in RED text right next to the code line
      "esbenp.prettier-vscode"     # Keeps your code formatted and clean
      "PKief.material-icon-theme"  # Makes the file explorer look like Android Studio
    ];
    workspace = {
      onCreate = {
        # 1. Download dependencies
        flutter-pub-get = "flutter pub get";
        # 2. Accept Android Licenses automatically (prevents build errors)
        accept-licenses = "yes | flutter doctor --android-licenses";
      };
      onStart = {
        # Optional: Check android device status on startup
        check-adb = "adb devices";
      };
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter" "run" "--machine" "-d" "web-server" "--web-hostname" "0.0.0.0" "--web-port" "$PORT"];
          manager = "flutter";
        };
        android = {
          command = ["flutter" "run" "--machine" "-d" "android" "-d" "localhost:5555"];
          manager = "flutter";
        };
      };
    };
  };
}
