package com.cyanogenmod.defyparts;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.PowerManager;
import android.os.SystemProperties;
import android.preference.CheckBoxPreference;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceActivity;
import android.preference.PreferenceCategory;
import android.text.TextUtils;
import android.util.Log;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class SettingsActivity extends PreferenceActivity implements OnPreferenceChangeListener {
    private static final String TAG = "DefyParts";

    private PackageManager mPm;

    private PreferenceCategory generalSettings;
    private ListPreference chargeLedModePref;
    private ListPreference touchPointsPref;
    private CheckBoxPreference kinetoPref;

    private static final String PROP_CHARGE_LED_MODE = "persist.sys.charge_led";
    private static final String PROP_TOUCH_POINTS = "persist.sys.multitouch";
    private static final String PROP_KINETO_ENABLED = "persist.sys.kineto.enable";
    private static final String FILE_TOUCH_POINTS = "/proc/multitouch/num";
    private static final String KINETO_PACKAGE = "com.android.kineto";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.settings);

        mPm = getPackageManager();

        generalSettings = (PreferenceCategory) getPreferenceScreen().findPreference("general");
        chargeLedModePref = (ListPreference) generalSettings.findPreference("charge_led_mode");
        chargeLedModePref.setOnPreferenceChangeListener(this);
        touchPointsPref = (ListPreference) generalSettings.findPreference("touch_points");
        touchPointsPref.setOnPreferenceChangeListener(this);

        PreferenceCategory otherSettings = (PreferenceCategory) getPreferenceScreen().findPreference("other");
        kinetoPref = (CheckBoxPreference) otherSettings.findPreference("kineto");
        kinetoPref.setOnPreferenceChangeListener(this);
    }

    @Override
    public void onResume() {
        super.onResume();

        chargeLedModePref.setValue(SystemProperties.get(PROP_CHARGE_LED_MODE));
        touchPointsPref.setValue(SystemProperties.get(PROP_TOUCH_POINTS));

        try {
            int setting = mPm.getApplicationEnabledSetting(KINETO_PACKAGE);
            kinetoPref.setEnabled(true);
            kinetoPref.setChecked(setting == PackageManager.COMPONENT_ENABLED_STATE_ENABLED);
        } catch (IllegalArgumentException e) {
            /* kineto not installed for whatever reason */
            kinetoPref.setEnabled(false);
        }
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (preference == chargeLedModePref) {
            SystemProperties.set(PROP_CHARGE_LED_MODE, (String) newValue);
            /* make NotificationManagerService update the LED, so the new setting takes effect */
            sendBroadcast(new Intent("com.android.server.NotificationManagerService.UPDATE_LED"));
        } else if (preference == touchPointsPref) {
            final String value = (String) newValue;
            final String oldValue = touchPointsPref.getValue();
            final CharSequence defaultValue = touchPointsPref.getEntryValues()[0];

            /* only show warning when moving away from the default value */
            if (TextUtils.equals(value, defaultValue) || !TextUtils.equals(oldValue, defaultValue)) {
                setTouchPointSetting(value);
            } else {
                AlertDialog dialog = new AlertDialog.Builder(this)
                    .setTitle(R.string.touch_point_warning_title)
                    .setMessage(R.string.touch_point_warning_message)
                    .setPositiveButton(R.string.yes, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            setTouchPointSetting(value);
                            touchPointsPref.setValue(value);
                        }
                    })
                    .setNegativeButton(R.string.no, null)
                    .create();

                dialog.show();
                return false;
            }
        } else if (preference == kinetoPref) {
            final Boolean value = (Boolean) newValue;
            final int setting = value ? PackageManager.COMPONENT_ENABLED_STATE_ENABLED :
                                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED;

            mPm.setApplicationEnabledSetting(KINETO_PACKAGE, setting, 0);
            SystemProperties.set(PROP_KINETO_ENABLED, value ? "1" : "0");

            AlertDialog dialog = new AlertDialog.Builder(this)
                    .setTitle(R.string.kineto_reboot_prompt_title)
                    .setMessage(R.string.kineto_reboot_prompt_message)
                    .setPositiveButton(R.string.yes, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            PowerManager pm = (PowerManager) getSystemService(POWER_SERVICE);
                            pm.reboot(null);
                        }
                    })
                    .setNegativeButton(R.string.no, null)
                    .create();

            dialog.show();
        }

        return true;
    }

    private void setTouchPointSetting(String value) {
        /* write the setting into the property to make it apply on next reboot */
        SystemProperties.set(PROP_TOUCH_POINTS, value);

        /* and also write it into the file to make it apply instantly */
        File touchPointsFile = new File(FILE_TOUCH_POINTS);
        FileWriter writer = null;
        try {
            writer = new FileWriter(touchPointsFile);
            writer.write(value);
        } catch (IOException e) {
            Log.e(TAG, "Could not apply touch point setting.", e);
            return;
        } finally {
            if (writer != null) {
                try {
                    writer.close();
                } catch (IOException e) {
                    Log.w(TAG, "Closing the touch point file failed.", e);
                }
            }
        }
    }
}
