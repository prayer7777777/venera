part of 'settings_page.dart';

class AboutSettings extends StatefulWidget {
  const AboutSettings({super.key});

  @override
  State<AboutSettings> createState() => _AboutSettingsState();
}

class _AboutSettingsState extends State<AboutSettings> {
  bool isCheckingUpdate = false;

  @override
  Widget build(BuildContext context) {
    return SmoothCustomScrollView(
      slivers: [
        SliverAppbar(title: Text("About".tl)),
        SizedBox(
          height: 112,
          width: double.infinity,
          child: Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(136),
              ),
              clipBehavior: Clip.antiAlias,
              child: const Image(
                image: AssetImage("assets/app_icon.png"),
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ).paddingTop(16).toSliver(),
        Column(
          children: [
            const SizedBox(height: 8),
            Text(
              "V${App.fullVersion}",
              style: const TextStyle(fontSize: 16),
            ),
            Text("Venera is a free and open-source app for comic reading.".tl),
            const SizedBox(height: 8),
          ],
        ).toSliver(),
        ListTile(
          title: Text("Check for updates".tl),
          trailing: Button.filled(
            isLoading: isCheckingUpdate,
            child: Text("Check".tl),
            onPressed: () {
              setState(() {
                isCheckingUpdate = true;
              });
              checkUpdateUi().then((value) {
                setState(() {
                  isCheckingUpdate = false;
                });
              });
            },
          ).fixHeight(32),
        ).toSliver(),
        _SwitchSetting(
          title: "Check for updates on startup".tl,
          settingKey: "checkUpdateOnStart",
        ).toSliver(),
        _SwitchSetting(
          title: "Auto update comic sources on startup".tl,
          settingKey: "autoUpdateComicSourcesOnStart",
        ).toSliver(),
        _PopupWindowSetting(
          title: "App Update Channel".tl,
          builder: () => const _AppUpdateChannelSettings(),
        ).toSliver(),
        ListTile(
          title: const Text("Github"),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrlString("https://github.com/venera-app/venera");
          },
        ).toSliver(),
        ListTile(
          title: const Text("Telegram"),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            launchUrlString("https://t.me/venera_release");
          },
        ).toSliver(),
      ],
    );
  }
}

class _UpdateCheckResult {
  const _UpdateCheckResult({
    required this.hasUpdate,
    required this.remoteVersion,
    required this.metaUrl,
    required this.releaseUrl,
  });

  final bool hasUpdate;
  final String remoteVersion;
  final String metaUrl;
  final String releaseUrl;
}

Future<_UpdateCheckResult> _checkUpdate() async {
  var metaUrl = appdata.settings['appUpdateMetaUrl'].toString();
  var releaseUrl = appdata.settings['appUpdateReleaseUrl'].toString();
  var res = await AppDio().get(metaUrl);
  if (res.statusCode == 200) {
    var data = loadYaml(res.data);
    if (data["version"] != null) {
      var remoteVersion = data["version"].toString();
      var hasUpdate = _compareVersionWithBuild(remoteVersion, App.fullVersion) > 0;
      return _UpdateCheckResult(
        hasUpdate: hasUpdate,
        remoteVersion: remoteVersion,
        metaUrl: metaUrl,
        releaseUrl: releaseUrl,
      );
    }
  }
  throw Exception("Invalid update metadata");
}

Future<bool> checkUpdateUi([bool showMessageIfNoUpdate = true, bool delay = false]) async {
  try {
    var value = await _checkUpdate();
    if (value.hasUpdate) {
      if (delay) {
        await Future.delayed(const Duration(seconds: 2));
      }
      showDialog(
          context: App.rootContext,
          builder: (context) {
            return ContentDialog(
              title: "New version available".tl,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("A new version is available. Do you want to update now?".tl),
                  const SizedBox(height: 8),
                  Text(
                    "Current version: ${App.fullVersion}",
                    style: TextStyle(color: context.colorScheme.outline),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Remote version: ${value.remoteVersion}",
                    style: TextStyle(color: context.colorScheme.outline),
                  ),
                ],
              ).paddingHorizontal(16),
              actions: [
                Button.text(
                  onPressed: () {
                    Navigator.pop(context);
                    launchUrlString(value.releaseUrl);
                  },
                  child: Text("Update".tl),
                ),
              ],
            );
          });
    } else if (showMessageIfNoUpdate) {
      App.rootContext.showMessage(
        message: "No new version available".tl,
      );
    }
    return true;
  } catch (e, s) {
    Log.error("Check Update", e.toString(), s);
    if (showMessageIfNoUpdate) {
      App.rootContext.showMessage(message: "Update check failed".tl);
    }
    return false;
  }
}

int _compareVersionWithBuild(String version1, String version2) {
  List<int> parseMain(String version) {
    var v = version.trim();
    if (v.startsWith("v") || v.startsWith("V")) {
      v = v.substring(1);
    }
    var main = v.split("+").first;
    return main
        .split(".")
        .map((e) => int.tryParse(e) ?? 0)
        .toList(growable: false);
  }

  int parseBuild(String version) {
    var v = version.trim();
    if (v.startsWith("v") || v.startsWith("V")) {
      v = v.substring(1);
    }
    var parts = v.split("+");
    if (parts.length < 2) {
      return 0;
    }
    return int.tryParse(parts[1]) ?? 0;
  }

  var v1 = parseMain(version1);
  var v2 = parseMain(version2);
  var maxLen = v1.length > v2.length ? v1.length : v2.length;
  for (var i = 0; i < maxLen; i++) {
    var a = i < v1.length ? v1[i] : 0;
    var b = i < v2.length ? v2[i] : 0;
    if (a > b) {
      return 1;
    }
    if (a < b) {
      return -1;
    }
  }

  var build1 = parseBuild(version1);
  var build2 = parseBuild(version2);
  if (build1 > build2) {
    return 1;
  }
  if (build1 < build2) {
    return -1;
  }
  return 0;
}

class _AppUpdateChannelSettings extends StatefulWidget {
  const _AppUpdateChannelSettings();

  @override
  State<_AppUpdateChannelSettings> createState() => _AppUpdateChannelSettingsState();
}

class _AppUpdateChannelSettingsState extends State<_AppUpdateChannelSettings> {
  static const _officialMetaUrl =
      "https://cdn.jsdelivr.net/gh/venera-app/venera@master/pubspec.yaml";
  static const _officialReleaseUrl = "https://github.com/venera-app/venera/releases";
  static const _forkMetaUrl =
      "https://cdn.jsdelivr.net/gh/prayer7777777/venera@main/pubspec.yaml";
  static const _forkReleaseUrl = "https://github.com/prayer7777777/venera/releases";

  final _metaUrlController = TextEditingController();
  final _releaseUrlController = TextEditingController();

  @override
  void initState() {
    _metaUrlController.text = appdata.settings['appUpdateMetaUrl'].toString();
    _releaseUrlController.text = appdata.settings['appUpdateReleaseUrl'].toString();
    super.initState();
  }

  @override
  void dispose() {
    _metaUrlController.dispose();
    _releaseUrlController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String value) {
    var uri = Uri.tryParse(value.trim());
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return PopUpWidgetScaffold(
      title: "App Update Channel".tl,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "Update metadata URL".tl,
                hintText: "pubspec.yaml URL".tl,
                border: const OutlineInputBorder(),
              ),
              controller: _metaUrlController,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: "Release page URL".tl,
                hintText: "GitHub releases URL".tl,
                border: const OutlineInputBorder(),
              ),
              controller: _releaseUrlController,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    _metaUrlController.text = _forkMetaUrl;
                    _releaseUrlController.text = _forkReleaseUrl;
                    setState(() {});
                  },
                  child: Text("Use Fork (Default)".tl),
                ),
                TextButton(
                  onPressed: () {
                    _metaUrlController.text = _officialMetaUrl;
                    _releaseUrlController.text = _officialReleaseUrl;
                    setState(() {});
                  },
                  child: Text("Use Official".tl),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                var metaUrl = _metaUrlController.text.trim();
                var releaseUrl = _releaseUrlController.text.trim();
                if (!_isValidUrl(metaUrl) || !_isValidUrl(releaseUrl)) {
                  context.showMessage(message: "Invalid URL".tl);
                  return;
                }
                appdata.settings['appUpdateMetaUrl'] = metaUrl;
                appdata.settings['appUpdateReleaseUrl'] = releaseUrl;
                appdata.saveData();
                context.showMessage(message: "Saved".tl);
                App.rootPop();
              },
              child: Text("Save".tl),
            ),
            const SizedBox(height: 16),
          ],
        ).paddingHorizontal(16),
      ),
    );
  }
}
