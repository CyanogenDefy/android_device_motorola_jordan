package com.cyanogenmod.defyparts;

import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.SystemProperties;
import android.preference.Preference;
import android.preference.PreferenceManager;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TextView;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.math.BigInteger;
import java.security.DigestInputStream;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class BasebandSelectionPreference extends Preference implements Preference.OnPreferenceClickListener
{
    private static final String TAG = "BasebandSelectionPreference";

    private static final String PROP_NAME = "persist.sys.new_baseband";
    private static final String CURRENT_BASEBAND_GSM_FILE = "/system/etc/motorola/bp_nvm_default/File_GSM";

    private static class RegionInfo {
        String name;
        String[] countryEntries;
        String[] countryValues;
        /* country name -> country info */
        Map<String, CountryInfo> countries;
    };

    private static class CountryInfo {
        String name;
        String uiName;
        String[] versions;
        /* version -> baseband */
        Map<String, BasebandInfo> basebands;
        RegionInfo regionInfo;
    };

    private static class BasebandInfo {
        String region;
        String country;
        String version;
        List<String> frequencies;
        String filename;
        String md5sum;
        CountryInfo countryInfo;
    };

    private List<BasebandInfo> mBasebands;
    /* region name -> region info */
    private Map<String, RegionInfo> mRegions;
    private String[] mRegionValues;
    private BasebandInfo mCurrentBaseband;
    private Resources mResources;

    public BasebandSelectionPreference(Context context, AttributeSet attrs) {
        super(context,attrs);

        mResources = getContext().getResources();
        buildBasebandList();
        buildRegionMap();
        initValue();
        setOnPreferenceClickListener(this);
    }

    @Override
    public boolean onPreferenceClick(Preference pref) {
        int regionPos = -1, countryPos = -1, versionPos = -1;

        if (mCurrentBaseband != null) {
            final CountryInfo country = mCurrentBaseband.countryInfo;
            final RegionInfo region = country.regionInfo;

            for (int i = 0; i < mRegionValues.length; i++) {
                if (region.name.equals(mRegionValues[i])) {
                    regionPos = i;
                    break;
                }
            }
            for (int i = 0; i < region.countryValues.length; i++) {
                if (country.name.equals(region.countryValues[i])) {
                    countryPos = i;
                    break;
                }
            }
            for (int i = 0; i < country.versions.length; i++) {
                if (mCurrentBaseband.version.equals(country.versions[i])) {
                    versionPos = i;
                    break;
                }
            }
        }

        Dialog d = new SelectionDialog(getContext(), regionPos, countryPos, versionPos);
        d.show();

        return true;
    }

    private void initValue() {
        final SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(getContext());
        final String basebandString = prefs.getString(getKey(), null);
        final String currentBasebandMd5 = getCurrentBasebandMd5Sum();
        BasebandInfo baseband = null;
        boolean needUpdate = false;

        if (basebandString != null) {
            final String[] values = TextUtils.split(basebandString, ":");
            if (values.length == 3) {
                baseband = getBaseband(values[0], values[1], values[2]);
                if (baseband != null && !baseband.md5sum.equals(currentBasebandMd5)) {
                    /* always trust the setting if we didn't reboot after setting it */
                    if (TextUtils.isEmpty(SystemProperties.get(PROP_NAME))) {
                        baseband = null;
                        needUpdate = true;
                    }
                }
            }
        }

        if (baseband == null) {
            /* check current MD5 against all known basebands */
            for (BasebandInfo bb : mBasebands) {
                if (bb.md5sum.equals(currentBasebandMd5)) {
                    baseband = bb;
                    needUpdate = true;
                    break;
                }
            }
        }

        mCurrentBaseband = baseband;
        if (needUpdate) {
            updatePrefValue(baseband);
        }

        updateSummary();
    }

    private BasebandInfo getBaseband(final String region, final String country, final String version) {
        if (region != null) {
            final RegionInfo regionInfo = mRegions.get(region);
            if (regionInfo != null) {
                final CountryInfo countryInfo = regionInfo.countries.get(country);
                if (countryInfo != null) {
                    return countryInfo.basebands.get(version);
                }
            }
        }
        return null;
    }

    private String getCurrentBasebandMd5Sum() {
        byte[] digest = null;
        FileInputStream fis = null;

        try {
            MessageDigest digester = MessageDigest.getInstance("MD5");
            fis = new FileInputStream(CURRENT_BASEBAND_GSM_FILE);
            DigestInputStream dis = new DigestInputStream(fis, digester);
            byte[] buffer = new byte[1024];

            while (dis.read(buffer) > 0);
            digest = digester.digest();
        } catch (NoSuchAlgorithmException e) {
            Log.e(TAG, "Could not instantiate MD5 algorithm", e);
        } catch (FileNotFoundException e) {
            Log.e(TAG, "Baseband file " + CURRENT_BASEBAND_GSM_FILE + " not found", e);
        } catch (IOException e) {
            Log.e(TAG, "Could not read current baseband file", e);
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (IOException e) {
                    Log.e(TAG, "Could not close current baseband file", e);
                }
            }
        }

        if (digest != null) {
            BigInteger bi = new BigInteger(1, digest);
            return String.format("%0" + (digest.length * 2) + "x", bi);
        }
        return null;
    }

    private void updateValue(final BasebandInfo baseband) {
        updatePrefValue(baseband);
        mCurrentBaseband = baseband;

        if (baseband != null) {
            SystemProperties.set(PROP_NAME, baseband.filename);
        }

        updateSummary();
        callChangeListener(this);
    }

    private void updatePrefValue(final BasebandInfo baseband) {
        final SharedPreferences.Editor editor =
                PreferenceManager.getDefaultSharedPreferences(getContext()).edit();

        if (baseband == null) {
            editor.remove(getKey());
            editor.commit();
            return;
        }

        final StringBuilder builder = new StringBuilder();
        builder.append(baseband.countryInfo.regionInfo.name);
        builder.append(':');
        builder.append(baseband.countryInfo.name);
        builder.append(':');
        builder.append(baseband.version);

        final String prefValue = builder.toString();
        editor.putString(getKey(), prefValue);
        editor.commit();

        Log.d(TAG, "Updated baseband to " + prefValue + ", filename " + baseband.filename);
     }

    private void updateSummary() {
        String countryString;
        String versionString;

        if (mCurrentBaseband != null) {
            countryString = mCurrentBaseband.countryInfo.uiName;
            versionString = mCurrentBaseband.version;
        } else {
            countryString = mResources.getString(R.string.unknown);
            versionString = "";
        }

        setSummary(mResources.getString(R.string.baseband_selection_summary, countryString, versionString));
    }

    private void buildBasebandList() {
        final Resources res = getContext().getResources();
        mBasebands = new ArrayList<BasebandInfo>();

        for (String item : res.getStringArray(R.array.available_basebands)) {
            String[] values = TextUtils.split(item, ":");
            if (values.length != 6) {
                Log.w(TAG, "Ignoring invalid baseband specification " + item);
                continue;
            }

            final BasebandInfo info = new BasebandInfo();
            info.region = values[0];
            info.country = values[1];
            info.version = values[2];
            info.frequencies = new ArrayList<String>();
            info.filename = values[4];
            info.md5sum = values[5];

            for (final String frequency : TextUtils.split(values[3], ",")) {
                info.frequencies.add(frequency);
            }

            mBasebands.add(info);
        }
    }

    private void buildRegionMap() {
        final Resources res = getContext().getResources();
        final String packageName = getClass().getPackage().getName();

        mRegionValues = res.getStringArray(R.array.baseband_region_values);
        mRegions = new HashMap<String, RegionInfo>();

        for (int rIndex = 0; rIndex < mRegionValues.length; rIndex++) {
            final String regionName = mRegionValues[rIndex];
            final String entryName = "baseband_countries_" + regionName + "_entries";
            final String valueName = "baseband_countries_" + regionName + "_values";
            final RegionInfo region = new RegionInfo();

            final int entryResId = res.getIdentifier(entryName, "array", packageName);
            final int valueResId = res.getIdentifier(valueName, "array", packageName);

            region.name = regionName;
            region.countries = new HashMap<String, CountryInfo>();

            if (entryResId != 0 && valueResId != 0) {
                region.countryEntries = res.getStringArray(entryResId);
                region.countryValues = res.getStringArray(valueResId);

                for (int cIndex = 0; cIndex < region.countryValues.length; cIndex++) {
                    final String countryName = region.countryValues[cIndex];
                    final CountryInfo country = new CountryInfo();

                    country.name = countryName;
                    country.uiName = region.countryEntries[cIndex];
                    country.basebands = new HashMap<String, BasebandInfo>();
                    country.regionInfo = region;

                    for (final BasebandInfo baseband : mBasebands) {
                        if (regionName.equals(baseband.region) && countryName.equals(baseband.country)) {
                            country.basebands.put(baseband.version, baseband);
                            baseband.countryInfo = country;
                        }
                    }
                    final Set<String> versions = country.basebands.keySet();
                    country.versions = versions.toArray(new String[versions.size()]);

                    region.countries.put(countryName, country);
                }
            }

            mRegions.put(regionName, region);
        }
    }

    private class SelectionDialog extends AlertDialog implements AdapterView.OnItemSelectedListener {
        private Spinner mRegion;
        private Spinner mCountry;
        private Spinner mVersion;
        private TextView mFrequencies;

        private int[] mInitialPositions;
        private String mSelectedRegion;
        private String mSelectedCountry;
        private String mSelectedVersion;

        public SelectionDialog(Context context, int regionPos, int countryPos, int versionPos) {
            super(context);
            mInitialPositions = new int[] { regionPos, countryPos, versionPos };
        }

        @Override
        protected void onCreate(Bundle savedInstanceState) {
            initViews();
            initButtons();

            super.onCreate(savedInstanceState);

            mRegion.setSelection(mInitialPositions[0]);
            updateCountrySpinner();
            mCountry.setSelection(mInitialPositions[1]);
            updateVersionSpinner();
            mVersion.setSelection(mInitialPositions[2]);
            updateFrequencies();
            validate();
        }

        @Override
        public void onItemSelected(AdapterView<?> parent, View view, int pos, long id) {
            if (parent == mRegion) {
                updateCountrySpinner();
            } else if (parent == mCountry) {
                updateVersionSpinner();
            }
            updateFrequencies();
            validate();
        }

        @Override
        public void onNothingSelected(AdapterView parent) {
            if (parent == mRegion) {
                updateCountrySpinner();
            } else if (parent == mCountry) {
                updateVersionSpinner();
            }
            updateFrequencies();
            validate();
        }

        private void initViews() {
            final View layout = getLayoutInflater().inflate(R.layout.dialog_baseband_selection, null);

            mRegion = (Spinner) layout.findViewById(R.id.region);
            mRegion.setOnItemSelectedListener(this);
            mCountry = (Spinner) layout.findViewById(R.id.country);
            mCountry.setOnItemSelectedListener(this);
            mCountry.setAdapter(new SpinnerUpdateAdapter(getContext()));
            mVersion = (Spinner) layout.findViewById(R.id.baseband);
            mVersion.setOnItemSelectedListener(this);
            mVersion.setAdapter(new SpinnerUpdateAdapter(getContext()));
            mFrequencies = (TextView) layout.findViewById(R.id.frequencies);

            setView(layout);
            setTitle(R.string.baseband_selection);
        }

        private void initButtons() {
            setButton(BUTTON_POSITIVE, mResources.getString(android.R.string.ok), new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    updateValue(getSelectedBaseband());
                }
            });
            setButton(BUTTON_NEGATIVE, mResources.getString(android.R.string.cancel), (DialogInterface.OnClickListener) null);
        }

        private void updateCountrySpinner() {
            final RegionInfo region = getSelectedRegion();
            String[] countries = region != null ? region.countryEntries : null;

            updateSpinner(mCountry, countries);
            updateVersionSpinner();
            validate();
        }

        private void updateVersionSpinner() {
            final RegionInfo region = mSelectedRegion != null ? mRegions.get(mSelectedRegion) : null;
            final CountryInfo country = getSelectedCountry();
            String[] versions = country != null ? country.versions : null;

            updateSpinner(mVersion, versions);
            validate();
        }

        private void validate() {
            boolean valid = getSelectedBaseband() != null;
            getButton(BUTTON_POSITIVE).setEnabled(valid);
        }

        private void updateSpinner(Spinner spinner, String[] items) {
            SpinnerUpdateAdapter adapter = (SpinnerUpdateAdapter) spinner.getAdapter();
            adapter.update(items);
            spinner.setEnabled(items != null && items.length > 0);
        }

        private void updateFrequencies() {
            BasebandInfo info = getSelectedBaseband();
            if (info != null) {
                final String freqList = TextUtils.join("/", info.frequencies);
                mFrequencies.setText(mResources.getString(R.string.baseband_frequencies, freqList));
                mFrequencies.setVisibility(View.VISIBLE);
            } else {
                mFrequencies.setVisibility(View.GONE);
            }
        }

        private RegionInfo getSelectedRegion() {
            int pos = mRegion.getSelectedItemPosition();
            if (pos == AdapterView.INVALID_POSITION || pos >= mRegion.getCount()) {
                return null;
            }
            return mRegions.get(mRegionValues[pos]);
        }

        private CountryInfo getSelectedCountry() {
            int pos = mCountry.getSelectedItemPosition();
            final RegionInfo region = getSelectedRegion();

            if (region == null || pos >= mCountry.getCount() || pos == AdapterView.INVALID_POSITION) {
                return null;
            }
            return region.countries.get(region.countryValues[pos]);
        }

        private BasebandInfo getSelectedBaseband() {
            int pos = mVersion.getSelectedItemPosition();
            final CountryInfo country = getSelectedCountry();

            if (country == null || pos >= mVersion.getCount() || pos == AdapterView.INVALID_POSITION) {
                return null;
            }
            return country.basebands.get(country.versions[pos]);
        }

        private class SpinnerUpdateAdapter extends ArrayAdapter<CharSequence> {
            public SpinnerUpdateAdapter(Context context) {
                super(context, android.R.layout.simple_spinner_item, new ArrayList<CharSequence>());
                setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
                setNotifyOnChange(false);
            }

            public void update(String[] items) {
                clear();
                if (items != null) {
                    for (String item : items) {
                        add(item);
                    }
                }
                notifyDataSetChanged();
            }
        };
    };
}

