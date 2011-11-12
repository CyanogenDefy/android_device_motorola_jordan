package com.cyanogenmod.defyparts;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.SystemProperties;
import android.preference.ListPreference;
import android.preference.Preference;
import android.preference.Preference.OnPreferenceChangeListener;
import android.preference.PreferenceActivity;
import android.preference.PreferenceCategory;
import android.text.TextUtils;

public class SettingsActivity extends PreferenceActivity implements OnPreferenceChangeListener {
    private PreferenceCategory generalSettings;
    private ListPreference chargeLedModePref;
    private ListPreference touchPointsPref;
    private Preference rebootNotice;

    private static final String PROP_CHARGE_LED_MODE = "persist.sys.charge_led";
    private static final String PROP_TOUCH_POINTS = "persist.sys.multitouch";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        addPreferencesFromResource(R.xml.settings);

        generalSettings = (PreferenceCategory) getPreferenceScreen().findPreference("general");
        chargeLedModePref = (ListPreference) generalSettings.findPreference("charge_led_mode");
        chargeLedModePref.setOnPreferenceChangeListener(this);
        touchPointsPref = (ListPreference) generalSettings.findPreference("touch_points");
        touchPointsPref.setOnPreferenceChangeListener(this);
        rebootNotice = generalSettings.findPreference("reboot_notice");
        generalSettings.removePreference(rebootNotice);
    }

    @Override
    public void onResume() {
        super.onResume();

        chargeLedModePref.setValue(SystemProperties.get(PROP_CHARGE_LED_MODE));
        touchPointsPref.setValue(SystemProperties.get(PROP_TOUCH_POINTS));
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (preference == chargeLedModePref) {
            String value = (String) newValue;
            applyPersistentPref(PROP_CHARGE_LED_MODE, value);
        } else if (preference == touchPointsPref) {
            final String value = (String) newValue;
            final String oldValue = touchPointsPref.getValue();
            final CharSequence defaultValue = touchPointsPref.getEntryValues()[0];

            /* only show warning when moving away from the default value */
            if (TextUtils.equals(value, defaultValue) || !TextUtils.equals(oldValue, defaultValue)) {
                applyPersistentPref(PROP_TOUCH_POINTS, value);
            } else {
                AlertDialog dialog = new AlertDialog.Builder(this)
                    .setTitle(R.string.touch_point_warning_title)
                    .setMessage(R.string.touch_point_warning_message)
                    .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            applyPersistentPref(PROP_TOUCH_POINTS, value);
                            touchPointsPref.setValue(value);
                        }
                    })
                    .setNegativeButton(android.R.string.no, null)
                    .create();

                dialog.show();
                return false;
            }
        }

        return true;
    }

    private void applyPersistentPref(String key, String value) {
        if (generalSettings.findPreference(rebootNotice.getKey()) == null) {
            generalSettings.addPreference(rebootNotice);
        }
        SystemProperties.set(key, value);
    }
}
