package com.cyanogenmod.defyparts;

import android.content.Context;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.preference.SeekBarPreference;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.LinearLayout;


public class BrightnessPreference extends SeekBarPreference implements SeekBar.OnSeekBarChangeListener
{
    private SeekBar mSeekBar;
    private TextView mValueText;

    private int mValue = 0, mOldValue;

    public BrightnessPreference(Context context, AttributeSet attrs) {
        super(context,attrs);

        setDialogLayoutResource(R.layout.preference_dialog_brightness);
    }

    @Override
    protected void onBindDialogView(View view) {
        super.onBindDialogView(view);

        if (shouldPersist()) {
            mValue = getPersistedInt(0);
        }
        mOldValue = mValue;

        mSeekBar = getSeekBar(view);
        mSeekBar.setMax(100);
        mSeekBar.setProgress(mValue);
        mSeekBar.setOnSeekBarChangeListener(this);

        mValueText = (TextView) view.findViewById(R.id.brightness_value);
        setValue(mValue);
    }

    @Override
    protected void onSetInitialValue(boolean restore, Object defaultValue) {
        super.onSetInitialValue(restore, defaultValue);
        if (restore) {
            mValue = shouldPersist() ? getPersistedInt(0) : 0;
        } else {
            mValue = (Integer) defaultValue;
        }
    }

    @Override
    public void onProgressChanged(SeekBar seek, int value, boolean fromTouch) {
        mValue = value;
        updateValueText();
    }

    private void updateValueText() {
        if (mValueText != null) {
            String text = String.valueOf(mValue) + "%";
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
        super.onDialogClosed(positiveResult);

        if (positiveResult) {
            persistInt(mValue);
            callChangeListener(new Integer(mValue));
        } else {
            mSeekBar.setProgress(mOldValue);
        }
    }

    public void setValue(int value) {
        mValue = Math.max(0, Math.min(value, 100));
        persistInt(mValue);
        updateValueText();
    }

    public int getValue() {
        return mValue;
    }
}

