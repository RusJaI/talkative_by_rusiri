package com.rusj.tts_with_local_notif;

import io.flutter.app.FlutterApplication;
import io.flutter.plugins.androidalarmmanager.AlarmService;
import io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import io.flutter.plugins.deviceinfo.DeviceInfoPlugin;
import com.tundralabs.fluttertts.FlutterTtsPlugin;

@SuppressWarnings("deprecation")
public class Application extends FlutterApplication
        implements io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback {
    @Override
    public void onCreate() {
        super.onCreate();
        AlarmService.setPluginRegistrant(this);
    }

    @Override
    @SuppressWarnings("deprecation")
    public void registerWith(io.flutter.plugin.common.PluginRegistry registry) {
        AndroidAlarmManagerPlugin.registerWith(
                registry.registrarFor("io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin"));
        PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
        FlutterLocalNotificationsPlugin.registerWith(registry.registrarFor("com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin"));
        SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
        DeviceInfoPlugin.registerWith(registry.registrarFor("io.flutter.plugins.deviceinfo.DeviceInfoPlugin"));
        FlutterTtsPlugin.registerWith(registry.registrarFor("com.tundralabs.fluttertts.FlutterTtsPlugin"));
    }
}
