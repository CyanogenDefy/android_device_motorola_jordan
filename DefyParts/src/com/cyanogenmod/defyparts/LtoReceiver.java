package com.cyanogenmod.defyparts;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.util.Log;

public class LtoReceiver extends BroadcastReceiver {
    private static final String TAG = "LtoReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        final String action = intent.getAction();

        if (ConnectivityManager.CONNECTIVITY_ACTION.equals(action)) {
            boolean hasConnection =
                    !intent.getBooleanExtra(ConnectivityManager.EXTRA_NO_CONNECTIVITY, false);

            Log.d(TAG, "Got connectivity change, has connection: " + hasConnection);
            Intent serviceIntent = new Intent(context, LtoDownloadService.class);

            if (hasConnection) {
                context.startService(serviceIntent);
            } else {
                context.stopService(serviceIntent);
            }
        } else if (Intent.ACTION_BOOT_COMPLETED.equals(action)) {
            long lastDownload = LtoDownloadUtils.getLastDownload(context);
            LtoDownloadUtils.scheduleNextDownload(context, lastDownload);
        }

    }
}
