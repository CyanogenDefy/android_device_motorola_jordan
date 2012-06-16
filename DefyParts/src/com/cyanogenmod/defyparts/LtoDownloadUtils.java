package com.cyanogenmod.defyparts;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

public class LtoDownloadUtils {
    private static final String TAG = "LtoDownloadUtils";
    private static final long DOWNLOAD_INTERVAL_DEFAULT = 3600 * 24 * 3 * 1000; /* 3 days */

    static long getLastDownload(Context context) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        return prefs.getLong(LtoDownloadService.KEY_LAST_DOWNLOAD, 0);
    }

    static long getDownloadInterval(Context context) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        String value = prefs.getString(LtoDownloadService.KEY_INTERVAL, null);
        if (value != null) {
            try {
                return Long.parseLong(value) * 1000;
            } catch (NumberFormatException e) {
                Log.w(TAG, "Found invalid interval " + value);
            }
        }
        return DOWNLOAD_INTERVAL_DEFAULT;
    }

    static void scheduleNextDownload(Context context, long lastDownload) {
        AlarmManager am = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        Intent intent = new Intent(context, LtoDownloadService.class);
        PendingIntent pi = PendingIntent.getService(context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_ONE_SHOT);

        am.set(AlarmManager.RTC, lastDownload + getDownloadInterval(context), pi);
    }
}
