package com.cyanogenmod.defyparts;

import android.content.Context;
import android.os.Bundle;
import android.os.SystemProperties;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager.LayoutParams;
import android.preference.SeekBarPreference;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.LinearLayout;


public class BrightnessPreference extends SeekBarPreference implements SeekBar.OnSeekBarChangeListener
{
    private SeekBar mSeekBar;
    private TextView mValueText;
    private Window mWindow;

    private static final String PROP_NAME = "persist.sys.button_brightness";

    private int mOldValue;

    public BrightnessPreference(Context context, AttributeSet attrs) {
        super(context,attrs);

        setDialogLayoutResource(R.layout.preference_dialog_brightness);
    }

    @Override
    protected void onBindDialogView(View view) {
        super.onBindDialogView(view);

        mOldValue = SystemProperties.getInt(PROP_NAME, 100);
        SystemProperties.set(PROP_NAME, "100");

        mSeekBar = getSeekBar(view);
        mSeekBar.setMax(100);
        mSeekBar.setProgress(mOldValue);
        mSeekBar.setOnSeekBarChangeListener(this);

        mValueText = (TextView) view.findViewById(R.id.brightness_value);
        updateBrightness();
        updateValueText();
    }

    @Override
    protected void showDialog(Bundle state) {
        super.showDialog(state);
        if (getDialog() != null) {
            mWindow = getDialog().getWindow();
        }
        updateBrightness();
    }

    @Override
    public void onProgressChanged(SeekBar seek, int value, boolean fromTouch) {
        updateBrightness();
        updateValueText();
    }

    private void updateBrightness() {
        if (mWindow != null) {
            LayoutParams params = mWindow.getAttributes();
            params.buttonBrightness = (float) mSeekBar.getProgress() / 100;
            mWindow.setAttributes(params);
        }
    }

    private void updateValueText() {
        if (mValueText != null) {
            String text = String.valueOf(mSeekBar.getProgress()) + "%";
            mValueText.setText(text);
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seek) {
    }

    @Override
    public void onStopTrackingTouch(SeekBar seek) {
    }

    @Override
    protected void onDialogClosed(boolean positiveResult) {
        int value;

        if (positiveResult) {
            value = mSeekBar.getProgress();
            callChangeListener(new Integer(value));
        } else {
            value = mOldValue;
        }

        SystemProperties.set(PROP_NAME, Integer.toString(value));
        super.onDialogClosed(positiveResult);
    }
}

